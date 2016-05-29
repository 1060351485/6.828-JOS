
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 e7 04 00 00       	call   800518 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800045:	e8 ca 05 00 00       	call   800614 <cprintf>
	exit();
  80004a:	e8 11 05 00 00       	call   800560 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

void umain(int argc, char **argv)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 5c             	sub    $0x5c,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  80005a:	c7 04 24 44 29 80 00 	movl   $0x802944,(%esp)
  800061:	e8 ae 05 00 00       	call   800614 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800066:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  80006d:	e8 69 04 00 00       	call   8004db <inet_addr>
  800072:	89 44 24 08          	mov    %eax,0x8(%esp)
  800076:	c7 44 24 04 54 29 80 	movl   $0x802954,0x4(%esp)
  80007d:	00 
  80007e:	c7 04 24 5e 29 80 00 	movl   $0x80295e,(%esp)
  800085:	e8 8a 05 00 00       	call   800614 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80008a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800099:	00 
  80009a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a1:	e8 9d 1c 00 00       	call   801d43 <socket>
  8000a6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	79 0a                	jns    8000b7 <umain+0x66>
		die("Failed to create socket");
  8000ad:	b8 73 29 80 00       	mov    $0x802973,%eax
  8000b2:	e8 7d ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  8000b7:	c7 04 24 8b 29 80 00 	movl   $0x80298b,(%esp)
  8000be:	e8 51 05 00 00       	call   800614 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 10 0c 00 00       	call   800cee <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000de:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e2:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  8000e9:	e8 ed 03 00 00       	call   8004db <inet_addr>
  8000ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f1:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f8:	e8 90 01 00 00       	call   80028d <htons>
  8000fd:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  800101:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  800108:	e8 07 05 00 00       	call   800614 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800114:	00 
  800115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800119:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 d2 1b 00 00       	call   801cf6 <connect>
  800124:	85 c0                	test   %eax,%eax
  800126:	79 0a                	jns    800132 <umain+0xe1>
		die("Failed to connect with server");
  800128:	b8 b7 29 80 00       	mov    $0x8029b7,%eax
  80012d:	e8 02 ff ff ff       	call   800034 <die>

	cprintf("connected to server\n");
  800132:	c7 04 24 d5 29 80 00 	movl   $0x8029d5,(%esp)
  800139:	e8 d6 04 00 00       	call   800614 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80013e:	a1 00 30 80 00       	mov    0x803000,%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 41 0a 00 00       	call   800b8c <strlen>
  80014b:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80014e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800152:	a1 00 30 80 00       	mov    0x803000,%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 2b 15 00 00       	call   801691 <write>
  800166:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  800169:	74 0a                	je     800175 <umain+0x124>
		die("Mismatch in number of sent bytes");
  80016b:	b8 04 2a 80 00       	mov    $0x802a04,%eax
  800170:	e8 bf fe ff ff       	call   800034 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 ea 29 80 00 	movl   $0x8029ea,(%esp)
  80017c:	e8 93 04 00 00       	call   800614 <cprintf>
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800181:	bf 00 00 00 00       	mov    $0x0,%edi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800186:	8d 75 b8             	lea    -0x48(%ebp),%esi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800189:	eb 36                	jmp    8001c1 <umain+0x170>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018b:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800192:	00 
  800193:	89 74 24 04          	mov    %esi,0x4(%esp)
  800197:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80019a:	89 04 24             	mov    %eax,(%esp)
  80019d:	e8 14 14 00 00       	call   8015b6 <read>
  8001a2:	89 c3                	mov    %eax,%ebx
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7f 0a                	jg     8001b2 <umain+0x161>
			die("Failed to receive bytes from server");
  8001a8:	b8 28 2a 80 00       	mov    $0x802a28,%eax
  8001ad:	e8 82 fe ff ff       	call   800034 <die>
		}
		received += bytes;
  8001b2:	01 df                	add    %ebx,%edi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b4:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  8001b9:	89 34 24             	mov    %esi,(%esp)
  8001bc:	e8 53 04 00 00       	call   800614 <cprintf>
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  8001c1:	39 7d b0             	cmp    %edi,-0x50(%ebp)
  8001c4:	77 c5                	ja     80018b <umain+0x13a>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001c6:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  8001cd:	e8 42 04 00 00       	call   800614 <cprintf>

	close(sock);
  8001d2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 75 12 00 00       	call   801452 <close>
}
  8001dd:	83 c4 5c             	add    $0x5c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    
  8001e5:	00 00                	add    %al,(%eax)
	...

008001e8 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8001f7:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001fb:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001fe:	c7 45 dc 00 40 80 00 	movl   $0x804000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800205:	b2 00                	mov    $0x0,%dl
  800207:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80020a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80020d:	8a 00                	mov    (%eax),%al
  80020f:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  800212:	0f b6 c0             	movzbl %al,%eax
  800215:	8d 34 80             	lea    (%eax,%eax,4),%esi
  800218:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  80021b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80021e:	66 c1 e8 0b          	shr    $0xb,%ax
  800222:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800225:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  800227:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80022a:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  80022d:	d1 e7                	shl    %edi
  80022f:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  800232:	89 f9                	mov    %edi,%ecx
  800234:	28 cb                	sub    %cl,%bl
  800236:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800238:	8d 4f 30             	lea    0x30(%edi),%ecx
  80023b:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  80023f:	42                   	inc    %edx
    } while(*ap);
  800240:	84 c0                	test   %al,%al
  800242:	75 c6                	jne    80020a <inet_ntoa+0x22>
  800244:	88 d0                	mov    %dl,%al
  800246:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800249:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80024c:	eb 0b                	jmp    800259 <inet_ntoa+0x71>
    while(i--)
  80024e:	48                   	dec    %eax
      *rp++ = inv[i];
  80024f:	0f b6 f0             	movzbl %al,%esi
  800252:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  800256:	88 19                	mov    %bl,(%ecx)
  800258:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800259:	84 c0                	test   %al,%al
  80025b:	75 f1                	jne    80024e <inet_ntoa+0x66>
  80025d:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  800260:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800263:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  800266:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800269:	fe 45 e3             	incb   -0x1d(%ebp)
  80026c:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  800270:	77 0b                	ja     80027d <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  800272:	42                   	inc    %edx
  800273:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  800276:	ff 45 d8             	incl   -0x28(%ebp)
  800279:	88 c2                	mov    %al,%dl
  80027b:	eb 8d                	jmp    80020a <inet_ntoa+0x22>
  }
  *--rp = 0;
  80027d:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  800280:	b8 00 40 80 00       	mov    $0x804000,%eax
  800285:	83 c4 1c             	add    $0x1c,%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	66 c1 c0 08          	rol    $0x8,%ax
}
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80029f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	e8 e2 ff ff ff       	call   80028d <htons>
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002b3:	89 d1                	mov    %edx,%ecx
  8002b5:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002b8:	89 d0                	mov    %edx,%eax
  8002ba:	c1 e0 18             	shl    $0x18,%eax
  8002bd:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002bf:	89 d1                	mov    %edx,%ecx
  8002c1:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002c7:	c1 e1 08             	shl    $0x8,%ecx
  8002ca:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8002cc:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002d2:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002d5:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	57                   	push   %edi
  8002dd:	56                   	push   %esi
  8002de:	53                   	push   %ebx
  8002df:	83 ec 24             	sub    $0x24,%esp
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002e5:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002e8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8002eb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8002ee:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8002f1:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002f4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f7:	80 f9 09             	cmp    $0x9,%cl
  8002fa:	0f 87 8f 01 00 00    	ja     80048f <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800300:	83 fa 30             	cmp    $0x30,%edx
  800303:	75 28                	jne    80032d <inet_aton+0x54>
      c = *++cp;
  800305:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800309:	83 fa 78             	cmp    $0x78,%edx
  80030c:	74 0f                	je     80031d <inet_aton+0x44>
  80030e:	83 fa 58             	cmp    $0x58,%edx
  800311:	74 0a                	je     80031d <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800313:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800314:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80031b:	eb 17                	jmp    800334 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80031d:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800321:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800324:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  80032b:	eb 07                	jmp    800334 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  80032d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800334:	40                   	inc    %eax
  800335:	be 00 00 00 00       	mov    $0x0,%esi
  80033a:	eb 01                	jmp    80033d <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80033c:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  80033d:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800340:	88 d1                	mov    %dl,%cl
  800342:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800345:	80 fb 09             	cmp    $0x9,%bl
  800348:	77 0d                	ja     800357 <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  80034a:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80034e:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800352:	0f be 10             	movsbl (%eax),%edx
  800355:	eb e5                	jmp    80033c <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  800357:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80035b:	75 30                	jne    80038d <inet_aton+0xb4>
  80035d:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800360:	88 5d da             	mov    %bl,-0x26(%ebp)
  800363:	80 fb 05             	cmp    $0x5,%bl
  800366:	76 08                	jbe    800370 <inet_aton+0x97>
  800368:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80036b:	80 fb 05             	cmp    $0x5,%bl
  80036e:	77 23                	ja     800393 <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800370:	89 f1                	mov    %esi,%ecx
  800372:	c1 e1 04             	shl    $0x4,%ecx
  800375:	8d 72 0a             	lea    0xa(%edx),%esi
  800378:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  80037c:	19 d2                	sbb    %edx,%edx
  80037e:	83 e2 20             	and    $0x20,%edx
  800381:	83 c2 41             	add    $0x41,%edx
  800384:	29 d6                	sub    %edx,%esi
  800386:	09 ce                	or     %ecx,%esi
        c = *++cp;
  800388:	0f be 10             	movsbl (%eax),%edx
  80038b:	eb af                	jmp    80033c <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  80038d:	89 d0                	mov    %edx,%eax
  80038f:	89 f3                	mov    %esi,%ebx
  800391:	eb 04                	jmp    800397 <inet_aton+0xbe>
  800393:	89 d0                	mov    %edx,%eax
  800395:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  800397:	83 f8 2e             	cmp    $0x2e,%eax
  80039a:	75 23                	jne    8003bf <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80039c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  8003a2:	0f 83 ee 00 00 00    	jae    800496 <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  8003a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ab:	89 1a                	mov    %ebx,(%edx)
  8003ad:	83 c2 04             	add    $0x4,%edx
  8003b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  8003b3:	8d 47 01             	lea    0x1(%edi),%eax
  8003b6:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  8003ba:	e9 35 ff ff ff       	jmp    8002f4 <inet_aton+0x1b>
  8003bf:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8003c1:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003c3:	85 d2                	test   %edx,%edx
  8003c5:	74 33                	je     8003fa <inet_aton+0x121>
  8003c7:	80 f9 1f             	cmp    $0x1f,%cl
  8003ca:	0f 86 cd 00 00 00    	jbe    80049d <inet_aton+0x1c4>
  8003d0:	84 d2                	test   %dl,%dl
  8003d2:	0f 88 cc 00 00 00    	js     8004a4 <inet_aton+0x1cb>
  8003d8:	83 fa 20             	cmp    $0x20,%edx
  8003db:	74 1d                	je     8003fa <inet_aton+0x121>
  8003dd:	83 fa 0c             	cmp    $0xc,%edx
  8003e0:	74 18                	je     8003fa <inet_aton+0x121>
  8003e2:	83 fa 0a             	cmp    $0xa,%edx
  8003e5:	74 13                	je     8003fa <inet_aton+0x121>
  8003e7:	83 fa 0d             	cmp    $0xd,%edx
  8003ea:	74 0e                	je     8003fa <inet_aton+0x121>
  8003ec:	83 fa 09             	cmp    $0x9,%edx
  8003ef:	74 09                	je     8003fa <inet_aton+0x121>
  8003f1:	83 fa 0b             	cmp    $0xb,%edx
  8003f4:	0f 85 b1 00 00 00    	jne    8004ab <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  8003fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8003fd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800400:	29 d1                	sub    %edx,%ecx
  800402:	89 ca                	mov    %ecx,%edx
  800404:	c1 fa 02             	sar    $0x2,%edx
  800407:	42                   	inc    %edx
  switch (n) {
  800408:	83 fa 02             	cmp    $0x2,%edx
  80040b:	74 1b                	je     800428 <inet_aton+0x14f>
  80040d:	83 fa 02             	cmp    $0x2,%edx
  800410:	7f 0a                	jg     80041c <inet_aton+0x143>
  800412:	85 d2                	test   %edx,%edx
  800414:	0f 84 98 00 00 00    	je     8004b2 <inet_aton+0x1d9>
  80041a:	eb 59                	jmp    800475 <inet_aton+0x19c>
  80041c:	83 fa 03             	cmp    $0x3,%edx
  80041f:	74 1c                	je     80043d <inet_aton+0x164>
  800421:	83 fa 04             	cmp    $0x4,%edx
  800424:	75 4f                	jne    800475 <inet_aton+0x19c>
  800426:	eb 2e                	jmp    800456 <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800428:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  80042d:	0f 87 86 00 00 00    	ja     8004b9 <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  800433:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800436:	c1 e3 18             	shl    $0x18,%ebx
  800439:	09 c3                	or     %eax,%ebx
    break;
  80043b:	eb 38                	jmp    800475 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80043d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  800442:	77 7c                	ja     8004c0 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800444:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800447:	c1 e3 10             	shl    $0x10,%ebx
  80044a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044d:	c1 e2 18             	shl    $0x18,%edx
  800450:	09 d3                	or     %edx,%ebx
  800452:	09 c3                	or     %eax,%ebx
    break;
  800454:	eb 1f                	jmp    800475 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800456:	3d ff 00 00 00       	cmp    $0xff,%eax
  80045b:	77 6a                	ja     8004c7 <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80045d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800460:	c1 e3 10             	shl    $0x10,%ebx
  800463:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800466:	c1 e2 18             	shl    $0x18,%edx
  800469:	09 d3                	or     %edx,%ebx
  80046b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80046e:	c1 e2 08             	shl    $0x8,%edx
  800471:	09 d3                	or     %edx,%ebx
  800473:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  800475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800479:	74 53                	je     8004ce <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  80047b:	89 1c 24             	mov    %ebx,(%esp)
  80047e:	e8 2a fe ff ff       	call   8002ad <htonl>
  800483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800486:	89 03                	mov    %eax,(%ebx)
  return (1);
  800488:	b8 01 00 00 00       	mov    $0x1,%eax
  80048d:	eb 44                	jmp    8004d3 <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	eb 3d                	jmp    8004d3 <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	eb 36                	jmp    8004d3 <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	eb 2f                	jmp    8004d3 <inet_aton+0x1fa>
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	eb 28                	jmp    8004d3 <inet_aton+0x1fa>
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	eb 21                	jmp    8004d3 <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	eb 1a                	jmp    8004d3 <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	eb 13                	jmp    8004d3 <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	eb 0c                	jmp    8004d3 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cc:	eb 05                	jmp    8004d3 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8004ce:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004d3:	83 c4 24             	add    $0x24,%esp
  8004d6:	5b                   	pop    %ebx
  8004d7:	5e                   	pop    %esi
  8004d8:	5f                   	pop    %edi
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8004e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	e8 e6 fd ff ff       	call   8002d9 <inet_aton>
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	74 05                	je     8004fc <inet_addr+0x21>
    return (val.s_addr);
  8004f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8004fa:	eb 05                	jmp    800501 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  8004fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800501:	c9                   	leave  
  800502:	c3                   	ret    

00800503 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 99 fd ff ff       	call   8002ad <htonl>
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    
	...

00800518 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	56                   	push   %esi
  80051c:	53                   	push   %ebx
  80051d:	83 ec 10             	sub    $0x10,%esp
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800526:	e8 48 0a 00 00       	call   800f73 <sys_getenvid>
  80052b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800530:	c1 e0 07             	shl    $0x7,%eax
  800533:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800538:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80053d:	85 f6                	test   %esi,%esi
  80053f:	7e 07                	jle    800548 <libmain+0x30>
		binaryname = argv[0];
  800541:	8b 03                	mov    (%ebx),%eax
  800543:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054c:	89 34 24             	mov    %esi,(%esp)
  80054f:	e8 fd fa ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  800554:	e8 07 00 00 00       	call   800560 <exit>
}
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	5b                   	pop    %ebx
  80055d:	5e                   	pop    %esi
  80055e:	5d                   	pop    %ebp
  80055f:	c3                   	ret    

