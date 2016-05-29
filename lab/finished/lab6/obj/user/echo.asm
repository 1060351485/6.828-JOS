
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
  800048:	c7 44 24 04 20 25 80 	movl   $0x802520,0x4(%esp)
  80004f:	00 
  800050:	8b 46 04             	mov    0x4(%esi),%eax
  800053:	89 04 24             	mov    %eax,(%esp)
  800056:	e8 d3 01 00 00       	call   80022e <strcmp>
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
  800090:	c7 44 24 04 23 25 80 	movl   $0x802523,0x4(%esp)
  800097:	00 
  800098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009f:	e8 b5 0b 00 00       	call   800c59 <write>
		write(1, argv[i], strlen(argv[i]));
  8000a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a7:	89 04 24             	mov    %eax,(%esp)
  8000aa:	e8 a5 00 00 00       	call   800154 <strlen>
  8000af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000c1:	e8 93 0b 00 00       	call   800c59 <write>
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
  8000d9:	c7 44 24 04 70 26 80 	movl   $0x802670,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e8:	e8 6c 0b 00 00       	call   800c59 <write>
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
  800106:	e8 30 04 00 00       	call   80053b <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	c1 e0 07             	shl    $0x7,%eax
  800113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800118:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011d:	85 f6                	test   %esi,%esi
  80011f:	7e 07                	jle    800128 <libmain+0x30>
		binaryname = argv[0];
  800121:	8b 03                	mov    (%ebx),%eax
  800123:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800128:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012c:	89 34 24             	mov    %esi,(%esp)
  80012f:	e8 00 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800134:	e8 07 00 00 00       	call   800140 <exit>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 97 03 00 00       	call   8004e9 <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80015a:	b8 00 00 00 00       	mov    $0x0,%eax
  80015f:	eb 01                	jmp    800162 <strlen+0xe>
		n++;
  800161:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800162:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800166:	75 f9                	jne    800161 <strlen+0xd>
		n++;
	return n;
}
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800173:	b8 00 00 00 00       	mov    $0x0,%eax
  800178:	eb 01                	jmp    80017b <strnlen+0x11>
		n++;
  80017a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80017b:	39 d0                	cmp    %edx,%eax
  80017d:	74 06                	je     800185 <strnlen+0x1b>
  80017f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800183:	75 f5                	jne    80017a <strnlen+0x10>
		n++;
	return n;
}
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	53                   	push   %ebx
  80018b:	8b 45 08             	mov    0x8(%ebp),%eax
  80018e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800191:	ba 00 00 00 00       	mov    $0x0,%edx
  800196:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800199:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80019c:	42                   	inc    %edx
  80019d:	84 c9                	test   %cl,%cl
  80019f:	75 f5                	jne    800196 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001a1:	5b                   	pop    %ebx
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001ae:	89 1c 24             	mov    %ebx,(%esp)
  8001b1:	e8 9e ff ff ff       	call   800154 <strlen>
	strcpy(dst + len, src);
  8001b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001bd:	01 d8                	add    %ebx,%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 c0 ff ff ff       	call   800187 <strcpy>
	return dst;
}
  8001c7:	89 d8                	mov    %ebx,%eax
  8001c9:	83 c4 08             	add    $0x8,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001da:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e2:	eb 0c                	jmp    8001f0 <strncpy+0x21>
		*dst++ = *src;
  8001e4:	8a 1a                	mov    (%edx),%bl
  8001e6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001e9:	80 3a 01             	cmpb   $0x1,(%edx)
  8001ec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001ef:	41                   	inc    %ecx
  8001f0:	39 f1                	cmp    %esi,%ecx
  8001f2:	75 f0                	jne    8001e4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800206:	85 d2                	test   %edx,%edx
  800208:	75 0a                	jne    800214 <strlcpy+0x1c>
  80020a:	89 f0                	mov    %esi,%eax
  80020c:	eb 1a                	jmp    800228 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80020e:	88 18                	mov    %bl,(%eax)
  800210:	40                   	inc    %eax
  800211:	41                   	inc    %ecx
  800212:	eb 02                	jmp    800216 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800214:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800216:	4a                   	dec    %edx
  800217:	74 0a                	je     800223 <strlcpy+0x2b>
  800219:	8a 19                	mov    (%ecx),%bl
  80021b:	84 db                	test   %bl,%bl
  80021d:	75 ef                	jne    80020e <strlcpy+0x16>
  80021f:	89 c2                	mov    %eax,%edx
  800221:	eb 02                	jmp    800225 <strlcpy+0x2d>
  800223:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800225:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800228:	29 f0                	sub    %esi,%eax
}
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800237:	eb 02                	jmp    80023b <strcmp+0xd>
		p++, q++;
  800239:	41                   	inc    %ecx
  80023a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80023b:	8a 01                	mov    (%ecx),%al
  80023d:	84 c0                	test   %al,%al
  80023f:	74 04                	je     800245 <strcmp+0x17>
  800241:	3a 02                	cmp    (%edx),%al
  800243:	74 f4                	je     800239 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800245:	0f b6 c0             	movzbl %al,%eax
  800248:	0f b6 12             	movzbl (%edx),%edx
  80024b:	29 d0                	sub    %edx,%eax
}
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	53                   	push   %ebx
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800259:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80025c:	eb 03                	jmp    800261 <strncmp+0x12>
		n--, p++, q++;
  80025e:	4a                   	dec    %edx
  80025f:	40                   	inc    %eax
  800260:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800261:	85 d2                	test   %edx,%edx
  800263:	74 14                	je     800279 <strncmp+0x2a>
  800265:	8a 18                	mov    (%eax),%bl
  800267:	84 db                	test   %bl,%bl
  800269:	74 04                	je     80026f <strncmp+0x20>
  80026b:	3a 19                	cmp    (%ecx),%bl
  80026d:	74 ef                	je     80025e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026f:	0f b6 00             	movzbl (%eax),%eax
  800272:	0f b6 11             	movzbl (%ecx),%edx
  800275:	29 d0                	sub    %edx,%eax
  800277:	eb 05                	jmp    80027e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800279:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027e:	5b                   	pop    %ebx
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80028a:	eb 05                	jmp    800291 <strchr+0x10>
		if (*s == c)
  80028c:	38 ca                	cmp    %cl,%dl
  80028e:	74 0c                	je     80029c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800290:	40                   	inc    %eax
  800291:	8a 10                	mov    (%eax),%dl
  800293:	84 d2                	test   %dl,%dl
  800295:	75 f5                	jne    80028c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800297:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002a7:	eb 05                	jmp    8002ae <strfind+0x10>
		if (*s == c)
  8002a9:	38 ca                	cmp    %cl,%dl
  8002ab:	74 07                	je     8002b4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002ad:	40                   	inc    %eax
  8002ae:	8a 10                	mov    (%eax),%dl
  8002b0:	84 d2                	test   %dl,%dl
  8002b2:	75 f5                	jne    8002a9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c5:	85 c9                	test   %ecx,%ecx
  8002c7:	74 30                	je     8002f9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002cf:	75 25                	jne    8002f6 <memset+0x40>
  8002d1:	f6 c1 03             	test   $0x3,%cl
  8002d4:	75 20                	jne    8002f6 <memset+0x40>
		c &= 0xFF;
  8002d6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002d9:	89 d3                	mov    %edx,%ebx
  8002db:	c1 e3 08             	shl    $0x8,%ebx
  8002de:	89 d6                	mov    %edx,%esi
  8002e0:	c1 e6 18             	shl    $0x18,%esi
  8002e3:	89 d0                	mov    %edx,%eax
  8002e5:	c1 e0 10             	shl    $0x10,%eax
  8002e8:	09 f0                	or     %esi,%eax
  8002ea:	09 d0                	or     %edx,%eax
  8002ec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8002ee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8002f1:	fc                   	cld    
  8002f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8002f4:	eb 03                	jmp    8002f9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002f6:	fc                   	cld    
  8002f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002f9:	89 f8                	mov    %edi,%eax
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80030e:	39 c6                	cmp    %eax,%esi
  800310:	73 34                	jae    800346 <memmove+0x46>
  800312:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800315:	39 d0                	cmp    %edx,%eax
  800317:	73 2d                	jae    800346 <memmove+0x46>
		s += n;
		d += n;
  800319:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80031c:	f6 c2 03             	test   $0x3,%dl
  80031f:	75 1b                	jne    80033c <memmove+0x3c>
  800321:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800327:	75 13                	jne    80033c <memmove+0x3c>
  800329:	f6 c1 03             	test   $0x3,%cl
  80032c:	75 0e                	jne    80033c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80032e:	83 ef 04             	sub    $0x4,%edi
  800331:	8d 72 fc             	lea    -0x4(%edx),%esi
  800334:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800337:	fd                   	std    
  800338:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80033a:	eb 07                	jmp    800343 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80033c:	4f                   	dec    %edi
  80033d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800340:	fd                   	std    
  800341:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800343:	fc                   	cld    
  800344:	eb 20                	jmp    800366 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800346:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80034c:	75 13                	jne    800361 <memmove+0x61>
  80034e:	a8 03                	test   $0x3,%al
  800350:	75 0f                	jne    800361 <memmove+0x61>
  800352:	f6 c1 03             	test   $0x3,%cl
  800355:	75 0a                	jne    800361 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800357:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80035a:	89 c7                	mov    %eax,%edi
  80035c:	fc                   	cld    
  80035d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80035f:	eb 05                	jmp    800366 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800370:	8b 45 10             	mov    0x10(%ebp),%eax
  800373:	89 44 24 08          	mov    %eax,0x8(%esp)
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	e8 77 ff ff ff       	call   800300 <memmove>
}
  800389:	c9                   	leave  
  80038a:	c3                   	ret    

0080038b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	57                   	push   %edi
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	8b 7d 08             	mov    0x8(%ebp),%edi
  800394:	8b 75 0c             	mov    0xc(%ebp),%esi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80039a:	ba 00 00 00 00       	mov    $0x0,%edx
  80039f:	eb 16                	jmp    8003b7 <memcmp+0x2c>
		if (*s1 != *s2)
  8003a1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8003a4:	42                   	inc    %edx
  8003a5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8003a9:	38 c8                	cmp    %cl,%al
  8003ab:	74 0a                	je     8003b7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8003ad:	0f b6 c0             	movzbl %al,%eax
  8003b0:	0f b6 c9             	movzbl %cl,%ecx
  8003b3:	29 c8                	sub    %ecx,%eax
  8003b5:	eb 09                	jmp    8003c0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b7:	39 da                	cmp    %ebx,%edx
  8003b9:	75 e6                	jne    8003a1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003ce:	89 c2                	mov    %eax,%edx
  8003d0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003d3:	eb 05                	jmp    8003da <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003d5:	38 08                	cmp    %cl,(%eax)
  8003d7:	74 05                	je     8003de <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d9:	40                   	inc    %eax
  8003da:	39 d0                	cmp    %edx,%eax
  8003dc:	72 f7                	jb     8003d5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 01                	jmp    8003ef <strtol+0xf>
		s++;
  8003ee:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ef:	8a 02                	mov    (%edx),%al
  8003f1:	3c 20                	cmp    $0x20,%al
  8003f3:	74 f9                	je     8003ee <strtol+0xe>
  8003f5:	3c 09                	cmp    $0x9,%al
  8003f7:	74 f5                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003f9:	3c 2b                	cmp    $0x2b,%al
  8003fb:	75 08                	jne    800405 <strtol+0x25>
		s++;
  8003fd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8003fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800403:	eb 13                	jmp    800418 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800405:	3c 2d                	cmp    $0x2d,%al
  800407:	75 0a                	jne    800413 <strtol+0x33>
		s++, neg = 1;
  800409:	8d 52 01             	lea    0x1(%edx),%edx
  80040c:	bf 01 00 00 00       	mov    $0x1,%edi
  800411:	eb 05                	jmp    800418 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800413:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800418:	85 db                	test   %ebx,%ebx
  80041a:	74 05                	je     800421 <strtol+0x41>
  80041c:	83 fb 10             	cmp    $0x10,%ebx
  80041f:	75 28                	jne    800449 <strtol+0x69>
  800421:	8a 02                	mov    (%edx),%al
  800423:	3c 30                	cmp    $0x30,%al
  800425:	75 10                	jne    800437 <strtol+0x57>
  800427:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80042b:	75 0a                	jne    800437 <strtol+0x57>
		s += 2, base = 16;
  80042d:	83 c2 02             	add    $0x2,%edx
  800430:	bb 10 00 00 00       	mov    $0x10,%ebx
  800435:	eb 12                	jmp    800449 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800437:	85 db                	test   %ebx,%ebx
  800439:	75 0e                	jne    800449 <strtol+0x69>
  80043b:	3c 30                	cmp    $0x30,%al
  80043d:	75 05                	jne    800444 <strtol+0x64>
		s++, base = 8;
  80043f:	42                   	inc    %edx
  800440:	b3 08                	mov    $0x8,%bl
  800442:	eb 05                	jmp    800449 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800444:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800450:	8a 0a                	mov    (%edx),%cl
  800452:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800455:	80 fb 09             	cmp    $0x9,%bl
  800458:	77 08                	ja     800462 <strtol+0x82>
			dig = *s - '0';
  80045a:	0f be c9             	movsbl %cl,%ecx
  80045d:	83 e9 30             	sub    $0x30,%ecx
  800460:	eb 1e                	jmp    800480 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800462:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800465:	80 fb 19             	cmp    $0x19,%bl
  800468:	77 08                	ja     800472 <strtol+0x92>
			dig = *s - 'a' + 10;
  80046a:	0f be c9             	movsbl %cl,%ecx
  80046d:	83 e9 57             	sub    $0x57,%ecx
  800470:	eb 0e                	jmp    800480 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800472:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800475:	80 fb 19             	cmp    $0x19,%bl
  800478:	77 12                	ja     80048c <strtol+0xac>
			dig = *s - 'A' + 10;
  80047a:	0f be c9             	movsbl %cl,%ecx
  80047d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800480:	39 f1                	cmp    %esi,%ecx
  800482:	7d 0c                	jge    800490 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800484:	42                   	inc    %edx
  800485:	0f af c6             	imul   %esi,%eax
  800488:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80048a:	eb c4                	jmp    800450 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80048c:	89 c1                	mov    %eax,%ecx
  80048e:	eb 02                	jmp    800492 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800490:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800492:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800496:	74 05                	je     80049d <strtol+0xbd>
		*endptr = (char *) s;
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80049d:	85 ff                	test   %edi,%edi
  80049f:	74 04                	je     8004a5 <strtol+0xc5>
  8004a1:	89 c8                	mov    %ecx,%eax
  8004a3:	f7 d8                	neg    %eax
}
  8004a5:	5b                   	pop    %ebx
  8004a6:	5e                   	pop    %esi
  8004a7:	5f                   	pop    %edi
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    
	...