00800560 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800566:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80056d:	e8 af 09 00 00       	call   800f21 <sys_env_destroy>
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	53                   	push   %ebx
  800578:	83 ec 14             	sub    $0x14,%esp
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80057e:	8b 03                	mov    (%ebx),%eax
  800580:	8b 55 08             	mov    0x8(%ebp),%edx
  800583:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800587:	40                   	inc    %eax
  800588:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80058a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80058f:	75 19                	jne    8005aa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800591:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800598:	00 
  800599:	8d 43 08             	lea    0x8(%ebx),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	e8 40 09 00 00       	call   800ee4 <sys_cputs>
		b->idx = 0;
  8005a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8005aa:	ff 43 04             	incl   0x4(%ebx)
}
  8005ad:	83 c4 14             	add    $0x14,%esp
  8005b0:	5b                   	pop    %ebx
  8005b1:	5d                   	pop    %ebp
  8005b2:	c3                   	ret    

008005b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005c3:	00 00 00 
	b.cnt = 0;
  8005c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e8:	c7 04 24 74 05 80 00 	movl   $0x800574,(%esp)
  8005ef:	e8 82 01 00 00       	call   800776 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005f4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	e8 d8 08 00 00       	call   800ee4 <sys_cputs>

	return b.cnt;
}
  80060c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800612:	c9                   	leave  
  800613:	c3                   	ret    

00800614 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80061a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80061d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800621:	8b 45 08             	mov    0x8(%ebp),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	e8 87 ff ff ff       	call   8005b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80062c:	c9                   	leave  
  80062d:	c3                   	ret    
	...

00800630 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	57                   	push   %edi
  800634:	56                   	push   %esi
  800635:	53                   	push   %ebx
  800636:	83 ec 3c             	sub    $0x3c,%esp
  800639:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063c:	89 d7                	mov    %edx,%edi
  80063e:	8b 45 08             	mov    0x8(%ebp),%eax
  800641:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800644:	8b 45 0c             	mov    0xc(%ebp),%eax
  800647:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80064d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800650:	85 c0                	test   %eax,%eax
  800652:	75 08                	jne    80065c <printnum+0x2c>
  800654:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800657:	39 45 10             	cmp    %eax,0x10(%ebp)
  80065a:	77 57                	ja     8006b3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80065c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800660:	4b                   	dec    %ebx
  800661:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800665:	8b 45 10             	mov    0x10(%ebp),%eax
  800668:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800670:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800674:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80067b:	00 
  80067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80067f:	89 04 24             	mov    %eax,(%esp)
  800682:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800685:	89 44 24 04          	mov    %eax,0x4(%esp)
  800689:	e8 5e 20 00 00       	call   8026ec <__udivdi3>
  80068e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800692:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800696:	89 04 24             	mov    %eax,(%esp)
  800699:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069d:	89 fa                	mov    %edi,%edx
  80069f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a2:	e8 89 ff ff ff       	call   800630 <printnum>
  8006a7:	eb 0f                	jmp    8006b8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ad:	89 34 24             	mov    %esi,(%esp)
  8006b0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006b3:	4b                   	dec    %ebx
  8006b4:	85 db                	test   %ebx,%ebx
  8006b6:	7f f1                	jg     8006a9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006ce:	00 
  8006cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006d2:	89 04 24             	mov    %eax,(%esp)
  8006d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	e8 2b 21 00 00       	call   80280c <__umoddi3>
  8006e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e5:	0f be 80 56 2a 80 00 	movsbl 0x802a56(%eax),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8006f2:	83 c4 3c             	add    $0x3c,%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006fd:	83 fa 01             	cmp    $0x1,%edx
  800700:	7e 0e                	jle    800710 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800702:	8b 10                	mov    (%eax),%edx
  800704:	8d 4a 08             	lea    0x8(%edx),%ecx
  800707:	89 08                	mov    %ecx,(%eax)
  800709:	8b 02                	mov    (%edx),%eax
  80070b:	8b 52 04             	mov    0x4(%edx),%edx
  80070e:	eb 22                	jmp    800732 <getuint+0x38>
	else if (lflag)
  800710:	85 d2                	test   %edx,%edx
  800712:	74 10                	je     800724 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800714:	8b 10                	mov    (%eax),%edx
  800716:	8d 4a 04             	lea    0x4(%edx),%ecx
  800719:	89 08                	mov    %ecx,(%eax)
  80071b:	8b 02                	mov    (%edx),%eax
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	eb 0e                	jmp    800732 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800724:	8b 10                	mov    (%eax),%edx
  800726:	8d 4a 04             	lea    0x4(%edx),%ecx
  800729:	89 08                	mov    %ecx,(%eax)
  80072b:	8b 02                	mov    (%edx),%eax
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80073a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	3b 50 04             	cmp    0x4(%eax),%edx
  800742:	73 08                	jae    80074c <sprintputch+0x18>
		*b->buf++ = ch;
  800744:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800747:	88 0a                	mov    %cl,(%edx)
  800749:	42                   	inc    %edx
  80074a:	89 10                	mov    %edx,(%eax)
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800757:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075b:	8b 45 10             	mov    0x10(%ebp),%eax
  80075e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	8b 45 08             	mov    0x8(%ebp),%eax
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	e8 02 00 00 00       	call   800776 <vprintfmt>
	va_end(ap);
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	57                   	push   %edi
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	83 ec 4c             	sub    $0x4c,%esp
  80077f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800782:	8b 75 10             	mov    0x10(%ebp),%esi
  800785:	eb 12                	jmp    800799 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800787:	85 c0                	test   %eax,%eax
  800789:	0f 84 6b 03 00 00    	je     800afa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80078f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800799:	0f b6 06             	movzbl (%esi),%eax
  80079c:	46                   	inc    %esi
  80079d:	83 f8 25             	cmp    $0x25,%eax
  8007a0:	75 e5                	jne    800787 <vprintfmt+0x11>
  8007a2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8007b2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007be:	eb 26                	jmp    8007e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007c3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007c7:	eb 1d                	jmp    8007e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007cc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007d0:	eb 14                	jmp    8007e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007dc:	eb 08                	jmp    8007e6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	0f b6 06             	movzbl (%esi),%eax
  8007e9:	8d 56 01             	lea    0x1(%esi),%edx
  8007ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007ef:	8a 16                	mov    (%esi),%dl
  8007f1:	83 ea 23             	sub    $0x23,%edx
  8007f4:	80 fa 55             	cmp    $0x55,%dl
  8007f7:	0f 87 e1 02 00 00    	ja     800ade <vprintfmt+0x368>
  8007fd:	0f b6 d2             	movzbl %dl,%edx
  800800:	ff 24 95 a0 2b 80 00 	jmp    *0x802ba0(,%edx,4)
  800807:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80080a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80080f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800812:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800816:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800819:	8d 50 d0             	lea    -0x30(%eax),%edx
  80081c:	83 fa 09             	cmp    $0x9,%edx
  80081f:	77 2a                	ja     80084b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800821:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800822:	eb eb                	jmp    80080f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)
  80082d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800832:	eb 17                	jmp    80084b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800834:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800838:	78 98                	js     8007d2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80083d:	eb a7                	jmp    8007e6 <vprintfmt+0x70>
  80083f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800842:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800849:	eb 9b                	jmp    8007e6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80084b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80084f:	79 95                	jns    8007e6 <vprintfmt+0x70>
  800851:	eb 8b                	jmp    8007de <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800853:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800854:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800857:	eb 8d                	jmp    8007e6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8d 50 04             	lea    0x4(%eax),%edx
  80085f:	89 55 14             	mov    %edx,0x14(%ebp)
  800862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800866:	8b 00                	mov    (%eax),%eax
  800868:	89 04 24             	mov    %eax,(%esp)
  80086b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800871:	e9 23 ff ff ff       	jmp    800799 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
  80087f:	8b 00                	mov    (%eax),%eax
  800881:	85 c0                	test   %eax,%eax
  800883:	79 02                	jns    800887 <vprintfmt+0x111>
  800885:	f7 d8                	neg    %eax
  800887:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800889:	83 f8 11             	cmp    $0x11,%eax
  80088c:	7f 0b                	jg     800899 <vprintfmt+0x123>
  80088e:	8b 04 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%eax
  800895:	85 c0                	test   %eax,%eax
  800897:	75 23                	jne    8008bc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800899:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80089d:	c7 44 24 08 6e 2a 80 	movl   $0x802a6e,0x8(%esp)
  8008a4:	00 
  8008a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	e8 9a fe ff ff       	call   80074e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008b7:	e9 dd fe ff ff       	jmp    800799 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c0:	c7 44 24 08 3d 2e 80 	movl   $0x802e3d,0x8(%esp)
  8008c7:	00 
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008cf:	89 14 24             	mov    %edx,(%esp)
  8008d2:	e8 77 fe ff ff       	call   80074e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008da:	e9 ba fe ff ff       	jmp    800799 <vprintfmt+0x23>
  8008df:	89 f9                	mov    %edi,%ecx
  8008e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ea:	8d 50 04             	lea    0x4(%eax),%edx
  8008ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f0:	8b 30                	mov    (%eax),%esi
  8008f2:	85 f6                	test   %esi,%esi
  8008f4:	75 05                	jne    8008fb <vprintfmt+0x185>
				p = "(null)";
  8008f6:	be 67 2a 80 00       	mov    $0x802a67,%esi
			if (width > 0 && padc != '-')
  8008fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008ff:	0f 8e 84 00 00 00    	jle    800989 <vprintfmt+0x213>
  800905:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800909:	74 7e                	je     800989 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80090b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80090f:	89 34 24             	mov    %esi,(%esp)
  800912:	e8 8b 02 00 00       	call   800ba2 <strnlen>
  800917:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80091a:	29 c2                	sub    %eax,%edx
  80091c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80091f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800923:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800926:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800929:	89 de                	mov    %ebx,%esi
  80092b:	89 d3                	mov    %edx,%ebx
  80092d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80092f:	eb 0b                	jmp    80093c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800931:	89 74 24 04          	mov    %esi,0x4(%esp)
  800935:	89 3c 24             	mov    %edi,(%esp)
  800938:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80093b:	4b                   	dec    %ebx
  80093c:	85 db                	test   %ebx,%ebx
  80093e:	7f f1                	jg     800931 <vprintfmt+0x1bb>
  800940:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800943:	89 f3                	mov    %esi,%ebx
  800945:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80094b:	85 c0                	test   %eax,%eax
  80094d:	79 05                	jns    800954 <vprintfmt+0x1de>
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800957:	29 c2                	sub    %eax,%edx
  800959:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80095c:	eb 2b                	jmp    800989 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80095e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800962:	74 18                	je     80097c <vprintfmt+0x206>
  800964:	8d 50 e0             	lea    -0x20(%eax),%edx
  800967:	83 fa 5e             	cmp    $0x5e,%edx
  80096a:	76 10                	jbe    80097c <vprintfmt+0x206>
					putch('?', putdat);
  80096c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800970:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800977:	ff 55 08             	call   *0x8(%ebp)
  80097a:	eb 0a                	jmp    800986 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80097c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800986:	ff 4d e4             	decl   -0x1c(%ebp)
  800989:	0f be 06             	movsbl (%esi),%eax
  80098c:	46                   	inc    %esi
  80098d:	85 c0                	test   %eax,%eax
  80098f:	74 21                	je     8009b2 <vprintfmt+0x23c>
  800991:	85 ff                	test   %edi,%edi
  800993:	78 c9                	js     80095e <vprintfmt+0x1e8>
  800995:	4f                   	dec    %edi
  800996:	79 c6                	jns    80095e <vprintfmt+0x1e8>
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	89 de                	mov    %ebx,%esi
  80099d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009a0:	eb 18                	jmp    8009ba <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009ad:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009af:	4b                   	dec    %ebx
  8009b0:	eb 08                	jmp    8009ba <vprintfmt+0x244>
  8009b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b5:	89 de                	mov    %ebx,%esi
  8009b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009ba:	85 db                	test   %ebx,%ebx
  8009bc:	7f e4                	jg     8009a2 <vprintfmt+0x22c>
  8009be:	89 7d 08             	mov    %edi,0x8(%ebp)
  8009c1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009c6:	e9 ce fd ff ff       	jmp    800799 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009cb:	83 f9 01             	cmp    $0x1,%ecx
  8009ce:	7e 10                	jle    8009e0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8009d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d3:	8d 50 08             	lea    0x8(%eax),%edx
  8009d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d9:	8b 30                	mov    (%eax),%esi
  8009db:	8b 78 04             	mov    0x4(%eax),%edi
  8009de:	eb 26                	jmp    800a06 <vprintfmt+0x290>
	else if (lflag)
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	74 12                	je     8009f6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8009e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ed:	8b 30                	mov    (%eax),%esi
  8009ef:	89 f7                	mov    %esi,%edi
  8009f1:	c1 ff 1f             	sar    $0x1f,%edi
  8009f4:	eb 10                	jmp    800a06 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8009f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f9:	8d 50 04             	lea    0x4(%eax),%edx
  8009fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ff:	8b 30                	mov    (%eax),%esi
  800a01:	89 f7                	mov    %esi,%edi
  800a03:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a06:	85 ff                	test   %edi,%edi
  800a08:	78 0a                	js     800a14 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0f:	e9 8c 00 00 00       	jmp    800aa0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a18:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a1f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a22:	f7 de                	neg    %esi
  800a24:	83 d7 00             	adc    $0x0,%edi
  800a27:	f7 df                	neg    %edi
			}
			base = 10;
  800a29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a2e:	eb 70                	jmp    800aa0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a30:	89 ca                	mov    %ecx,%edx
  800a32:	8d 45 14             	lea    0x14(%ebp),%eax
  800a35:	e8 c0 fc ff ff       	call   8006fa <getuint>
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	89 d7                	mov    %edx,%edi
			base = 10;
  800a3e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a43:	eb 5b                	jmp    800aa0 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800a45:	89 ca                	mov    %ecx,%edx
  800a47:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4a:	e8 ab fc ff ff       	call   8006fa <getuint>
  800a4f:	89 c6                	mov    %eax,%esi
  800a51:	89 d7                	mov    %edx,%edi
			base = 8;
  800a53:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a58:	eb 46                	jmp    800aa0 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a65:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a73:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 50 04             	lea    0x4(%eax),%edx
  800a7c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a7f:	8b 30                	mov    (%eax),%esi
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a86:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a8b:	eb 13                	jmp    800aa0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a8d:	89 ca                	mov    %ecx,%edx
  800a8f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a92:	e8 63 fc ff ff       	call   8006fa <getuint>
  800a97:	89 c6                	mov    %eax,%esi
  800a99:	89 d7                	mov    %edx,%edi
			base = 16;
  800a9b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800aa4:	89 54 24 10          	mov    %edx,0x10(%esp)
  800aa8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab3:	89 34 24             	mov    %esi,(%esp)
  800ab6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aba:	89 da                	mov    %ebx,%edx
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	e8 6c fb ff ff       	call   800630 <printnum>
			break;
  800ac4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ac7:	e9 cd fc ff ff       	jmp    800799 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800acc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad0:	89 04 24             	mov    %eax,(%esp)
  800ad3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ad9:	e9 bb fc ff ff       	jmp    800799 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ade:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aec:	eb 01                	jmp    800aef <vprintfmt+0x379>
  800aee:	4e                   	dec    %esi
  800aef:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800af3:	75 f9                	jne    800aee <vprintfmt+0x378>
  800af5:	e9 9f fc ff ff       	jmp    800799 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800afa:	83 c4 4c             	add    $0x4c,%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	83 ec 28             	sub    $0x28,%esp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b11:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b15:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	74 30                	je     800b53 <vsnprintf+0x51>
  800b23:	85 d2                	test   %edx,%edx
  800b25:	7e 33                	jle    800b5a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b27:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3c:	c7 04 24 34 07 80 00 	movl   $0x800734,(%esp)
  800b43:	e8 2e fc ff ff       	call   800776 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b51:	eb 0c                	jmp    800b5f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b58:	eb 05                	jmp    800b5f <vsnprintf+0x5d>
  800b5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b67:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	89 04 24             	mov    %eax,(%esp)
  800b82:	e8 7b ff ff ff       	call   800b02 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    
  800b89:	00 00                	add    %al,(%eax)
	...