008004ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	89 c7                	mov    %eax,%edi
  8004c1:	89 c6                	mov    %eax,%esi
  8004c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004c5:	5b                   	pop    %ebx
  8004c6:	5e                   	pop    %esi
  8004c7:	5f                   	pop    %edi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	57                   	push   %edi
  8004ce:	56                   	push   %esi
  8004cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8004da:	89 d1                	mov    %edx,%ecx
  8004dc:	89 d3                	mov    %edx,%ebx
  8004de:	89 d7                	mov    %edx,%edi
  8004e0:	89 d6                	mov    %edx,%esi
  8004e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004e4:	5b                   	pop    %ebx
  8004e5:	5e                   	pop    %esi
  8004e6:	5f                   	pop    %edi
  8004e7:	5d                   	pop    %ebp
  8004e8:	c3                   	ret    

008004e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	53                   	push   %ebx
  8004ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 cb                	mov    %ecx,%ebx
  800501:	89 cf                	mov    %ecx,%edi
  800503:	89 ce                	mov    %ecx,%esi
  800505:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800507:	85 c0                	test   %eax,%eax
  800509:	7e 28                	jle    800533 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80050b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80050f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800516:	00 
  800517:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  80051e:	00 
  80051f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800526:	00 
  800527:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  80052e:	e8 d5 15 00 00       	call   801b08 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800533:	83 c4 2c             	add    $0x2c,%esp
  800536:	5b                   	pop    %ebx
  800537:	5e                   	pop    %esi
  800538:	5f                   	pop    %edi
  800539:	5d                   	pop    %ebp
  80053a:	c3                   	ret    

0080053b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800541:	ba 00 00 00 00       	mov    $0x0,%edx
  800546:	b8 02 00 00 00       	mov    $0x2,%eax
  80054b:	89 d1                	mov    %edx,%ecx
  80054d:	89 d3                	mov    %edx,%ebx
  80054f:	89 d7                	mov    %edx,%edi
  800551:	89 d6                	mov    %edx,%esi
  800553:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800555:	5b                   	pop    %ebx
  800556:	5e                   	pop    %esi
  800557:	5f                   	pop    %edi
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <sys_yield>:

void
sys_yield(void)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800560:	ba 00 00 00 00       	mov    $0x0,%edx
  800565:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056a:	89 d1                	mov    %edx,%ecx
  80056c:	89 d3                	mov    %edx,%ebx
  80056e:	89 d7                	mov    %edx,%edi
  800570:	89 d6                	mov    %edx,%esi
  800572:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800574:	5b                   	pop    %ebx
  800575:	5e                   	pop    %esi
  800576:	5f                   	pop    %edi
  800577:	5d                   	pop    %ebp
  800578:	c3                   	ret    

00800579 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	57                   	push   %edi
  80057d:	56                   	push   %esi
  80057e:	53                   	push   %ebx
  80057f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800582:	be 00 00 00 00       	mov    $0x0,%esi
  800587:	b8 04 00 00 00       	mov    $0x4,%eax
  80058c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80058f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800592:	8b 55 08             	mov    0x8(%ebp),%edx
  800595:	89 f7                	mov    %esi,%edi
  800597:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800599:	85 c0                	test   %eax,%eax
  80059b:	7e 28                	jle    8005c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005a8:	00 
  8005a9:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  8005b0:	00 
  8005b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005b8:	00 
  8005b9:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  8005c0:	e8 43 15 00 00       	call   801b08 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005c5:	83 c4 2c             	add    $0x2c,%esp
  8005c8:	5b                   	pop    %ebx
  8005c9:	5e                   	pop    %esi
  8005ca:	5f                   	pop    %edi
  8005cb:	5d                   	pop    %ebp
  8005cc:	c3                   	ret    

008005cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005cd:	55                   	push   %ebp
  8005ce:	89 e5                	mov    %esp,%ebp
  8005d0:	57                   	push   %edi
  8005d1:	56                   	push   %esi
  8005d2:	53                   	push   %ebx
  8005d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005db:	8b 75 18             	mov    0x18(%ebp),%esi
  8005de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	7e 28                	jle    800618 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8005fb:	00 
  8005fc:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  800603:	00 
  800604:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80060b:	00 
  80060c:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  800613:	e8 f0 14 00 00       	call   801b08 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800618:	83 c4 2c             	add    $0x2c,%esp
  80061b:	5b                   	pop    %ebx
  80061c:	5e                   	pop    %esi
  80061d:	5f                   	pop    %edi
  80061e:	5d                   	pop    %ebp
  80061f:	c3                   	ret    

00800620 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	57                   	push   %edi
  800624:	56                   	push   %esi
  800625:	53                   	push   %ebx
  800626:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800629:	bb 00 00 00 00       	mov    $0x0,%ebx
  80062e:	b8 06 00 00 00       	mov    $0x6,%eax
  800633:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800636:	8b 55 08             	mov    0x8(%ebp),%edx
  800639:	89 df                	mov    %ebx,%edi
  80063b:	89 de                	mov    %ebx,%esi
  80063d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80063f:	85 c0                	test   %eax,%eax
  800641:	7e 28                	jle    80066b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800643:	89 44 24 10          	mov    %eax,0x10(%esp)
  800647:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80064e:	00 
  80064f:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  800656:	00 
  800657:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80065e:	00 
  80065f:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  800666:	e8 9d 14 00 00       	call   801b08 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80066b:	83 c4 2c             	add    $0x2c,%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	57                   	push   %edi
  800677:	56                   	push   %esi
  800678:	53                   	push   %ebx
  800679:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80067c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
  800686:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800689:	8b 55 08             	mov    0x8(%ebp),%edx
  80068c:	89 df                	mov    %ebx,%edi
  80068e:	89 de                	mov    %ebx,%esi
  800690:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800692:	85 c0                	test   %eax,%eax
  800694:	7e 28                	jle    8006be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800696:	89 44 24 10          	mov    %eax,0x10(%esp)
  80069a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006a1:	00 
  8006a2:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  8006a9:	00 
  8006aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006b1:	00 
  8006b2:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  8006b9:	e8 4a 14 00 00       	call   801b08 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006be:	83 c4 2c             	add    $0x2c,%esp
  8006c1:	5b                   	pop    %ebx
  8006c2:	5e                   	pop    %esi
  8006c3:	5f                   	pop    %edi
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	57                   	push   %edi
  8006ca:	56                   	push   %esi
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8006d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006df:	89 df                	mov    %ebx,%edi
  8006e1:	89 de                	mov    %ebx,%esi
  8006e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	7e 28                	jle    800711 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8006f4:	00 
  8006f5:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  8006fc:	00 
  8006fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800704:	00 
  800705:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  80070c:	e8 f7 13 00 00       	call   801b08 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800711:	83 c4 2c             	add    $0x2c,%esp
  800714:	5b                   	pop    %ebx
  800715:	5e                   	pop    %esi
  800716:	5f                   	pop    %edi
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	57                   	push   %edi
  80071d:	56                   	push   %esi
  80071e:	53                   	push   %ebx
  80071f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800722:	bb 00 00 00 00       	mov    $0x0,%ebx
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
  800732:	89 df                	mov    %ebx,%edi
  800734:	89 de                	mov    %ebx,%esi
  800736:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800738:	85 c0                	test   %eax,%eax
  80073a:	7e 28                	jle    800764 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80073c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800740:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800747:	00 
  800748:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  80074f:	00 
  800750:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800757:	00 
  800758:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  80075f:	e8 a4 13 00 00       	call   801b08 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800764:	83 c4 2c             	add    $0x2c,%esp
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	57                   	push   %edi
  800770:	56                   	push   %esi
  800771:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800772:	be 00 00 00 00       	mov    $0x0,%esi
  800777:	b8 0c 00 00 00       	mov    $0xc,%eax
  80077c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80077f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800785:	8b 55 08             	mov    0x8(%ebp),%edx
  800788:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5f                   	pop    %edi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	57                   	push   %edi
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
  800795:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800798:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a5:	89 cb                	mov    %ecx,%ebx
  8007a7:	89 cf                	mov    %ecx,%edi
  8007a9:	89 ce                	mov    %ecx,%esi
  8007ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	7e 28                	jle    8007d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007bc:	00 
  8007bd:	c7 44 24 08 2f 25 80 	movl   $0x80252f,0x8(%esp)
  8007c4:	00 
  8007c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007cc:	00 
  8007cd:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  8007d4:	e8 2f 13 00 00       	call   801b08 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007d9:	83 c4 2c             	add    $0x2c,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	57                   	push   %edi
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8007f1:	89 d1                	mov    %edx,%ecx
  8007f3:	89 d3                	mov    %edx,%ebx
  8007f5:	89 d7                	mov    %edx,%edi
  8007f7:	89 d6                	mov    %edx,%esi
  8007f9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	57                   	push   %edi
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800806:	bb 00 00 00 00       	mov    $0x0,%ebx
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
  800816:	89 df                	mov    %ebx,%edi
  800818:	89 de                	mov    %ebx,%esi
  80081a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	57                   	push   %edi
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800827:	bb 00 00 00 00       	mov    $0x0,%ebx
  80082c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800834:	8b 55 08             	mov    0x8(%ebp),%edx
  800837:	89 df                	mov    %ebx,%edi
  800839:	89 de                	mov    %ebx,%esi
  80083b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	57                   	push   %edi
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800848:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084d:	b8 11 00 00 00       	mov    $0x11,%eax
  800852:	8b 55 08             	mov    0x8(%ebp),%edx
  800855:	89 cb                	mov    %ecx,%ebx
  800857:	89 cf                	mov    %ecx,%edi
  800859:	89 ce                	mov    %ecx,%esi
  80085b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5f                   	pop    %edi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    
	...

00800864 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	05 00 00 00 30       	add    $0x30000000,%eax
  80086f:	c1 e8 0c             	shr    $0xc,%eax
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	89 04 24             	mov    %eax,(%esp)
  800880:	e8 df ff ff ff       	call   800864 <fd2num>
  800885:	05 20 00 0d 00       	add    $0xd0020,%eax
  80088a:	c1 e0 0c             	shl    $0xc,%eax
}
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800896:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80089b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	c1 ea 16             	shr    $0x16,%edx
  8008a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008a9:	f6 c2 01             	test   $0x1,%dl
  8008ac:	74 11                	je     8008bf <fd_alloc+0x30>
  8008ae:	89 c2                	mov    %eax,%edx
  8008b0:	c1 ea 0c             	shr    $0xc,%edx
  8008b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008ba:	f6 c2 01             	test   $0x1,%dl
  8008bd:	75 09                	jne    8008c8 <fd_alloc+0x39>
			*fd_store = fd;
  8008bf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c6:	eb 17                	jmp    8008df <fd_alloc+0x50>
  8008c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8008cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8008d2:	75 c7                	jne    80089b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8008d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8008da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8008e8:	83 f8 1f             	cmp    $0x1f,%eax
  8008eb:	77 36                	ja     800923 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8008ed:	05 00 00 0d 00       	add    $0xd0000,%eax
  8008f2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	c1 ea 16             	shr    $0x16,%edx
  8008fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800901:	f6 c2 01             	test   $0x1,%dl
  800904:	74 24                	je     80092a <fd_lookup+0x48>
  800906:	89 c2                	mov    %eax,%edx
  800908:	c1 ea 0c             	shr    $0xc,%edx
  80090b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800912:	f6 c2 01             	test   $0x1,%dl
  800915:	74 1a                	je     800931 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	89 02                	mov    %eax,(%edx)
	return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 13                	jmp    800936 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800923:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800928:	eb 0c                	jmp    800936 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80092a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80092f:	eb 05                	jmp    800936 <fd_lookup+0x54>
  800931:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	83 ec 14             	sub    $0x14,%esp
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	eb 0e                	jmp    80095a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80094c:	39 08                	cmp    %ecx,(%eax)
  80094e:	75 09                	jne    800959 <dev_lookup+0x21>
			*dev = devtab[i];
  800950:	89 03                	mov    %eax,(%ebx)
			return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	eb 33                	jmp    80098c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800959:	42                   	inc    %edx
  80095a:	8b 04 95 d8 25 80 00 	mov    0x8025d8(,%edx,4),%eax
  800961:	85 c0                	test   %eax,%eax
  800963:	75 e7                	jne    80094c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800965:	a1 08 40 80 00       	mov    0x804008,%eax
  80096a:	8b 40 48             	mov    0x48(%eax),%eax
  80096d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  80097c:	e8 7f 12 00 00       	call   801c00 <cprintf>
	*dev = 0;
  800981:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800987:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80098c:	83 c4 14             	add    $0x14,%esp
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	83 ec 30             	sub    $0x30,%esp
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8a 45 0c             	mov    0xc(%ebp),%al
  8009a0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8009a3:	89 34 24             	mov    %esi,(%esp)
  8009a6:	e8 b9 fe ff ff       	call   800864 <fd2num>
  8009ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8009ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b2:	89 04 24             	mov    %eax,(%esp)
  8009b5:	e8 28 ff ff ff       	call   8008e2 <fd_lookup>
  8009ba:	89 c3                	mov    %eax,%ebx
  8009bc:	85 c0                	test   %eax,%eax
  8009be:	78 05                	js     8009c5 <fd_close+0x33>
	    || fd != fd2)
  8009c0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8009c3:	74 0d                	je     8009d2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8009c5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8009c9:	75 46                	jne    800a11 <fd_close+0x7f>
  8009cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009d0:	eb 3f                	jmp    800a11 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8009d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d9:	8b 06                	mov    (%esi),%eax
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	e8 55 ff ff ff       	call   800938 <dev_lookup>
  8009e3:	89 c3                	mov    %eax,%ebx
  8009e5:	85 c0                	test   %eax,%eax
  8009e7:	78 18                	js     800a01 <fd_close+0x6f>
		if (dev->dev_close)
  8009e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ec:	8b 40 10             	mov    0x10(%eax),%eax
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	74 09                	je     8009fc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8009f3:	89 34 24             	mov    %esi,(%esp)
  8009f6:	ff d0                	call   *%eax
  8009f8:	89 c3                	mov    %eax,%ebx
  8009fa:	eb 05                	jmp    800a01 <fd_close+0x6f>
		else
			r = 0;
  8009fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a01:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a0c:	e8 0f fc ff ff       	call   800620 <sys_page_unmap>
	return r;
}
  800a11:	89 d8                	mov    %ebx,%eax
  800a13:	83 c4 30             	add    $0x30,%esp
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	e8 b0 fe ff ff       	call   8008e2 <fd_lookup>
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 13                	js     800a49 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800a36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800a3d:	00 
  800a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a41:	89 04 24             	mov    %eax,(%esp)
  800a44:	e8 49 ff ff ff       	call   800992 <fd_close>
}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <close_all>:

void
close_all(void)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a52:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800a57:	89 1c 24             	mov    %ebx,(%esp)
  800a5a:	e8 bb ff ff ff       	call   800a1a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800a5f:	43                   	inc    %ebx
  800a60:	83 fb 20             	cmp    $0x20,%ebx
  800a63:	75 f2                	jne    800a57 <close_all+0xc>
		close(i);
}
  800a65:	83 c4 14             	add    $0x14,%esp
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 4c             	sub    $0x4c,%esp
  800a74:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	89 04 24             	mov    %eax,(%esp)
  800a84:	e8 59 fe ff ff       	call   8008e2 <fd_lookup>
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	0f 88 e1 00 00 00    	js     800b74 <dup+0x109>
		return r;
	close(newfdnum);
  800a93:	89 3c 24             	mov    %edi,(%esp)
  800a96:	e8 7f ff ff ff       	call   800a1a <close>

	newfd = INDEX2FD(newfdnum);
  800a9b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800aa1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800aa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	e8 c5 fd ff ff       	call   800874 <fd2data>
  800aaf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800ab1:	89 34 24             	mov    %esi,(%esp)
  800ab4:	e8 bb fd ff ff       	call   800874 <fd2data>
  800ab9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800abc:	89 d8                	mov    %ebx,%eax
  800abe:	c1 e8 16             	shr    $0x16,%eax
  800ac1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ac8:	a8 01                	test   $0x1,%al
  800aca:	74 46                	je     800b12 <dup+0xa7>
  800acc:	89 d8                	mov    %ebx,%eax
  800ace:	c1 e8 0c             	shr    $0xc,%eax
  800ad1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ad8:	f6 c2 01             	test   $0x1,%dl
  800adb:	74 35                	je     800b12 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800add:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ae4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ae9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800af0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800afb:	00 
  800afc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b07:	e8 c1 fa ff ff       	call   8005cd <sys_page_map>
  800b0c:	89 c3                	mov    %eax,%ebx
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	78 3b                	js     800b4d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	c1 ea 0c             	shr    $0xc,%edx
  800b1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b21:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800b27:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b2b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b36:	00 
  800b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b42:	e8 86 fa ff ff       	call   8005cd <sys_page_map>
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	79 25                	jns    800b72 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b58:	e8 c3 fa ff ff       	call   800620 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b6b:	e8 b0 fa ff ff       	call   800620 <sys_page_unmap>
	return r;
  800b70:	eb 02                	jmp    800b74 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800b72:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800b74:	89 d8                	mov    %ebx,%eax
  800b76:	83 c4 4c             	add    $0x4c,%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	53                   	push   %ebx
  800b82:	83 ec 24             	sub    $0x24,%esp
  800b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8f:	89 1c 24             	mov    %ebx,(%esp)
  800b92:	e8 4b fd ff ff       	call   8008e2 <fd_lookup>
  800b97:	85 c0                	test   %eax,%eax
  800b99:	78 6d                	js     800c08 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba5:	8b 00                	mov    (%eax),%eax
  800ba7:	89 04 24             	mov    %eax,(%esp)
  800baa:	e8 89 fd ff ff       	call   800938 <dev_lookup>
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	78 55                	js     800c08 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb6:	8b 50 08             	mov    0x8(%eax),%edx
  800bb9:	83 e2 03             	and    $0x3,%edx
  800bbc:	83 fa 01             	cmp    $0x1,%edx
  800bbf:	75 23                	jne    800be4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bc1:	a1 08 40 80 00       	mov    0x804008,%eax
  800bc6:	8b 40 48             	mov    0x48(%eax),%eax
  800bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd1:	c7 04 24 9d 25 80 00 	movl   $0x80259d,(%esp)
  800bd8:	e8 23 10 00 00       	call   801c00 <cprintf>
		return -E_INVAL;
  800bdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800be2:	eb 24                	jmp    800c08 <read+0x8a>
	}
	if (!dev->dev_read)
  800be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be7:	8b 52 08             	mov    0x8(%edx),%edx
  800bea:	85 d2                	test   %edx,%edx
  800bec:	74 15                	je     800c03 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bf1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bfc:	89 04 24             	mov    %eax,(%esp)
  800bff:	ff d2                	call   *%edx
  800c01:	eb 05                	jmp    800c08 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c03:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800c08:	83 c4 24             	add    $0x24,%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 1c             	sub    $0x1c,%esp
  800c17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	eb 23                	jmp    800c47 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c24:	89 f0                	mov    %esi,%eax
  800c26:	29 d8                	sub    %ebx,%eax
  800c28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	01 d8                	add    %ebx,%eax
  800c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c35:	89 3c 24             	mov    %edi,(%esp)
  800c38:	e8 41 ff ff ff       	call   800b7e <read>
		if (m < 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	78 10                	js     800c51 <readn+0x43>
			return m;
		if (m == 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	74 0a                	je     800c4f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c45:	01 c3                	add    %eax,%ebx
  800c47:	39 f3                	cmp    %esi,%ebx
  800c49:	72 d9                	jb     800c24 <readn+0x16>
  800c4b:	89 d8                	mov    %ebx,%eax
  800c4d:	eb 02                	jmp    800c51 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800c4f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800c51:	83 c4 1c             	add    $0x1c,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 24             	sub    $0x24,%esp
  800c60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6a:	89 1c 24             	mov    %ebx,(%esp)
  800c6d:	e8 70 fc ff ff       	call   8008e2 <fd_lookup>
  800c72:	85 c0                	test   %eax,%eax
  800c74:	78 68                	js     800cde <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c80:	8b 00                	mov    (%eax),%eax
  800c82:	89 04 24             	mov    %eax,(%esp)
  800c85:	e8 ae fc ff ff       	call   800938 <dev_lookup>
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	78 50                	js     800cde <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c91:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c95:	75 23                	jne    800cba <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c97:	a1 08 40 80 00       	mov    0x804008,%eax
  800c9c:	8b 40 48             	mov    0x48(%eax),%eax
  800c9f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca7:	c7 04 24 b9 25 80 00 	movl   $0x8025b9,(%esp)
  800cae:	e8 4d 0f 00 00       	call   801c00 <cprintf>
		return -E_INVAL;
  800cb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cb8:	eb 24                	jmp    800cde <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cbd:	8b 52 0c             	mov    0xc(%edx),%edx
  800cc0:	85 d2                	test   %edx,%edx
  800cc2:	74 15                	je     800cd9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cd2:	89 04 24             	mov    %eax,(%esp)
  800cd5:	ff d2                	call   *%edx
  800cd7:	eb 05                	jmp    800cde <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800cd9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800cde:	83 c4 24             	add    $0x24,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800cea:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	89 04 24             	mov    %eax,(%esp)
  800cf7:	e8 e6 fb ff ff       	call   8008e2 <fd_lookup>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 0e                	js     800d0e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d06:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	53                   	push   %ebx
  800d14:	83 ec 24             	sub    $0x24,%esp
  800d17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d21:	89 1c 24             	mov    %ebx,(%esp)
  800d24:	e8 b9 fb ff ff       	call   8008e2 <fd_lookup>
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	78 61                	js     800d8e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d37:	8b 00                	mov    (%eax),%eax
  800d39:	89 04 24             	mov    %eax,(%esp)
  800d3c:	e8 f7 fb ff ff       	call   800938 <dev_lookup>
  800d41:	85 c0                	test   %eax,%eax
  800d43:	78 49                	js     800d8e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d48:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d4c:	75 23                	jne    800d71 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d4e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d53:	8b 40 48             	mov    0x48(%eax),%eax
  800d56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5e:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800d65:	e8 96 0e 00 00       	call   801c00 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d6f:	eb 1d                	jmp    800d8e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d74:	8b 52 18             	mov    0x18(%edx),%edx
  800d77:	85 d2                	test   %edx,%edx
  800d79:	74 0e                	je     800d89 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d82:	89 04 24             	mov    %eax,(%esp)
  800d85:	ff d2                	call   *%edx
  800d87:	eb 05                	jmp    800d8e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d89:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d8e:	83 c4 24             	add    $0x24,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	53                   	push   %ebx
  800d98:	83 ec 24             	sub    $0x24,%esp
  800d9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	89 04 24             	mov    %eax,(%esp)
  800dab:	e8 32 fb ff ff       	call   8008e2 <fd_lookup>
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 52                	js     800e06 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800db4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800db7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dbe:	8b 00                	mov    (%eax),%eax
  800dc0:	89 04 24             	mov    %eax,(%esp)
  800dc3:	e8 70 fb ff ff       	call   800938 <dev_lookup>
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	78 3a                	js     800e06 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800dd3:	74 2c                	je     800e01 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800dd5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800dd8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ddf:	00 00 00 
	stat->st_isdir = 0;
  800de2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800de9:	00 00 00 
	stat->st_dev = dev;
  800dec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800df2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800df6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800df9:	89 14 24             	mov    %edx,(%esp)
  800dfc:	ff 50 14             	call   *0x14(%eax)
  800dff:	eb 05                	jmp    800e06 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e06:	83 c4 24             	add    $0x24,%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e1b:	00 
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1f:	89 04 24             	mov    %eax,(%esp)
  800e22:	e8 2d 02 00 00       	call   801054 <open>
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	78 1b                	js     800e48 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e34:	89 1c 24             	mov    %ebx,(%esp)
  800e37:	e8 58 ff ff ff       	call   800d94 <fstat>
  800e3c:	89 c6                	mov    %eax,%esi
	close(fd);
  800e3e:	89 1c 24             	mov    %ebx,(%esp)
  800e41:	e8 d4 fb ff ff       	call   800a1a <close>
	return r;
  800e46:	89 f3                	mov    %esi,%ebx
}
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
  800e51:	00 00                	add    %al,(%eax)
	...

00800e54 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 10             	sub    $0x10,%esp
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800e60:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e67:	75 11                	jne    800e7a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e70:	e8 da 13 00 00       	call   80224f <ipc_find_env>
  800e75:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e7a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e89:	00 
  800e8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e8e:	a1 00 40 80 00       	mov    0x804000,%eax
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 46 13 00 00       	call   8021e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea2:	00 
  800ea3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eae:	e8 c5 12 00 00       	call   802178 <ipc_recv>
}
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ec6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ece:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ed3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed8:	b8 02 00 00 00       	mov    $0x2,%eax
  800edd:	e8 72 ff ff ff       	call   800e54 <fsipc>
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	8b 40 0c             	mov    0xc(%eax),%eax
  800ef0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ef5:	ba 00 00 00 00       	mov    $0x0,%edx
  800efa:	b8 06 00 00 00       	mov    $0x6,%eax
  800eff:	e8 50 ff ff ff       	call   800e54 <fsipc>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 14             	sub    $0x14,%esp
  800f0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	8b 40 0c             	mov    0xc(%eax),%eax
  800f16:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 05 00 00 00       	mov    $0x5,%eax
  800f25:	e8 2a ff ff ff       	call   800e54 <fsipc>
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	78 2b                	js     800f59 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f2e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f35:	00 
  800f36:	89 1c 24             	mov    %ebx,(%esp)
  800f39:	e8 49 f2 ff ff       	call   800187 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f3e:	a1 80 50 80 00       	mov    0x805080,%eax
  800f43:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f49:	a1 84 50 80 00       	mov    0x805084,%eax
  800f4e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f59:	83 c4 14             	add    $0x14,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 18             	sub    $0x18,%esp
  800f65:	8b 55 10             	mov    0x10(%ebp),%edx
  800f68:	89 d0                	mov    %edx,%eax
  800f6a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  800f70:	76 05                	jbe    800f77 <devfile_write+0x18>
  800f72:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f77:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7a:	8b 52 0c             	mov    0xc(%edx),%edx
  800f7d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800f83:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800f88:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f93:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f9a:	e8 61 f3 ff ff       	call   800300 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  800f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa4:	b8 04 00 00 00       	mov    $0x4,%eax
  800fa9:	e8 a6 fe ff ff       	call   800e54 <fsipc>
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 10             	sub    $0x10,%esp
  800fb8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fc6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd6:	e8 79 fe ff ff       	call   800e54 <fsipc>
  800fdb:	89 c3                	mov    %eax,%ebx
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 6a                	js     80104b <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800fe1:	39 c6                	cmp    %eax,%esi
  800fe3:	73 24                	jae    801009 <devfile_read+0x59>
  800fe5:	c7 44 24 0c ec 25 80 	movl   $0x8025ec,0xc(%esp)
  800fec:	00 
  800fed:	c7 44 24 08 f3 25 80 	movl   $0x8025f3,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 08 26 80 00 	movl   $0x802608,(%esp)
  801004:	e8 ff 0a 00 00       	call   801b08 <_panic>
	assert(r <= PGSIZE);
  801009:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80100e:	7e 24                	jle    801034 <devfile_read+0x84>
  801010:	c7 44 24 0c 13 26 80 	movl   $0x802613,0xc(%esp)
  801017:	00 
  801018:	c7 44 24 08 f3 25 80 	movl   $0x8025f3,0x8(%esp)
  80101f:	00 
  801020:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801027:	00 
  801028:	c7 04 24 08 26 80 00 	movl   $0x802608,(%esp)
  80102f:	e8 d4 0a 00 00       	call   801b08 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801034:	89 44 24 08          	mov    %eax,0x8(%esp)
  801038:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80103f:	00 
  801040:	8b 45 0c             	mov    0xc(%ebp),%eax
  801043:	89 04 24             	mov    %eax,(%esp)
  801046:	e8 b5 f2 ff ff       	call   800300 <memmove>
	return r;
}
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 20             	sub    $0x20,%esp
  80105c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80105f:	89 34 24             	mov    %esi,(%esp)
  801062:	e8 ed f0 ff ff       	call   800154 <strlen>
  801067:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80106c:	7f 60                	jg     8010ce <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80106e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801071:	89 04 24             	mov    %eax,(%esp)
  801074:	e8 16 f8 ff ff       	call   80088f <fd_alloc>
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 54                	js     8010d3 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80107f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801083:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80108a:	e8 f8 f0 ff ff       	call   800187 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80108f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801092:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801097:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80109a:	b8 01 00 00 00       	mov    $0x1,%eax
  80109f:	e8 b0 fd ff ff       	call   800e54 <fsipc>
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 15                	jns    8010bf <open+0x6b>
		fd_close(fd, 0);
  8010aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b1:	00 
  8010b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b5:	89 04 24             	mov    %eax,(%esp)
  8010b8:	e8 d5 f8 ff ff       	call   800992 <fd_close>
		return r;
  8010bd:	eb 14                	jmp    8010d3 <open+0x7f>
	}

	return fd2num(fd);
  8010bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c2:	89 04 24             	mov    %eax,(%esp)
  8010c5:	e8 9a f7 ff ff       	call   800864 <fd2num>
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	eb 05                	jmp    8010d3 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010ce:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	83 c4 20             	add    $0x20,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8010ec:	e8 63 fd ff ff       	call   800e54 <fsipc>
}
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    
	...