00800b8c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	eb 01                	jmp    800b9a <strlen+0xe>
		n++;
  800b99:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b9a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b9e:	75 f9                	jne    800b99 <strlen+0xd>
		n++;
	return n;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	eb 01                	jmp    800bb3 <strnlen+0x11>
		n++;
  800bb2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bb3:	39 d0                	cmp    %edx,%eax
  800bb5:	74 06                	je     800bbd <strnlen+0x1b>
  800bb7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bbb:	75 f5                	jne    800bb2 <strnlen+0x10>
		n++;
	return n;
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800bd1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd4:	42                   	inc    %edx
  800bd5:	84 c9                	test   %cl,%cl
  800bd7:	75 f5                	jne    800bce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 08             	sub    $0x8,%esp
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be6:	89 1c 24             	mov    %ebx,(%esp)
  800be9:	e8 9e ff ff ff       	call   800b8c <strlen>
	strcpy(dst + len, src);
  800bee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf5:	01 d8                	add    %ebx,%eax
  800bf7:	89 04 24             	mov    %eax,(%esp)
  800bfa:	e8 c0 ff ff ff       	call   800bbf <strcpy>
	return dst;
}
  800bff:	89 d8                	mov    %ebx,%eax
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c12:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1a:	eb 0c                	jmp    800c28 <strncpy+0x21>
		*dst++ = *src;
  800c1c:	8a 1a                	mov    (%edx),%bl
  800c1e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c21:	80 3a 01             	cmpb   $0x1,(%edx)
  800c24:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c27:	41                   	inc    %ecx
  800c28:	39 f1                	cmp    %esi,%ecx
  800c2a:	75 f0                	jne    800c1c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	8b 75 08             	mov    0x8(%ebp),%esi
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3e:	85 d2                	test   %edx,%edx
  800c40:	75 0a                	jne    800c4c <strlcpy+0x1c>
  800c42:	89 f0                	mov    %esi,%eax
  800c44:	eb 1a                	jmp    800c60 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c46:	88 18                	mov    %bl,(%eax)
  800c48:	40                   	inc    %eax
  800c49:	41                   	inc    %ecx
  800c4a:	eb 02                	jmp    800c4e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c4c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800c4e:	4a                   	dec    %edx
  800c4f:	74 0a                	je     800c5b <strlcpy+0x2b>
  800c51:	8a 19                	mov    (%ecx),%bl
  800c53:	84 db                	test   %bl,%bl
  800c55:	75 ef                	jne    800c46 <strlcpy+0x16>
  800c57:	89 c2                	mov    %eax,%edx
  800c59:	eb 02                	jmp    800c5d <strlcpy+0x2d>
  800c5b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c5d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c60:	29 f0                	sub    %esi,%eax
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6f:	eb 02                	jmp    800c73 <strcmp+0xd>
		p++, q++;
  800c71:	41                   	inc    %ecx
  800c72:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c73:	8a 01                	mov    (%ecx),%al
  800c75:	84 c0                	test   %al,%al
  800c77:	74 04                	je     800c7d <strcmp+0x17>
  800c79:	3a 02                	cmp    (%edx),%al
  800c7b:	74 f4                	je     800c71 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c7d:	0f b6 c0             	movzbl %al,%eax
  800c80:	0f b6 12             	movzbl (%edx),%edx
  800c83:	29 d0                	sub    %edx,%eax
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	53                   	push   %ebx
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c94:	eb 03                	jmp    800c99 <strncmp+0x12>
		n--, p++, q++;
  800c96:	4a                   	dec    %edx
  800c97:	40                   	inc    %eax
  800c98:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c99:	85 d2                	test   %edx,%edx
  800c9b:	74 14                	je     800cb1 <strncmp+0x2a>
  800c9d:	8a 18                	mov    (%eax),%bl
  800c9f:	84 db                	test   %bl,%bl
  800ca1:	74 04                	je     800ca7 <strncmp+0x20>
  800ca3:	3a 19                	cmp    (%ecx),%bl
  800ca5:	74 ef                	je     800c96 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca7:	0f b6 00             	movzbl (%eax),%eax
  800caa:	0f b6 11             	movzbl (%ecx),%edx
  800cad:	29 d0                	sub    %edx,%eax
  800caf:	eb 05                	jmp    800cb6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cc2:	eb 05                	jmp    800cc9 <strchr+0x10>
		if (*s == c)
  800cc4:	38 ca                	cmp    %cl,%dl
  800cc6:	74 0c                	je     800cd4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cc8:	40                   	inc    %eax
  800cc9:	8a 10                	mov    (%eax),%dl
  800ccb:	84 d2                	test   %dl,%dl
  800ccd:	75 f5                	jne    800cc4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cdf:	eb 05                	jmp    800ce6 <strfind+0x10>
		if (*s == c)
  800ce1:	38 ca                	cmp    %cl,%dl
  800ce3:	74 07                	je     800cec <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ce5:	40                   	inc    %eax
  800ce6:	8a 10                	mov    (%eax),%dl
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	75 f5                	jne    800ce1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cfd:	85 c9                	test   %ecx,%ecx
  800cff:	74 30                	je     800d31 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d07:	75 25                	jne    800d2e <memset+0x40>
  800d09:	f6 c1 03             	test   $0x3,%cl
  800d0c:	75 20                	jne    800d2e <memset+0x40>
		c &= 0xFF;
  800d0e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d11:	89 d3                	mov    %edx,%ebx
  800d13:	c1 e3 08             	shl    $0x8,%ebx
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	c1 e6 18             	shl    $0x18,%esi
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	c1 e0 10             	shl    $0x10,%eax
  800d20:	09 f0                	or     %esi,%eax
  800d22:	09 d0                	or     %edx,%eax
  800d24:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d26:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d29:	fc                   	cld    
  800d2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800d2c:	eb 03                	jmp    800d31 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d2e:	fc                   	cld    
  800d2f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d31:	89 f8                	mov    %edi,%eax
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d46:	39 c6                	cmp    %eax,%esi
  800d48:	73 34                	jae    800d7e <memmove+0x46>
  800d4a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d4d:	39 d0                	cmp    %edx,%eax
  800d4f:	73 2d                	jae    800d7e <memmove+0x46>
		s += n;
		d += n;
  800d51:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d54:	f6 c2 03             	test   $0x3,%dl
  800d57:	75 1b                	jne    800d74 <memmove+0x3c>
  800d59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d5f:	75 13                	jne    800d74 <memmove+0x3c>
  800d61:	f6 c1 03             	test   $0x3,%cl
  800d64:	75 0e                	jne    800d74 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d66:	83 ef 04             	sub    $0x4,%edi
  800d69:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d6c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d6f:	fd                   	std    
  800d70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d72:	eb 07                	jmp    800d7b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d74:	4f                   	dec    %edi
  800d75:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d78:	fd                   	std    
  800d79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d7b:	fc                   	cld    
  800d7c:	eb 20                	jmp    800d9e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d84:	75 13                	jne    800d99 <memmove+0x61>
  800d86:	a8 03                	test   $0x3,%al
  800d88:	75 0f                	jne    800d99 <memmove+0x61>
  800d8a:	f6 c1 03             	test   $0x3,%cl
  800d8d:	75 0a                	jne    800d99 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d8f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d92:	89 c7                	mov    %eax,%edi
  800d94:	fc                   	cld    
  800d95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d97:	eb 05                	jmp    800d9e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d99:	89 c7                	mov    %eax,%edi
  800d9b:	fc                   	cld    
  800d9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	89 04 24             	mov    %eax,(%esp)
  800dbc:	e8 77 ff ff ff       	call   800d38 <memmove>
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	eb 16                	jmp    800def <memcmp+0x2c>
		if (*s1 != *s2)
  800dd9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ddc:	42                   	inc    %edx
  800ddd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800de1:	38 c8                	cmp    %cl,%al
  800de3:	74 0a                	je     800def <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800de5:	0f b6 c0             	movzbl %al,%eax
  800de8:	0f b6 c9             	movzbl %cl,%ecx
  800deb:	29 c8                	sub    %ecx,%eax
  800ded:	eb 09                	jmp    800df8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800def:	39 da                	cmp    %ebx,%edx
  800df1:	75 e6                	jne    800dd9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e0b:	eb 05                	jmp    800e12 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e0d:	38 08                	cmp    %cl,(%eax)
  800e0f:	74 05                	je     800e16 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e11:	40                   	inc    %eax
  800e12:	39 d0                	cmp    %edx,%eax
  800e14:	72 f7                	jb     800e0d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e24:	eb 01                	jmp    800e27 <strtol+0xf>
		s++;
  800e26:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e27:	8a 02                	mov    (%edx),%al
  800e29:	3c 20                	cmp    $0x20,%al
  800e2b:	74 f9                	je     800e26 <strtol+0xe>
  800e2d:	3c 09                	cmp    $0x9,%al
  800e2f:	74 f5                	je     800e26 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e31:	3c 2b                	cmp    $0x2b,%al
  800e33:	75 08                	jne    800e3d <strtol+0x25>
		s++;
  800e35:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e36:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3b:	eb 13                	jmp    800e50 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e3d:	3c 2d                	cmp    $0x2d,%al
  800e3f:	75 0a                	jne    800e4b <strtol+0x33>
		s++, neg = 1;
  800e41:	8d 52 01             	lea    0x1(%edx),%edx
  800e44:	bf 01 00 00 00       	mov    $0x1,%edi
  800e49:	eb 05                	jmp    800e50 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e50:	85 db                	test   %ebx,%ebx
  800e52:	74 05                	je     800e59 <strtol+0x41>
  800e54:	83 fb 10             	cmp    $0x10,%ebx
  800e57:	75 28                	jne    800e81 <strtol+0x69>
  800e59:	8a 02                	mov    (%edx),%al
  800e5b:	3c 30                	cmp    $0x30,%al
  800e5d:	75 10                	jne    800e6f <strtol+0x57>
  800e5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e63:	75 0a                	jne    800e6f <strtol+0x57>
		s += 2, base = 16;
  800e65:	83 c2 02             	add    $0x2,%edx
  800e68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e6d:	eb 12                	jmp    800e81 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800e6f:	85 db                	test   %ebx,%ebx
  800e71:	75 0e                	jne    800e81 <strtol+0x69>
  800e73:	3c 30                	cmp    $0x30,%al
  800e75:	75 05                	jne    800e7c <strtol+0x64>
		s++, base = 8;
  800e77:	42                   	inc    %edx
  800e78:	b3 08                	mov    $0x8,%bl
  800e7a:	eb 05                	jmp    800e81 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800e7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e88:	8a 0a                	mov    (%edx),%cl
  800e8a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e8d:	80 fb 09             	cmp    $0x9,%bl
  800e90:	77 08                	ja     800e9a <strtol+0x82>
			dig = *s - '0';
  800e92:	0f be c9             	movsbl %cl,%ecx
  800e95:	83 e9 30             	sub    $0x30,%ecx
  800e98:	eb 1e                	jmp    800eb8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800e9a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e9d:	80 fb 19             	cmp    $0x19,%bl
  800ea0:	77 08                	ja     800eaa <strtol+0x92>
			dig = *s - 'a' + 10;
  800ea2:	0f be c9             	movsbl %cl,%ecx
  800ea5:	83 e9 57             	sub    $0x57,%ecx
  800ea8:	eb 0e                	jmp    800eb8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800eaa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ead:	80 fb 19             	cmp    $0x19,%bl
  800eb0:	77 12                	ja     800ec4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800eb2:	0f be c9             	movsbl %cl,%ecx
  800eb5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eb8:	39 f1                	cmp    %esi,%ecx
  800eba:	7d 0c                	jge    800ec8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ebc:	42                   	inc    %edx
  800ebd:	0f af c6             	imul   %esi,%eax
  800ec0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ec2:	eb c4                	jmp    800e88 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ec4:	89 c1                	mov    %eax,%ecx
  800ec6:	eb 02                	jmp    800eca <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ec8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800eca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ece:	74 05                	je     800ed5 <strtol+0xbd>
		*endptr = (char *) s;
  800ed0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ed5:	85 ff                	test   %edi,%edi
  800ed7:	74 04                	je     800edd <strtol+0xc5>
  800ed9:	89 c8                	mov    %ecx,%eax
  800edb:	f7 d8                	neg    %eax
}
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
	...