008010f4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8010fa:	c7 44 24 04 1f 26 80 	movl   $0x80261f,0x4(%esp)
  801101:	00 
  801102:	8b 45 0c             	mov    0xc(%ebp),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	e8 7a f0 ff ff       	call   800187 <strcpy>
	return 0;
}
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	53                   	push   %ebx
  801118:	83 ec 14             	sub    $0x14,%esp
  80111b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80111e:	89 1c 24             	mov    %ebx,(%esp)
  801121:	e8 62 11 00 00       	call   802288 <pageref>
  801126:	83 f8 01             	cmp    $0x1,%eax
  801129:	75 0d                	jne    801138 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80112b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80112e:	89 04 24             	mov    %eax,(%esp)
  801131:	e8 1f 03 00 00       	call   801455 <nsipc_close>
  801136:	eb 05                	jmp    80113d <devsock_close+0x29>
	else
		return 0;
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80113d:	83 c4 14             	add    $0x14,%esp
  801140:	5b                   	pop    %ebx
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801149:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801150:	00 
  801151:	8b 45 10             	mov    0x10(%ebp),%eax
  801154:	89 44 24 08          	mov    %eax,0x8(%esp)
  801158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	8b 40 0c             	mov    0xc(%eax),%eax
  801165:	89 04 24             	mov    %eax,(%esp)
  801168:	e8 e3 03 00 00       	call   801550 <nsipc_send>
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801175:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80117c:	00 
  80117d:	8b 45 10             	mov    0x10(%ebp),%eax
  801180:	89 44 24 08          	mov    %eax,0x8(%esp)
  801184:	8b 45 0c             	mov    0xc(%ebp),%eax
  801187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	8b 40 0c             	mov    0xc(%eax),%eax
  801191:	89 04 24             	mov    %eax,(%esp)
  801194:	e8 37 03 00 00       	call   8014d0 <nsipc_recv>
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 20             	sub    $0x20,%esp
  8011a3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8011a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a8:	89 04 24             	mov    %eax,(%esp)
  8011ab:	e8 df f6 ff ff       	call   80088f <fd_alloc>
  8011b0:	89 c3                	mov    %eax,%ebx
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 21                	js     8011d7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8011b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011bd:	00 
  8011be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cc:	e8 a8 f3 ff ff       	call   800579 <sys_page_alloc>
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	79 0a                	jns    8011e1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8011d7:	89 34 24             	mov    %esi,(%esp)
  8011da:	e8 76 02 00 00       	call   801455 <nsipc_close>
		return r;
  8011df:	eb 22                	jmp    801203 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8011e1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8011ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8011f6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8011f9:	89 04 24             	mov    %eax,(%esp)
  8011fc:	e8 63 f6 ff ff       	call   800864 <fd2num>
  801201:	89 c3                	mov    %eax,%ebx
}
  801203:	89 d8                	mov    %ebx,%eax
  801205:	83 c4 20             	add    $0x20,%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801212:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801215:	89 54 24 04          	mov    %edx,0x4(%esp)
  801219:	89 04 24             	mov    %eax,(%esp)
  80121c:	e8 c1 f6 ff ff       	call   8008e2 <fd_lookup>
  801221:	85 c0                	test   %eax,%eax
  801223:	78 17                	js     80123c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801228:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80122e:	39 10                	cmp    %edx,(%eax)
  801230:	75 05                	jne    801237 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801232:	8b 40 0c             	mov    0xc(%eax),%eax
  801235:	eb 05                	jmp    80123c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801237:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	e8 c0 ff ff ff       	call   80120c <fd2sockid>
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 1f                	js     80126f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801250:	8b 55 10             	mov    0x10(%ebp),%edx
  801253:	89 54 24 08          	mov    %edx,0x8(%esp)
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80125e:	89 04 24             	mov    %eax,(%esp)
  801261:	e8 38 01 00 00       	call   80139e <nsipc_accept>
  801266:	85 c0                	test   %eax,%eax
  801268:	78 05                	js     80126f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80126a:	e8 2c ff ff ff       	call   80119b <alloc_sockfd>
}
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801277:	8b 45 08             	mov    0x8(%ebp),%eax
  80127a:	e8 8d ff ff ff       	call   80120c <fd2sockid>
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 16                	js     801299 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801283:	8b 55 10             	mov    0x10(%ebp),%edx
  801286:	89 54 24 08          	mov    %edx,0x8(%esp)
  80128a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 5b 01 00 00       	call   8013f4 <nsipc_bind>
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <shutdown>:

int
shutdown(int s, int how)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a4:	e8 63 ff ff ff       	call   80120c <fd2sockid>
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 0f                	js     8012bc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8012ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012b4:	89 04 24             	mov    %eax,(%esp)
  8012b7:	e8 77 01 00 00       	call   801433 <nsipc_shutdown>
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c7:	e8 40 ff ff ff       	call   80120c <fd2sockid>
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 16                	js     8012e6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8012d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8012d3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012de:	89 04 24             	mov    %eax,(%esp)
  8012e1:	e8 89 01 00 00       	call   80146f <nsipc_connect>
}
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <listen>:

int
listen(int s, int backlog)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f1:	e8 16 ff ff ff       	call   80120c <fd2sockid>
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 0f                	js     801309 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8012fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801301:	89 04 24             	mov    %eax,(%esp)
  801304:	e8 a5 01 00 00       	call   8014ae <nsipc_listen>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801311:	8b 45 10             	mov    0x10(%ebp),%eax
  801314:	89 44 24 08          	mov    %eax,0x8(%esp)
  801318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	e8 99 02 00 00       	call   8015c3 <nsipc_socket>
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 05                	js     801333 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  80132e:	e8 68 fe ff ff       	call   80119b <alloc_sockfd>
}
  801333:	c9                   	leave  
  801334:	c3                   	ret    
  801335:	00 00                	add    %al,(%eax)
	...