00800ee4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 c3                	mov    %eax,%ebx
  800ef7:	89 c7                	mov    %eax,%edi
  800ef9:	89 c6                	mov    %eax,%esi
  800efb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f08:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f12:	89 d1                	mov    %edx,%ecx
  800f14:	89 d3                	mov    %edx,%ebx
  800f16:	89 d7                	mov    %edx,%edi
  800f18:	89 d6                	mov    %edx,%esi
  800f1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 cb                	mov    %ecx,%ebx
  800f39:	89 cf                	mov    %ecx,%edi
  800f3b:	89 ce                	mov    %ecx,%esi
  800f3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	7e 28                	jle    800f6b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f47:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  800f56:	00 
  800f57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5e:	00 
  800f5f:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  800f66:	e8 d5 15 00 00       	call   802540 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f6b:	83 c4 2c             	add    $0x2c,%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f83:	89 d1                	mov    %edx,%ecx
  800f85:	89 d3                	mov    %edx,%ebx
  800f87:	89 d7                	mov    %edx,%edi
  800f89:	89 d6                	mov    %edx,%esi
  800f8b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <sys_yield>:

void
sys_yield(void)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f98:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	89 d3                	mov    %edx,%ebx
  800fa6:	89 d7                	mov    %edx,%edi
  800fa8:	89 d6                	mov    %edx,%esi
  800faa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	be 00 00 00 00       	mov    $0x0,%esi
  800fbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800fc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fca:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcd:	89 f7                	mov    %esi,%edi
  800fcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 28                	jle    800ffd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  800ff8:	e8 43 15 00 00       	call   802540 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ffd:	83 c4 2c             	add    $0x2c,%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  80100e:	b8 05 00 00 00       	mov    $0x5,%eax
  801013:	8b 75 18             	mov    0x18(%ebp),%esi
  801016:	8b 7d 14             	mov    0x14(%ebp),%edi
  801019:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101f:	8b 55 08             	mov    0x8(%ebp),%edx
  801022:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	7e 28                	jle    801050 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801028:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  80104b:	e8 f0 14 00 00       	call   802540 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801050:	83 c4 2c             	add    $0x2c,%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
  801066:	b8 06 00 00 00       	mov    $0x6,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 df                	mov    %ebx,%edi
  801073:	89 de                	mov    %ebx,%esi
  801075:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	7e 28                	jle    8010a3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801086:	00 
  801087:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  80109e:	e8 9d 14 00 00       	call   802540 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010a3:	83 c4 2c             	add    $0x2c,%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8010be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c4:	89 df                	mov    %ebx,%edi
  8010c6:	89 de                	mov    %ebx,%esi
  8010c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	7e 28                	jle    8010f6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010d9:	00 
  8010da:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  8010e1:	00 
  8010e2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e9:	00 
  8010ea:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  8010f1:	e8 4a 14 00 00       	call   802540 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010f6:	83 c4 2c             	add    $0x2c,%esp
  8010f9:	5b                   	pop    %ebx
  8010fa:	5e                   	pop    %esi
  8010fb:	5f                   	pop    %edi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110c:	b8 09 00 00 00       	mov    $0x9,%eax
  801111:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	89 df                	mov    %ebx,%edi
  801119:	89 de                	mov    %ebx,%esi
  80111b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	7e 28                	jle    801149 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	89 44 24 10          	mov    %eax,0x10(%esp)
  801125:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80112c:	00 
  80112d:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  801144:	e8 f7 13 00 00       	call   802540 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801149:	83 c4 2c             	add    $0x2c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
  801157:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801164:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801167:	8b 55 08             	mov    0x8(%ebp),%edx
  80116a:	89 df                	mov    %ebx,%edi
  80116c:	89 de                	mov    %ebx,%esi
  80116e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801170:	85 c0                	test   %eax,%eax
  801172:	7e 28                	jle    80119c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801174:	89 44 24 10          	mov    %eax,0x10(%esp)
  801178:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80117f:	00 
  801180:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  801187:	00 
  801188:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80118f:	00 
  801190:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  801197:	e8 a4 13 00 00       	call   802540 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80119c:	83 c4 2c             	add    $0x2c,%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011aa:	be 00 00 00 00       	mov    $0x0,%esi
  8011af:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011d5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011da:	8b 55 08             	mov    0x8(%ebp),%edx
  8011dd:	89 cb                	mov    %ecx,%ebx
  8011df:	89 cf                	mov    %ecx,%edi
  8011e1:	89 ce                	mov    %ecx,%esi
  8011e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	7e 28                	jle    801211 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ed:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011f4:	00 
  8011f5:	c7 44 24 08 67 2d 80 	movl   $0x802d67,0x8(%esp)
  8011fc:	00 
  8011fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801204:	00 
  801205:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  80120c:	e8 2f 13 00 00       	call   802540 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801211:	83 c4 2c             	add    $0x2c,%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121f:	ba 00 00 00 00       	mov    $0x0,%edx
  801224:	b8 0e 00 00 00       	mov    $0xe,%eax
  801229:	89 d1                	mov    %edx,%ecx
  80122b:	89 d3                	mov    %edx,%ebx
  80122d:	89 d7                	mov    %edx,%edi
  80122f:	89 d6                	mov    %edx,%esi
  801231:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	57                   	push   %edi
  80123c:	56                   	push   %esi
  80123d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801243:	b8 10 00 00 00       	mov    $0x10,%eax
  801248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124b:	8b 55 08             	mov    0x8(%ebp),%edx
  80124e:	89 df                	mov    %ebx,%edi
  801250:	89 de                	mov    %ebx,%esi
  801252:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	57                   	push   %edi
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801264:	b8 0f 00 00 00       	mov    $0xf,%eax
  801269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126c:	8b 55 08             	mov    0x8(%ebp),%edx
  80126f:	89 df                	mov    %ebx,%edi
  801271:	89 de                	mov    %ebx,%esi
  801273:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	57                   	push   %edi
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801280:	b9 00 00 00 00       	mov    $0x0,%ecx
  801285:	b8 11 00 00 00       	mov    $0x11,%eax
  80128a:	8b 55 08             	mov    0x8(%ebp),%edx
  80128d:	89 cb                	mov    %ecx,%ebx
  80128f:	89 cf                	mov    %ecx,%edi
  801291:	89 ce                	mov    %ecx,%esi
  801293:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
	...

0080129c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129f:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b5:	89 04 24             	mov    %eax,(%esp)
  8012b8:	e8 df ff ff ff       	call   80129c <fd2num>
  8012bd:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012c2:	c1 e0 0c             	shl    $0xc,%eax
}
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	53                   	push   %ebx
  8012cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012d3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 16             	shr    $0x16,%edx
  8012da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e1:	f6 c2 01             	test   $0x1,%dl
  8012e4:	74 11                	je     8012f7 <fd_alloc+0x30>
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	c1 ea 0c             	shr    $0xc,%edx
  8012eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	75 09                	jne    801300 <fd_alloc+0x39>
			*fd_store = fd;
  8012f7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	eb 17                	jmp    801317 <fd_alloc+0x50>
  801300:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801305:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130a:	75 c7                	jne    8012d3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80130c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801312:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801317:	5b                   	pop    %ebx
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801320:	83 f8 1f             	cmp    $0x1f,%eax
  801323:	77 36                	ja     80135b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801325:	05 00 00 0d 00       	add    $0xd0000,%eax
  80132a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	c1 ea 16             	shr    $0x16,%edx
  801332:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801339:	f6 c2 01             	test   $0x1,%dl
  80133c:	74 24                	je     801362 <fd_lookup+0x48>
  80133e:	89 c2                	mov    %eax,%edx
  801340:	c1 ea 0c             	shr    $0xc,%edx
  801343:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134a:	f6 c2 01             	test   $0x1,%dl
  80134d:	74 1a                	je     801369 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80134f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801352:	89 02                	mov    %eax,(%edx)
	return 0;
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
  801359:	eb 13                	jmp    80136e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801360:	eb 0c                	jmp    80136e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801362:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801367:	eb 05                	jmp    80136e <fd_lookup+0x54>
  801369:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	53                   	push   %ebx
  801374:	83 ec 14             	sub    $0x14,%esp
  801377:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80137d:	ba 00 00 00 00       	mov    $0x0,%edx
  801382:	eb 0e                	jmp    801392 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801384:	39 08                	cmp    %ecx,(%eax)
  801386:	75 09                	jne    801391 <dev_lookup+0x21>
			*dev = devtab[i];
  801388:	89 03                	mov    %eax,(%ebx)
			return 0;
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
  80138f:	eb 33                	jmp    8013c4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801391:	42                   	inc    %edx
  801392:	8b 04 95 10 2e 80 00 	mov    0x802e10(,%edx,4),%eax
  801399:	85 c0                	test   %eax,%eax
  80139b:	75 e7                	jne    801384 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80139d:	a1 18 40 80 00       	mov    0x804018,%eax
  8013a2:	8b 40 48             	mov    0x48(%eax),%eax
  8013a5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ad:	c7 04 24 94 2d 80 00 	movl   $0x802d94,(%esp)
  8013b4:	e8 5b f2 ff ff       	call   800614 <cprintf>
	*dev = 0;
  8013b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c4:	83 c4 14             	add    $0x14,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 30             	sub    $0x30,%esp
  8013d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d5:	8a 45 0c             	mov    0xc(%ebp),%al
  8013d8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013db:	89 34 24             	mov    %esi,(%esp)
  8013de:	e8 b9 fe ff ff       	call   80129c <fd2num>
  8013e3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013ea:	89 04 24             	mov    %eax,(%esp)
  8013ed:	e8 28 ff ff ff       	call   80131a <fd_lookup>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 05                	js     8013fd <fd_close+0x33>
	    || fd != fd2)
  8013f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013fb:	74 0d                	je     80140a <fd_close+0x40>
		return (must_exist ? r : 0);
  8013fd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801401:	75 46                	jne    801449 <fd_close+0x7f>
  801403:	bb 00 00 00 00       	mov    $0x0,%ebx
  801408:	eb 3f                	jmp    801449 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	8b 06                	mov    (%esi),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 55 ff ff ff       	call   801370 <dev_lookup>
  80141b:	89 c3                	mov    %eax,%ebx
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 18                	js     801439 <fd_close+0x6f>
		if (dev->dev_close)
  801421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801424:	8b 40 10             	mov    0x10(%eax),%eax
  801427:	85 c0                	test   %eax,%eax
  801429:	74 09                	je     801434 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80142b:	89 34 24             	mov    %esi,(%esp)
  80142e:	ff d0                	call   *%eax
  801430:	89 c3                	mov    %eax,%ebx
  801432:	eb 05                	jmp    801439 <fd_close+0x6f>
		else
			r = 0;
  801434:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801439:	89 74 24 04          	mov    %esi,0x4(%esp)
  80143d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801444:	e8 0f fc ff ff       	call   801058 <sys_page_unmap>
	return r;
}
  801449:	89 d8                	mov    %ebx,%eax
  80144b:	83 c4 30             	add    $0x30,%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5e                   	pop    %esi
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145f:	8b 45 08             	mov    0x8(%ebp),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 b0 fe ff ff       	call   80131a <fd_lookup>
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 13                	js     801481 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80146e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801475:	00 
  801476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 49 ff ff ff       	call   8013ca <fd_close>
}
  801481:	c9                   	leave  
  801482:	c3                   	ret    

00801483 <close_all>:

void
close_all(void)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80148f:	89 1c 24             	mov    %ebx,(%esp)
  801492:	e8 bb ff ff ff       	call   801452 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801497:	43                   	inc    %ebx
  801498:	83 fb 20             	cmp    $0x20,%ebx
  80149b:	75 f2                	jne    80148f <close_all+0xc>
		close(i);
}
  80149d:	83 c4 14             	add    $0x14,%esp
  8014a0:	5b                   	pop    %ebx
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	57                   	push   %edi
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 4c             	sub    $0x4c,%esp
  8014ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	89 04 24             	mov    %eax,(%esp)
  8014bc:	e8 59 fe ff ff       	call   80131a <fd_lookup>
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	0f 88 e1 00 00 00    	js     8015ac <dup+0x109>
		return r;
	close(newfdnum);
  8014cb:	89 3c 24             	mov    %edi,(%esp)
  8014ce:	e8 7f ff ff ff       	call   801452 <close>

	newfd = INDEX2FD(newfdnum);
  8014d3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014d9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 c5 fd ff ff       	call   8012ac <fd2data>
  8014e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014e9:	89 34 24             	mov    %esi,(%esp)
  8014ec:	e8 bb fd ff ff       	call   8012ac <fd2data>
  8014f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f4:	89 d8                	mov    %ebx,%eax
  8014f6:	c1 e8 16             	shr    $0x16,%eax
  8014f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801500:	a8 01                	test   $0x1,%al
  801502:	74 46                	je     80154a <dup+0xa7>
  801504:	89 d8                	mov    %ebx,%eax
  801506:	c1 e8 0c             	shr    $0xc,%eax
  801509:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801510:	f6 c2 01             	test   $0x1,%dl
  801513:	74 35                	je     80154a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801515:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151c:	25 07 0e 00 00       	and    $0xe07,%eax
  801521:	89 44 24 10          	mov    %eax,0x10(%esp)
  801525:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801528:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801533:	00 
  801534:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801538:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153f:	e8 c1 fa ff ff       	call   801005 <sys_page_map>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 3b                	js     801585 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	c1 ea 0c             	shr    $0xc,%edx
  801552:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801559:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80155f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801563:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801567:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156e:	00 
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157a:	e8 86 fa ff ff       	call   801005 <sys_page_map>
  80157f:	89 c3                	mov    %eax,%ebx
  801581:	85 c0                	test   %eax,%eax
  801583:	79 25                	jns    8015aa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801585:	89 74 24 04          	mov    %esi,0x4(%esp)
  801589:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801590:	e8 c3 fa ff ff       	call   801058 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801595:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a3:	e8 b0 fa ff ff       	call   801058 <sys_page_unmap>
	return r;
  8015a8:	eb 02                	jmp    8015ac <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015aa:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015ac:	89 d8                	mov    %ebx,%eax
  8015ae:	83 c4 4c             	add    $0x4c,%esp
  8015b1:	5b                   	pop    %ebx
  8015b2:	5e                   	pop    %esi
  8015b3:	5f                   	pop    %edi
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 24             	sub    $0x24,%esp
  8015bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c7:	89 1c 24             	mov    %ebx,(%esp)
  8015ca:	e8 4b fd ff ff       	call   80131a <fd_lookup>
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 6d                	js     801640 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dd:	8b 00                	mov    (%eax),%eax
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	e8 89 fd ff ff       	call   801370 <dev_lookup>
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 55                	js     801640 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	8b 50 08             	mov    0x8(%eax),%edx
  8015f1:	83 e2 03             	and    $0x3,%edx
  8015f4:	83 fa 01             	cmp    $0x1,%edx
  8015f7:	75 23                	jne    80161c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f9:	a1 18 40 80 00       	mov    0x804018,%eax
  8015fe:	8b 40 48             	mov    0x48(%eax),%eax
  801601:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801605:	89 44 24 04          	mov    %eax,0x4(%esp)
  801609:	c7 04 24 d5 2d 80 00 	movl   $0x802dd5,(%esp)
  801610:	e8 ff ef ff ff       	call   800614 <cprintf>
		return -E_INVAL;
  801615:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161a:	eb 24                	jmp    801640 <read+0x8a>
	}
	if (!dev->dev_read)
  80161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161f:	8b 52 08             	mov    0x8(%edx),%edx
  801622:	85 d2                	test   %edx,%edx
  801624:	74 15                	je     80163b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801626:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801629:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80162d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801630:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	ff d2                	call   *%edx
  801639:	eb 05                	jmp    801640 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80163b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801640:	83 c4 24             	add    $0x24,%esp
  801643:	5b                   	pop    %ebx
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	83 ec 1c             	sub    $0x1c,%esp
  80164f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801652:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801655:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165a:	eb 23                	jmp    80167f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165c:	89 f0                	mov    %esi,%eax
  80165e:	29 d8                	sub    %ebx,%eax
  801660:	89 44 24 08          	mov    %eax,0x8(%esp)
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	01 d8                	add    %ebx,%eax
  801669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166d:	89 3c 24             	mov    %edi,(%esp)
  801670:	e8 41 ff ff ff       	call   8015b6 <read>
		if (m < 0)
  801675:	85 c0                	test   %eax,%eax
  801677:	78 10                	js     801689 <readn+0x43>
			return m;
		if (m == 0)
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 0a                	je     801687 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167d:	01 c3                	add    %eax,%ebx
  80167f:	39 f3                	cmp    %esi,%ebx
  801681:	72 d9                	jb     80165c <readn+0x16>
  801683:	89 d8                	mov    %ebx,%eax
  801685:	eb 02                	jmp    801689 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801687:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801689:	83 c4 1c             	add    $0x1c,%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5f                   	pop    %edi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 24             	sub    $0x24,%esp
  801698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	89 1c 24             	mov    %ebx,(%esp)
  8016a5:	e8 70 fc ff ff       	call   80131a <fd_lookup>
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 68                	js     801716 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	8b 00                	mov    (%eax),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 ae fc ff ff       	call   801370 <dev_lookup>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 50                	js     801716 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cd:	75 23                	jne    8016f2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cf:	a1 18 40 80 00       	mov    0x804018,%eax
  8016d4:	8b 40 48             	mov    0x48(%eax),%eax
  8016d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016df:	c7 04 24 f1 2d 80 00 	movl   $0x802df1,(%esp)
  8016e6:	e8 29 ef ff ff       	call   800614 <cprintf>
		return -E_INVAL;
  8016eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f0:	eb 24                	jmp    801716 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f8:	85 d2                	test   %edx,%edx
  8016fa:	74 15                	je     801711 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801706:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80170a:	89 04 24             	mov    %eax,(%esp)
  80170d:	ff d2                	call   *%edx
  80170f:	eb 05                	jmp    801716 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801711:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801716:	83 c4 24             	add    $0x24,%esp
  801719:	5b                   	pop    %ebx
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <seek>:

int
seek(int fdnum, off_t offset)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801722:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	89 04 24             	mov    %eax,(%esp)
  80172f:	e8 e6 fb ff ff       	call   80131a <fd_lookup>
  801734:	85 c0                	test   %eax,%eax
  801736:	78 0e                	js     801746 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801738:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80173b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801741:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 24             	sub    $0x24,%esp
  80174f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801752:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801755:	89 44 24 04          	mov    %eax,0x4(%esp)
  801759:	89 1c 24             	mov    %ebx,(%esp)
  80175c:	e8 b9 fb ff ff       	call   80131a <fd_lookup>
  801761:	85 c0                	test   %eax,%eax
  801763:	78 61                	js     8017c6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801765:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176f:	8b 00                	mov    (%eax),%eax
  801771:	89 04 24             	mov    %eax,(%esp)
  801774:	e8 f7 fb ff ff       	call   801370 <dev_lookup>
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 49                	js     8017c6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801780:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801784:	75 23                	jne    8017a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801786:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80178b:	8b 40 48             	mov    0x48(%eax),%eax
  80178e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801792:	89 44 24 04          	mov    %eax,0x4(%esp)
  801796:	c7 04 24 b4 2d 80 00 	movl   $0x802db4,(%esp)
  80179d:	e8 72 ee ff ff       	call   800614 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a7:	eb 1d                	jmp    8017c6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ac:	8b 52 18             	mov    0x18(%edx),%edx
  8017af:	85 d2                	test   %edx,%edx
  8017b1:	74 0e                	je     8017c1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	ff d2                	call   *%edx
  8017bf:	eb 05                	jmp    8017c6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c6:	83 c4 24             	add    $0x24,%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 24             	sub    $0x24,%esp
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 32 fb ff ff       	call   80131a <fd_lookup>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 52                	js     80183e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f6:	8b 00                	mov    (%eax),%eax
  8017f8:	89 04 24             	mov    %eax,(%esp)
  8017fb:	e8 70 fb ff ff       	call   801370 <dev_lookup>
  801800:	85 c0                	test   %eax,%eax
  801802:	78 3a                	js     80183e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801807:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180b:	74 2c                	je     801839 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801810:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801817:	00 00 00 
	stat->st_isdir = 0;
  80181a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801821:	00 00 00 
	stat->st_dev = dev;
  801824:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80182e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801831:	89 14 24             	mov    %edx,(%esp)
  801834:	ff 50 14             	call   *0x14(%eax)
  801837:	eb 05                	jmp    80183e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801839:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183e:	83 c4 24             	add    $0x24,%esp
  801841:	5b                   	pop    %ebx
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801853:	00 
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 2d 02 00 00       	call   801a8c <open>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	85 c0                	test   %eax,%eax
  801863:	78 1b                	js     801880 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	89 1c 24             	mov    %ebx,(%esp)
  80186f:	e8 58 ff ff ff       	call   8017cc <fstat>
  801874:	89 c6                	mov    %eax,%esi
	close(fd);
  801876:	89 1c 24             	mov    %ebx,(%esp)
  801879:	e8 d4 fb ff ff       	call   801452 <close>
	return r;
  80187e:	89 f3                	mov    %esi,%ebx
}
  801880:	89 d8                	mov    %ebx,%eax
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    
  801889:	00 00                	add    %al,(%eax)
	...

0080188c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
  801891:	83 ec 10             	sub    $0x10,%esp
  801894:	89 c3                	mov    %eax,%ebx
  801896:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801898:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  80189f:	75 11                	jne    8018b2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018a8:	e8 c2 0d 00 00       	call   80266f <ipc_find_env>
  8018ad:	a3 10 40 80 00       	mov    %eax,0x804010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018b9:	00 
  8018ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018c1:	00 
  8018c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c6:	a1 10 40 80 00       	mov    0x804010,%eax
  8018cb:	89 04 24             	mov    %eax,(%esp)
  8018ce:	e8 2e 0d 00 00       	call   802601 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018da:	00 
  8018db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e6:	e8 ad 0c 00 00       	call   802598 <ipc_recv>
}
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801903:	8b 45 0c             	mov    0xc(%ebp),%eax
  801906:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 02 00 00 00       	mov    $0x2,%eax
  801915:	e8 72 ff ff ff       	call   80188c <fsipc>
}
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	8b 40 0c             	mov    0xc(%eax),%eax
  801928:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
  801932:	b8 06 00 00 00       	mov    $0x6,%eax
  801937:	e8 50 ff ff ff       	call   80188c <fsipc>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 14             	sub    $0x14,%esp
  801945:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 40 0c             	mov    0xc(%eax),%eax
  80194e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801953:	ba 00 00 00 00       	mov    $0x0,%edx
  801958:	b8 05 00 00 00       	mov    $0x5,%eax
  80195d:	e8 2a ff ff ff       	call   80188c <fsipc>
  801962:	85 c0                	test   %eax,%eax
  801964:	78 2b                	js     801991 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801966:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80196d:	00 
  80196e:	89 1c 24             	mov    %ebx,(%esp)
  801971:	e8 49 f2 ff ff       	call   800bbf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801976:	a1 80 50 80 00       	mov    0x805080,%eax
  80197b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801981:	a1 84 50 80 00       	mov    0x805084,%eax
  801986:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80198c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801991:	83 c4 14             	add    $0x14,%esp
  801994:	5b                   	pop    %ebx
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    

00801997 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 18             	sub    $0x18,%esp
  80199d:	8b 55 10             	mov    0x10(%ebp),%edx
  8019a0:	89 d0                	mov    %edx,%eax
  8019a2:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8019a8:	76 05                	jbe    8019af <devfile_write+0x18>
  8019aa:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019af:	8b 55 08             	mov    0x8(%ebp),%edx
  8019b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8019b5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019bb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019d2:	e8 61 f3 ff ff       	call   800d38 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e1:	e8 a6 fe ff ff       	call   80188c <fsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 10             	sub    $0x10,%esp
  8019f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a04:	ba 00 00 00 00       	mov    $0x0,%edx
  801a09:	b8 03 00 00 00       	mov    $0x3,%eax
  801a0e:	e8 79 fe ff ff       	call   80188c <fsipc>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 6a                	js     801a83 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a19:	39 c6                	cmp    %eax,%esi
  801a1b:	73 24                	jae    801a41 <devfile_read+0x59>
  801a1d:	c7 44 24 0c 24 2e 80 	movl   $0x802e24,0xc(%esp)
  801a24:	00 
  801a25:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  801a2c:	00 
  801a2d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a34:	00 
  801a35:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  801a3c:	e8 ff 0a 00 00       	call   802540 <_panic>
	assert(r <= PGSIZE);
  801a41:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a46:	7e 24                	jle    801a6c <devfile_read+0x84>
  801a48:	c7 44 24 0c 4b 2e 80 	movl   $0x802e4b,0xc(%esp)
  801a4f:	00 
  801a50:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  801a57:	00 
  801a58:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a5f:	00 
  801a60:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  801a67:	e8 d4 0a 00 00       	call   802540 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a70:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a77:	00 
  801a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7b:	89 04 24             	mov    %eax,(%esp)
  801a7e:	e8 b5 f2 ff ff       	call   800d38 <memmove>
	return r;
}
  801a83:	89 d8                	mov    %ebx,%eax
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	5b                   	pop    %ebx
  801a89:	5e                   	pop    %esi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 20             	sub    $0x20,%esp
  801a94:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a97:	89 34 24             	mov    %esi,(%esp)
  801a9a:	e8 ed f0 ff ff       	call   800b8c <strlen>
  801a9f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa4:	7f 60                	jg     801b06 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 16 f8 ff ff       	call   8012c7 <fd_alloc>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 54                	js     801b0b <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801abb:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ac2:	e8 f8 f0 ff ff       	call   800bbf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801acf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad7:	e8 b0 fd ff ff       	call   80188c <fsipc>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 15                	jns    801af7 <open+0x6b>
		fd_close(fd, 0);
  801ae2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ae9:	00 
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	89 04 24             	mov    %eax,(%esp)
  801af0:	e8 d5 f8 ff ff       	call   8013ca <fd_close>
		return r;
  801af5:	eb 14                	jmp    801b0b <open+0x7f>
	}

	return fd2num(fd);
  801af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afa:	89 04 24             	mov    %eax,(%esp)
  801afd:	e8 9a f7 ff ff       	call   80129c <fd2num>
  801b02:	89 c3                	mov    %eax,%ebx
  801b04:	eb 05                	jmp    801b0b <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b06:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b0b:	89 d8                	mov    %ebx,%eax
  801b0d:	83 c4 20             	add    $0x20,%esp
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1f:	b8 08 00 00 00       	mov    $0x8,%eax
  801b24:	e8 63 fd ff ff       	call   80188c <fsipc>
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    
	...