00801338 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 14             	sub    $0x14,%esp
  80133f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801341:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801348:	75 11                	jne    80135b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80134a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801351:	e8 f9 0e 00 00       	call   80224f <ipc_find_env>
  801356:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80135b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801362:	00 
  801363:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80136a:	00 
  80136b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80136f:	a1 04 40 80 00       	mov    0x804004,%eax
  801374:	89 04 24             	mov    %eax,(%esp)
  801377:	e8 65 0e 00 00       	call   8021e1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80137c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801383:	00 
  801384:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80138b:	00 
  80138c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801393:	e8 e0 0d 00 00       	call   802178 <ipc_recv>
}
  801398:	83 c4 14             	add    $0x14,%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 10             	sub    $0x10,%esp
  8013a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8013b1:	8b 06                	mov    (%esi),%eax
  8013b3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8013b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bd:	e8 76 ff ff ff       	call   801338 <nsipc>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 23                	js     8013eb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8013c8:	a1 10 60 80 00       	mov    0x806010,%eax
  8013cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8013d8:	00 
  8013d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dc:	89 04 24             	mov    %eax,(%esp)
  8013df:	e8 1c ef ff ff       	call   800300 <memmove>
		*addrlen = ret->ret_addrlen;
  8013e4:	a1 10 60 80 00       	mov    0x806010,%eax
  8013e9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8013eb:	89 d8                	mov    %ebx,%eax
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 14             	sub    $0x14,%esp
  8013fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801406:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801418:	e8 e3 ee ff ff       	call   800300 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80141d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801423:	b8 02 00 00 00       	mov    $0x2,%eax
  801428:	e8 0b ff ff ff       	call   801338 <nsipc>
}
  80142d:	83 c4 14             	add    $0x14,%esp
  801430:	5b                   	pop    %ebx
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801441:	8b 45 0c             	mov    0xc(%ebp),%eax
  801444:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801449:	b8 03 00 00 00       	mov    $0x3,%eax
  80144e:	e8 e5 fe ff ff       	call   801338 <nsipc>
}
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <nsipc_close>:

int
nsipc_close(int s)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801463:	b8 04 00 00 00       	mov    $0x4,%eax
  801468:	e8 cb fe ff ff       	call   801338 <nsipc>
}
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 14             	sub    $0x14,%esp
  801476:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801481:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801485:	8b 45 0c             	mov    0xc(%ebp),%eax
  801488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801493:	e8 68 ee ff ff       	call   800300 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801498:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80149e:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a3:	e8 90 fe ff ff       	call   801338 <nsipc>
}
  8014a8:	83 c4 14             	add    $0x14,%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8014bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8014c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c9:	e8 6a fe ff ff       	call   801338 <nsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 10             	sub    $0x10,%esp
  8014d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8014e3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8014e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ec:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8014f1:	b8 07 00 00 00       	mov    $0x7,%eax
  8014f6:	e8 3d fe ff ff       	call   801338 <nsipc>
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 46                	js     801547 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801501:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801506:	7f 04                	jg     80150c <nsipc_recv+0x3c>
  801508:	39 c6                	cmp    %eax,%esi
  80150a:	7d 24                	jge    801530 <nsipc_recv+0x60>
  80150c:	c7 44 24 0c 2b 26 80 	movl   $0x80262b,0xc(%esp)
  801513:	00 
  801514:	c7 44 24 08 f3 25 80 	movl   $0x8025f3,0x8(%esp)
  80151b:	00 
  80151c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801523:	00 
  801524:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  80152b:	e8 d8 05 00 00       	call   801b08 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801530:	89 44 24 08          	mov    %eax,0x8(%esp)
  801534:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80153b:	00 
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	89 04 24             	mov    %eax,(%esp)
  801542:	e8 b9 ed ff ff       	call   800300 <memmove>
	}

	return r;
}
  801547:	89 d8                	mov    %ebx,%eax
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 14             	sub    $0x14,%esp
  801557:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80155a:	8b 45 08             	mov    0x8(%ebp),%eax
  80155d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801562:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801568:	7e 24                	jle    80158e <nsipc_send+0x3e>
  80156a:	c7 44 24 0c 4c 26 80 	movl   $0x80264c,0xc(%esp)
  801571:	00 
  801572:	c7 44 24 08 f3 25 80 	movl   $0x8025f3,0x8(%esp)
  801579:	00 
  80157a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801581:	00 
  801582:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  801589:	e8 7a 05 00 00       	call   801b08 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80158e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801592:	8b 45 0c             	mov    0xc(%ebp),%eax
  801595:	89 44 24 04          	mov    %eax,0x4(%esp)
  801599:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8015a0:	e8 5b ed ff ff       	call   800300 <memmove>
	nsipcbuf.send.req_size = size;
  8015a5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8015ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ae:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8015b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b8:	e8 7b fd ff ff       	call   801338 <nsipc>
}
  8015bd:	83 c4 14             	add    $0x14,%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8015c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8015d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8015d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8015dc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8015e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8015e6:	e8 4d fd ff ff       	call   801338 <nsipc>
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    
  8015ed:	00 00                	add    %al,(%eax)
	...

008015f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 10             	sub    $0x10,%esp
  8015f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 6e f2 ff ff       	call   800874 <fd2data>
  801606:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801608:	c7 44 24 04 58 26 80 	movl   $0x802658,0x4(%esp)
  80160f:	00 
  801610:	89 34 24             	mov    %esi,(%esp)
  801613:	e8 6f eb ff ff       	call   800187 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801618:	8b 43 04             	mov    0x4(%ebx),%eax
  80161b:	2b 03                	sub    (%ebx),%eax
  80161d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801623:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80162a:	00 00 00 
	stat->st_dev = &devpipe;
  80162d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801634:	30 80 00 
	return 0;
}
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 14             	sub    $0x14,%esp
  80164a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80164d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801658:	e8 c3 ef ff ff       	call   800620 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80165d:	89 1c 24             	mov    %ebx,(%esp)
  801660:	e8 0f f2 ff ff       	call   800874 <fd2data>
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801670:	e8 ab ef ff ff       	call   800620 <sys_page_unmap>
}
  801675:	83 c4 14             	add    $0x14,%esp
  801678:	5b                   	pop    %ebx
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 2c             	sub    $0x2c,%esp
  801684:	89 c7                	mov    %eax,%edi
  801686:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801689:	a1 08 40 80 00       	mov    0x804008,%eax
  80168e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801691:	89 3c 24             	mov    %edi,(%esp)
  801694:	e8 ef 0b 00 00       	call   802288 <pageref>
  801699:	89 c6                	mov    %eax,%esi
  80169b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80169e:	89 04 24             	mov    %eax,(%esp)
  8016a1:	e8 e2 0b 00 00       	call   802288 <pageref>
  8016a6:	39 c6                	cmp    %eax,%esi
  8016a8:	0f 94 c0             	sete   %al
  8016ab:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016ae:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016b7:	39 cb                	cmp    %ecx,%ebx
  8016b9:	75 08                	jne    8016c3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016bb:	83 c4 2c             	add    $0x2c,%esp
  8016be:	5b                   	pop    %ebx
  8016bf:	5e                   	pop    %esi
  8016c0:	5f                   	pop    %edi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016c3:	83 f8 01             	cmp    $0x1,%eax
  8016c6:	75 c1                	jne    801689 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016c8:	8b 42 58             	mov    0x58(%edx),%eax
  8016cb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016d2:	00 
  8016d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016db:	c7 04 24 5f 26 80 00 	movl   $0x80265f,(%esp)
  8016e2:	e8 19 05 00 00       	call   801c00 <cprintf>
  8016e7:	eb a0                	jmp    801689 <_pipeisclosed+0xe>

008016e9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	57                   	push   %edi
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	83 ec 1c             	sub    $0x1c,%esp
  8016f2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016f5:	89 34 24             	mov    %esi,(%esp)
  8016f8:	e8 77 f1 ff ff       	call   800874 <fd2data>
  8016fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801704:	eb 3c                	jmp    801742 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801706:	89 da                	mov    %ebx,%edx
  801708:	89 f0                	mov    %esi,%eax
  80170a:	e8 6c ff ff ff       	call   80167b <_pipeisclosed>
  80170f:	85 c0                	test   %eax,%eax
  801711:	75 38                	jne    80174b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801713:	e8 42 ee ff ff       	call   80055a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801718:	8b 43 04             	mov    0x4(%ebx),%eax
  80171b:	8b 13                	mov    (%ebx),%edx
  80171d:	83 c2 20             	add    $0x20,%edx
  801720:	39 d0                	cmp    %edx,%eax
  801722:	73 e2                	jae    801706 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801724:	8b 55 0c             	mov    0xc(%ebp),%edx
  801727:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801732:	79 05                	jns    801739 <devpipe_write+0x50>
  801734:	4a                   	dec    %edx
  801735:	83 ca e0             	or     $0xffffffe0,%edx
  801738:	42                   	inc    %edx
  801739:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80173d:	40                   	inc    %eax
  80173e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801741:	47                   	inc    %edi
  801742:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801745:	75 d1                	jne    801718 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801747:	89 f8                	mov    %edi,%eax
  801749:	eb 05                	jmp    801750 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801750:	83 c4 1c             	add    $0x1c,%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 1c             	sub    $0x1c,%esp
  801761:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801764:	89 3c 24             	mov    %edi,(%esp)
  801767:	e8 08 f1 ff ff       	call   800874 <fd2data>
  80176c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176e:	be 00 00 00 00       	mov    $0x0,%esi
  801773:	eb 3a                	jmp    8017af <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801775:	85 f6                	test   %esi,%esi
  801777:	74 04                	je     80177d <devpipe_read+0x25>
				return i;
  801779:	89 f0                	mov    %esi,%eax
  80177b:	eb 40                	jmp    8017bd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80177d:	89 da                	mov    %ebx,%edx
  80177f:	89 f8                	mov    %edi,%eax
  801781:	e8 f5 fe ff ff       	call   80167b <_pipeisclosed>
  801786:	85 c0                	test   %eax,%eax
  801788:	75 2e                	jne    8017b8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80178a:	e8 cb ed ff ff       	call   80055a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80178f:	8b 03                	mov    (%ebx),%eax
  801791:	3b 43 04             	cmp    0x4(%ebx),%eax
  801794:	74 df                	je     801775 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801796:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80179b:	79 05                	jns    8017a2 <devpipe_read+0x4a>
  80179d:	48                   	dec    %eax
  80179e:	83 c8 e0             	or     $0xffffffe0,%eax
  8017a1:	40                   	inc    %eax
  8017a2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017ac:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ae:	46                   	inc    %esi
  8017af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017b2:	75 db                	jne    80178f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017b4:	89 f0                	mov    %esi,%eax
  8017b6:	eb 05                	jmp    8017bd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017bd:	83 c4 1c             	add    $0x1c,%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5f                   	pop    %edi
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	57                   	push   %edi
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 3c             	sub    $0x3c,%esp
  8017ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	e8 b3 f0 ff ff       	call   80088f <fd_alloc>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	0f 88 45 01 00 00    	js     80192b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017ed:	00 
  8017ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fc:	e8 78 ed ff ff       	call   800579 <sys_page_alloc>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	85 c0                	test   %eax,%eax
  801805:	0f 88 20 01 00 00    	js     80192b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80180b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 79 f0 ff ff       	call   80088f <fd_alloc>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	85 c0                	test   %eax,%eax
  80181a:	0f 88 f8 00 00 00    	js     801918 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801820:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801827:	00 
  801828:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80182b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801836:	e8 3e ed ff ff       	call   800579 <sys_page_alloc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	85 c0                	test   %eax,%eax
  80183f:	0f 88 d3 00 00 00    	js     801918 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801845:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801848:	89 04 24             	mov    %eax,(%esp)
  80184b:	e8 24 f0 ff ff       	call   800874 <fd2data>
  801850:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801852:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801859:	00 
  80185a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801865:	e8 0f ed ff ff       	call   800579 <sys_page_alloc>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	85 c0                	test   %eax,%eax
  80186e:	0f 88 91 00 00 00    	js     801905 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801874:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801877:	89 04 24             	mov    %eax,(%esp)
  80187a:	e8 f5 ef ff ff       	call   800874 <fd2data>
  80187f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801886:	00 
  801887:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80188b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801892:	00 
  801893:	89 74 24 04          	mov    %esi,0x4(%esp)
  801897:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80189e:	e8 2a ed ff ff       	call   8005cd <sys_page_map>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 4c                	js     8018f5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018a9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8018af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018be:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8018c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018c7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 86 ef ff ff       	call   800864 <fd2num>
  8018de:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 79 ef ff ff       	call   800864 <fd2num>
  8018eb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f3:	eb 36                	jmp    80192b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801900:	e8 1b ed ff ff       	call   800620 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801905:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801913:	e8 08 ed ff ff       	call   800620 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801918:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80191b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801926:	e8 f5 ec ff ff       	call   800620 <sys_page_unmap>
    err:
	return r;
}
  80192b:	89 d8                	mov    %ebx,%eax
  80192d:	83 c4 3c             	add    $0x3c,%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5f                   	pop    %edi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	89 04 24             	mov    %eax,(%esp)
  801948:	e8 95 ef ff ff       	call   8008e2 <fd_lookup>
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 15                	js     801966 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801954:	89 04 24             	mov    %eax,(%esp)
  801957:	e8 18 ef ff ff       	call   800874 <fd2data>
	return _pipeisclosed(fd, p);
  80195c:	89 c2                	mov    %eax,%edx
  80195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801961:	e8 15 fd ff ff       	call   80167b <_pipeisclosed>
}
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801978:	c7 44 24 04 77 26 80 	movl   $0x802677,0x4(%esp)
  80197f:	00 
  801980:	8b 45 0c             	mov    0xc(%ebp),%eax
  801983:	89 04 24             	mov    %eax,(%esp)
  801986:	e8 fc e7 ff ff       	call   800187 <strcpy>
	return 0;
}
  80198b:	b8 00 00 00 00       	mov    $0x0,%eax
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	57                   	push   %edi
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
  801998:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80199e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a9:	eb 30                	jmp    8019db <devcons_write+0x49>
		m = n - tot;
  8019ab:	8b 75 10             	mov    0x10(%ebp),%esi
  8019ae:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019b0:	83 fe 7f             	cmp    $0x7f,%esi
  8019b3:	76 05                	jbe    8019ba <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019b5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019be:	03 45 0c             	add    0xc(%ebp),%eax
  8019c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c5:	89 3c 24             	mov    %edi,(%esp)
  8019c8:	e8 33 e9 ff ff       	call   800300 <memmove>
		sys_cputs(buf, m);
  8019cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d1:	89 3c 24             	mov    %edi,(%esp)
  8019d4:	e8 d3 ea ff ff       	call   8004ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d9:	01 f3                	add    %esi,%ebx
  8019db:	89 d8                	mov    %ebx,%eax
  8019dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019e0:	72 c9                	jb     8019ab <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019f7:	75 07                	jne    801a00 <devcons_read+0x13>
  8019f9:	eb 25                	jmp    801a20 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019fb:	e8 5a eb ff ff       	call   80055a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a00:	e8 c5 ea ff ff       	call   8004ca <sys_cgetc>
  801a05:	85 c0                	test   %eax,%eax
  801a07:	74 f2                	je     8019fb <devcons_read+0xe>
  801a09:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 1d                	js     801a2c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a0f:	83 f8 04             	cmp    $0x4,%eax
  801a12:	74 13                	je     801a27 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a17:	88 10                	mov    %dl,(%eax)
	return 1;
  801a19:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1e:	eb 0c                	jmp    801a2c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
  801a25:	eb 05                	jmp    801a2c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a41:	00 
  801a42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a45:	89 04 24             	mov    %eax,(%esp)
  801a48:	e8 5f ea ff ff       	call   8004ac <sys_cputs>
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <getchar>:

int
getchar(void)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a55:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a5c:	00 
  801a5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a6b:	e8 0e f1 ff ff       	call   800b7e <read>
	if (r < 0)
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 0f                	js     801a83 <getchar+0x34>
		return r;
	if (r < 1)
  801a74:	85 c0                	test   %eax,%eax
  801a76:	7e 06                	jle    801a7e <getchar+0x2f>
		return -E_EOF;
	return c;
  801a78:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a7c:	eb 05                	jmp    801a83 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a7e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	89 04 24             	mov    %eax,(%esp)
  801a98:	e8 45 ee ff ff       	call   8008e2 <fd_lookup>
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 11                	js     801ab2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801aaa:	39 10                	cmp    %edx,(%eax)
  801aac:	0f 94 c0             	sete   %al
  801aaf:	0f b6 c0             	movzbl %al,%eax
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <opencons>:

int
opencons(void)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 ca ed ff ff       	call   80088f <fd_alloc>
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 3c                	js     801b05 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ac9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ad0:	00 
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801adf:	e8 95 ea ff ff       	call   800579 <sys_page_alloc>
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 1d                	js     801b05 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ae8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801afd:	89 04 24             	mov    %eax,(%esp)
  801b00:	e8 5f ed ff ff       	call   800864 <fd2num>
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    
	...

00801b08 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b10:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b13:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b19:	e8 1d ea ff ff       	call   80053b <sys_getenvid>
  801b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b21:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b25:	8b 55 08             	mov    0x8(%ebp),%edx
  801b28:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b2c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b34:	c7 04 24 84 26 80 00 	movl   $0x802684,(%esp)
  801b3b:	e8 c0 00 00 00       	call   801c00 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b40:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b44:	8b 45 10             	mov    0x10(%ebp),%eax
  801b47:	89 04 24             	mov    %eax,(%esp)
  801b4a:	e8 50 00 00 00       	call   801b9f <vcprintf>
	cprintf("\n");
  801b4f:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  801b56:	e8 a5 00 00 00       	call   801c00 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b5b:	cc                   	int3   
  801b5c:	eb fd                	jmp    801b5b <_panic+0x53>
	...

00801b60 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	53                   	push   %ebx
  801b64:	83 ec 14             	sub    $0x14,%esp
  801b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b6a:	8b 03                	mov    (%ebx),%eax
  801b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  801b6f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801b73:	40                   	inc    %eax
  801b74:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801b76:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b7b:	75 19                	jne    801b96 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801b7d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801b84:	00 
  801b85:	8d 43 08             	lea    0x8(%ebx),%eax
  801b88:	89 04 24             	mov    %eax,(%esp)
  801b8b:	e8 1c e9 ff ff       	call   8004ac <sys_cputs>
		b->idx = 0;
  801b90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801b96:	ff 43 04             	incl   0x4(%ebx)
}
  801b99:	83 c4 14             	add    $0x14,%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801ba8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801baf:	00 00 00 
	b.cnt = 0;
  801bb2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801bb9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd4:	c7 04 24 60 1b 80 00 	movl   $0x801b60,(%esp)
  801bdb:	e8 82 01 00 00       	call   801d62 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801be0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bf0:	89 04 24             	mov    %eax,(%esp)
  801bf3:	e8 b4 e8 ff ff       	call   8004ac <sys_cputs>

	return b.cnt;
}
  801bf8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c06:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	89 04 24             	mov    %eax,(%esp)
  801c13:	e8 87 ff ff ff       	call   801b9f <vcprintf>
	va_end(ap);

	return cnt;
}
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    
	...