00801b2c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b32:	c7 44 24 04 57 2e 80 	movl   $0x802e57,0x4(%esp)
  801b39:	00 
  801b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3d:	89 04 24             	mov    %eax,(%esp)
  801b40:	e8 7a f0 ff ff       	call   800bbf <strcpy>
	return 0;
}
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 14             	sub    $0x14,%esp
  801b53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b56:	89 1c 24             	mov    %ebx,(%esp)
  801b59:	e8 4a 0b 00 00       	call   8026a8 <pageref>
  801b5e:	83 f8 01             	cmp    $0x1,%eax
  801b61:	75 0d                	jne    801b70 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b63:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b66:	89 04 24             	mov    %eax,(%esp)
  801b69:	e8 1f 03 00 00       	call   801e8d <nsipc_close>
  801b6e:	eb 05                	jmp    801b75 <devsock_close+0x29>
	else
		return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b75:	83 c4 14             	add    $0x14,%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b88:	00 
  801b89:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9d:	89 04 24             	mov    %eax,(%esp)
  801ba0:	e8 e3 03 00 00       	call   801f88 <nsipc_send>
}
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bb4:	00 
  801bb5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc9:	89 04 24             	mov    %eax,(%esp)
  801bcc:	e8 37 03 00 00       	call   801f08 <nsipc_recv>
}
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 20             	sub    $0x20,%esp
  801bdb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 df f6 ff ff       	call   8012c7 <fd_alloc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 21                	js     801c0f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bf5:	00 
  801bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c04:	e8 a8 f3 ff ff       	call   800fb1 <sys_page_alloc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	79 0a                	jns    801c19 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c0f:	89 34 24             	mov    %esi,(%esp)
  801c12:	e8 76 02 00 00       	call   801e8d <nsipc_close>
		return r;
  801c17:	eb 22                	jmp    801c3b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c19:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c22:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c27:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c2e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c31:	89 04 24             	mov    %eax,(%esp)
  801c34:	e8 63 f6 ff ff       	call   80129c <fd2num>
  801c39:	89 c3                	mov    %eax,%ebx
}
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	83 c4 20             	add    $0x20,%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c4a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 c1 f6 ff ff       	call   80131a <fd_lookup>
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 17                	js     801c74 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c66:	39 10                	cmp    %edx,(%eax)
  801c68:	75 05                	jne    801c6f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c6d:	eb 05                	jmp    801c74 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c6f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7f:	e8 c0 ff ff ff       	call   801c44 <fd2sockid>
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 1f                	js     801ca7 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c88:	8b 55 10             	mov    0x10(%ebp),%edx
  801c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c92:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 38 01 00 00       	call   801dd6 <nsipc_accept>
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 05                	js     801ca7 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801ca2:	e8 2c ff ff ff       	call   801bd3 <alloc_sockfd>
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	e8 8d ff ff ff       	call   801c44 <fd2sockid>
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 16                	js     801cd1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cbb:	8b 55 10             	mov    0x10(%ebp),%edx
  801cbe:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cc9:	89 04 24             	mov    %eax,(%esp)
  801ccc:	e8 5b 01 00 00       	call   801e2c <nsipc_bind>
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <shutdown>:

int
shutdown(int s, int how)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	e8 63 ff ff ff       	call   801c44 <fd2sockid>
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 0f                	js     801cf4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 77 01 00 00       	call   801e6b <nsipc_shutdown>
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	e8 40 ff ff ff       	call   801c44 <fd2sockid>
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 16                	js     801d1e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d08:	8b 55 10             	mov    0x10(%ebp),%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d12:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	e8 89 01 00 00       	call   801ea7 <nsipc_connect>
}
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <listen>:

int
listen(int s, int backlog)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	e8 16 ff ff ff       	call   801c44 <fd2sockid>
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 0f                	js     801d41 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d35:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 a5 01 00 00       	call   801ee6 <nsipc_listen>
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d49:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	89 04 24             	mov    %eax,(%esp)
  801d5d:	e8 99 02 00 00       	call   801ffb <nsipc_socket>
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 05                	js     801d6b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d66:	e8 68 fe ff ff       	call   801bd3 <alloc_sockfd>
}
  801d6b:	c9                   	leave  
  801d6c:	c3                   	ret    
  801d6d:	00 00                	add    %al,(%eax)
	...

00801d70 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	53                   	push   %ebx
  801d74:	83 ec 14             	sub    $0x14,%esp
  801d77:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d79:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801d80:	75 11                	jne    801d93 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d82:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d89:	e8 e1 08 00 00       	call   80266f <ipc_find_env>
  801d8e:	a3 14 40 80 00       	mov    %eax,0x804014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d93:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d9a:	00 
  801d9b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801da2:	00 
  801da3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801da7:	a1 14 40 80 00       	mov    0x804014,%eax
  801dac:	89 04 24             	mov    %eax,(%esp)
  801daf:	e8 4d 08 00 00       	call   802601 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801db4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dbb:	00 
  801dbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dc3:	00 
  801dc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dcb:	e8 c8 07 00 00       	call   802598 <ipc_recv>
}
  801dd0:	83 c4 14             	add    $0x14,%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 10             	sub    $0x10,%esp
  801dde:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801de1:	8b 45 08             	mov    0x8(%ebp),%eax
  801de4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801de9:	8b 06                	mov    (%esi),%eax
  801deb:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801df0:	b8 01 00 00 00       	mov    $0x1,%eax
  801df5:	e8 76 ff ff ff       	call   801d70 <nsipc>
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 23                	js     801e23 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e00:	a1 10 60 80 00       	mov    0x806010,%eax
  801e05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e09:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e10:	00 
  801e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e14:	89 04 24             	mov    %eax,(%esp)
  801e17:	e8 1c ef ff ff       	call   800d38 <memmove>
		*addrlen = ret->ret_addrlen;
  801e1c:	a1 10 60 80 00       	mov    0x806010,%eax
  801e21:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e23:	89 d8                	mov    %ebx,%eax
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    

00801e2c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 14             	sub    $0x14,%esp
  801e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e49:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e50:	e8 e3 ee ff ff       	call   800d38 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e55:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e5b:	b8 02 00 00 00       	mov    $0x2,%eax
  801e60:	e8 0b ff ff ff       	call   801d70 <nsipc>
}
  801e65:	83 c4 14             	add    $0x14,%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e81:	b8 03 00 00 00       	mov    $0x3,%eax
  801e86:	e8 e5 fe ff ff       	call   801d70 <nsipc>
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <nsipc_close>:

int
nsipc_close(int s)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e93:	8b 45 08             	mov    0x8(%ebp),%eax
  801e96:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e9b:	b8 04 00 00 00       	mov    $0x4,%eax
  801ea0:	e8 cb fe ff ff       	call   801d70 <nsipc>
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 14             	sub    $0x14,%esp
  801eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801eb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec4:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ecb:	e8 68 ee ff ff       	call   800d38 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ed0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ed6:	b8 05 00 00 00       	mov    $0x5,%eax
  801edb:	e8 90 fe ff ff       	call   801d70 <nsipc>
}
  801ee0:	83 c4 14             	add    $0x14,%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801efc:	b8 06 00 00 00       	mov    $0x6,%eax
  801f01:	e8 6a fe ff ff       	call   801d70 <nsipc>
}
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 10             	sub    $0x10,%esp
  801f10:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f13:	8b 45 08             	mov    0x8(%ebp),%eax
  801f16:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f1b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f21:	8b 45 14             	mov    0x14(%ebp),%eax
  801f24:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f29:	b8 07 00 00 00       	mov    $0x7,%eax
  801f2e:	e8 3d fe ff ff       	call   801d70 <nsipc>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 46                	js     801f7f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f39:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f3e:	7f 04                	jg     801f44 <nsipc_recv+0x3c>
  801f40:	39 c6                	cmp    %eax,%esi
  801f42:	7d 24                	jge    801f68 <nsipc_recv+0x60>
  801f44:	c7 44 24 0c 63 2e 80 	movl   $0x802e63,0xc(%esp)
  801f4b:	00 
  801f4c:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  801f53:	00 
  801f54:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f5b:	00 
  801f5c:	c7 04 24 78 2e 80 00 	movl   $0x802e78,(%esp)
  801f63:	e8 d8 05 00 00       	call   802540 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f6c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f73:	00 
  801f74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f77:	89 04 24             	mov    %eax,(%esp)
  801f7a:	e8 b9 ed ff ff       	call   800d38 <memmove>
	}

	return r;
}
  801f7f:	89 d8                	mov    %ebx,%eax
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	53                   	push   %ebx
  801f8c:	83 ec 14             	sub    $0x14,%esp
  801f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f9a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fa0:	7e 24                	jle    801fc6 <nsipc_send+0x3e>
  801fa2:	c7 44 24 0c 84 2e 80 	movl   $0x802e84,0xc(%esp)
  801fa9:	00 
  801faa:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  801fb1:	00 
  801fb2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fb9:	00 
  801fba:	c7 04 24 78 2e 80 00 	movl   $0x802e78,(%esp)
  801fc1:	e8 7a 05 00 00       	call   802540 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fc6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd1:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801fd8:	e8 5b ed ff ff       	call   800d38 <memmove>
	nsipcbuf.send.req_size = size;
  801fdd:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fe3:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801feb:	b8 08 00 00 00       	mov    $0x8,%eax
  801ff0:	e8 7b fd ff ff       	call   801d70 <nsipc>
}
  801ff5:	83 c4 14             	add    $0x14,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802011:	8b 45 10             	mov    0x10(%ebp),%eax
  802014:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802019:	b8 09 00 00 00       	mov    $0x9,%eax
  80201e:	e8 4d fd ff ff       	call   801d70 <nsipc>
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    
  802025:	00 00                	add    %al,(%eax)
	...

00802028 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	56                   	push   %esi
  80202c:	53                   	push   %ebx
  80202d:	83 ec 10             	sub    $0x10,%esp
  802030:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802033:	8b 45 08             	mov    0x8(%ebp),%eax
  802036:	89 04 24             	mov    %eax,(%esp)
  802039:	e8 6e f2 ff ff       	call   8012ac <fd2data>
  80203e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802040:	c7 44 24 04 90 2e 80 	movl   $0x802e90,0x4(%esp)
  802047:	00 
  802048:	89 34 24             	mov    %esi,(%esp)
  80204b:	e8 6f eb ff ff       	call   800bbf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802050:	8b 43 04             	mov    0x4(%ebx),%eax
  802053:	2b 03                	sub    (%ebx),%eax
  802055:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80205b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802062:	00 00 00 
	stat->st_dev = &devpipe;
  802065:	c7 86 88 00 00 00 40 	movl   $0x803040,0x88(%esi)
  80206c:	30 80 00 
	return 0;
}
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	53                   	push   %ebx
  80207f:	83 ec 14             	sub    $0x14,%esp
  802082:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802085:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802089:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802090:	e8 c3 ef ff ff       	call   801058 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802095:	89 1c 24             	mov    %ebx,(%esp)
  802098:	e8 0f f2 ff ff       	call   8012ac <fd2data>
  80209d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a8:	e8 ab ef ff ff       	call   801058 <sys_page_unmap>
}
  8020ad:	83 c4 14             	add    $0x14,%esp
  8020b0:	5b                   	pop    %ebx
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	57                   	push   %edi
  8020b7:	56                   	push   %esi
  8020b8:	53                   	push   %ebx
  8020b9:	83 ec 2c             	sub    $0x2c,%esp
  8020bc:	89 c7                	mov    %eax,%edi
  8020be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020c1:	a1 18 40 80 00       	mov    0x804018,%eax
  8020c6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020c9:	89 3c 24             	mov    %edi,(%esp)
  8020cc:	e8 d7 05 00 00       	call   8026a8 <pageref>
  8020d1:	89 c6                	mov    %eax,%esi
  8020d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d6:	89 04 24             	mov    %eax,(%esp)
  8020d9:	e8 ca 05 00 00       	call   8026a8 <pageref>
  8020de:	39 c6                	cmp    %eax,%esi
  8020e0:	0f 94 c0             	sete   %al
  8020e3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020e6:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8020ec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020ef:	39 cb                	cmp    %ecx,%ebx
  8020f1:	75 08                	jne    8020fb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8020f3:	83 c4 2c             	add    $0x2c,%esp
  8020f6:	5b                   	pop    %ebx
  8020f7:	5e                   	pop    %esi
  8020f8:	5f                   	pop    %edi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8020fb:	83 f8 01             	cmp    $0x1,%eax
  8020fe:	75 c1                	jne    8020c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802100:	8b 42 58             	mov    0x58(%edx),%eax
  802103:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80210a:	00 
  80210b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80210f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802113:	c7 04 24 97 2e 80 00 	movl   $0x802e97,(%esp)
  80211a:	e8 f5 e4 ff ff       	call   800614 <cprintf>
  80211f:	eb a0                	jmp    8020c1 <_pipeisclosed+0xe>