00801c1c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	83 ec 3c             	sub    $0x3c,%esp
  801c25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c28:	89 d7                	mov    %edx,%edi
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c33:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c36:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801c39:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	75 08                	jne    801c48 <printnum+0x2c>
  801c40:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c43:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c46:	77 57                	ja     801c9f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c48:	89 74 24 10          	mov    %esi,0x10(%esp)
  801c4c:	4b                   	dec    %ebx
  801c4d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c51:	8b 45 10             	mov    0x10(%ebp),%eax
  801c54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c58:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801c5c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801c60:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c67:	00 
  801c68:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c75:	e8 52 06 00 00       	call   8022cc <__udivdi3>
  801c7a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c82:	89 04 24             	mov    %eax,(%esp)
  801c85:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c89:	89 fa                	mov    %edi,%edx
  801c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8e:	e8 89 ff ff ff       	call   801c1c <printnum>
  801c93:	eb 0f                	jmp    801ca4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c95:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c99:	89 34 24             	mov    %esi,(%esp)
  801c9c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c9f:	4b                   	dec    %ebx
  801ca0:	85 db                	test   %ebx,%ebx
  801ca2:	7f f1                	jg     801c95 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ca4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ca8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801cac:	8b 45 10             	mov    0x10(%ebp),%eax
  801caf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cba:	00 
  801cbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801cbe:	89 04 24             	mov    %eax,(%esp)
  801cc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc8:	e8 1f 07 00 00       	call   8023ec <__umoddi3>
  801ccd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cd1:	0f be 80 a7 26 80 00 	movsbl 0x8026a7(%eax),%eax
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801cde:	83 c4 3c             	add    $0x3c,%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801ce9:	83 fa 01             	cmp    $0x1,%edx
  801cec:	7e 0e                	jle    801cfc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801cee:	8b 10                	mov    (%eax),%edx
  801cf0:	8d 4a 08             	lea    0x8(%edx),%ecx
  801cf3:	89 08                	mov    %ecx,(%eax)
  801cf5:	8b 02                	mov    (%edx),%eax
  801cf7:	8b 52 04             	mov    0x4(%edx),%edx
  801cfa:	eb 22                	jmp    801d1e <getuint+0x38>
	else if (lflag)
  801cfc:	85 d2                	test   %edx,%edx
  801cfe:	74 10                	je     801d10 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801d00:	8b 10                	mov    (%eax),%edx
  801d02:	8d 4a 04             	lea    0x4(%edx),%ecx
  801d05:	89 08                	mov    %ecx,(%eax)
  801d07:	8b 02                	mov    (%edx),%eax
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	eb 0e                	jmp    801d1e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801d10:	8b 10                	mov    (%eax),%edx
  801d12:	8d 4a 04             	lea    0x4(%edx),%ecx
  801d15:	89 08                	mov    %ecx,(%eax)
  801d17:	8b 02                	mov    (%edx),%eax
  801d19:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d26:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801d29:	8b 10                	mov    (%eax),%edx
  801d2b:	3b 50 04             	cmp    0x4(%eax),%edx
  801d2e:	73 08                	jae    801d38 <sprintputch+0x18>
		*b->buf++ = ch;
  801d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d33:	88 0a                	mov    %cl,(%edx)
  801d35:	42                   	inc    %edx
  801d36:	89 10                	mov    %edx,(%eax)
}
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801d40:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801d43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d47:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	89 04 24             	mov    %eax,(%esp)
  801d5b:	e8 02 00 00 00       	call   801d62 <vprintfmt>
	va_end(ap);
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	83 ec 4c             	sub    $0x4c,%esp
  801d6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d6e:	8b 75 10             	mov    0x10(%ebp),%esi
  801d71:	eb 12                	jmp    801d85 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d73:	85 c0                	test   %eax,%eax
  801d75:	0f 84 6b 03 00 00    	je     8020e6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801d7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d7f:	89 04 24             	mov    %eax,(%esp)
  801d82:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d85:	0f b6 06             	movzbl (%esi),%eax
  801d88:	46                   	inc    %esi
  801d89:	83 f8 25             	cmp    $0x25,%eax
  801d8c:	75 e5                	jne    801d73 <vprintfmt+0x11>
  801d8e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801d92:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801d99:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801d9e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801da5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801daa:	eb 26                	jmp    801dd2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dac:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801daf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801db3:	eb 1d                	jmp    801dd2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801db8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801dbc:	eb 14                	jmp    801dd2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dbe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801dc1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801dc8:	eb 08                	jmp    801dd2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801dca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801dcd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dd2:	0f b6 06             	movzbl (%esi),%eax
  801dd5:	8d 56 01             	lea    0x1(%esi),%edx
  801dd8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801ddb:	8a 16                	mov    (%esi),%dl
  801ddd:	83 ea 23             	sub    $0x23,%edx
  801de0:	80 fa 55             	cmp    $0x55,%dl
  801de3:	0f 87 e1 02 00 00    	ja     8020ca <vprintfmt+0x368>
  801de9:	0f b6 d2             	movzbl %dl,%edx
  801dec:	ff 24 95 e0 27 80 00 	jmp    *0x8027e0(,%edx,4)
  801df3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801df6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801dfb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801dfe:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801e02:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801e05:	8d 50 d0             	lea    -0x30(%eax),%edx
  801e08:	83 fa 09             	cmp    $0x9,%edx
  801e0b:	77 2a                	ja     801e37 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801e0d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801e0e:	eb eb                	jmp    801dfb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801e10:	8b 45 14             	mov    0x14(%ebp),%eax
  801e13:	8d 50 04             	lea    0x4(%eax),%edx
  801e16:	89 55 14             	mov    %edx,0x14(%ebp)
  801e19:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e1b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801e1e:	eb 17                	jmp    801e37 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801e20:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801e24:	78 98                	js     801dbe <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e26:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801e29:	eb a7                	jmp    801dd2 <vprintfmt+0x70>
  801e2b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801e2e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801e35:	eb 9b                	jmp    801dd2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801e37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801e3b:	79 95                	jns    801dd2 <vprintfmt+0x70>
  801e3d:	eb 8b                	jmp    801dca <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801e3f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e40:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801e43:	eb 8d                	jmp    801dd2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801e45:	8b 45 14             	mov    0x14(%ebp),%eax
  801e48:	8d 50 04             	lea    0x4(%eax),%edx
  801e4b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e52:	8b 00                	mov    (%eax),%eax
  801e54:	89 04 24             	mov    %eax,(%esp)
  801e57:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e5a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e5d:	e9 23 ff ff ff       	jmp    801d85 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e62:	8b 45 14             	mov    0x14(%ebp),%eax
  801e65:	8d 50 04             	lea    0x4(%eax),%edx
  801e68:	89 55 14             	mov    %edx,0x14(%ebp)
  801e6b:	8b 00                	mov    (%eax),%eax
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	79 02                	jns    801e73 <vprintfmt+0x111>
  801e71:	f7 d8                	neg    %eax
  801e73:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e75:	83 f8 11             	cmp    $0x11,%eax
  801e78:	7f 0b                	jg     801e85 <vprintfmt+0x123>
  801e7a:	8b 04 85 40 29 80 00 	mov    0x802940(,%eax,4),%eax
  801e81:	85 c0                	test   %eax,%eax
  801e83:	75 23                	jne    801ea8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801e85:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e89:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  801e90:	00 
  801e91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e95:	8b 45 08             	mov    0x8(%ebp),%eax
  801e98:	89 04 24             	mov    %eax,(%esp)
  801e9b:	e8 9a fe ff ff       	call   801d3a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ea0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801ea3:	e9 dd fe ff ff       	jmp    801d85 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801ea8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eac:	c7 44 24 08 05 26 80 	movl   $0x802605,0x8(%esp)
  801eb3:	00 
  801eb4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  801ebb:	89 14 24             	mov    %edx,(%esp)
  801ebe:	e8 77 fe ff ff       	call   801d3a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ec3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ec6:	e9 ba fe ff ff       	jmp    801d85 <vprintfmt+0x23>
  801ecb:	89 f9                	mov    %edi,%ecx
  801ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ed3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed6:	8d 50 04             	lea    0x4(%eax),%edx
  801ed9:	89 55 14             	mov    %edx,0x14(%ebp)
  801edc:	8b 30                	mov    (%eax),%esi
  801ede:	85 f6                	test   %esi,%esi
  801ee0:	75 05                	jne    801ee7 <vprintfmt+0x185>
				p = "(null)";
  801ee2:	be b8 26 80 00       	mov    $0x8026b8,%esi
			if (width > 0 && padc != '-')
  801ee7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801eeb:	0f 8e 84 00 00 00    	jle    801f75 <vprintfmt+0x213>
  801ef1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801ef5:	74 7e                	je     801f75 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801ef7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801efb:	89 34 24             	mov    %esi,(%esp)
  801efe:	e8 67 e2 ff ff       	call   80016a <strnlen>
  801f03:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801f06:	29 c2                	sub    %eax,%edx
  801f08:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801f0b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801f0f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801f12:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801f15:	89 de                	mov    %ebx,%esi
  801f17:	89 d3                	mov    %edx,%ebx
  801f19:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f1b:	eb 0b                	jmp    801f28 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801f1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f21:	89 3c 24             	mov    %edi,(%esp)
  801f24:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f27:	4b                   	dec    %ebx
  801f28:	85 db                	test   %ebx,%ebx
  801f2a:	7f f1                	jg     801f1d <vprintfmt+0x1bb>
  801f2c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801f2f:	89 f3                	mov    %esi,%ebx
  801f31:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f37:	85 c0                	test   %eax,%eax
  801f39:	79 05                	jns    801f40 <vprintfmt+0x1de>
  801f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f40:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f43:	29 c2                	sub    %eax,%edx
  801f45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801f48:	eb 2b                	jmp    801f75 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801f4a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f4e:	74 18                	je     801f68 <vprintfmt+0x206>
  801f50:	8d 50 e0             	lea    -0x20(%eax),%edx
  801f53:	83 fa 5e             	cmp    $0x5e,%edx
  801f56:	76 10                	jbe    801f68 <vprintfmt+0x206>
					putch('?', putdat);
  801f58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f5c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801f63:	ff 55 08             	call   *0x8(%ebp)
  801f66:	eb 0a                	jmp    801f72 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801f68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f6c:	89 04 24             	mov    %eax,(%esp)
  801f6f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f72:	ff 4d e4             	decl   -0x1c(%ebp)
  801f75:	0f be 06             	movsbl (%esi),%eax
  801f78:	46                   	inc    %esi
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	74 21                	je     801f9e <vprintfmt+0x23c>
  801f7d:	85 ff                	test   %edi,%edi
  801f7f:	78 c9                	js     801f4a <vprintfmt+0x1e8>
  801f81:	4f                   	dec    %edi
  801f82:	79 c6                	jns    801f4a <vprintfmt+0x1e8>
  801f84:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f87:	89 de                	mov    %ebx,%esi
  801f89:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801f8c:	eb 18                	jmp    801fa6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f92:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801f99:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f9b:	4b                   	dec    %ebx
  801f9c:	eb 08                	jmp    801fa6 <vprintfmt+0x244>
  801f9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa1:	89 de                	mov    %ebx,%esi
  801fa3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801fa6:	85 db                	test   %ebx,%ebx
  801fa8:	7f e4                	jg     801f8e <vprintfmt+0x22c>
  801faa:	89 7d 08             	mov    %edi,0x8(%ebp)
  801fad:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801faf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801fb2:	e9 ce fd ff ff       	jmp    801d85 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801fb7:	83 f9 01             	cmp    $0x1,%ecx
  801fba:	7e 10                	jle    801fcc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801fbc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fbf:	8d 50 08             	lea    0x8(%eax),%edx
  801fc2:	89 55 14             	mov    %edx,0x14(%ebp)
  801fc5:	8b 30                	mov    (%eax),%esi
  801fc7:	8b 78 04             	mov    0x4(%eax),%edi
  801fca:	eb 26                	jmp    801ff2 <vprintfmt+0x290>
	else if (lflag)
  801fcc:	85 c9                	test   %ecx,%ecx
  801fce:	74 12                	je     801fe2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801fd0:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd3:	8d 50 04             	lea    0x4(%eax),%edx
  801fd6:	89 55 14             	mov    %edx,0x14(%ebp)
  801fd9:	8b 30                	mov    (%eax),%esi
  801fdb:	89 f7                	mov    %esi,%edi
  801fdd:	c1 ff 1f             	sar    $0x1f,%edi
  801fe0:	eb 10                	jmp    801ff2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801fe2:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe5:	8d 50 04             	lea    0x4(%eax),%edx
  801fe8:	89 55 14             	mov    %edx,0x14(%ebp)
  801feb:	8b 30                	mov    (%eax),%esi
  801fed:	89 f7                	mov    %esi,%edi
  801fef:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ff2:	85 ff                	test   %edi,%edi
  801ff4:	78 0a                	js     802000 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ff6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801ffb:	e9 8c 00 00 00       	jmp    80208c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  802000:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802004:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80200b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80200e:	f7 de                	neg    %esi
  802010:	83 d7 00             	adc    $0x0,%edi
  802013:	f7 df                	neg    %edi
			}
			base = 10;
  802015:	b8 0a 00 00 00       	mov    $0xa,%eax
  80201a:	eb 70                	jmp    80208c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80201c:	89 ca                	mov    %ecx,%edx
  80201e:	8d 45 14             	lea    0x14(%ebp),%eax
  802021:	e8 c0 fc ff ff       	call   801ce6 <getuint>
  802026:	89 c6                	mov    %eax,%esi
  802028:	89 d7                	mov    %edx,%edi
			base = 10;
  80202a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80202f:	eb 5b                	jmp    80208c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  802031:	89 ca                	mov    %ecx,%edx
  802033:	8d 45 14             	lea    0x14(%ebp),%eax
  802036:	e8 ab fc ff ff       	call   801ce6 <getuint>
  80203b:	89 c6                	mov    %eax,%esi
  80203d:	89 d7                	mov    %edx,%edi
			base = 8;
  80203f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  802044:	eb 46                	jmp    80208c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  802046:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80204a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802051:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802054:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802058:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80205f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802062:	8b 45 14             	mov    0x14(%ebp),%eax
  802065:	8d 50 04             	lea    0x4(%eax),%edx
  802068:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80206b:	8b 30                	mov    (%eax),%esi
  80206d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802072:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  802077:	eb 13                	jmp    80208c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802079:	89 ca                	mov    %ecx,%edx
  80207b:	8d 45 14             	lea    0x14(%ebp),%eax
  80207e:	e8 63 fc ff ff       	call   801ce6 <getuint>
  802083:	89 c6                	mov    %eax,%esi
  802085:	89 d7                	mov    %edx,%edi
			base = 16;
  802087:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80208c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  802090:	89 54 24 10          	mov    %edx,0x10(%esp)
  802094:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802097:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80209b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209f:	89 34 24             	mov    %esi,(%esp)
  8020a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020a6:	89 da                	mov    %ebx,%edx
  8020a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ab:	e8 6c fb ff ff       	call   801c1c <printnum>
			break;
  8020b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8020b3:	e9 cd fc ff ff       	jmp    801d85 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020bc:	89 04 24             	mov    %eax,(%esp)
  8020bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020c5:	e9 bb fc ff ff       	jmp    801d85 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8020d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020d8:	eb 01                	jmp    8020db <vprintfmt+0x379>
  8020da:	4e                   	dec    %esi
  8020db:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8020df:	75 f9                	jne    8020da <vprintfmt+0x378>
  8020e1:	e9 9f fc ff ff       	jmp    801d85 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8020e6:	83 c4 4c             	add    $0x4c,%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5e                   	pop    %esi
  8020eb:	5f                   	pop    %edi
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 28             	sub    $0x28,%esp
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020fd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802101:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802104:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80210b:	85 c0                	test   %eax,%eax
  80210d:	74 30                	je     80213f <vsnprintf+0x51>
  80210f:	85 d2                	test   %edx,%edx
  802111:	7e 33                	jle    802146 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802113:	8b 45 14             	mov    0x14(%ebp),%eax
  802116:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211a:	8b 45 10             	mov    0x10(%ebp),%eax
  80211d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802121:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802124:	89 44 24 04          	mov    %eax,0x4(%esp)
  802128:	c7 04 24 20 1d 80 00 	movl   $0x801d20,(%esp)
  80212f:	e8 2e fc ff ff       	call   801d62 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802134:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802137:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	eb 0c                	jmp    80214b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80213f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802144:	eb 05                	jmp    80214b <vsnprintf+0x5d>
  802146:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802153:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215a:	8b 45 10             	mov    0x10(%ebp),%eax
  80215d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802161:	8b 45 0c             	mov    0xc(%ebp),%eax
  802164:	89 44 24 04          	mov    %eax,0x4(%esp)
  802168:	8b 45 08             	mov    0x8(%ebp),%eax
  80216b:	89 04 24             	mov    %eax,(%esp)
  80216e:	e8 7b ff ff ff       	call   8020ee <vsnprintf>
	va_end(ap);

	return rc;
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    
  802175:	00 00                	add    %al,(%eax)
	...