00802121 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	57                   	push   %edi
  802125:	56                   	push   %esi
  802126:	53                   	push   %ebx
  802127:	83 ec 1c             	sub    $0x1c,%esp
  80212a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80212d:	89 34 24             	mov    %esi,(%esp)
  802130:	e8 77 f1 ff ff       	call   8012ac <fd2data>
  802135:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802137:	bf 00 00 00 00       	mov    $0x0,%edi
  80213c:	eb 3c                	jmp    80217a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80213e:	89 da                	mov    %ebx,%edx
  802140:	89 f0                	mov    %esi,%eax
  802142:	e8 6c ff ff ff       	call   8020b3 <_pipeisclosed>
  802147:	85 c0                	test   %eax,%eax
  802149:	75 38                	jne    802183 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80214b:	e8 42 ee ff ff       	call   800f92 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802150:	8b 43 04             	mov    0x4(%ebx),%eax
  802153:	8b 13                	mov    (%ebx),%edx
  802155:	83 c2 20             	add    $0x20,%edx
  802158:	39 d0                	cmp    %edx,%eax
  80215a:	73 e2                	jae    80213e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80215c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80215f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802162:	89 c2                	mov    %eax,%edx
  802164:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80216a:	79 05                	jns    802171 <devpipe_write+0x50>
  80216c:	4a                   	dec    %edx
  80216d:	83 ca e0             	or     $0xffffffe0,%edx
  802170:	42                   	inc    %edx
  802171:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802175:	40                   	inc    %eax
  802176:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802179:	47                   	inc    %edi
  80217a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80217d:	75 d1                	jne    802150 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80217f:	89 f8                	mov    %edi,%eax
  802181:	eb 05                	jmp    802188 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802188:	83 c4 1c             	add    $0x1c,%esp
  80218b:	5b                   	pop    %ebx
  80218c:	5e                   	pop    %esi
  80218d:	5f                   	pop    %edi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    

00802190 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	53                   	push   %ebx
  802196:	83 ec 1c             	sub    $0x1c,%esp
  802199:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80219c:	89 3c 24             	mov    %edi,(%esp)
  80219f:	e8 08 f1 ff ff       	call   8012ac <fd2data>
  8021a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a6:	be 00 00 00 00       	mov    $0x0,%esi
  8021ab:	eb 3a                	jmp    8021e7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021ad:	85 f6                	test   %esi,%esi
  8021af:	74 04                	je     8021b5 <devpipe_read+0x25>
				return i;
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	eb 40                	jmp    8021f5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021b5:	89 da                	mov    %ebx,%edx
  8021b7:	89 f8                	mov    %edi,%eax
  8021b9:	e8 f5 fe ff ff       	call   8020b3 <_pipeisclosed>
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	75 2e                	jne    8021f0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021c2:	e8 cb ed ff ff       	call   800f92 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021c7:	8b 03                	mov    (%ebx),%eax
  8021c9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021cc:	74 df                	je     8021ad <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021ce:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021d3:	79 05                	jns    8021da <devpipe_read+0x4a>
  8021d5:	48                   	dec    %eax
  8021d6:	83 c8 e0             	or     $0xffffffe0,%eax
  8021d9:	40                   	inc    %eax
  8021da:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8021de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021e1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021e4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e6:	46                   	inc    %esi
  8021e7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ea:	75 db                	jne    8021c7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021ec:	89 f0                	mov    %esi,%eax
  8021ee:	eb 05                	jmp    8021f5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021f0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    

008021fd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	57                   	push   %edi
  802201:	56                   	push   %esi
  802202:	53                   	push   %ebx
  802203:	83 ec 3c             	sub    $0x3c,%esp
  802206:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802209:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80220c:	89 04 24             	mov    %eax,(%esp)
  80220f:	e8 b3 f0 ff ff       	call   8012c7 <fd_alloc>
  802214:	89 c3                	mov    %eax,%ebx
  802216:	85 c0                	test   %eax,%eax
  802218:	0f 88 45 01 00 00    	js     802363 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80221e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802225:	00 
  802226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802234:	e8 78 ed ff ff       	call   800fb1 <sys_page_alloc>
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	85 c0                	test   %eax,%eax
  80223d:	0f 88 20 01 00 00    	js     802363 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802243:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802246:	89 04 24             	mov    %eax,(%esp)
  802249:	e8 79 f0 ff ff       	call   8012c7 <fd_alloc>
  80224e:	89 c3                	mov    %eax,%ebx
  802250:	85 c0                	test   %eax,%eax
  802252:	0f 88 f8 00 00 00    	js     802350 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802258:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80225f:	00 
  802260:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802263:	89 44 24 04          	mov    %eax,0x4(%esp)
  802267:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80226e:	e8 3e ed ff ff       	call   800fb1 <sys_page_alloc>
  802273:	89 c3                	mov    %eax,%ebx
  802275:	85 c0                	test   %eax,%eax
  802277:	0f 88 d3 00 00 00    	js     802350 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80227d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802280:	89 04 24             	mov    %eax,(%esp)
  802283:	e8 24 f0 ff ff       	call   8012ac <fd2data>
  802288:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80228a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802291:	00 
  802292:	89 44 24 04          	mov    %eax,0x4(%esp)
  802296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229d:	e8 0f ed ff ff       	call   800fb1 <sys_page_alloc>
  8022a2:	89 c3                	mov    %eax,%ebx
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	0f 88 91 00 00 00    	js     80233d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022af:	89 04 24             	mov    %eax,(%esp)
  8022b2:	e8 f5 ef ff ff       	call   8012ac <fd2data>
  8022b7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022be:	00 
  8022bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022ca:	00 
  8022cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d6:	e8 2a ed ff ff       	call   801005 <sys_page_map>
  8022db:	89 c3                	mov    %eax,%ebx
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 4c                	js     80232d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022e1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ea:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022f6:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022ff:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802301:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802304:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80230b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80230e:	89 04 24             	mov    %eax,(%esp)
  802311:	e8 86 ef ff ff       	call   80129c <fd2num>
  802316:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802318:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80231b:	89 04 24             	mov    %eax,(%esp)
  80231e:	e8 79 ef ff ff       	call   80129c <fd2num>
  802323:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80232b:	eb 36                	jmp    802363 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80232d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802331:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802338:	e8 1b ed ff ff       	call   801058 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80233d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802340:	89 44 24 04          	mov    %eax,0x4(%esp)
  802344:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234b:	e8 08 ed ff ff       	call   801058 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802353:	89 44 24 04          	mov    %eax,0x4(%esp)
  802357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235e:	e8 f5 ec ff ff       	call   801058 <sys_page_unmap>
    err:
	return r;
}
  802363:	89 d8                	mov    %ebx,%eax
  802365:	83 c4 3c             	add    $0x3c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    

0080236d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80236d:	55                   	push   %ebp
  80236e:	89 e5                	mov    %esp,%ebp
  802370:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237a:	8b 45 08             	mov    0x8(%ebp),%eax
  80237d:	89 04 24             	mov    %eax,(%esp)
  802380:	e8 95 ef ff ff       	call   80131a <fd_lookup>
  802385:	85 c0                	test   %eax,%eax
  802387:	78 15                	js     80239e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238c:	89 04 24             	mov    %eax,(%esp)
  80238f:	e8 18 ef ff ff       	call   8012ac <fd2data>
	return _pipeisclosed(fd, p);
  802394:	89 c2                	mov    %eax,%edx
  802396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802399:	e8 15 fd ff ff       	call   8020b3 <_pipeisclosed>
}
  80239e:	c9                   	leave  
  80239f:	c3                   	ret    

008023a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a8:	5d                   	pop    %ebp
  8023a9:	c3                   	ret    

008023aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023aa:	55                   	push   %ebp
  8023ab:	89 e5                	mov    %esp,%ebp
  8023ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8023b0:	c7 44 24 04 af 2e 80 	movl   $0x802eaf,0x4(%esp)
  8023b7:	00 
  8023b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bb:	89 04 24             	mov    %eax,(%esp)
  8023be:	e8 fc e7 ff ff       	call   800bbf <strcpy>
	return 0;
}
  8023c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c8:	c9                   	leave  
  8023c9:	c3                   	ret    

008023ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	57                   	push   %edi
  8023ce:	56                   	push   %esi
  8023cf:	53                   	push   %ebx
  8023d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e1:	eb 30                	jmp    802413 <devcons_write+0x49>
		m = n - tot;
  8023e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8023e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8023e8:	83 fe 7f             	cmp    $0x7f,%esi
  8023eb:	76 05                	jbe    8023f2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8023ed:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023f2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023f6:	03 45 0c             	add    0xc(%ebp),%eax
  8023f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023fd:	89 3c 24             	mov    %edi,(%esp)
  802400:	e8 33 e9 ff ff       	call   800d38 <memmove>
		sys_cputs(buf, m);
  802405:	89 74 24 04          	mov    %esi,0x4(%esp)
  802409:	89 3c 24             	mov    %edi,(%esp)
  80240c:	e8 d3 ea ff ff       	call   800ee4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802411:	01 f3                	add    %esi,%ebx
  802413:	89 d8                	mov    %ebx,%eax
  802415:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802418:	72 c9                	jb     8023e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80241a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802420:	5b                   	pop    %ebx
  802421:	5e                   	pop    %esi
  802422:	5f                   	pop    %edi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80242b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80242f:	75 07                	jne    802438 <devcons_read+0x13>
  802431:	eb 25                	jmp    802458 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802433:	e8 5a eb ff ff       	call   800f92 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802438:	e8 c5 ea ff ff       	call   800f02 <sys_cgetc>
  80243d:	85 c0                	test   %eax,%eax
  80243f:	74 f2                	je     802433 <devcons_read+0xe>
  802441:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802443:	85 c0                	test   %eax,%eax
  802445:	78 1d                	js     802464 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802447:	83 f8 04             	cmp    $0x4,%eax
  80244a:	74 13                	je     80245f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80244c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244f:	88 10                	mov    %dl,(%eax)
	return 1;
  802451:	b8 01 00 00 00       	mov    $0x1,%eax
  802456:	eb 0c                	jmp    802464 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802458:	b8 00 00 00 00       	mov    $0x0,%eax
  80245d:	eb 05                	jmp    802464 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80245f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802464:	c9                   	leave  
  802465:	c3                   	ret    

00802466 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80246c:	8b 45 08             	mov    0x8(%ebp),%eax
  80246f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802472:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802479:	00 
  80247a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80247d:	89 04 24             	mov    %eax,(%esp)
  802480:	e8 5f ea ff ff       	call   800ee4 <sys_cputs>
}
  802485:	c9                   	leave  
  802486:	c3                   	ret    

00802487 <getchar>:

int
getchar(void)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80248d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802494:	00 
  802495:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a3:	e8 0e f1 ff ff       	call   8015b6 <read>
	if (r < 0)
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	78 0f                	js     8024bb <getchar+0x34>
		return r;
	if (r < 1)
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	7e 06                	jle    8024b6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8024b0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024b4:	eb 05                	jmp    8024bb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024b6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024bb:	c9                   	leave  
  8024bc:	c3                   	ret    

008024bd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024bd:	55                   	push   %ebp
  8024be:	89 e5                	mov    %esp,%ebp
  8024c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cd:	89 04 24             	mov    %eax,(%esp)
  8024d0:	e8 45 ee ff ff       	call   80131a <fd_lookup>
  8024d5:	85 c0                	test   %eax,%eax
  8024d7:	78 11                	js     8024ea <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dc:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8024e2:	39 10                	cmp    %edx,(%eax)
  8024e4:	0f 94 c0             	sete   %al
  8024e7:	0f b6 c0             	movzbl %al,%eax
}
  8024ea:	c9                   	leave  
  8024eb:	c3                   	ret    

008024ec <opencons>:

int
opencons(void)
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f5:	89 04 24             	mov    %eax,(%esp)
  8024f8:	e8 ca ed ff ff       	call   8012c7 <fd_alloc>
  8024fd:	85 c0                	test   %eax,%eax
  8024ff:	78 3c                	js     80253d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802501:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802508:	00 
  802509:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802510:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802517:	e8 95 ea ff ff       	call   800fb1 <sys_page_alloc>
  80251c:	85 c0                	test   %eax,%eax
  80251e:	78 1d                	js     80253d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802520:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802526:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802529:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80252b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802535:	89 04 24             	mov    %eax,(%esp)
  802538:	e8 5f ed ff ff       	call   80129c <fd2num>
}
  80253d:	c9                   	leave  
  80253e:	c3                   	ret    
	...

00802540 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	56                   	push   %esi
  802544:	53                   	push   %ebx
  802545:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802548:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80254b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  802551:	e8 1d ea ff ff       	call   800f73 <sys_getenvid>
  802556:	8b 55 0c             	mov    0xc(%ebp),%edx
  802559:	89 54 24 10          	mov    %edx,0x10(%esp)
  80255d:	8b 55 08             	mov    0x8(%ebp),%edx
  802560:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802564:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802568:	89 44 24 04          	mov    %eax,0x4(%esp)
  80256c:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  802573:	e8 9c e0 ff ff       	call   800614 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802578:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257c:	8b 45 10             	mov    0x10(%ebp),%eax
  80257f:	89 04 24             	mov    %eax,(%esp)
  802582:	e8 2c e0 ff ff       	call   8005b3 <vcprintf>
	cprintf("\n");
  802587:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  80258e:	e8 81 e0 ff ff       	call   800614 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802593:	cc                   	int3   
  802594:	eb fd                	jmp    802593 <_panic+0x53>
	...

00802598 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802598:	55                   	push   %ebp
  802599:	89 e5                	mov    %esp,%ebp
  80259b:	56                   	push   %esi
  80259c:	53                   	push   %ebx
  80259d:	83 ec 10             	sub    $0x10,%esp
  8025a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8025a9:	85 c0                	test   %eax,%eax
  8025ab:	75 05                	jne    8025b2 <ipc_recv+0x1a>
  8025ad:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025b2:	89 04 24             	mov    %eax,(%esp)
  8025b5:	e8 0d ec ff ff       	call   8011c7 <sys_ipc_recv>
	if (from_env_store != NULL)
  8025ba:	85 db                	test   %ebx,%ebx
  8025bc:	74 0b                	je     8025c9 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8025be:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8025c4:	8b 52 74             	mov    0x74(%edx),%edx
  8025c7:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8025c9:	85 f6                	test   %esi,%esi
  8025cb:	74 0b                	je     8025d8 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8025cd:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8025d3:	8b 52 78             	mov    0x78(%edx),%edx
  8025d6:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8025d8:	85 c0                	test   %eax,%eax
  8025da:	79 16                	jns    8025f2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8025dc:	85 db                	test   %ebx,%ebx
  8025de:	74 06                	je     8025e6 <ipc_recv+0x4e>
			*from_env_store = 0;
  8025e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8025e6:	85 f6                	test   %esi,%esi
  8025e8:	74 10                	je     8025fa <ipc_recv+0x62>
			*perm_store = 0;
  8025ea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025f0:	eb 08                	jmp    8025fa <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8025f2:	a1 18 40 80 00       	mov    0x804018,%eax
  8025f7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025fa:	83 c4 10             	add    $0x10,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    