00802178 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	56                   	push   %esi
  80217c:	53                   	push   %ebx
  80217d:	83 ec 10             	sub    $0x10,%esp
  802180:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802183:	8b 45 0c             	mov    0xc(%ebp),%eax
  802186:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802189:	85 c0                	test   %eax,%eax
  80218b:	75 05                	jne    802192 <ipc_recv+0x1a>
  80218d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802192:	89 04 24             	mov    %eax,(%esp)
  802195:	e8 f5 e5 ff ff       	call   80078f <sys_ipc_recv>
	if (from_env_store != NULL)
  80219a:	85 db                	test   %ebx,%ebx
  80219c:	74 0b                	je     8021a9 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80219e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021a4:	8b 52 74             	mov    0x74(%edx),%edx
  8021a7:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8021a9:	85 f6                	test   %esi,%esi
  8021ab:	74 0b                	je     8021b8 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8021ad:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021b3:	8b 52 78             	mov    0x78(%edx),%edx
  8021b6:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	79 16                	jns    8021d2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8021bc:	85 db                	test   %ebx,%ebx
  8021be:	74 06                	je     8021c6 <ipc_recv+0x4e>
			*from_env_store = 0;
  8021c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8021c6:	85 f6                	test   %esi,%esi
  8021c8:	74 10                	je     8021da <ipc_recv+0x62>
			*perm_store = 0;
  8021ca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021d0:	eb 08                	jmp    8021da <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8021d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8021d7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	57                   	push   %edi
  8021e5:	56                   	push   %esi
  8021e6:	53                   	push   %ebx
  8021e7:	83 ec 1c             	sub    $0x1c,%esp
  8021ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8021f3:	eb 2a                	jmp    80221f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8021f5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021f8:	74 20                	je     80221a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8021fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fe:	c7 44 24 08 a8 29 80 	movl   $0x8029a8,0x8(%esp)
  802205:	00 
  802206:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80220d:	00 
  80220e:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  802215:	e8 ee f8 ff ff       	call   801b08 <_panic>
		sys_yield();
  80221a:	e8 3b e3 ff ff       	call   80055a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80221f:	85 db                	test   %ebx,%ebx
  802221:	75 07                	jne    80222a <ipc_send+0x49>
  802223:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802228:	eb 02                	jmp    80222c <ipc_send+0x4b>
  80222a:	89 d8                	mov    %ebx,%eax
  80222c:	8b 55 14             	mov    0x14(%ebp),%edx
  80222f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802233:	89 44 24 08          	mov    %eax,0x8(%esp)
  802237:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80223b:	89 34 24             	mov    %esi,(%esp)
  80223e:	e8 29 e5 ff ff       	call   80076c <sys_ipc_try_send>
  802243:	85 c0                	test   %eax,%eax
  802245:	78 ae                	js     8021f5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802247:	83 c4 1c             	add    $0x1c,%esp
  80224a:	5b                   	pop    %ebx
  80224b:	5e                   	pop    %esi
  80224c:	5f                   	pop    %edi
  80224d:	5d                   	pop    %ebp
  80224e:	c3                   	ret    

0080224f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802255:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80225a:	89 c2                	mov    %eax,%edx
  80225c:	c1 e2 07             	shl    $0x7,%edx
  80225f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802265:	8b 52 50             	mov    0x50(%edx),%edx
  802268:	39 ca                	cmp    %ecx,%edx
  80226a:	75 0d                	jne    802279 <ipc_find_env+0x2a>
			return envs[i].env_id;
  80226c:	c1 e0 07             	shl    $0x7,%eax
  80226f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802274:	8b 40 40             	mov    0x40(%eax),%eax
  802277:	eb 0c                	jmp    802285 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802279:	40                   	inc    %eax
  80227a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80227f:	75 d9                	jne    80225a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802281:	66 b8 00 00          	mov    $0x0,%ax
}
  802285:	5d                   	pop    %ebp
  802286:	c3                   	ret    
	...

00802288 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80228e:	89 c2                	mov    %eax,%edx
  802290:	c1 ea 16             	shr    $0x16,%edx
  802293:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80229a:	f6 c2 01             	test   $0x1,%dl
  80229d:	74 1e                	je     8022bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80229f:	c1 e8 0c             	shr    $0xc,%eax
  8022a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022a9:	a8 01                	test   $0x1,%al
  8022ab:	74 17                	je     8022c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022ad:	c1 e8 0c             	shr    $0xc,%eax
  8022b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022b7:	ef 
  8022b8:	0f b7 c0             	movzwl %ax,%eax
  8022bb:	eb 0c                	jmp    8022c9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c2:	eb 05                	jmp    8022c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    
	...

008022cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022cc:	55                   	push   %ebp
  8022cd:	57                   	push   %edi
  8022ce:	56                   	push   %esi
  8022cf:	83 ec 10             	sub    $0x10,%esp
  8022d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8022e2:	89 cd                	mov    %ecx,%ebp
  8022e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022e8:	85 c0                	test   %eax,%eax
  8022ea:	75 2c                	jne    802318 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8022ec:	39 f9                	cmp    %edi,%ecx
  8022ee:	77 68                	ja     802358 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022f0:	85 c9                	test   %ecx,%ecx
  8022f2:	75 0b                	jne    8022ff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f9:	31 d2                	xor    %edx,%edx
  8022fb:	f7 f1                	div    %ecx
  8022fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022ff:	31 d2                	xor    %edx,%edx
  802301:	89 f8                	mov    %edi,%eax
  802303:	f7 f1                	div    %ecx
  802305:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802307:	89 f0                	mov    %esi,%eax
  802309:	f7 f1                	div    %ecx
  80230b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80230d:	89 f0                	mov    %esi,%eax
  80230f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802311:	83 c4 10             	add    $0x10,%esp
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802318:	39 f8                	cmp    %edi,%eax
  80231a:	77 2c                	ja     802348 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80231c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80231f:	83 f6 1f             	xor    $0x1f,%esi
  802322:	75 4c                	jne    802370 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802324:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802326:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80232b:	72 0a                	jb     802337 <__udivdi3+0x6b>
  80232d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802331:	0f 87 ad 00 00 00    	ja     8023e4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802337:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80233c:	89 f0                	mov    %esi,%eax
  80233e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	5e                   	pop    %esi
  802344:	5f                   	pop    %edi
  802345:	5d                   	pop    %ebp
  802346:	c3                   	ret    
  802347:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802348:	31 ff                	xor    %edi,%edi
  80234a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80234c:	89 f0                	mov    %esi,%eax
  80234e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802350:	83 c4 10             	add    $0x10,%esp
  802353:	5e                   	pop    %esi
  802354:	5f                   	pop    %edi
  802355:	5d                   	pop    %ebp
  802356:	c3                   	ret    
  802357:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802358:	89 fa                	mov    %edi,%edx
  80235a:	89 f0                	mov    %esi,%eax
  80235c:	f7 f1                	div    %ecx
  80235e:	89 c6                	mov    %eax,%esi
  802360:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802362:	89 f0                	mov    %esi,%eax
  802364:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802366:	83 c4 10             	add    $0x10,%esp
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802370:	89 f1                	mov    %esi,%ecx
  802372:	d3 e0                	shl    %cl,%eax
  802374:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802378:	b8 20 00 00 00       	mov    $0x20,%eax
  80237d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80237f:	89 ea                	mov    %ebp,%edx
  802381:	88 c1                	mov    %al,%cl
  802383:	d3 ea                	shr    %cl,%edx
  802385:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802389:	09 ca                	or     %ecx,%edx
  80238b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80238f:	89 f1                	mov    %esi,%ecx
  802391:	d3 e5                	shl    %cl,%ebp
  802393:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802397:	89 fd                	mov    %edi,%ebp
  802399:	88 c1                	mov    %al,%cl
  80239b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80239d:	89 fa                	mov    %edi,%edx
  80239f:	89 f1                	mov    %esi,%ecx
  8023a1:	d3 e2                	shl    %cl,%edx
  8023a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023a7:	88 c1                	mov    %al,%cl
  8023a9:	d3 ef                	shr    %cl,%edi
  8023ab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023ad:	89 f8                	mov    %edi,%eax
  8023af:	89 ea                	mov    %ebp,%edx
  8023b1:	f7 74 24 08          	divl   0x8(%esp)
  8023b5:	89 d1                	mov    %edx,%ecx
  8023b7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023b9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023bd:	39 d1                	cmp    %edx,%ecx
  8023bf:	72 17                	jb     8023d8 <__udivdi3+0x10c>
  8023c1:	74 09                	je     8023cc <__udivdi3+0x100>
  8023c3:	89 fe                	mov    %edi,%esi
  8023c5:	31 ff                	xor    %edi,%edi
  8023c7:	e9 41 ff ff ff       	jmp    80230d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023d0:	89 f1                	mov    %esi,%ecx
  8023d2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023d4:	39 c2                	cmp    %eax,%edx
  8023d6:	73 eb                	jae    8023c3 <__udivdi3+0xf7>
		{
		  q0--;
  8023d8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023db:	31 ff                	xor    %edi,%edi
  8023dd:	e9 2b ff ff ff       	jmp    80230d <__udivdi3+0x41>
  8023e2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023e4:	31 f6                	xor    %esi,%esi
  8023e6:	e9 22 ff ff ff       	jmp    80230d <__udivdi3+0x41>
	...

008023ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8023ec:	55                   	push   %ebp
  8023ed:	57                   	push   %edi
  8023ee:	56                   	push   %esi
  8023ef:	83 ec 20             	sub    $0x20,%esp
  8023f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802402:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802406:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80240a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80240c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80240e:	85 ed                	test   %ebp,%ebp
  802410:	75 16                	jne    802428 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802412:	39 f1                	cmp    %esi,%ecx
  802414:	0f 86 a6 00 00 00    	jbe    8024c0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80241a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80241c:	89 d0                	mov    %edx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802420:	83 c4 20             	add    $0x20,%esp
  802423:	5e                   	pop    %esi
  802424:	5f                   	pop    %edi
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    
  802427:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802428:	39 f5                	cmp    %esi,%ebp
  80242a:	0f 87 ac 00 00 00    	ja     8024dc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802430:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802433:	83 f0 1f             	xor    $0x1f,%eax
  802436:	89 44 24 10          	mov    %eax,0x10(%esp)
  80243a:	0f 84 a8 00 00 00    	je     8024e8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802440:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802444:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802446:	bf 20 00 00 00       	mov    $0x20,%edi
  80244b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80244f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802453:	89 f9                	mov    %edi,%ecx
  802455:	d3 e8                	shr    %cl,%eax
  802457:	09 e8                	or     %ebp,%eax
  802459:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80245d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802461:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802465:	d3 e0                	shl    %cl,%eax
  802467:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80246b:	89 f2                	mov    %esi,%edx
  80246d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80246f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802473:	d3 e0                	shl    %cl,%eax
  802475:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802479:	8b 44 24 14          	mov    0x14(%esp),%eax
  80247d:	89 f9                	mov    %edi,%ecx
  80247f:	d3 e8                	shr    %cl,%eax
  802481:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802483:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802485:	89 f2                	mov    %esi,%edx
  802487:	f7 74 24 18          	divl   0x18(%esp)
  80248b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80248d:	f7 64 24 0c          	mull   0xc(%esp)
  802491:	89 c5                	mov    %eax,%ebp
  802493:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802495:	39 d6                	cmp    %edx,%esi
  802497:	72 67                	jb     802500 <__umoddi3+0x114>
  802499:	74 75                	je     802510 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80249b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80249f:	29 e8                	sub    %ebp,%eax
  8024a1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024a7:	d3 e8                	shr    %cl,%eax
  8024a9:	89 f2                	mov    %esi,%edx
  8024ab:	89 f9                	mov    %edi,%ecx
  8024ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024af:	09 d0                	or     %edx,%eax
  8024b1:	89 f2                	mov    %esi,%edx
  8024b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024b7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024b9:	83 c4 20             	add    $0x20,%esp
  8024bc:	5e                   	pop    %esi
  8024bd:	5f                   	pop    %edi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024c0:	85 c9                	test   %ecx,%ecx
  8024c2:	75 0b                	jne    8024cf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c9:	31 d2                	xor    %edx,%edx
  8024cb:	f7 f1                	div    %ecx
  8024cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024cf:	89 f0                	mov    %esi,%eax
  8024d1:	31 d2                	xor    %edx,%edx
  8024d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024d5:	89 f8                	mov    %edi,%eax
  8024d7:	e9 3e ff ff ff       	jmp    80241a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024de:	83 c4 20             	add    $0x20,%esp
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024e8:	39 f5                	cmp    %esi,%ebp
  8024ea:	72 04                	jb     8024f0 <__umoddi3+0x104>
  8024ec:	39 f9                	cmp    %edi,%ecx
  8024ee:	77 06                	ja     8024f6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	29 cf                	sub    %ecx,%edi
  8024f4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8024f6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024f8:	83 c4 20             	add    $0x20,%esp
  8024fb:	5e                   	pop    %esi
  8024fc:	5f                   	pop    %edi
  8024fd:	5d                   	pop    %ebp
  8024fe:	c3                   	ret    
  8024ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802500:	89 d1                	mov    %edx,%ecx
  802502:	89 c5                	mov    %eax,%ebp
  802504:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802508:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80250c:	eb 8d                	jmp    80249b <__umoddi3+0xaf>
  80250e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802510:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802514:	72 ea                	jb     802500 <__umoddi3+0x114>
  802516:	89 f1                	mov    %esi,%ecx
  802518:	eb 81                	jmp    80249b <__umoddi3+0xaf>