00802601 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802601:	55                   	push   %ebp
  802602:	89 e5                	mov    %esp,%ebp
  802604:	57                   	push   %edi
  802605:	56                   	push   %esi
  802606:	53                   	push   %ebx
  802607:	83 ec 1c             	sub    $0x1c,%esp
  80260a:	8b 75 08             	mov    0x8(%ebp),%esi
  80260d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802610:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802613:	eb 2a                	jmp    80263f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802615:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802618:	74 20                	je     80263a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80261a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261e:	c7 44 24 08 e0 2e 80 	movl   $0x802ee0,0x8(%esp)
  802625:	00 
  802626:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80262d:	00 
  80262e:	c7 04 24 08 2f 80 00 	movl   $0x802f08,(%esp)
  802635:	e8 06 ff ff ff       	call   802540 <_panic>
		sys_yield();
  80263a:	e8 53 e9 ff ff       	call   800f92 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80263f:	85 db                	test   %ebx,%ebx
  802641:	75 07                	jne    80264a <ipc_send+0x49>
  802643:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802648:	eb 02                	jmp    80264c <ipc_send+0x4b>
  80264a:	89 d8                	mov    %ebx,%eax
  80264c:	8b 55 14             	mov    0x14(%ebp),%edx
  80264f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802653:	89 44 24 08          	mov    %eax,0x8(%esp)
  802657:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80265b:	89 34 24             	mov    %esi,(%esp)
  80265e:	e8 41 eb ff ff       	call   8011a4 <sys_ipc_try_send>
  802663:	85 c0                	test   %eax,%eax
  802665:	78 ae                	js     802615 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802667:	83 c4 1c             	add    $0x1c,%esp
  80266a:	5b                   	pop    %ebx
  80266b:	5e                   	pop    %esi
  80266c:	5f                   	pop    %edi
  80266d:	5d                   	pop    %ebp
  80266e:	c3                   	ret    

0080266f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80266f:	55                   	push   %ebp
  802670:	89 e5                	mov    %esp,%ebp
  802672:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802675:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80267a:	89 c2                	mov    %eax,%edx
  80267c:	c1 e2 07             	shl    $0x7,%edx
  80267f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802685:	8b 52 50             	mov    0x50(%edx),%edx
  802688:	39 ca                	cmp    %ecx,%edx
  80268a:	75 0d                	jne    802699 <ipc_find_env+0x2a>
			return envs[i].env_id;
  80268c:	c1 e0 07             	shl    $0x7,%eax
  80268f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802694:	8b 40 40             	mov    0x40(%eax),%eax
  802697:	eb 0c                	jmp    8026a5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802699:	40                   	inc    %eax
  80269a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80269f:	75 d9                	jne    80267a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026a1:	66 b8 00 00          	mov    $0x0,%ax
}
  8026a5:	5d                   	pop    %ebp
  8026a6:	c3                   	ret    
	...

008026a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026a8:	55                   	push   %ebp
  8026a9:	89 e5                	mov    %esp,%ebp
  8026ab:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ae:	89 c2                	mov    %eax,%edx
  8026b0:	c1 ea 16             	shr    $0x16,%edx
  8026b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026ba:	f6 c2 01             	test   $0x1,%dl
  8026bd:	74 1e                	je     8026dd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026bf:	c1 e8 0c             	shr    $0xc,%eax
  8026c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026c9:	a8 01                	test   $0x1,%al
  8026cb:	74 17                	je     8026e4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026cd:	c1 e8 0c             	shr    $0xc,%eax
  8026d0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026d7:	ef 
  8026d8:	0f b7 c0             	movzwl %ax,%eax
  8026db:	eb 0c                	jmp    8026e9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8026dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8026e2:	eb 05                	jmp    8026e9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8026e4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8026e9:	5d                   	pop    %ebp
  8026ea:	c3                   	ret    
	...

008026ec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8026ec:	55                   	push   %ebp
  8026ed:	57                   	push   %edi
  8026ee:	56                   	push   %esi
  8026ef:	83 ec 10             	sub    $0x10,%esp
  8026f2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8026f6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026fe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802702:	89 cd                	mov    %ecx,%ebp
  802704:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802708:	85 c0                	test   %eax,%eax
  80270a:	75 2c                	jne    802738 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80270c:	39 f9                	cmp    %edi,%ecx
  80270e:	77 68                	ja     802778 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802710:	85 c9                	test   %ecx,%ecx
  802712:	75 0b                	jne    80271f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802714:	b8 01 00 00 00       	mov    $0x1,%eax
  802719:	31 d2                	xor    %edx,%edx
  80271b:	f7 f1                	div    %ecx
  80271d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80271f:	31 d2                	xor    %edx,%edx
  802721:	89 f8                	mov    %edi,%eax
  802723:	f7 f1                	div    %ecx
  802725:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802727:	89 f0                	mov    %esi,%eax
  802729:	f7 f1                	div    %ecx
  80272b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80272d:	89 f0                	mov    %esi,%eax
  80272f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802731:	83 c4 10             	add    $0x10,%esp
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802738:	39 f8                	cmp    %edi,%eax
  80273a:	77 2c                	ja     802768 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80273c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80273f:	83 f6 1f             	xor    $0x1f,%esi
  802742:	75 4c                	jne    802790 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802744:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802746:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80274b:	72 0a                	jb     802757 <__udivdi3+0x6b>
  80274d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802751:	0f 87 ad 00 00 00    	ja     802804 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802757:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80275c:	89 f0                	mov    %esi,%eax
  80275e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802760:	83 c4 10             	add    $0x10,%esp
  802763:	5e                   	pop    %esi
  802764:	5f                   	pop    %edi
  802765:	5d                   	pop    %ebp
  802766:	c3                   	ret    
  802767:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802768:	31 ff                	xor    %edi,%edi
  80276a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80276c:	89 f0                	mov    %esi,%eax
  80276e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802770:	83 c4 10             	add    $0x10,%esp
  802773:	5e                   	pop    %esi
  802774:	5f                   	pop    %edi
  802775:	5d                   	pop    %ebp
  802776:	c3                   	ret    
  802777:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802778:	89 fa                	mov    %edi,%edx
  80277a:	89 f0                	mov    %esi,%eax
  80277c:	f7 f1                	div    %ecx
  80277e:	89 c6                	mov    %eax,%esi
  802780:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802782:	89 f0                	mov    %esi,%eax
  802784:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802786:	83 c4 10             	add    $0x10,%esp
  802789:	5e                   	pop    %esi
  80278a:	5f                   	pop    %edi
  80278b:	5d                   	pop    %ebp
  80278c:	c3                   	ret    
  80278d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802790:	89 f1                	mov    %esi,%ecx
  802792:	d3 e0                	shl    %cl,%eax
  802794:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802798:	b8 20 00 00 00       	mov    $0x20,%eax
  80279d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80279f:	89 ea                	mov    %ebp,%edx
  8027a1:	88 c1                	mov    %al,%cl
  8027a3:	d3 ea                	shr    %cl,%edx
  8027a5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027a9:	09 ca                	or     %ecx,%edx
  8027ab:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027af:	89 f1                	mov    %esi,%ecx
  8027b1:	d3 e5                	shl    %cl,%ebp
  8027b3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027b7:	89 fd                	mov    %edi,%ebp
  8027b9:	88 c1                	mov    %al,%cl
  8027bb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027bd:	89 fa                	mov    %edi,%edx
  8027bf:	89 f1                	mov    %esi,%ecx
  8027c1:	d3 e2                	shl    %cl,%edx
  8027c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027c7:	88 c1                	mov    %al,%cl
  8027c9:	d3 ef                	shr    %cl,%edi
  8027cb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027cd:	89 f8                	mov    %edi,%eax
  8027cf:	89 ea                	mov    %ebp,%edx
  8027d1:	f7 74 24 08          	divl   0x8(%esp)
  8027d5:	89 d1                	mov    %edx,%ecx
  8027d7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8027d9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027dd:	39 d1                	cmp    %edx,%ecx
  8027df:	72 17                	jb     8027f8 <__udivdi3+0x10c>
  8027e1:	74 09                	je     8027ec <__udivdi3+0x100>
  8027e3:	89 fe                	mov    %edi,%esi
  8027e5:	31 ff                	xor    %edi,%edi
  8027e7:	e9 41 ff ff ff       	jmp    80272d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8027ec:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027f0:	89 f1                	mov    %esi,%ecx
  8027f2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027f4:	39 c2                	cmp    %eax,%edx
  8027f6:	73 eb                	jae    8027e3 <__udivdi3+0xf7>
		{
		  q0--;
  8027f8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027fb:	31 ff                	xor    %edi,%edi
  8027fd:	e9 2b ff ff ff       	jmp    80272d <__udivdi3+0x41>
  802802:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802804:	31 f6                	xor    %esi,%esi
  802806:	e9 22 ff ff ff       	jmp    80272d <__udivdi3+0x41>
	...

0080280c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80280c:	55                   	push   %ebp
  80280d:	57                   	push   %edi
  80280e:	56                   	push   %esi
  80280f:	83 ec 20             	sub    $0x20,%esp
  802812:	8b 44 24 30          	mov    0x30(%esp),%eax
  802816:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80281a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80281e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802822:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802826:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80282a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80282c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80282e:	85 ed                	test   %ebp,%ebp
  802830:	75 16                	jne    802848 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802832:	39 f1                	cmp    %esi,%ecx
  802834:	0f 86 a6 00 00 00    	jbe    8028e0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80283a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80283c:	89 d0                	mov    %edx,%eax
  80283e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802840:	83 c4 20             	add    $0x20,%esp
  802843:	5e                   	pop    %esi
  802844:	5f                   	pop    %edi
  802845:	5d                   	pop    %ebp
  802846:	c3                   	ret    
  802847:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802848:	39 f5                	cmp    %esi,%ebp
  80284a:	0f 87 ac 00 00 00    	ja     8028fc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802850:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802853:	83 f0 1f             	xor    $0x1f,%eax
  802856:	89 44 24 10          	mov    %eax,0x10(%esp)
  80285a:	0f 84 a8 00 00 00    	je     802908 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802860:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802864:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802866:	bf 20 00 00 00       	mov    $0x20,%edi
  80286b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80286f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802873:	89 f9                	mov    %edi,%ecx
  802875:	d3 e8                	shr    %cl,%eax
  802877:	09 e8                	or     %ebp,%eax
  802879:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80287d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802881:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802885:	d3 e0                	shl    %cl,%eax
  802887:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80288b:	89 f2                	mov    %esi,%edx
  80288d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80288f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802893:	d3 e0                	shl    %cl,%eax
  802895:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802899:	8b 44 24 14          	mov    0x14(%esp),%eax
  80289d:	89 f9                	mov    %edi,%ecx
  80289f:	d3 e8                	shr    %cl,%eax
  8028a1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028a3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028a5:	89 f2                	mov    %esi,%edx
  8028a7:	f7 74 24 18          	divl   0x18(%esp)
  8028ab:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028ad:	f7 64 24 0c          	mull   0xc(%esp)
  8028b1:	89 c5                	mov    %eax,%ebp
  8028b3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028b5:	39 d6                	cmp    %edx,%esi
  8028b7:	72 67                	jb     802920 <__umoddi3+0x114>
  8028b9:	74 75                	je     802930 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028bb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028bf:	29 e8                	sub    %ebp,%eax
  8028c1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	89 f2                	mov    %esi,%edx
  8028cb:	89 f9                	mov    %edi,%ecx
  8028cd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028cf:	09 d0                	or     %edx,%eax
  8028d1:	89 f2                	mov    %esi,%edx
  8028d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028d7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028d9:	83 c4 20             	add    $0x20,%esp
  8028dc:	5e                   	pop    %esi
  8028dd:	5f                   	pop    %edi
  8028de:	5d                   	pop    %ebp
  8028df:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028e0:	85 c9                	test   %ecx,%ecx
  8028e2:	75 0b                	jne    8028ef <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8028e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028e9:	31 d2                	xor    %edx,%edx
  8028eb:	f7 f1                	div    %ecx
  8028ed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8028ef:	89 f0                	mov    %esi,%eax
  8028f1:	31 d2                	xor    %edx,%edx
  8028f3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028f5:	89 f8                	mov    %edi,%eax
  8028f7:	e9 3e ff ff ff       	jmp    80283a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8028fc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028fe:	83 c4 20             	add    $0x20,%esp
  802901:	5e                   	pop    %esi
  802902:	5f                   	pop    %edi
  802903:	5d                   	pop    %ebp
  802904:	c3                   	ret    
  802905:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802908:	39 f5                	cmp    %esi,%ebp
  80290a:	72 04                	jb     802910 <__umoddi3+0x104>
  80290c:	39 f9                	cmp    %edi,%ecx
  80290e:	77 06                	ja     802916 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802910:	89 f2                	mov    %esi,%edx
  802912:	29 cf                	sub    %ecx,%edi
  802914:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802916:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802918:	83 c4 20             	add    $0x20,%esp
  80291b:	5e                   	pop    %esi
  80291c:	5f                   	pop    %edi
  80291d:	5d                   	pop    %ebp
  80291e:	c3                   	ret    
  80291f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802920:	89 d1                	mov    %edx,%ecx
  802922:	89 c5                	mov    %eax,%ebp
  802924:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802928:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80292c:	eb 8d                	jmp    8028bb <__umoddi3+0xaf>
  80292e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802930:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802934:	72 ea                	jb     802920 <__umoddi3+0x114>
  802936:	89 f1                	mov    %esi,%ecx
  802938:	eb 81                	jmp    8028bb <__umoddi3+0xaf>
