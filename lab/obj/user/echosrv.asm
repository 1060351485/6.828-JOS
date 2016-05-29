
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 0b 05 00 00       	call   80053c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 b0 29 80 00 	movl   $0x8029b0,(%esp)
  800045:	e8 ee 05 00 00       	call   800638 <cprintf>
	exit();
  80004a:	e8 35 05 00 00       	call   800584 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <handle_client>:

void
handle_client(int sock)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 3c             	sub    $0x3c,%esp
  80005a:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005d:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  800064:	00 
  800065:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	89 34 24             	mov    %esi,(%esp)
  80006f:	e8 66 15 00 00       	call   8015da <read>
  800074:	89 c3                	mov    %eax,%ebx
  800076:	85 c0                	test   %eax,%eax
  800078:	79 50                	jns    8000ca <handle_client+0x79>
		die("Failed to receive initial bytes from client");
  80007a:	b8 b4 29 80 00       	mov    $0x8029b4,%eax
  80007f:	e8 b0 ff ff ff       	call   800034 <die>
  800084:	eb 44                	jmp    8000ca <handle_client+0x79>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800086:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80008a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80008e:	89 34 24             	mov    %esi,(%esp)
  800091:	e8 1f 16 00 00       	call   8016b5 <write>
  800096:	39 d8                	cmp    %ebx,%eax
  800098:	74 0a                	je     8000a4 <handle_client+0x53>
			die("Failed to send bytes to client");
  80009a:	b8 e0 29 80 00       	mov    $0x8029e0,%eax
  80009f:	e8 90 ff ff ff       	call   800034 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000a4:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  8000ab:	00 
  8000ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 22 15 00 00       	call   8015da <read>
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	79 0f                	jns    8000cd <handle_client+0x7c>
			die("Failed to receive additional bytes from client");
  8000be:	b8 00 2a 80 00       	mov    $0x802a00,%eax
  8000c3:	e8 6c ff ff ff       	call   800034 <die>
  8000c8:	eb 03                	jmp    8000cd <handle_client+0x7c>
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  8000ca:	8d 7d c8             	lea    -0x38(%ebp),%edi
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7f b5                	jg     800086 <handle_client+0x35>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 9d 13 00 00       	call   801476 <close>
}
  8000d9:	83 c4 3c             	add    $0x3c,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <umain>:

void
umain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 4c             	sub    $0x4c,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000ea:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8000f1:	00 
  8000f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000f9:	00 
  8000fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800101:	e8 61 1c 00 00       	call   801d67 <socket>
  800106:	89 c6                	mov    %eax,%esi
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 0a                	jns    800116 <umain+0x35>
		die("Failed to create socket");
  80010c:	b8 60 29 80 00       	mov    $0x802960,%eax
  800111:	e8 1e ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  800116:	c7 04 24 78 29 80 00 	movl   $0x802978,(%esp)
  80011d:	e8 16 05 00 00       	call   800638 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800122:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800129:	00 
  80012a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800131:	00 
  800132:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800135:	89 1c 24             	mov    %ebx,(%esp)
  800138:	e8 d5 0b 00 00       	call   800d12 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  80013d:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 84 01 00 00       	call   8002d1 <htonl>
  80014d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800150:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800157:	e8 55 01 00 00       	call   8002b1 <htons>
  80015c:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800160:	c7 04 24 87 29 80 00 	movl   $0x802987,(%esp)
  800167:	e8 cc 04 00 00       	call   800638 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  80016c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800173:	00 
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 4d 1b 00 00       	call   801ccd <bind>
  800180:	85 c0                	test   %eax,%eax
  800182:	79 0a                	jns    80018e <umain+0xad>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800184:	b8 30 2a 80 00       	mov    $0x802a30,%eax
  800189:	e8 a6 fe ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80018e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800195:	00 
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 a6 1b 00 00       	call   801d44 <listen>
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 0a                	jns    8001ac <umain+0xcb>
		die("Failed to listen on server socket");
  8001a2:	b8 54 2a 80 00       	mov    $0x802a54,%eax
  8001a7:	e8 88 fe ff ff       	call   800034 <die>

	cprintf("bound\n");
  8001ac:	c7 04 24 97 29 80 00 	movl   $0x802997,(%esp)
  8001b3:	e8 80 04 00 00       	call   800638 <cprintf>
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
  8001b8:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  8001bb:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
  8001c2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001c6:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  8001cd:	89 34 24             	mov    %esi,(%esp)
  8001d0:	e8 c5 1a 00 00       	call   801c9a <accept>
  8001d5:	89 c3                	mov    %eax,%ebx
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	79 0a                	jns    8001e5 <umain+0x104>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001db:	b8 78 2a 80 00       	mov    $0x802a78,%eax
  8001e0:	e8 4f fe ff ff       	call   800034 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 1c 00 00 00       	call   80020c <inet_ntoa>
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 9e 29 80 00 	movl   $0x80299e,(%esp)
  8001fb:	e8 38 04 00 00       	call   800638 <cprintf>
		handle_client(clientsock);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 49 fe ff ff       	call   800051 <handle_client>
	}
  800208:	eb b1                	jmp    8001bb <umain+0xda>
	...

0080020c <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80021b:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80021f:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800222:	c7 45 dc 00 40 80 00 	movl   $0x804000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800229:	b2 00                	mov    $0x0,%dl
  80022b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80022e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800231:	8a 00                	mov    (%eax),%al
  800233:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  800236:	0f b6 c0             	movzbl %al,%eax
  800239:	8d 34 80             	lea    (%eax,%eax,4),%esi
  80023c:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  80023f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800242:	66 c1 e8 0b          	shr    $0xb,%ax
  800246:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800249:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  80024b:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80024e:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  800251:	d1 e7                	shl    %edi
  800253:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  800256:	89 f9                	mov    %edi,%ecx
  800258:	28 cb                	sub    %cl,%bl
  80025a:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  80025c:	8d 4f 30             	lea    0x30(%edi),%ecx
  80025f:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  800263:	42                   	inc    %edx
    } while(*ap);
  800264:	84 c0                	test   %al,%al
  800266:	75 c6                	jne    80022e <inet_ntoa+0x22>
  800268:	88 d0                	mov    %dl,%al
  80026a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026d:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800270:	eb 0b                	jmp    80027d <inet_ntoa+0x71>
    while(i--)
  800272:	48                   	dec    %eax
      *rp++ = inv[i];
  800273:	0f b6 f0             	movzbl %al,%esi
  800276:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  80027a:	88 19                	mov    %bl,(%ecx)
  80027c:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80027d:	84 c0                	test   %al,%al
  80027f:	75 f1                	jne    800272 <inet_ntoa+0x66>
  800281:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  800284:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800287:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  80028a:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80028d:	fe 45 e3             	incb   -0x1d(%ebp)
  800290:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  800294:	77 0b                	ja     8002a1 <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  800296:	42                   	inc    %edx
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  80029a:	ff 45 d8             	incl   -0x28(%ebp)
  80029d:	88 c2                	mov    %al,%dl
  80029f:	eb 8d                	jmp    80022e <inet_ntoa+0x22>
  }
  *--rp = 0;
  8002a1:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  8002a4:	b8 00 40 80 00       	mov    $0x804000,%eax
  8002a9:	83 c4 1c             	add    $0x1c,%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	66 c1 c0 08          	rol    $0x8,%ax
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8002c3:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 e2 ff ff ff       	call   8002b1 <htons>
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002d7:	89 d1                	mov    %edx,%ecx
  8002d9:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002dc:	89 d0                	mov    %edx,%eax
  8002de:	c1 e0 18             	shl    $0x18,%eax
  8002e1:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002e3:	89 d1                	mov    %edx,%ecx
  8002e5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002eb:	c1 e1 08             	shl    $0x8,%ecx
  8002ee:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8002f0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002f6:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002f9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 24             	sub    $0x24,%esp
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800309:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  80030c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80030f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800312:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800315:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800318:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80031b:	80 f9 09             	cmp    $0x9,%cl
  80031e:	0f 87 8f 01 00 00    	ja     8004b3 <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800324:	83 fa 30             	cmp    $0x30,%edx
  800327:	75 28                	jne    800351 <inet_aton+0x54>
      c = *++cp;
  800329:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80032d:	83 fa 78             	cmp    $0x78,%edx
  800330:	74 0f                	je     800341 <inet_aton+0x44>
  800332:	83 fa 58             	cmp    $0x58,%edx
  800335:	74 0a                	je     800341 <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800337:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800338:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80033f:	eb 17                	jmp    800358 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800341:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800345:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800348:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  80034f:	eb 07                	jmp    800358 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  800351:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800358:	40                   	inc    %eax
  800359:	be 00 00 00 00       	mov    $0x0,%esi
  80035e:	eb 01                	jmp    800361 <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800360:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800361:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800364:	88 d1                	mov    %dl,%cl
  800366:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800369:	80 fb 09             	cmp    $0x9,%bl
  80036c:	77 0d                	ja     80037b <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  80036e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800372:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb e5                	jmp    800360 <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  80037b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80037f:	75 30                	jne    8003b1 <inet_aton+0xb4>
  800381:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800384:	88 5d da             	mov    %bl,-0x26(%ebp)
  800387:	80 fb 05             	cmp    $0x5,%bl
  80038a:	76 08                	jbe    800394 <inet_aton+0x97>
  80038c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80038f:	80 fb 05             	cmp    $0x5,%bl
  800392:	77 23                	ja     8003b7 <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800394:	89 f1                	mov    %esi,%ecx
  800396:	c1 e1 04             	shl    $0x4,%ecx
  800399:	8d 72 0a             	lea    0xa(%edx),%esi
  80039c:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  8003a0:	19 d2                	sbb    %edx,%edx
  8003a2:	83 e2 20             	and    $0x20,%edx
  8003a5:	83 c2 41             	add    $0x41,%edx
  8003a8:	29 d6                	sub    %edx,%esi
  8003aa:	09 ce                	or     %ecx,%esi
        c = *++cp;
  8003ac:	0f be 10             	movsbl (%eax),%edx
  8003af:	eb af                	jmp    800360 <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  8003b1:	89 d0                	mov    %edx,%eax
  8003b3:	89 f3                	mov    %esi,%ebx
  8003b5:	eb 04                	jmp    8003bb <inet_aton+0xbe>
  8003b7:	89 d0                	mov    %edx,%eax
  8003b9:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8003bb:	83 f8 2e             	cmp    $0x2e,%eax
  8003be:	75 23                	jne    8003e3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8003c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  8003c6:	0f 83 ee 00 00 00    	jae    8004ba <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  8003cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003cf:	89 1a                	mov    %ebx,(%edx)
  8003d1:	83 c2 04             	add    $0x4,%edx
  8003d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  8003d7:	8d 47 01             	lea    0x1(%edi),%eax
  8003da:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  8003de:	e9 35 ff ff ff       	jmp    800318 <inet_aton+0x1b>
  8003e3:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8003e5:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003e7:	85 d2                	test   %edx,%edx
  8003e9:	74 33                	je     80041e <inet_aton+0x121>
  8003eb:	80 f9 1f             	cmp    $0x1f,%cl
  8003ee:	0f 86 cd 00 00 00    	jbe    8004c1 <inet_aton+0x1c4>
  8003f4:	84 d2                	test   %dl,%dl
  8003f6:	0f 88 cc 00 00 00    	js     8004c8 <inet_aton+0x1cb>
  8003fc:	83 fa 20             	cmp    $0x20,%edx
  8003ff:	74 1d                	je     80041e <inet_aton+0x121>
  800401:	83 fa 0c             	cmp    $0xc,%edx
  800404:	74 18                	je     80041e <inet_aton+0x121>
  800406:	83 fa 0a             	cmp    $0xa,%edx
  800409:	74 13                	je     80041e <inet_aton+0x121>
  80040b:	83 fa 0d             	cmp    $0xd,%edx
  80040e:	74 0e                	je     80041e <inet_aton+0x121>
  800410:	83 fa 09             	cmp    $0x9,%edx
  800413:	74 09                	je     80041e <inet_aton+0x121>
  800415:	83 fa 0b             	cmp    $0xb,%edx
  800418:	0f 85 b1 00 00 00    	jne    8004cf <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80041e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800421:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800424:	29 d1                	sub    %edx,%ecx
  800426:	89 ca                	mov    %ecx,%edx
  800428:	c1 fa 02             	sar    $0x2,%edx
  80042b:	42                   	inc    %edx
  switch (n) {
  80042c:	83 fa 02             	cmp    $0x2,%edx
  80042f:	74 1b                	je     80044c <inet_aton+0x14f>
  800431:	83 fa 02             	cmp    $0x2,%edx
  800434:	7f 0a                	jg     800440 <inet_aton+0x143>
  800436:	85 d2                	test   %edx,%edx
  800438:	0f 84 98 00 00 00    	je     8004d6 <inet_aton+0x1d9>
  80043e:	eb 59                	jmp    800499 <inet_aton+0x19c>
  800440:	83 fa 03             	cmp    $0x3,%edx
  800443:	74 1c                	je     800461 <inet_aton+0x164>
  800445:	83 fa 04             	cmp    $0x4,%edx
  800448:	75 4f                	jne    800499 <inet_aton+0x19c>
  80044a:	eb 2e                	jmp    80047a <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80044c:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  800451:	0f 87 86 00 00 00    	ja     8004dd <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  800457:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80045a:	c1 e3 18             	shl    $0x18,%ebx
  80045d:	09 c3                	or     %eax,%ebx
    break;
  80045f:	eb 38                	jmp    800499 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800461:	3d ff ff 00 00       	cmp    $0xffff,%eax
  800466:	77 7c                	ja     8004e4 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800468:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80046b:	c1 e3 10             	shl    $0x10,%ebx
  80046e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800471:	c1 e2 18             	shl    $0x18,%edx
  800474:	09 d3                	or     %edx,%ebx
  800476:	09 c3                	or     %eax,%ebx
    break;
  800478:	eb 1f                	jmp    800499 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80047a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80047f:	77 6a                	ja     8004eb <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800481:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800484:	c1 e3 10             	shl    $0x10,%ebx
  800487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048a:	c1 e2 18             	shl    $0x18,%edx
  80048d:	09 d3                	or     %edx,%ebx
  80048f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800492:	c1 e2 08             	shl    $0x8,%edx
  800495:	09 d3                	or     %edx,%ebx
  800497:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  800499:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80049d:	74 53                	je     8004f2 <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  80049f:	89 1c 24             	mov    %ebx,(%esp)
  8004a2:	e8 2a fe ff ff       	call   8002d1 <htonl>
  8004a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004aa:	89 03                	mov    %eax,(%ebx)
  return (1);
  8004ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8004b1:	eb 44                	jmp    8004f7 <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	eb 3d                	jmp    8004f7 <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	eb 36                	jmp    8004f7 <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	eb 2f                	jmp    8004f7 <inet_aton+0x1fa>
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	eb 28                	jmp    8004f7 <inet_aton+0x1fa>
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	eb 21                	jmp    8004f7 <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	eb 1a                	jmp    8004f7 <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	eb 13                	jmp    8004f7 <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	eb 0c                	jmp    8004f7 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	eb 05                	jmp    8004f7 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8004f2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004f7:	83 c4 24             	add    $0x24,%esp
  8004fa:	5b                   	pop    %ebx
  8004fb:	5e                   	pop    %esi
  8004fc:	5f                   	pop    %edi
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800505:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	8b 45 08             	mov    0x8(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 e6 fd ff ff       	call   8002fd <inet_aton>
  800517:	85 c0                	test   %eax,%eax
  800519:	74 05                	je     800520 <inet_addr+0x21>
    return (val.s_addr);
  80051b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80051e:	eb 05                	jmp    800525 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  800520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  80052d:	8b 45 08             	mov    0x8(%ebp),%eax
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 99 fd ff ff       	call   8002d1 <htonl>
}
  800538:	c9                   	leave  
  800539:	c3                   	ret    
	...

0080053c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 10             	sub    $0x10,%esp
  800544:	8b 75 08             	mov    0x8(%ebp),%esi
  800547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80054a:	e8 48 0a 00 00       	call   800f97 <sys_getenvid>
  80054f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800554:	c1 e0 07             	shl    $0x7,%eax
  800557:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80055c:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800561:	85 f6                	test   %esi,%esi
  800563:	7e 07                	jle    80056c <libmain+0x30>
		binaryname = argv[0];
  800565:	8b 03                	mov    (%ebx),%eax
  800567:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	89 34 24             	mov    %esi,(%esp)
  800573:	e8 69 fb ff ff       	call   8000e1 <umain>

	// exit gracefully
	exit();
  800578:	e8 07 00 00 00       	call   800584 <exit>
}
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	5b                   	pop    %ebx
  800581:	5e                   	pop    %esi
  800582:	5d                   	pop    %ebp
  800583:	c3                   	ret    

00800584 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80058a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800591:	e8 af 09 00 00       	call   800f45 <sys_env_destroy>
}
  800596:	c9                   	leave  
  800597:	c3                   	ret    

00800598 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	53                   	push   %ebx
  80059c:	83 ec 14             	sub    $0x14,%esp
  80059f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005a2:	8b 03                	mov    (%ebx),%eax
  8005a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005ab:	40                   	inc    %eax
  8005ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005b3:	75 19                	jne    8005ce <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8005b5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8005bc:	00 
  8005bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 40 09 00 00       	call   800f08 <sys_cputs>
		b->idx = 0;
  8005c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8005ce:	ff 43 04             	incl   0x4(%ebx)
}
  8005d1:	83 c4 14             	add    $0x14,%esp
  8005d4:	5b                   	pop    %ebx
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005e7:	00 00 00 
	b.cnt = 0;
  8005ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800602:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060c:	c7 04 24 98 05 80 00 	movl   $0x800598,(%esp)
  800613:	e8 82 01 00 00       	call   80079a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800618:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	e8 d8 08 00 00       	call   800f08 <sys_cputs>

	return b.cnt;
}
  800630:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800636:	c9                   	leave  
  800637:	c3                   	ret    

00800638 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80063e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800641:	89 44 24 04          	mov    %eax,0x4(%esp)
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	e8 87 ff ff ff       	call   8005d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800650:	c9                   	leave  
  800651:	c3                   	ret    
	...

00800654 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	57                   	push   %edi
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	83 ec 3c             	sub    $0x3c,%esp
  80065d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800660:	89 d7                	mov    %edx,%edi
  800662:	8b 45 08             	mov    0x8(%ebp),%eax
  800665:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800671:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800674:	85 c0                	test   %eax,%eax
  800676:	75 08                	jne    800680 <printnum+0x2c>
  800678:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80067b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80067e:	77 57                	ja     8006d7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800680:	89 74 24 10          	mov    %esi,0x10(%esp)
  800684:	4b                   	dec    %ebx
  800685:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800689:	8b 45 10             	mov    0x10(%ebp),%eax
  80068c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800690:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800694:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800698:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80069f:	00 
  8006a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	e8 5e 20 00 00       	call   802710 <__udivdi3>
  8006b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006ba:	89 04 24             	mov    %eax,(%esp)
  8006bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c1:	89 fa                	mov    %edi,%edx
  8006c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c6:	e8 89 ff ff ff       	call   800654 <printnum>
  8006cb:	eb 0f                	jmp    8006dc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d1:	89 34 24             	mov    %esi,(%esp)
  8006d4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006d7:	4b                   	dec    %ebx
  8006d8:	85 db                	test   %ebx,%ebx
  8006da:	7f f1                	jg     8006cd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006f2:	00 
  8006f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006f6:	89 04 24             	mov    %eax,(%esp)
  8006f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800700:	e8 2b 21 00 00       	call   802830 <__umoddi3>
  800705:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800709:	0f be 80 a5 2a 80 00 	movsbl 0x802aa5(%eax),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800716:	83 c4 3c             	add    $0x3c,%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800721:	83 fa 01             	cmp    $0x1,%edx
  800724:	7e 0e                	jle    800734 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800726:	8b 10                	mov    (%eax),%edx
  800728:	8d 4a 08             	lea    0x8(%edx),%ecx
  80072b:	89 08                	mov    %ecx,(%eax)
  80072d:	8b 02                	mov    (%edx),%eax
  80072f:	8b 52 04             	mov    0x4(%edx),%edx
  800732:	eb 22                	jmp    800756 <getuint+0x38>
	else if (lflag)
  800734:	85 d2                	test   %edx,%edx
  800736:	74 10                	je     800748 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80073d:	89 08                	mov    %ecx,(%eax)
  80073f:	8b 02                	mov    (%edx),%eax
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 0e                	jmp    800756 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80074d:	89 08                	mov    %ecx,(%eax)
  80074f:	8b 02                	mov    (%edx),%eax
  800751:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80075e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800761:	8b 10                	mov    (%eax),%edx
  800763:	3b 50 04             	cmp    0x4(%eax),%edx
  800766:	73 08                	jae    800770 <sprintputch+0x18>
		*b->buf++ = ch;
  800768:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076b:	88 0a                	mov    %cl,(%edx)
  80076d:	42                   	inc    %edx
  80076e:	89 10                	mov    %edx,(%eax)
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80077b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077f:	8b 45 10             	mov    0x10(%ebp),%eax
  800782:	89 44 24 08          	mov    %eax,0x8(%esp)
  800786:	8b 45 0c             	mov    0xc(%ebp),%eax
  800789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	e8 02 00 00 00       	call   80079a <vprintfmt>
	va_end(ap);
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	57                   	push   %edi
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 4c             	sub    $0x4c,%esp
  8007a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8007a9:	eb 12                	jmp    8007bd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	0f 84 6b 03 00 00    	je     800b1e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007bd:	0f b6 06             	movzbl (%esi),%eax
  8007c0:	46                   	inc    %esi
  8007c1:	83 f8 25             	cmp    $0x25,%eax
  8007c4:	75 e5                	jne    8007ab <vprintfmt+0x11>
  8007c6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007ca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8007d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e2:	eb 26                	jmp    80080a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007e7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007eb:	eb 1d                	jmp    80080a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007f0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007f4:	eb 14                	jmp    80080a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800800:	eb 08                	jmp    80080a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800802:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800805:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	0f b6 06             	movzbl (%esi),%eax
  80080d:	8d 56 01             	lea    0x1(%esi),%edx
  800810:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800813:	8a 16                	mov    (%esi),%dl
  800815:	83 ea 23             	sub    $0x23,%edx
  800818:	80 fa 55             	cmp    $0x55,%dl
  80081b:	0f 87 e1 02 00 00    	ja     800b02 <vprintfmt+0x368>
  800821:	0f b6 d2             	movzbl %dl,%edx
  800824:	ff 24 95 e0 2b 80 00 	jmp    *0x802be0(,%edx,4)
  80082b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80082e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800833:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800836:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80083a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80083d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800840:	83 fa 09             	cmp    $0x9,%edx
  800843:	77 2a                	ja     80086f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800845:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800846:	eb eb                	jmp    800833 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8d 50 04             	lea    0x4(%eax),%edx
  80084e:	89 55 14             	mov    %edx,0x14(%ebp)
  800851:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800853:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800856:	eb 17                	jmp    80086f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800858:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80085c:	78 98                	js     8007f6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800861:	eb a7                	jmp    80080a <vprintfmt+0x70>
  800863:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800866:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80086d:	eb 9b                	jmp    80080a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80086f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800873:	79 95                	jns    80080a <vprintfmt+0x70>
  800875:	eb 8b                	jmp    800802 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800877:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800878:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80087b:	eb 8d                	jmp    80080a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8d 50 04             	lea    0x4(%eax),%edx
  800883:	89 55 14             	mov    %edx,0x14(%ebp)
  800886:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088a:	8b 00                	mov    (%eax),%eax
  80088c:	89 04 24             	mov    %eax,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800892:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800895:	e9 23 ff ff ff       	jmp    8007bd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8d 50 04             	lea    0x4(%eax),%edx
  8008a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a3:	8b 00                	mov    (%eax),%eax
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	79 02                	jns    8008ab <vprintfmt+0x111>
  8008a9:	f7 d8                	neg    %eax
  8008ab:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008ad:	83 f8 11             	cmp    $0x11,%eax
  8008b0:	7f 0b                	jg     8008bd <vprintfmt+0x123>
  8008b2:	8b 04 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%eax
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	75 23                	jne    8008e0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8008bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008c1:	c7 44 24 08 bd 2a 80 	movl   $0x802abd,0x8(%esp)
  8008c8:	00 
  8008c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	89 04 24             	mov    %eax,(%esp)
  8008d3:	e8 9a fe ff ff       	call   800772 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008db:	e9 dd fe ff ff       	jmp    8007bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e4:	c7 44 24 08 7d 2e 80 	movl   $0x802e7d,0x8(%esp)
  8008eb:	00 
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f3:	89 14 24             	mov    %edx,(%esp)
  8008f6:	e8 77 fe ff ff       	call   800772 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fe:	e9 ba fe ff ff       	jmp    8007bd <vprintfmt+0x23>
  800903:	89 f9                	mov    %edi,%ecx
  800905:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800908:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 50 04             	lea    0x4(%eax),%edx
  800911:	89 55 14             	mov    %edx,0x14(%ebp)
  800914:	8b 30                	mov    (%eax),%esi
  800916:	85 f6                	test   %esi,%esi
  800918:	75 05                	jne    80091f <vprintfmt+0x185>
				p = "(null)";
  80091a:	be b6 2a 80 00       	mov    $0x802ab6,%esi
			if (width > 0 && padc != '-')
  80091f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800923:	0f 8e 84 00 00 00    	jle    8009ad <vprintfmt+0x213>
  800929:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80092d:	74 7e                	je     8009ad <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80092f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800933:	89 34 24             	mov    %esi,(%esp)
  800936:	e8 8b 02 00 00       	call   800bc6 <strnlen>
  80093b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80093e:	29 c2                	sub    %eax,%edx
  800940:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800943:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800947:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80094a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80094d:	89 de                	mov    %ebx,%esi
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800953:	eb 0b                	jmp    800960 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800955:	89 74 24 04          	mov    %esi,0x4(%esp)
  800959:	89 3c 24             	mov    %edi,(%esp)
  80095c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80095f:	4b                   	dec    %ebx
  800960:	85 db                	test   %ebx,%ebx
  800962:	7f f1                	jg     800955 <vprintfmt+0x1bb>
  800964:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800967:	89 f3                	mov    %esi,%ebx
  800969:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80096c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80096f:	85 c0                	test   %eax,%eax
  800971:	79 05                	jns    800978 <vprintfmt+0x1de>
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
  800978:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097b:	29 c2                	sub    %eax,%edx
  80097d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800980:	eb 2b                	jmp    8009ad <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800982:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800986:	74 18                	je     8009a0 <vprintfmt+0x206>
  800988:	8d 50 e0             	lea    -0x20(%eax),%edx
  80098b:	83 fa 5e             	cmp    $0x5e,%edx
  80098e:	76 10                	jbe    8009a0 <vprintfmt+0x206>
					putch('?', putdat);
  800990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800994:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80099b:	ff 55 08             	call   *0x8(%ebp)
  80099e:	eb 0a                	jmp    8009aa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8009a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a4:	89 04 24             	mov    %eax,(%esp)
  8009a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009aa:	ff 4d e4             	decl   -0x1c(%ebp)
  8009ad:	0f be 06             	movsbl (%esi),%eax
  8009b0:	46                   	inc    %esi
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	74 21                	je     8009d6 <vprintfmt+0x23c>
  8009b5:	85 ff                	test   %edi,%edi
  8009b7:	78 c9                	js     800982 <vprintfmt+0x1e8>
  8009b9:	4f                   	dec    %edi
  8009ba:	79 c6                	jns    800982 <vprintfmt+0x1e8>
  8009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bf:	89 de                	mov    %ebx,%esi
  8009c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009c4:	eb 18                	jmp    8009de <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d3:	4b                   	dec    %ebx
  8009d4:	eb 08                	jmp    8009de <vprintfmt+0x244>
  8009d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d9:	89 de                	mov    %ebx,%esi
  8009db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009de:	85 db                	test   %ebx,%ebx
  8009e0:	7f e4                	jg     8009c6 <vprintfmt+0x22c>
  8009e2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8009e5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009ea:	e9 ce fd ff ff       	jmp    8007bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009ef:	83 f9 01             	cmp    $0x1,%ecx
  8009f2:	7e 10                	jle    800a04 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8009f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f7:	8d 50 08             	lea    0x8(%eax),%edx
  8009fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fd:	8b 30                	mov    (%eax),%esi
  8009ff:	8b 78 04             	mov    0x4(%eax),%edi
  800a02:	eb 26                	jmp    800a2a <vprintfmt+0x290>
	else if (lflag)
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	74 12                	je     800a1a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a08:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0b:	8d 50 04             	lea    0x4(%eax),%edx
  800a0e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a11:	8b 30                	mov    (%eax),%esi
  800a13:	89 f7                	mov    %esi,%edi
  800a15:	c1 ff 1f             	sar    $0x1f,%edi
  800a18:	eb 10                	jmp    800a2a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1d:	8d 50 04             	lea    0x4(%eax),%edx
  800a20:	89 55 14             	mov    %edx,0x14(%ebp)
  800a23:	8b 30                	mov    (%eax),%esi
  800a25:	89 f7                	mov    %esi,%edi
  800a27:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a2a:	85 ff                	test   %edi,%edi
  800a2c:	78 0a                	js     800a38 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a33:	e9 8c 00 00 00       	jmp    800ac4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a43:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a46:	f7 de                	neg    %esi
  800a48:	83 d7 00             	adc    $0x0,%edi
  800a4b:	f7 df                	neg    %edi
			}
			base = 10;
  800a4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a52:	eb 70                	jmp    800ac4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a54:	89 ca                	mov    %ecx,%edx
  800a56:	8d 45 14             	lea    0x14(%ebp),%eax
  800a59:	e8 c0 fc ff ff       	call   80071e <getuint>
  800a5e:	89 c6                	mov    %eax,%esi
  800a60:	89 d7                	mov    %edx,%edi
			base = 10;
  800a62:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a67:	eb 5b                	jmp    800ac4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800a69:	89 ca                	mov    %ecx,%edx
  800a6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6e:	e8 ab fc ff ff       	call   80071e <getuint>
  800a73:	89 c6                	mov    %eax,%esi
  800a75:	89 d7                	mov    %edx,%edi
			base = 8;
  800a77:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a7c:	eb 46                	jmp    800ac4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a82:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a89:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a90:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a97:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9d:	8d 50 04             	lea    0x4(%eax),%edx
  800aa0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800aa3:	8b 30                	mov    (%eax),%esi
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800aaa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800aaf:	eb 13                	jmp    800ac4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ab1:	89 ca                	mov    %ecx,%edx
  800ab3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab6:	e8 63 fc ff ff       	call   80071e <getuint>
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	89 d7                	mov    %edx,%edi
			base = 16;
  800abf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800ac8:	89 54 24 10          	mov    %edx,0x10(%esp)
  800acc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800acf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad7:	89 34 24             	mov    %esi,(%esp)
  800ada:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ade:	89 da                	mov    %ebx,%edx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	e8 6c fb ff ff       	call   800654 <printnum>
			break;
  800ae8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800aeb:	e9 cd fc ff ff       	jmp    8007bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800af0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af4:	89 04 24             	mov    %eax,(%esp)
  800af7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800afd:	e9 bb fc ff ff       	jmp    8007bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b06:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b0d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b10:	eb 01                	jmp    800b13 <vprintfmt+0x379>
  800b12:	4e                   	dec    %esi
  800b13:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b17:	75 f9                	jne    800b12 <vprintfmt+0x378>
  800b19:	e9 9f fc ff ff       	jmp    8007bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b1e:	83 c4 4c             	add    $0x4c,%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 28             	sub    $0x28,%esp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b35:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b39:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	74 30                	je     800b77 <vsnprintf+0x51>
  800b47:	85 d2                	test   %edx,%edx
  800b49:	7e 33                	jle    800b7e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	c7 04 24 58 07 80 00 	movl   $0x800758,(%esp)
  800b67:	e8 2e fc ff ff       	call   80079a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b75:	eb 0c                	jmp    800b83 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b7c:	eb 05                	jmp    800b83 <vsnprintf+0x5d>
  800b7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b8b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b92:	8b 45 10             	mov    0x10(%ebp),%eax
  800b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	89 04 24             	mov    %eax,(%esp)
  800ba6:	e8 7b ff ff ff       	call   800b26 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    
  800bad:	00 00                	add    %al,(%eax)
	...

00800bb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb 01                	jmp    800bbe <strlen+0xe>
		n++;
  800bbd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bbe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc2:	75 f9                	jne    800bbd <strlen+0xd>
		n++;
	return n;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	eb 01                	jmp    800bd7 <strnlen+0x11>
		n++;
  800bd6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd7:	39 d0                	cmp    %edx,%eax
  800bd9:	74 06                	je     800be1 <strnlen+0x1b>
  800bdb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bdf:	75 f5                	jne    800bd6 <strnlen+0x10>
		n++;
	return n;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	53                   	push   %ebx
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800bf5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bf8:	42                   	inc    %edx
  800bf9:	84 c9                	test   %cl,%cl
  800bfb:	75 f5                	jne    800bf2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	53                   	push   %ebx
  800c04:	83 ec 08             	sub    $0x8,%esp
  800c07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c0a:	89 1c 24             	mov    %ebx,(%esp)
  800c0d:	e8 9e ff ff ff       	call   800bb0 <strlen>
	strcpy(dst + len, src);
  800c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c15:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c19:	01 d8                	add    %ebx,%eax
  800c1b:	89 04 24             	mov    %eax,(%esp)
  800c1e:	e8 c0 ff ff ff       	call   800be3 <strcpy>
	return dst;
}
  800c23:	89 d8                	mov    %ebx,%eax
  800c25:	83 c4 08             	add    $0x8,%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c36:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3e:	eb 0c                	jmp    800c4c <strncpy+0x21>
		*dst++ = *src;
  800c40:	8a 1a                	mov    (%edx),%bl
  800c42:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c45:	80 3a 01             	cmpb   $0x1,(%edx)
  800c48:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c4b:	41                   	inc    %ecx
  800c4c:	39 f1                	cmp    %esi,%ecx
  800c4e:	75 f0                	jne    800c40 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	8b 75 08             	mov    0x8(%ebp),%esi
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c62:	85 d2                	test   %edx,%edx
  800c64:	75 0a                	jne    800c70 <strlcpy+0x1c>
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	eb 1a                	jmp    800c84 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c6a:	88 18                	mov    %bl,(%eax)
  800c6c:	40                   	inc    %eax
  800c6d:	41                   	inc    %ecx
  800c6e:	eb 02                	jmp    800c72 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c70:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800c72:	4a                   	dec    %edx
  800c73:	74 0a                	je     800c7f <strlcpy+0x2b>
  800c75:	8a 19                	mov    (%ecx),%bl
  800c77:	84 db                	test   %bl,%bl
  800c79:	75 ef                	jne    800c6a <strlcpy+0x16>
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	eb 02                	jmp    800c81 <strlcpy+0x2d>
  800c7f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c81:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c84:	29 f0                	sub    %esi,%eax
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c90:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c93:	eb 02                	jmp    800c97 <strcmp+0xd>
		p++, q++;
  800c95:	41                   	inc    %ecx
  800c96:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c97:	8a 01                	mov    (%ecx),%al
  800c99:	84 c0                	test   %al,%al
  800c9b:	74 04                	je     800ca1 <strcmp+0x17>
  800c9d:	3a 02                	cmp    (%edx),%al
  800c9f:	74 f4                	je     800c95 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca1:	0f b6 c0             	movzbl %al,%eax
  800ca4:	0f b6 12             	movzbl (%edx),%edx
  800ca7:	29 d0                	sub    %edx,%eax
}
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800cb8:	eb 03                	jmp    800cbd <strncmp+0x12>
		n--, p++, q++;
  800cba:	4a                   	dec    %edx
  800cbb:	40                   	inc    %eax
  800cbc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cbd:	85 d2                	test   %edx,%edx
  800cbf:	74 14                	je     800cd5 <strncmp+0x2a>
  800cc1:	8a 18                	mov    (%eax),%bl
  800cc3:	84 db                	test   %bl,%bl
  800cc5:	74 04                	je     800ccb <strncmp+0x20>
  800cc7:	3a 19                	cmp    (%ecx),%bl
  800cc9:	74 ef                	je     800cba <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ccb:	0f b6 00             	movzbl (%eax),%eax
  800cce:	0f b6 11             	movzbl (%ecx),%edx
  800cd1:	29 d0                	sub    %edx,%eax
  800cd3:	eb 05                	jmp    800cda <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ce6:	eb 05                	jmp    800ced <strchr+0x10>
		if (*s == c)
  800ce8:	38 ca                	cmp    %cl,%dl
  800cea:	74 0c                	je     800cf8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cec:	40                   	inc    %eax
  800ced:	8a 10                	mov    (%eax),%dl
  800cef:	84 d2                	test   %dl,%dl
  800cf1:	75 f5                	jne    800ce8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d03:	eb 05                	jmp    800d0a <strfind+0x10>
		if (*s == c)
  800d05:	38 ca                	cmp    %cl,%dl
  800d07:	74 07                	je     800d10 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d09:	40                   	inc    %eax
  800d0a:	8a 10                	mov    (%eax),%dl
  800d0c:	84 d2                	test   %dl,%dl
  800d0e:	75 f5                	jne    800d05 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d21:	85 c9                	test   %ecx,%ecx
  800d23:	74 30                	je     800d55 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d2b:	75 25                	jne    800d52 <memset+0x40>
  800d2d:	f6 c1 03             	test   $0x3,%cl
  800d30:	75 20                	jne    800d52 <memset+0x40>
		c &= 0xFF;
  800d32:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d35:	89 d3                	mov    %edx,%ebx
  800d37:	c1 e3 08             	shl    $0x8,%ebx
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	c1 e6 18             	shl    $0x18,%esi
  800d3f:	89 d0                	mov    %edx,%eax
  800d41:	c1 e0 10             	shl    $0x10,%eax
  800d44:	09 f0                	or     %esi,%eax
  800d46:	09 d0                	or     %edx,%eax
  800d48:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d4a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d4d:	fc                   	cld    
  800d4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800d50:	eb 03                	jmp    800d55 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d52:	fc                   	cld    
  800d53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d55:	89 f8                	mov    %edi,%eax
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d6a:	39 c6                	cmp    %eax,%esi
  800d6c:	73 34                	jae    800da2 <memmove+0x46>
  800d6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d71:	39 d0                	cmp    %edx,%eax
  800d73:	73 2d                	jae    800da2 <memmove+0x46>
		s += n;
		d += n;
  800d75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d78:	f6 c2 03             	test   $0x3,%dl
  800d7b:	75 1b                	jne    800d98 <memmove+0x3c>
  800d7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d83:	75 13                	jne    800d98 <memmove+0x3c>
  800d85:	f6 c1 03             	test   $0x3,%cl
  800d88:	75 0e                	jne    800d98 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d8a:	83 ef 04             	sub    $0x4,%edi
  800d8d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d90:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d93:	fd                   	std    
  800d94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d96:	eb 07                	jmp    800d9f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d98:	4f                   	dec    %edi
  800d99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d9c:	fd                   	std    
  800d9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d9f:	fc                   	cld    
  800da0:	eb 20                	jmp    800dc2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da8:	75 13                	jne    800dbd <memmove+0x61>
  800daa:	a8 03                	test   $0x3,%al
  800dac:	75 0f                	jne    800dbd <memmove+0x61>
  800dae:	f6 c1 03             	test   $0x3,%cl
  800db1:	75 0a                	jne    800dbd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800db3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800db6:	89 c7                	mov    %eax,%edi
  800db8:	fc                   	cld    
  800db9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbb:	eb 05                	jmp    800dc2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dbd:	89 c7                	mov    %eax,%edi
  800dbf:	fc                   	cld    
  800dc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	89 04 24             	mov    %eax,(%esp)
  800de0:	e8 77 ff ff ff       	call   800d5c <memmove>
}
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    

00800de7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	8b 7d 08             	mov    0x8(%ebp),%edi
  800df0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfb:	eb 16                	jmp    800e13 <memcmp+0x2c>
		if (*s1 != *s2)
  800dfd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e00:	42                   	inc    %edx
  800e01:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e05:	38 c8                	cmp    %cl,%al
  800e07:	74 0a                	je     800e13 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e09:	0f b6 c0             	movzbl %al,%eax
  800e0c:	0f b6 c9             	movzbl %cl,%ecx
  800e0f:	29 c8                	sub    %ecx,%eax
  800e11:	eb 09                	jmp    800e1c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e13:	39 da                	cmp    %ebx,%edx
  800e15:	75 e6                	jne    800dfd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e2a:	89 c2                	mov    %eax,%edx
  800e2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e2f:	eb 05                	jmp    800e36 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e31:	38 08                	cmp    %cl,(%eax)
  800e33:	74 05                	je     800e3a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e35:	40                   	inc    %eax
  800e36:	39 d0                	cmp    %edx,%eax
  800e38:	72 f7                	jb     800e31 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e48:	eb 01                	jmp    800e4b <strtol+0xf>
		s++;
  800e4a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e4b:	8a 02                	mov    (%edx),%al
  800e4d:	3c 20                	cmp    $0x20,%al
  800e4f:	74 f9                	je     800e4a <strtol+0xe>
  800e51:	3c 09                	cmp    $0x9,%al
  800e53:	74 f5                	je     800e4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e55:	3c 2b                	cmp    $0x2b,%al
  800e57:	75 08                	jne    800e61 <strtol+0x25>
		s++;
  800e59:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e5f:	eb 13                	jmp    800e74 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e61:	3c 2d                	cmp    $0x2d,%al
  800e63:	75 0a                	jne    800e6f <strtol+0x33>
		s++, neg = 1;
  800e65:	8d 52 01             	lea    0x1(%edx),%edx
  800e68:	bf 01 00 00 00       	mov    $0x1,%edi
  800e6d:	eb 05                	jmp    800e74 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e74:	85 db                	test   %ebx,%ebx
  800e76:	74 05                	je     800e7d <strtol+0x41>
  800e78:	83 fb 10             	cmp    $0x10,%ebx
  800e7b:	75 28                	jne    800ea5 <strtol+0x69>
  800e7d:	8a 02                	mov    (%edx),%al
  800e7f:	3c 30                	cmp    $0x30,%al
  800e81:	75 10                	jne    800e93 <strtol+0x57>
  800e83:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e87:	75 0a                	jne    800e93 <strtol+0x57>
		s += 2, base = 16;
  800e89:	83 c2 02             	add    $0x2,%edx
  800e8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e91:	eb 12                	jmp    800ea5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800e93:	85 db                	test   %ebx,%ebx
  800e95:	75 0e                	jne    800ea5 <strtol+0x69>
  800e97:	3c 30                	cmp    $0x30,%al
  800e99:	75 05                	jne    800ea0 <strtol+0x64>
		s++, base = 8;
  800e9b:	42                   	inc    %edx
  800e9c:	b3 08                	mov    $0x8,%bl
  800e9e:	eb 05                	jmp    800ea5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ea0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800eac:	8a 0a                	mov    (%edx),%cl
  800eae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800eb1:	80 fb 09             	cmp    $0x9,%bl
  800eb4:	77 08                	ja     800ebe <strtol+0x82>
			dig = *s - '0';
  800eb6:	0f be c9             	movsbl %cl,%ecx
  800eb9:	83 e9 30             	sub    $0x30,%ecx
  800ebc:	eb 1e                	jmp    800edc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ebe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ec1:	80 fb 19             	cmp    $0x19,%bl
  800ec4:	77 08                	ja     800ece <strtol+0x92>
			dig = *s - 'a' + 10;
  800ec6:	0f be c9             	movsbl %cl,%ecx
  800ec9:	83 e9 57             	sub    $0x57,%ecx
  800ecc:	eb 0e                	jmp    800edc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ece:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ed1:	80 fb 19             	cmp    $0x19,%bl
  800ed4:	77 12                	ja     800ee8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ed6:	0f be c9             	movsbl %cl,%ecx
  800ed9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800edc:	39 f1                	cmp    %esi,%ecx
  800ede:	7d 0c                	jge    800eec <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ee0:	42                   	inc    %edx
  800ee1:	0f af c6             	imul   %esi,%eax
  800ee4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ee6:	eb c4                	jmp    800eac <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ee8:	89 c1                	mov    %eax,%ecx
  800eea:	eb 02                	jmp    800eee <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800eec:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800eee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef2:	74 05                	je     800ef9 <strtol+0xbd>
		*endptr = (char *) s;
  800ef4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ef7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ef9:	85 ff                	test   %edi,%edi
  800efb:	74 04                	je     800f01 <strtol+0xc5>
  800efd:	89 c8                	mov    %ecx,%eax
  800eff:	f7 d8                	neg    %eax
}
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    
	...

00800f08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	89 c6                	mov    %eax,%esi
  800f1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 01 00 00 00       	mov    $0x1,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	b8 03 00 00 00       	mov    $0x3,%eax
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	89 cb                	mov    %ecx,%ebx
  800f5d:	89 cf                	mov    %ecx,%edi
  800f5f:	89 ce                	mov    %ecx,%esi
  800f61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	7e 28                	jle    800f8f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f72:	00 
  800f73:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f82:	00 
  800f83:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  800f8a:	e8 d5 15 00 00       	call   802564 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f8f:	83 c4 2c             	add    $0x2c,%esp
  800f92:	5b                   	pop    %ebx
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa2:	b8 02 00 00 00       	mov    $0x2,%eax
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 d3                	mov    %edx,%ebx
  800fab:	89 d7                	mov    %edx,%edi
  800fad:	89 d6                	mov    %edx,%esi
  800faf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sys_yield>:

void
sys_yield(void)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fc6:	89 d1                	mov    %edx,%ecx
  800fc8:	89 d3                	mov    %edx,%ebx
  800fca:	89 d7                	mov    %edx,%edi
  800fcc:	89 d6                	mov    %edx,%esi
  800fce:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	be 00 00 00 00       	mov    $0x0,%esi
  800fe3:	b8 04 00 00 00       	mov    $0x4,%eax
  800fe8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800feb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 f7                	mov    %esi,%edi
  800ff3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	7e 28                	jle    801021 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801004:	00 
  801005:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  80100c:	00 
  80100d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801014:	00 
  801015:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  80101c:	e8 43 15 00 00       	call   802564 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801021:	83 c4 2c             	add    $0x2c,%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	57                   	push   %edi
  80102d:	56                   	push   %esi
  80102e:	53                   	push   %ebx
  80102f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	b8 05 00 00 00       	mov    $0x5,%eax
  801037:	8b 75 18             	mov    0x18(%ebp),%esi
  80103a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80103d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801048:	85 c0                	test   %eax,%eax
  80104a:	7e 28                	jle    801074 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801050:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801057:	00 
  801058:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  80106f:	e8 f0 14 00 00       	call   802564 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801074:	83 c4 2c             	add    $0x2c,%esp
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801085:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108a:	b8 06 00 00 00       	mov    $0x6,%eax
  80108f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801092:	8b 55 08             	mov    0x8(%ebp),%edx
  801095:	89 df                	mov    %ebx,%edi
  801097:	89 de                	mov    %ebx,%esi
  801099:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 28                	jle    8010c7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  8010c2:	e8 9d 14 00 00       	call   802564 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010c7:	83 c4 2c             	add    $0x2c,%esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5f                   	pop    %edi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010dd:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	89 df                	mov    %ebx,%edi
  8010ea:	89 de                	mov    %ebx,%esi
  8010ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	7e 28                	jle    80111a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  801115:	e8 4a 14 00 00       	call   802564 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80111a:	83 c4 2c             	add    $0x2c,%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	57                   	push   %edi
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
  801128:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801130:	b8 09 00 00 00       	mov    $0x9,%eax
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	8b 55 08             	mov    0x8(%ebp),%edx
  80113b:	89 df                	mov    %ebx,%edi
  80113d:	89 de                	mov    %ebx,%esi
  80113f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801141:	85 c0                	test   %eax,%eax
  801143:	7e 28                	jle    80116d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801145:	89 44 24 10          	mov    %eax,0x10(%esp)
  801149:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801150:	00 
  801151:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  801158:	00 
  801159:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801160:	00 
  801161:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  801168:	e8 f7 13 00 00       	call   802564 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80116d:	83 c4 2c             	add    $0x2c,%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801183:	b8 0a 00 00 00       	mov    $0xa,%eax
  801188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118b:	8b 55 08             	mov    0x8(%ebp),%edx
  80118e:	89 df                	mov    %ebx,%edi
  801190:	89 de                	mov    %ebx,%esi
  801192:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801194:	85 c0                	test   %eax,%eax
  801196:	7e 28                	jle    8011c0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801198:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011a3:	00 
  8011a4:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  8011ab:	00 
  8011ac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b3:	00 
  8011b4:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  8011bb:	e8 a4 13 00 00       	call   802564 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011c0:	83 c4 2c             	add    $0x2c,%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	57                   	push   %edi
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ce:	be 00 00 00 00       	mov    $0x0,%esi
  8011d3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	57                   	push   %edi
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801201:	89 cb                	mov    %ecx,%ebx
  801203:	89 cf                	mov    %ecx,%edi
  801205:	89 ce                	mov    %ecx,%esi
  801207:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801209:	85 c0                	test   %eax,%eax
  80120b:	7e 28                	jle    801235 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801211:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801218:	00 
  801219:	c7 44 24 08 a7 2d 80 	movl   $0x802da7,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  801230:	e8 2f 13 00 00       	call   802564 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801235:	83 c4 2c             	add    $0x2c,%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801243:	ba 00 00 00 00       	mov    $0x0,%edx
  801248:	b8 0e 00 00 00       	mov    $0xe,%eax
  80124d:	89 d1                	mov    %edx,%ecx
  80124f:	89 d3                	mov    %edx,%ebx
  801251:	89 d7                	mov    %edx,%edi
  801253:	89 d6                	mov    %edx,%esi
  801255:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801262:	bb 00 00 00 00       	mov    $0x0,%ebx
  801267:	b8 10 00 00 00       	mov    $0x10,%eax
  80126c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126f:	8b 55 08             	mov    0x8(%ebp),%edx
  801272:	89 df                	mov    %ebx,%edi
  801274:	89 de                	mov    %ebx,%esi
  801276:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801283:	bb 00 00 00 00       	mov    $0x0,%ebx
  801288:	b8 0f 00 00 00       	mov    $0xf,%eax
  80128d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801290:	8b 55 08             	mov    0x8(%ebp),%edx
  801293:	89 df                	mov    %ebx,%edi
  801295:	89 de                	mov    %ebx,%esi
  801297:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801299:	5b                   	pop    %ebx
  80129a:	5e                   	pop    %esi
  80129b:	5f                   	pop    %edi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a9:	b8 11 00 00 00       	mov    $0x11,%eax
  8012ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b1:	89 cb                	mov    %ecx,%ebx
  8012b3:	89 cf                	mov    %ecx,%edi
  8012b5:	89 ce                	mov    %ecx,%esi
  8012b7:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    
	...

008012c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d9:	89 04 24             	mov    %eax,(%esp)
  8012dc:	e8 df ff ff ff       	call   8012c0 <fd2num>
  8012e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	53                   	push   %ebx
  8012ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012f2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012f7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 ea 16             	shr    $0x16,%edx
  8012fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801305:	f6 c2 01             	test   $0x1,%dl
  801308:	74 11                	je     80131b <fd_alloc+0x30>
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	c1 ea 0c             	shr    $0xc,%edx
  80130f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	75 09                	jne    801324 <fd_alloc+0x39>
			*fd_store = fd;
  80131b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb 17                	jmp    80133b <fd_alloc+0x50>
  801324:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801329:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80132e:	75 c7                	jne    8012f7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801330:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801336:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80133b:	5b                   	pop    %ebx
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801344:	83 f8 1f             	cmp    $0x1f,%eax
  801347:	77 36                	ja     80137f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801349:	05 00 00 0d 00       	add    $0xd0000,%eax
  80134e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801351:	89 c2                	mov    %eax,%edx
  801353:	c1 ea 16             	shr    $0x16,%edx
  801356:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	74 24                	je     801386 <fd_lookup+0x48>
  801362:	89 c2                	mov    %eax,%edx
  801364:	c1 ea 0c             	shr    $0xc,%edx
  801367:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136e:	f6 c2 01             	test   $0x1,%dl
  801371:	74 1a                	je     80138d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801373:	8b 55 0c             	mov    0xc(%ebp),%edx
  801376:	89 02                	mov    %eax,(%edx)
	return 0;
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	eb 13                	jmp    801392 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801384:	eb 0c                	jmp    801392 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801386:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138b:	eb 05                	jmp    801392 <fd_lookup+0x54>
  80138d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	53                   	push   %ebx
  801398:	83 ec 14             	sub    $0x14,%esp
  80139b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a6:	eb 0e                	jmp    8013b6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8013a8:	39 08                	cmp    %ecx,(%eax)
  8013aa:	75 09                	jne    8013b5 <dev_lookup+0x21>
			*dev = devtab[i];
  8013ac:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b3:	eb 33                	jmp    8013e8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013b5:	42                   	inc    %edx
  8013b6:	8b 04 95 50 2e 80 00 	mov    0x802e50(,%edx,4),%eax
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	75 e7                	jne    8013a8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c1:	a1 18 40 80 00       	mov    0x804018,%eax
  8013c6:	8b 40 48             	mov    0x48(%eax),%eax
  8013c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  8013d8:	e8 5b f2 ff ff       	call   800638 <cprintf>
	*dev = 0;
  8013dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013e8:	83 c4 14             	add    $0x14,%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 30             	sub    $0x30,%esp
  8013f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f9:	8a 45 0c             	mov    0xc(%ebp),%al
  8013fc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ff:	89 34 24             	mov    %esi,(%esp)
  801402:	e8 b9 fe ff ff       	call   8012c0 <fd2num>
  801407:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80140a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80140e:	89 04 24             	mov    %eax,(%esp)
  801411:	e8 28 ff ff ff       	call   80133e <fd_lookup>
  801416:	89 c3                	mov    %eax,%ebx
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 05                	js     801421 <fd_close+0x33>
	    || fd != fd2)
  80141c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141f:	74 0d                	je     80142e <fd_close+0x40>
		return (must_exist ? r : 0);
  801421:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801425:	75 46                	jne    80146d <fd_close+0x7f>
  801427:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142c:	eb 3f                	jmp    80146d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80142e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	8b 06                	mov    (%esi),%eax
  801437:	89 04 24             	mov    %eax,(%esp)
  80143a:	e8 55 ff ff ff       	call   801394 <dev_lookup>
  80143f:	89 c3                	mov    %eax,%ebx
  801441:	85 c0                	test   %eax,%eax
  801443:	78 18                	js     80145d <fd_close+0x6f>
		if (dev->dev_close)
  801445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801448:	8b 40 10             	mov    0x10(%eax),%eax
  80144b:	85 c0                	test   %eax,%eax
  80144d:	74 09                	je     801458 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144f:	89 34 24             	mov    %esi,(%esp)
  801452:	ff d0                	call   *%eax
  801454:	89 c3                	mov    %eax,%ebx
  801456:	eb 05                	jmp    80145d <fd_close+0x6f>
		else
			r = 0;
  801458:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80145d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801461:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801468:	e8 0f fc ff ff       	call   80107c <sys_page_unmap>
	return r;
}
  80146d:	89 d8                	mov    %ebx,%eax
  80146f:	83 c4 30             	add    $0x30,%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	89 04 24             	mov    %eax,(%esp)
  801489:	e8 b0 fe ff ff       	call   80133e <fd_lookup>
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 13                	js     8014a5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801492:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801499:	00 
  80149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149d:	89 04 24             	mov    %eax,(%esp)
  8014a0:	e8 49 ff ff ff       	call   8013ee <fd_close>
}
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <close_all>:

void
close_all(void)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b3:	89 1c 24             	mov    %ebx,(%esp)
  8014b6:	e8 bb ff ff ff       	call   801476 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bb:	43                   	inc    %ebx
  8014bc:	83 fb 20             	cmp    $0x20,%ebx
  8014bf:	75 f2                	jne    8014b3 <close_all+0xc>
		close(i);
}
  8014c1:	83 c4 14             	add    $0x14,%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	57                   	push   %edi
  8014cb:	56                   	push   %esi
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 4c             	sub    $0x4c,%esp
  8014d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	89 04 24             	mov    %eax,(%esp)
  8014e0:	e8 59 fe ff ff       	call   80133e <fd_lookup>
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	0f 88 e1 00 00 00    	js     8015d0 <dup+0x109>
		return r;
	close(newfdnum);
  8014ef:	89 3c 24             	mov    %edi,(%esp)
  8014f2:	e8 7f ff ff ff       	call   801476 <close>

	newfd = INDEX2FD(newfdnum);
  8014f7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014fd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801503:	89 04 24             	mov    %eax,(%esp)
  801506:	e8 c5 fd ff ff       	call   8012d0 <fd2data>
  80150b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80150d:	89 34 24             	mov    %esi,(%esp)
  801510:	e8 bb fd ff ff       	call   8012d0 <fd2data>
  801515:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	c1 e8 16             	shr    $0x16,%eax
  80151d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801524:	a8 01                	test   $0x1,%al
  801526:	74 46                	je     80156e <dup+0xa7>
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	c1 e8 0c             	shr    $0xc,%eax
  80152d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801534:	f6 c2 01             	test   $0x1,%dl
  801537:	74 35                	je     80156e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801539:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801540:	25 07 0e 00 00       	and    $0xe07,%eax
  801545:	89 44 24 10          	mov    %eax,0x10(%esp)
  801549:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80154c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801550:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801557:	00 
  801558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801563:	e8 c1 fa ff ff       	call   801029 <sys_page_map>
  801568:	89 c3                	mov    %eax,%ebx
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 3b                	js     8015a9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801571:	89 c2                	mov    %eax,%edx
  801573:	c1 ea 0c             	shr    $0xc,%edx
  801576:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80157d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801583:	89 54 24 10          	mov    %edx,0x10(%esp)
  801587:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80158b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801592:	00 
  801593:	89 44 24 04          	mov    %eax,0x4(%esp)
  801597:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159e:	e8 86 fa ff ff       	call   801029 <sys_page_map>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	79 25                	jns    8015ce <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b4:	e8 c3 fa ff ff       	call   80107c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c7:	e8 b0 fa ff ff       	call   80107c <sys_page_unmap>
	return r;
  8015cc:	eb 02                	jmp    8015d0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015ce:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	83 c4 4c             	add    $0x4c,%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5f                   	pop    %edi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 24             	sub    $0x24,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 4b fd ff ff       	call   80133e <fd_lookup>
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 6d                	js     801664 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	8b 00                	mov    (%eax),%eax
  801603:	89 04 24             	mov    %eax,(%esp)
  801606:	e8 89 fd ff ff       	call   801394 <dev_lookup>
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 55                	js     801664 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	8b 50 08             	mov    0x8(%eax),%edx
  801615:	83 e2 03             	and    $0x3,%edx
  801618:	83 fa 01             	cmp    $0x1,%edx
  80161b:	75 23                	jne    801640 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80161d:	a1 18 40 80 00       	mov    0x804018,%eax
  801622:	8b 40 48             	mov    0x48(%eax),%eax
  801625:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162d:	c7 04 24 15 2e 80 00 	movl   $0x802e15,(%esp)
  801634:	e8 ff ef ff ff       	call   800638 <cprintf>
		return -E_INVAL;
  801639:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163e:	eb 24                	jmp    801664 <read+0x8a>
	}
	if (!dev->dev_read)
  801640:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801643:	8b 52 08             	mov    0x8(%edx),%edx
  801646:	85 d2                	test   %edx,%edx
  801648:	74 15                	je     80165f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80164a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80164d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801651:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801654:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801658:	89 04 24             	mov    %eax,(%esp)
  80165b:	ff d2                	call   *%edx
  80165d:	eb 05                	jmp    801664 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80165f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801664:	83 c4 24             	add    $0x24,%esp
  801667:	5b                   	pop    %ebx
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	57                   	push   %edi
  80166e:	56                   	push   %esi
  80166f:	53                   	push   %ebx
  801670:	83 ec 1c             	sub    $0x1c,%esp
  801673:	8b 7d 08             	mov    0x8(%ebp),%edi
  801676:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801679:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167e:	eb 23                	jmp    8016a3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801680:	89 f0                	mov    %esi,%eax
  801682:	29 d8                	sub    %ebx,%eax
  801684:	89 44 24 08          	mov    %eax,0x8(%esp)
  801688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168b:	01 d8                	add    %ebx,%eax
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	89 3c 24             	mov    %edi,(%esp)
  801694:	e8 41 ff ff ff       	call   8015da <read>
		if (m < 0)
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 10                	js     8016ad <readn+0x43>
			return m;
		if (m == 0)
  80169d:	85 c0                	test   %eax,%eax
  80169f:	74 0a                	je     8016ab <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a1:	01 c3                	add    %eax,%ebx
  8016a3:	39 f3                	cmp    %esi,%ebx
  8016a5:	72 d9                	jb     801680 <readn+0x16>
  8016a7:	89 d8                	mov    %ebx,%eax
  8016a9:	eb 02                	jmp    8016ad <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016ab:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016ad:	83 c4 1c             	add    $0x1c,%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5e                   	pop    %esi
  8016b2:	5f                   	pop    %edi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 24             	sub    $0x24,%esp
  8016bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c6:	89 1c 24             	mov    %ebx,(%esp)
  8016c9:	e8 70 fc ff ff       	call   80133e <fd_lookup>
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 68                	js     80173a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dc:	8b 00                	mov    (%eax),%eax
  8016de:	89 04 24             	mov    %eax,(%esp)
  8016e1:	e8 ae fc ff ff       	call   801394 <dev_lookup>
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 50                	js     80173a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f1:	75 23                	jne    801716 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f3:	a1 18 40 80 00       	mov    0x804018,%eax
  8016f8:	8b 40 48             	mov    0x48(%eax),%eax
  8016fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801703:	c7 04 24 31 2e 80 00 	movl   $0x802e31,(%esp)
  80170a:	e8 29 ef ff ff       	call   800638 <cprintf>
		return -E_INVAL;
  80170f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801714:	eb 24                	jmp    80173a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801716:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801719:	8b 52 0c             	mov    0xc(%edx),%edx
  80171c:	85 d2                	test   %edx,%edx
  80171e:	74 15                	je     801735 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801720:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801723:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	ff d2                	call   *%edx
  801733:	eb 05                	jmp    80173a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801735:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80173a:	83 c4 24             	add    $0x24,%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <seek>:

int
seek(int fdnum, off_t offset)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801746:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	89 04 24             	mov    %eax,(%esp)
  801753:	e8 e6 fb ff ff       	call   80133e <fd_lookup>
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 0e                	js     80176a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80175c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80175f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801762:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 24             	sub    $0x24,%esp
  801773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801776:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177d:	89 1c 24             	mov    %ebx,(%esp)
  801780:	e8 b9 fb ff ff       	call   80133e <fd_lookup>
  801785:	85 c0                	test   %eax,%eax
  801787:	78 61                	js     8017ea <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801793:	8b 00                	mov    (%eax),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 f7 fb ff ff       	call   801394 <dev_lookup>
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 49                	js     8017ea <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a8:	75 23                	jne    8017cd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017aa:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017af:	8b 40 48             	mov    0x48(%eax),%eax
  8017b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ba:	c7 04 24 f4 2d 80 00 	movl   $0x802df4,(%esp)
  8017c1:	e8 72 ee ff ff       	call   800638 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cb:	eb 1d                	jmp    8017ea <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d0:	8b 52 18             	mov    0x18(%edx),%edx
  8017d3:	85 d2                	test   %edx,%edx
  8017d5:	74 0e                	je     8017e5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017de:	89 04 24             	mov    %eax,(%esp)
  8017e1:	ff d2                	call   *%edx
  8017e3:	eb 05                	jmp    8017ea <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017ea:	83 c4 24             	add    $0x24,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 24             	sub    $0x24,%esp
  8017f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 32 fb ff ff       	call   80133e <fd_lookup>
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 52                	js     801862 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801813:	89 44 24 04          	mov    %eax,0x4(%esp)
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	8b 00                	mov    (%eax),%eax
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 70 fb ff ff       	call   801394 <dev_lookup>
  801824:	85 c0                	test   %eax,%eax
  801826:	78 3a                	js     801862 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80182f:	74 2c                	je     80185d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801831:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801834:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80183b:	00 00 00 
	stat->st_isdir = 0;
  80183e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801845:	00 00 00 
	stat->st_dev = dev;
  801848:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80184e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801852:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801855:	89 14 24             	mov    %edx,(%esp)
  801858:	ff 50 14             	call   *0x14(%eax)
  80185b:	eb 05                	jmp    801862 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80185d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801862:	83 c4 24             	add    $0x24,%esp
  801865:	5b                   	pop    %ebx
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801870:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801877:	00 
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	89 04 24             	mov    %eax,(%esp)
  80187e:	e8 2d 02 00 00       	call   801ab0 <open>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	85 c0                	test   %eax,%eax
  801887:	78 1b                	js     8018a4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	89 1c 24             	mov    %ebx,(%esp)
  801893:	e8 58 ff ff ff       	call   8017f0 <fstat>
  801898:	89 c6                	mov    %eax,%esi
	close(fd);
  80189a:	89 1c 24             	mov    %ebx,(%esp)
  80189d:	e8 d4 fb ff ff       	call   801476 <close>
	return r;
  8018a2:	89 f3                	mov    %esi,%ebx
}
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    
  8018ad:	00 00                	add    %al,(%eax)
	...

008018b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 10             	sub    $0x10,%esp
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018bc:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  8018c3:	75 11                	jne    8018d6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018cc:	e8 c2 0d 00 00       	call   802693 <ipc_find_env>
  8018d1:	a3 10 40 80 00       	mov    %eax,0x804010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018dd:	00 
  8018de:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018e5:	00 
  8018e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ea:	a1 10 40 80 00       	mov    0x804010,%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 2e 0d 00 00       	call   802625 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018fe:	00 
  8018ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801903:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190a:	e8 ad 0c 00 00       	call   8025bc <ipc_recv>
}
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192f:	ba 00 00 00 00       	mov    $0x0,%edx
  801934:	b8 02 00 00 00       	mov    $0x2,%eax
  801939:	e8 72 ff ff ff       	call   8018b0 <fsipc>
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 40 0c             	mov    0xc(%eax),%eax
  80194c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	b8 06 00 00 00       	mov    $0x6,%eax
  80195b:	e8 50 ff ff ff       	call   8018b0 <fsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 14             	sub    $0x14,%esp
  801969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	8b 40 0c             	mov    0xc(%eax),%eax
  801972:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 05 00 00 00       	mov    $0x5,%eax
  801981:	e8 2a ff ff ff       	call   8018b0 <fsipc>
  801986:	85 c0                	test   %eax,%eax
  801988:	78 2b                	js     8019b5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801991:	00 
  801992:	89 1c 24             	mov    %ebx,(%esp)
  801995:	e8 49 f2 ff ff       	call   800be3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199a:	a1 80 50 80 00       	mov    0x805080,%eax
  80199f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a5:	a1 84 50 80 00       	mov    0x805084,%eax
  8019aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b5:	83 c4 14             	add    $0x14,%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 18             	sub    $0x18,%esp
  8019c1:	8b 55 10             	mov    0x10(%ebp),%edx
  8019c4:	89 d0                	mov    %edx,%eax
  8019c6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8019cc:	76 05                	jbe    8019d3 <devfile_write+0x18>
  8019ce:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8019d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8019d9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019df:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019f6:	e8 61 f3 ff ff       	call   800d5c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 04 00 00 00       	mov    $0x4,%eax
  801a05:	e8 a6 fe ff ff       	call   8018b0 <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	83 ec 10             	sub    $0x10,%esp
  801a14:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a22:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a28:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2d:	b8 03 00 00 00       	mov    $0x3,%eax
  801a32:	e8 79 fe ff ff       	call   8018b0 <fsipc>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 6a                	js     801aa7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a3d:	39 c6                	cmp    %eax,%esi
  801a3f:	73 24                	jae    801a65 <devfile_read+0x59>
  801a41:	c7 44 24 0c 64 2e 80 	movl   $0x802e64,0xc(%esp)
  801a48:	00 
  801a49:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  801a50:	00 
  801a51:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a58:	00 
  801a59:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801a60:	e8 ff 0a 00 00       	call   802564 <_panic>
	assert(r <= PGSIZE);
  801a65:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a6a:	7e 24                	jle    801a90 <devfile_read+0x84>
  801a6c:	c7 44 24 0c 8b 2e 80 	movl   $0x802e8b,0xc(%esp)
  801a73:	00 
  801a74:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  801a7b:	00 
  801a7c:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a83:	00 
  801a84:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801a8b:	e8 d4 0a 00 00       	call   802564 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a90:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a9b:	00 
  801a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 b5 f2 ff ff       	call   800d5c <memmove>
	return r;
}
  801aa7:	89 d8                	mov    %ebx,%eax
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 20             	sub    $0x20,%esp
  801ab8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801abb:	89 34 24             	mov    %esi,(%esp)
  801abe:	e8 ed f0 ff ff       	call   800bb0 <strlen>
  801ac3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ac8:	7f 60                	jg     801b2a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acd:	89 04 24             	mov    %eax,(%esp)
  801ad0:	e8 16 f8 ff ff       	call   8012eb <fd_alloc>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 54                	js     801b2f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801adb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801adf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ae6:	e8 f8 f0 ff ff       	call   800be3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801af6:	b8 01 00 00 00       	mov    $0x1,%eax
  801afb:	e8 b0 fd ff ff       	call   8018b0 <fsipc>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	85 c0                	test   %eax,%eax
  801b04:	79 15                	jns    801b1b <open+0x6b>
		fd_close(fd, 0);
  801b06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b0d:	00 
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 d5 f8 ff ff       	call   8013ee <fd_close>
		return r;
  801b19:	eb 14                	jmp    801b2f <open+0x7f>
	}

	return fd2num(fd);
  801b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 9a f7 ff ff       	call   8012c0 <fd2num>
  801b26:	89 c3                	mov    %eax,%ebx
  801b28:	eb 05                	jmp    801b2f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b2a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b2f:	89 d8                	mov    %ebx,%eax
  801b31:	83 c4 20             	add    $0x20,%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b43:	b8 08 00 00 00       	mov    $0x8,%eax
  801b48:	e8 63 fd ff ff       	call   8018b0 <fsipc>
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    
	...

00801b50 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b56:	c7 44 24 04 97 2e 80 	movl   $0x802e97,0x4(%esp)
  801b5d:	00 
  801b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b61:	89 04 24             	mov    %eax,(%esp)
  801b64:	e8 7a f0 ff ff       	call   800be3 <strcpy>
	return 0;
}
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	c9                   	leave  
  801b6f:	c3                   	ret    

00801b70 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	53                   	push   %ebx
  801b74:	83 ec 14             	sub    $0x14,%esp
  801b77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b7a:	89 1c 24             	mov    %ebx,(%esp)
  801b7d:	e8 4a 0b 00 00       	call   8026cc <pageref>
  801b82:	83 f8 01             	cmp    $0x1,%eax
  801b85:	75 0d                	jne    801b94 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b87:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b8a:	89 04 24             	mov    %eax,(%esp)
  801b8d:	e8 1f 03 00 00       	call   801eb1 <nsipc_close>
  801b92:	eb 05                	jmp    801b99 <devsock_close+0x29>
	else
		return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b99:	83 c4 14             	add    $0x14,%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ba5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bac:	00 
  801bad:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc1:	89 04 24             	mov    %eax,(%esp)
  801bc4:	e8 e3 03 00 00       	call   801fac <nsipc_send>
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bd1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bd8:	00 
  801bd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bea:	8b 40 0c             	mov    0xc(%eax),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 37 03 00 00       	call   801f2c <nsipc_recv>
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 20             	sub    $0x20,%esp
  801bff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 df f6 ff ff       	call   8012eb <fd_alloc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 21                	js     801c33 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c19:	00 
  801c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c28:	e8 a8 f3 ff ff       	call   800fd5 <sys_page_alloc>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	79 0a                	jns    801c3d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c33:	89 34 24             	mov    %esi,(%esp)
  801c36:	e8 76 02 00 00       	call   801eb1 <nsipc_close>
		return r;
  801c3b:	eb 22                	jmp    801c5f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c52:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 63 f6 ff ff       	call   8012c0 <fd2num>
  801c5d:	89 c3                	mov    %eax,%ebx
}
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	83 c4 20             	add    $0x20,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c6e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c75:	89 04 24             	mov    %eax,(%esp)
  801c78:	e8 c1 f6 ff ff       	call   80133e <fd_lookup>
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 17                	js     801c98 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c84:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8a:	39 10                	cmp    %edx,(%eax)
  801c8c:	75 05                	jne    801c93 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c91:	eb 05                	jmp    801c98 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c93:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    

00801c9a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	e8 c0 ff ff ff       	call   801c68 <fd2sockid>
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 1f                	js     801ccb <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cac:	8b 55 10             	mov    0x10(%ebp),%edx
  801caf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb6:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cba:	89 04 24             	mov    %eax,(%esp)
  801cbd:	e8 38 01 00 00       	call   801dfa <nsipc_accept>
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	78 05                	js     801ccb <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801cc6:	e8 2c ff ff ff       	call   801bf7 <alloc_sockfd>
}
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    

00801ccd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd6:	e8 8d ff ff ff       	call   801c68 <fd2sockid>
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	78 16                	js     801cf5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cdf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ce2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ced:	89 04 24             	mov    %eax,(%esp)
  801cf0:	e8 5b 01 00 00       	call   801e50 <nsipc_bind>
}
  801cf5:	c9                   	leave  
  801cf6:	c3                   	ret    

00801cf7 <shutdown>:

int
shutdown(int s, int how)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801d00:	e8 63 ff ff ff       	call   801c68 <fd2sockid>
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 0f                	js     801d18 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d10:	89 04 24             	mov    %eax,(%esp)
  801d13:	e8 77 01 00 00       	call   801e8f <nsipc_shutdown>
}
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	e8 40 ff ff ff       	call   801c68 <fd2sockid>
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	78 16                	js     801d42 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d2c:	8b 55 10             	mov    0x10(%ebp),%edx
  801d2f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d36:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d3a:	89 04 24             	mov    %eax,(%esp)
  801d3d:	e8 89 01 00 00       	call   801ecb <nsipc_connect>
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <listen>:

int
listen(int s, int backlog)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	e8 16 ff ff ff       	call   801c68 <fd2sockid>
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 0f                	js     801d65 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d59:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 a5 01 00 00       	call   801f0a <nsipc_listen>
}
  801d65:	c9                   	leave  
  801d66:	c3                   	ret    

00801d67 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	89 04 24             	mov    %eax,(%esp)
  801d81:	e8 99 02 00 00       	call   80201f <nsipc_socket>
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 05                	js     801d8f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d8a:	e8 68 fe ff ff       	call   801bf7 <alloc_sockfd>
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    
  801d91:	00 00                	add    %al,(%eax)
	...

00801d94 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	83 ec 14             	sub    $0x14,%esp
  801d9b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d9d:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801da4:	75 11                	jne    801db7 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801da6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801dad:	e8 e1 08 00 00       	call   802693 <ipc_find_env>
  801db2:	a3 14 40 80 00       	mov    %eax,0x804014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801db7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801dbe:	00 
  801dbf:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801dc6:	00 
  801dc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dcb:	a1 14 40 80 00       	mov    0x804014,%eax
  801dd0:	89 04 24             	mov    %eax,(%esp)
  801dd3:	e8 4d 08 00 00       	call   802625 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ddf:	00 
  801de0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801de7:	00 
  801de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801def:	e8 c8 07 00 00       	call   8025bc <ipc_recv>
}
  801df4:	83 c4 14             	add    $0x14,%esp
  801df7:	5b                   	pop    %ebx
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 10             	sub    $0x10,%esp
  801e02:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e05:	8b 45 08             	mov    0x8(%ebp),%eax
  801e08:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e0d:	8b 06                	mov    (%esi),%eax
  801e0f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e14:	b8 01 00 00 00       	mov    $0x1,%eax
  801e19:	e8 76 ff ff ff       	call   801d94 <nsipc>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	85 c0                	test   %eax,%eax
  801e22:	78 23                	js     801e47 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e24:	a1 10 60 80 00       	mov    0x806010,%eax
  801e29:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2d:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e34:	00 
  801e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e38:	89 04 24             	mov    %eax,(%esp)
  801e3b:	e8 1c ef ff ff       	call   800d5c <memmove>
		*addrlen = ret->ret_addrlen;
  801e40:	a1 10 60 80 00       	mov    0x806010,%eax
  801e45:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e47:	89 d8                	mov    %ebx,%eax
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5e                   	pop    %esi
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	53                   	push   %ebx
  801e54:	83 ec 14             	sub    $0x14,%esp
  801e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e62:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e74:	e8 e3 ee ff ff       	call   800d5c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e79:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e7f:	b8 02 00 00 00       	mov    $0x2,%eax
  801e84:	e8 0b ff ff ff       	call   801d94 <nsipc>
}
  801e89:	83 c4 14             	add    $0x14,%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e95:	8b 45 08             	mov    0x8(%ebp),%eax
  801e98:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ea5:	b8 03 00 00 00       	mov    $0x3,%eax
  801eaa:	e8 e5 fe ff ff       	call   801d94 <nsipc>
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <nsipc_close>:

int
nsipc_close(int s)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ebf:	b8 04 00 00 00       	mov    $0x4,%eax
  801ec4:	e8 cb fe ff ff       	call   801d94 <nsipc>
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 14             	sub    $0x14,%esp
  801ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801edd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee8:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801eef:	e8 68 ee ff ff       	call   800d5c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ef4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801efa:	b8 05 00 00 00       	mov    $0x5,%eax
  801eff:	e8 90 fe ff ff       	call   801d94 <nsipc>
}
  801f04:	83 c4 14             	add    $0x14,%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f10:	8b 45 08             	mov    0x8(%ebp),%eax
  801f13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f20:	b8 06 00 00 00       	mov    $0x6,%eax
  801f25:	e8 6a fe ff ff       	call   801d94 <nsipc>
}
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	56                   	push   %esi
  801f30:	53                   	push   %ebx
  801f31:	83 ec 10             	sub    $0x10,%esp
  801f34:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f37:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f3f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f45:	8b 45 14             	mov    0x14(%ebp),%eax
  801f48:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f4d:	b8 07 00 00 00       	mov    $0x7,%eax
  801f52:	e8 3d fe ff ff       	call   801d94 <nsipc>
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 46                	js     801fa3 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f5d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f62:	7f 04                	jg     801f68 <nsipc_recv+0x3c>
  801f64:	39 c6                	cmp    %eax,%esi
  801f66:	7d 24                	jge    801f8c <nsipc_recv+0x60>
  801f68:	c7 44 24 0c a3 2e 80 	movl   $0x802ea3,0xc(%esp)
  801f6f:	00 
  801f70:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  801f77:	00 
  801f78:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f7f:	00 
  801f80:	c7 04 24 b8 2e 80 00 	movl   $0x802eb8,(%esp)
  801f87:	e8 d8 05 00 00       	call   802564 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f90:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f97:	00 
  801f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9b:	89 04 24             	mov    %eax,(%esp)
  801f9e:	e8 b9 ed ff ff       	call   800d5c <memmove>
	}

	return r;
}
  801fa3:	89 d8                	mov    %ebx,%eax
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	5b                   	pop    %ebx
  801fa9:	5e                   	pop    %esi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	53                   	push   %ebx
  801fb0:	83 ec 14             	sub    $0x14,%esp
  801fb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fbe:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fc4:	7e 24                	jle    801fea <nsipc_send+0x3e>
  801fc6:	c7 44 24 0c c4 2e 80 	movl   $0x802ec4,0xc(%esp)
  801fcd:	00 
  801fce:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  801fd5:	00 
  801fd6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fdd:	00 
  801fde:	c7 04 24 b8 2e 80 00 	movl   $0x802eb8,(%esp)
  801fe5:	e8 7a 05 00 00       	call   802564 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff5:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801ffc:	e8 5b ed ff ff       	call   800d5c <memmove>
	nsipcbuf.send.req_size = size;
  802001:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802007:	8b 45 14             	mov    0x14(%ebp),%eax
  80200a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80200f:	b8 08 00 00 00       	mov    $0x8,%eax
  802014:	e8 7b fd ff ff       	call   801d94 <nsipc>
}
  802019:	83 c4 14             	add    $0x14,%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802025:	8b 45 08             	mov    0x8(%ebp),%eax
  802028:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80202d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802030:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802035:	8b 45 10             	mov    0x10(%ebp),%eax
  802038:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80203d:	b8 09 00 00 00       	mov    $0x9,%eax
  802042:	e8 4d fd ff ff       	call   801d94 <nsipc>
}
  802047:	c9                   	leave  
  802048:	c3                   	ret    
  802049:	00 00                	add    %al,(%eax)
	...

0080204c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	56                   	push   %esi
  802050:	53                   	push   %ebx
  802051:	83 ec 10             	sub    $0x10,%esp
  802054:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802057:	8b 45 08             	mov    0x8(%ebp),%eax
  80205a:	89 04 24             	mov    %eax,(%esp)
  80205d:	e8 6e f2 ff ff       	call   8012d0 <fd2data>
  802062:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802064:	c7 44 24 04 d0 2e 80 	movl   $0x802ed0,0x4(%esp)
  80206b:	00 
  80206c:	89 34 24             	mov    %esi,(%esp)
  80206f:	e8 6f eb ff ff       	call   800be3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802074:	8b 43 04             	mov    0x4(%ebx),%eax
  802077:	2b 03                	sub    (%ebx),%eax
  802079:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80207f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802086:	00 00 00 
	stat->st_dev = &devpipe;
  802089:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802090:	30 80 00 
	return 0;
}
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    

0080209f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 14             	sub    $0x14,%esp
  8020a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b4:	e8 c3 ef ff ff       	call   80107c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020b9:	89 1c 24             	mov    %ebx,(%esp)
  8020bc:	e8 0f f2 ff ff       	call   8012d0 <fd2data>
  8020c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cc:	e8 ab ef ff ff       	call   80107c <sys_page_unmap>
}
  8020d1:	83 c4 14             	add    $0x14,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    

008020d7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	57                   	push   %edi
  8020db:	56                   	push   %esi
  8020dc:	53                   	push   %ebx
  8020dd:	83 ec 2c             	sub    $0x2c,%esp
  8020e0:	89 c7                	mov    %eax,%edi
  8020e2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020e5:	a1 18 40 80 00       	mov    0x804018,%eax
  8020ea:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020ed:	89 3c 24             	mov    %edi,(%esp)
  8020f0:	e8 d7 05 00 00       	call   8026cc <pageref>
  8020f5:	89 c6                	mov    %eax,%esi
  8020f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020fa:	89 04 24             	mov    %eax,(%esp)
  8020fd:	e8 ca 05 00 00       	call   8026cc <pageref>
  802102:	39 c6                	cmp    %eax,%esi
  802104:	0f 94 c0             	sete   %al
  802107:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80210a:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802110:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802113:	39 cb                	cmp    %ecx,%ebx
  802115:	75 08                	jne    80211f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802117:	83 c4 2c             	add    $0x2c,%esp
  80211a:	5b                   	pop    %ebx
  80211b:	5e                   	pop    %esi
  80211c:	5f                   	pop    %edi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80211f:	83 f8 01             	cmp    $0x1,%eax
  802122:	75 c1                	jne    8020e5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802124:	8b 42 58             	mov    0x58(%edx),%eax
  802127:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80212e:	00 
  80212f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802137:	c7 04 24 d7 2e 80 00 	movl   $0x802ed7,(%esp)
  80213e:	e8 f5 e4 ff ff       	call   800638 <cprintf>
  802143:	eb a0                	jmp    8020e5 <_pipeisclosed+0xe>

00802145 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	57                   	push   %edi
  802149:	56                   	push   %esi
  80214a:	53                   	push   %ebx
  80214b:	83 ec 1c             	sub    $0x1c,%esp
  80214e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802151:	89 34 24             	mov    %esi,(%esp)
  802154:	e8 77 f1 ff ff       	call   8012d0 <fd2data>
  802159:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80215b:	bf 00 00 00 00       	mov    $0x0,%edi
  802160:	eb 3c                	jmp    80219e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802162:	89 da                	mov    %ebx,%edx
  802164:	89 f0                	mov    %esi,%eax
  802166:	e8 6c ff ff ff       	call   8020d7 <_pipeisclosed>
  80216b:	85 c0                	test   %eax,%eax
  80216d:	75 38                	jne    8021a7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80216f:	e8 42 ee ff ff       	call   800fb6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802174:	8b 43 04             	mov    0x4(%ebx),%eax
  802177:	8b 13                	mov    (%ebx),%edx
  802179:	83 c2 20             	add    $0x20,%edx
  80217c:	39 d0                	cmp    %edx,%eax
  80217e:	73 e2                	jae    802162 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802180:	8b 55 0c             	mov    0xc(%ebp),%edx
  802183:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802186:	89 c2                	mov    %eax,%edx
  802188:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80218e:	79 05                	jns    802195 <devpipe_write+0x50>
  802190:	4a                   	dec    %edx
  802191:	83 ca e0             	or     $0xffffffe0,%edx
  802194:	42                   	inc    %edx
  802195:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802199:	40                   	inc    %eax
  80219a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219d:	47                   	inc    %edi
  80219e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021a1:	75 d1                	jne    802174 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021a3:	89 f8                	mov    %edi,%eax
  8021a5:	eb 05                	jmp    8021ac <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021a7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	57                   	push   %edi
  8021b8:	56                   	push   %esi
  8021b9:	53                   	push   %ebx
  8021ba:	83 ec 1c             	sub    $0x1c,%esp
  8021bd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021c0:	89 3c 24             	mov    %edi,(%esp)
  8021c3:	e8 08 f1 ff ff       	call   8012d0 <fd2data>
  8021c8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ca:	be 00 00 00 00       	mov    $0x0,%esi
  8021cf:	eb 3a                	jmp    80220b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021d1:	85 f6                	test   %esi,%esi
  8021d3:	74 04                	je     8021d9 <devpipe_read+0x25>
				return i;
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	eb 40                	jmp    802219 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021d9:	89 da                	mov    %ebx,%edx
  8021db:	89 f8                	mov    %edi,%eax
  8021dd:	e8 f5 fe ff ff       	call   8020d7 <_pipeisclosed>
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	75 2e                	jne    802214 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021e6:	e8 cb ed ff ff       	call   800fb6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021eb:	8b 03                	mov    (%ebx),%eax
  8021ed:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021f0:	74 df                	je     8021d1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021f2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021f7:	79 05                	jns    8021fe <devpipe_read+0x4a>
  8021f9:	48                   	dec    %eax
  8021fa:	83 c8 e0             	or     $0xffffffe0,%eax
  8021fd:	40                   	inc    %eax
  8021fe:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802202:	8b 55 0c             	mov    0xc(%ebp),%edx
  802205:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802208:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80220a:	46                   	inc    %esi
  80220b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80220e:	75 db                	jne    8021eb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802210:	89 f0                	mov    %esi,%eax
  802212:	eb 05                	jmp    802219 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802214:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802219:	83 c4 1c             	add    $0x1c,%esp
  80221c:	5b                   	pop    %ebx
  80221d:	5e                   	pop    %esi
  80221e:	5f                   	pop    %edi
  80221f:	5d                   	pop    %ebp
  802220:	c3                   	ret    

00802221 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	57                   	push   %edi
  802225:	56                   	push   %esi
  802226:	53                   	push   %ebx
  802227:	83 ec 3c             	sub    $0x3c,%esp
  80222a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80222d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802230:	89 04 24             	mov    %eax,(%esp)
  802233:	e8 b3 f0 ff ff       	call   8012eb <fd_alloc>
  802238:	89 c3                	mov    %eax,%ebx
  80223a:	85 c0                	test   %eax,%eax
  80223c:	0f 88 45 01 00 00    	js     802387 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802242:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802249:	00 
  80224a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80224d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802251:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802258:	e8 78 ed ff ff       	call   800fd5 <sys_page_alloc>
  80225d:	89 c3                	mov    %eax,%ebx
  80225f:	85 c0                	test   %eax,%eax
  802261:	0f 88 20 01 00 00    	js     802387 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802267:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80226a:	89 04 24             	mov    %eax,(%esp)
  80226d:	e8 79 f0 ff ff       	call   8012eb <fd_alloc>
  802272:	89 c3                	mov    %eax,%ebx
  802274:	85 c0                	test   %eax,%eax
  802276:	0f 88 f8 00 00 00    	js     802374 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802283:	00 
  802284:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802292:	e8 3e ed ff ff       	call   800fd5 <sys_page_alloc>
  802297:	89 c3                	mov    %eax,%ebx
  802299:	85 c0                	test   %eax,%eax
  80229b:	0f 88 d3 00 00 00    	js     802374 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022a4:	89 04 24             	mov    %eax,(%esp)
  8022a7:	e8 24 f0 ff ff       	call   8012d0 <fd2data>
  8022ac:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ae:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022b5:	00 
  8022b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c1:	e8 0f ed ff ff       	call   800fd5 <sys_page_alloc>
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	0f 88 91 00 00 00    	js     802361 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 f5 ef ff ff       	call   8012d0 <fd2data>
  8022db:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022e2:	00 
  8022e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022ee:	00 
  8022ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fa:	e8 2a ed ff ff       	call   801029 <sys_page_map>
  8022ff:	89 c3                	mov    %eax,%ebx
  802301:	85 c0                	test   %eax,%eax
  802303:	78 4c                	js     802351 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802305:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80230b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80230e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802313:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80231a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802320:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802323:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802328:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80232f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802332:	89 04 24             	mov    %eax,(%esp)
  802335:	e8 86 ef ff ff       	call   8012c0 <fd2num>
  80233a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80233c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80233f:	89 04 24             	mov    %eax,(%esp)
  802342:	e8 79 ef ff ff       	call   8012c0 <fd2num>
  802347:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80234a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80234f:	eb 36                	jmp    802387 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802351:	89 74 24 04          	mov    %esi,0x4(%esp)
  802355:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235c:	e8 1b ed ff ff       	call   80107c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802361:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802364:	89 44 24 04          	mov    %eax,0x4(%esp)
  802368:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236f:	e8 08 ed ff ff       	call   80107c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802382:	e8 f5 ec ff ff       	call   80107c <sys_page_unmap>
    err:
	return r;
}
  802387:	89 d8                	mov    %ebx,%eax
  802389:	83 c4 3c             	add    $0x3c,%esp
  80238c:	5b                   	pop    %ebx
  80238d:	5e                   	pop    %esi
  80238e:	5f                   	pop    %edi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    

00802391 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239e:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a1:	89 04 24             	mov    %eax,(%esp)
  8023a4:	e8 95 ef ff ff       	call   80133e <fd_lookup>
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 15                	js     8023c2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b0:	89 04 24             	mov    %eax,(%esp)
  8023b3:	e8 18 ef ff ff       	call   8012d0 <fd2data>
	return _pipeisclosed(fd, p);
  8023b8:	89 c2                	mov    %eax,%edx
  8023ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bd:	e8 15 fd ff ff       	call   8020d7 <_pipeisclosed>
}
  8023c2:	c9                   	leave  
  8023c3:	c3                   	ret    

008023c4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023cc:	5d                   	pop    %ebp
  8023cd:	c3                   	ret    

008023ce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8023d4:	c7 44 24 04 ef 2e 80 	movl   $0x802eef,0x4(%esp)
  8023db:	00 
  8023dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023df:	89 04 24             	mov    %eax,(%esp)
  8023e2:	e8 fc e7 ff ff       	call   800be3 <strcpy>
	return 0;
}
  8023e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ec:	c9                   	leave  
  8023ed:	c3                   	ret    

008023ee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023ff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802405:	eb 30                	jmp    802437 <devcons_write+0x49>
		m = n - tot;
  802407:	8b 75 10             	mov    0x10(%ebp),%esi
  80240a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80240c:	83 fe 7f             	cmp    $0x7f,%esi
  80240f:	76 05                	jbe    802416 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802411:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802416:	89 74 24 08          	mov    %esi,0x8(%esp)
  80241a:	03 45 0c             	add    0xc(%ebp),%eax
  80241d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802421:	89 3c 24             	mov    %edi,(%esp)
  802424:	e8 33 e9 ff ff       	call   800d5c <memmove>
		sys_cputs(buf, m);
  802429:	89 74 24 04          	mov    %esi,0x4(%esp)
  80242d:	89 3c 24             	mov    %edi,(%esp)
  802430:	e8 d3 ea ff ff       	call   800f08 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802435:	01 f3                	add    %esi,%ebx
  802437:	89 d8                	mov    %ebx,%eax
  802439:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80243c:	72 c9                	jb     802407 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80243e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    

00802449 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
  80244c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80244f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802453:	75 07                	jne    80245c <devcons_read+0x13>
  802455:	eb 25                	jmp    80247c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802457:	e8 5a eb ff ff       	call   800fb6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80245c:	e8 c5 ea ff ff       	call   800f26 <sys_cgetc>
  802461:	85 c0                	test   %eax,%eax
  802463:	74 f2                	je     802457 <devcons_read+0xe>
  802465:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802467:	85 c0                	test   %eax,%eax
  802469:	78 1d                	js     802488 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80246b:	83 f8 04             	cmp    $0x4,%eax
  80246e:	74 13                	je     802483 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802470:	8b 45 0c             	mov    0xc(%ebp),%eax
  802473:	88 10                	mov    %dl,(%eax)
	return 1;
  802475:	b8 01 00 00 00       	mov    $0x1,%eax
  80247a:	eb 0c                	jmp    802488 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80247c:	b8 00 00 00 00       	mov    $0x0,%eax
  802481:	eb 05                	jmp    802488 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802483:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802488:	c9                   	leave  
  802489:	c3                   	ret    

0080248a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80248a:	55                   	push   %ebp
  80248b:	89 e5                	mov    %esp,%ebp
  80248d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802490:	8b 45 08             	mov    0x8(%ebp),%eax
  802493:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802496:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80249d:	00 
  80249e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024a1:	89 04 24             	mov    %eax,(%esp)
  8024a4:	e8 5f ea ff ff       	call   800f08 <sys_cputs>
}
  8024a9:	c9                   	leave  
  8024aa:	c3                   	ret    

008024ab <getchar>:

int
getchar(void)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8024b8:	00 
  8024b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c7:	e8 0e f1 ff ff       	call   8015da <read>
	if (r < 0)
  8024cc:	85 c0                	test   %eax,%eax
  8024ce:	78 0f                	js     8024df <getchar+0x34>
		return r;
	if (r < 1)
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	7e 06                	jle    8024da <getchar+0x2f>
		return -E_EOF;
	return c;
  8024d4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024d8:	eb 05                	jmp    8024df <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024da:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024df:	c9                   	leave  
  8024e0:	c3                   	ret    

008024e1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024e1:	55                   	push   %ebp
  8024e2:	89 e5                	mov    %esp,%ebp
  8024e4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f1:	89 04 24             	mov    %eax,(%esp)
  8024f4:	e8 45 ee ff ff       	call   80133e <fd_lookup>
  8024f9:	85 c0                	test   %eax,%eax
  8024fb:	78 11                	js     80250e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802500:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802506:	39 10                	cmp    %edx,(%eax)
  802508:	0f 94 c0             	sete   %al
  80250b:	0f b6 c0             	movzbl %al,%eax
}
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <opencons>:

int
opencons(void)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802519:	89 04 24             	mov    %eax,(%esp)
  80251c:	e8 ca ed ff ff       	call   8012eb <fd_alloc>
  802521:	85 c0                	test   %eax,%eax
  802523:	78 3c                	js     802561 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802525:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80252c:	00 
  80252d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802530:	89 44 24 04          	mov    %eax,0x4(%esp)
  802534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80253b:	e8 95 ea ff ff       	call   800fd5 <sys_page_alloc>
  802540:	85 c0                	test   %eax,%eax
  802542:	78 1d                	js     802561 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802544:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80254a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80254f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802552:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802559:	89 04 24             	mov    %eax,(%esp)
  80255c:	e8 5f ed ff ff       	call   8012c0 <fd2num>
}
  802561:	c9                   	leave  
  802562:	c3                   	ret    
	...

00802564 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
  802567:	56                   	push   %esi
  802568:	53                   	push   %ebx
  802569:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80256c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80256f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802575:	e8 1d ea ff ff       	call   800f97 <sys_getenvid>
  80257a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80257d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802581:	8b 55 08             	mov    0x8(%ebp),%edx
  802584:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802588:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80258c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802590:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  802597:	e8 9c e0 ff ff       	call   800638 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80259c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8025a3:	89 04 24             	mov    %eax,(%esp)
  8025a6:	e8 2c e0 ff ff       	call   8005d7 <vcprintf>
	cprintf("\n");
  8025ab:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  8025b2:	e8 81 e0 ff ff       	call   800638 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8025b7:	cc                   	int3   
  8025b8:	eb fd                	jmp    8025b7 <_panic+0x53>
	...

008025bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025bc:	55                   	push   %ebp
  8025bd:	89 e5                	mov    %esp,%ebp
  8025bf:	56                   	push   %esi
  8025c0:	53                   	push   %ebx
  8025c1:	83 ec 10             	sub    $0x10,%esp
  8025c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8025cd:	85 c0                	test   %eax,%eax
  8025cf:	75 05                	jne    8025d6 <ipc_recv+0x1a>
  8025d1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025d6:	89 04 24             	mov    %eax,(%esp)
  8025d9:	e8 0d ec ff ff       	call   8011eb <sys_ipc_recv>
	if (from_env_store != NULL)
  8025de:	85 db                	test   %ebx,%ebx
  8025e0:	74 0b                	je     8025ed <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8025e2:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8025e8:	8b 52 74             	mov    0x74(%edx),%edx
  8025eb:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8025ed:	85 f6                	test   %esi,%esi
  8025ef:	74 0b                	je     8025fc <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8025f1:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8025f7:	8b 52 78             	mov    0x78(%edx),%edx
  8025fa:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8025fc:	85 c0                	test   %eax,%eax
  8025fe:	79 16                	jns    802616 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802600:	85 db                	test   %ebx,%ebx
  802602:	74 06                	je     80260a <ipc_recv+0x4e>
			*from_env_store = 0;
  802604:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80260a:	85 f6                	test   %esi,%esi
  80260c:	74 10                	je     80261e <ipc_recv+0x62>
			*perm_store = 0;
  80260e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802614:	eb 08                	jmp    80261e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802616:	a1 18 40 80 00       	mov    0x804018,%eax
  80261b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80261e:	83 c4 10             	add    $0x10,%esp
  802621:	5b                   	pop    %ebx
  802622:	5e                   	pop    %esi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    

00802625 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802625:	55                   	push   %ebp
  802626:	89 e5                	mov    %esp,%ebp
  802628:	57                   	push   %edi
  802629:	56                   	push   %esi
  80262a:	53                   	push   %ebx
  80262b:	83 ec 1c             	sub    $0x1c,%esp
  80262e:	8b 75 08             	mov    0x8(%ebp),%esi
  802631:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802634:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802637:	eb 2a                	jmp    802663 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802639:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80263c:	74 20                	je     80265e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80263e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802642:	c7 44 24 08 20 2f 80 	movl   $0x802f20,0x8(%esp)
  802649:	00 
  80264a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802651:	00 
  802652:	c7 04 24 48 2f 80 00 	movl   $0x802f48,(%esp)
  802659:	e8 06 ff ff ff       	call   802564 <_panic>
		sys_yield();
  80265e:	e8 53 e9 ff ff       	call   800fb6 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802663:	85 db                	test   %ebx,%ebx
  802665:	75 07                	jne    80266e <ipc_send+0x49>
  802667:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80266c:	eb 02                	jmp    802670 <ipc_send+0x4b>
  80266e:	89 d8                	mov    %ebx,%eax
  802670:	8b 55 14             	mov    0x14(%ebp),%edx
  802673:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802677:	89 44 24 08          	mov    %eax,0x8(%esp)
  80267b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80267f:	89 34 24             	mov    %esi,(%esp)
  802682:	e8 41 eb ff ff       	call   8011c8 <sys_ipc_try_send>
  802687:	85 c0                	test   %eax,%eax
  802689:	78 ae                	js     802639 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80268b:	83 c4 1c             	add    $0x1c,%esp
  80268e:	5b                   	pop    %ebx
  80268f:	5e                   	pop    %esi
  802690:	5f                   	pop    %edi
  802691:	5d                   	pop    %ebp
  802692:	c3                   	ret    

00802693 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802693:	55                   	push   %ebp
  802694:	89 e5                	mov    %esp,%ebp
  802696:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802699:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80269e:	89 c2                	mov    %eax,%edx
  8026a0:	c1 e2 07             	shl    $0x7,%edx
  8026a3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026a9:	8b 52 50             	mov    0x50(%edx),%edx
  8026ac:	39 ca                	cmp    %ecx,%edx
  8026ae:	75 0d                	jne    8026bd <ipc_find_env+0x2a>
			return envs[i].env_id;
  8026b0:	c1 e0 07             	shl    $0x7,%eax
  8026b3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026b8:	8b 40 40             	mov    0x40(%eax),%eax
  8026bb:	eb 0c                	jmp    8026c9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026bd:	40                   	inc    %eax
  8026be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026c3:	75 d9                	jne    80269e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8026c9:	5d                   	pop    %ebp
  8026ca:	c3                   	ret    
	...

008026cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026cc:	55                   	push   %ebp
  8026cd:	89 e5                	mov    %esp,%ebp
  8026cf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026d2:	89 c2                	mov    %eax,%edx
  8026d4:	c1 ea 16             	shr    $0x16,%edx
  8026d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026de:	f6 c2 01             	test   $0x1,%dl
  8026e1:	74 1e                	je     802701 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026e3:	c1 e8 0c             	shr    $0xc,%eax
  8026e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026ed:	a8 01                	test   $0x1,%al
  8026ef:	74 17                	je     802708 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026f1:	c1 e8 0c             	shr    $0xc,%eax
  8026f4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026fb:	ef 
  8026fc:	0f b7 c0             	movzwl %ax,%eax
  8026ff:	eb 0c                	jmp    80270d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802701:	b8 00 00 00 00       	mov    $0x0,%eax
  802706:	eb 05                	jmp    80270d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802708:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80270d:	5d                   	pop    %ebp
  80270e:	c3                   	ret    
	...

00802710 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802710:	55                   	push   %ebp
  802711:	57                   	push   %edi
  802712:	56                   	push   %esi
  802713:	83 ec 10             	sub    $0x10,%esp
  802716:	8b 74 24 20          	mov    0x20(%esp),%esi
  80271a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80271e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802722:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802726:	89 cd                	mov    %ecx,%ebp
  802728:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80272c:	85 c0                	test   %eax,%eax
  80272e:	75 2c                	jne    80275c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802730:	39 f9                	cmp    %edi,%ecx
  802732:	77 68                	ja     80279c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802734:	85 c9                	test   %ecx,%ecx
  802736:	75 0b                	jne    802743 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802738:	b8 01 00 00 00       	mov    $0x1,%eax
  80273d:	31 d2                	xor    %edx,%edx
  80273f:	f7 f1                	div    %ecx
  802741:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802743:	31 d2                	xor    %edx,%edx
  802745:	89 f8                	mov    %edi,%eax
  802747:	f7 f1                	div    %ecx
  802749:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80274b:	89 f0                	mov    %esi,%eax
  80274d:	f7 f1                	div    %ecx
  80274f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802751:	89 f0                	mov    %esi,%eax
  802753:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802755:	83 c4 10             	add    $0x10,%esp
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80275c:	39 f8                	cmp    %edi,%eax
  80275e:	77 2c                	ja     80278c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802760:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802763:	83 f6 1f             	xor    $0x1f,%esi
  802766:	75 4c                	jne    8027b4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802768:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80276a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80276f:	72 0a                	jb     80277b <__udivdi3+0x6b>
  802771:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802775:	0f 87 ad 00 00 00    	ja     802828 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80277b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802780:	89 f0                	mov    %esi,%eax
  802782:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802784:	83 c4 10             	add    $0x10,%esp
  802787:	5e                   	pop    %esi
  802788:	5f                   	pop    %edi
  802789:	5d                   	pop    %ebp
  80278a:	c3                   	ret    
  80278b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80278c:	31 ff                	xor    %edi,%edi
  80278e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802790:	89 f0                	mov    %esi,%eax
  802792:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802794:	83 c4 10             	add    $0x10,%esp
  802797:	5e                   	pop    %esi
  802798:	5f                   	pop    %edi
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80279c:	89 fa                	mov    %edi,%edx
  80279e:	89 f0                	mov    %esi,%eax
  8027a0:	f7 f1                	div    %ecx
  8027a2:	89 c6                	mov    %eax,%esi
  8027a4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027a6:	89 f0                	mov    %esi,%eax
  8027a8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027aa:	83 c4 10             	add    $0x10,%esp
  8027ad:	5e                   	pop    %esi
  8027ae:	5f                   	pop    %edi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    
  8027b1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027b4:	89 f1                	mov    %esi,%ecx
  8027b6:	d3 e0                	shl    %cl,%eax
  8027b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8027c1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8027c3:	89 ea                	mov    %ebp,%edx
  8027c5:	88 c1                	mov    %al,%cl
  8027c7:	d3 ea                	shr    %cl,%edx
  8027c9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027cd:	09 ca                	or     %ecx,%edx
  8027cf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027d3:	89 f1                	mov    %esi,%ecx
  8027d5:	d3 e5                	shl    %cl,%ebp
  8027d7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027db:	89 fd                	mov    %edi,%ebp
  8027dd:	88 c1                	mov    %al,%cl
  8027df:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027e1:	89 fa                	mov    %edi,%edx
  8027e3:	89 f1                	mov    %esi,%ecx
  8027e5:	d3 e2                	shl    %cl,%edx
  8027e7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027eb:	88 c1                	mov    %al,%cl
  8027ed:	d3 ef                	shr    %cl,%edi
  8027ef:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027f1:	89 f8                	mov    %edi,%eax
  8027f3:	89 ea                	mov    %ebp,%edx
  8027f5:	f7 74 24 08          	divl   0x8(%esp)
  8027f9:	89 d1                	mov    %edx,%ecx
  8027fb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8027fd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802801:	39 d1                	cmp    %edx,%ecx
  802803:	72 17                	jb     80281c <__udivdi3+0x10c>
  802805:	74 09                	je     802810 <__udivdi3+0x100>
  802807:	89 fe                	mov    %edi,%esi
  802809:	31 ff                	xor    %edi,%edi
  80280b:	e9 41 ff ff ff       	jmp    802751 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802810:	8b 54 24 04          	mov    0x4(%esp),%edx
  802814:	89 f1                	mov    %esi,%ecx
  802816:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802818:	39 c2                	cmp    %eax,%edx
  80281a:	73 eb                	jae    802807 <__udivdi3+0xf7>
		{
		  q0--;
  80281c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80281f:	31 ff                	xor    %edi,%edi
  802821:	e9 2b ff ff ff       	jmp    802751 <__udivdi3+0x41>
  802826:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802828:	31 f6                	xor    %esi,%esi
  80282a:	e9 22 ff ff ff       	jmp    802751 <__udivdi3+0x41>
	...

00802830 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802830:	55                   	push   %ebp
  802831:	57                   	push   %edi
  802832:	56                   	push   %esi
  802833:	83 ec 20             	sub    $0x20,%esp
  802836:	8b 44 24 30          	mov    0x30(%esp),%eax
  80283a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80283e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802842:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802846:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80284a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80284e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802850:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802852:	85 ed                	test   %ebp,%ebp
  802854:	75 16                	jne    80286c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802856:	39 f1                	cmp    %esi,%ecx
  802858:	0f 86 a6 00 00 00    	jbe    802904 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80285e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802860:	89 d0                	mov    %edx,%eax
  802862:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802864:	83 c4 20             	add    $0x20,%esp
  802867:	5e                   	pop    %esi
  802868:	5f                   	pop    %edi
  802869:	5d                   	pop    %ebp
  80286a:	c3                   	ret    
  80286b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80286c:	39 f5                	cmp    %esi,%ebp
  80286e:	0f 87 ac 00 00 00    	ja     802920 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802874:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802877:	83 f0 1f             	xor    $0x1f,%eax
  80287a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80287e:	0f 84 a8 00 00 00    	je     80292c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802884:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802888:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80288a:	bf 20 00 00 00       	mov    $0x20,%edi
  80288f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802893:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802897:	89 f9                	mov    %edi,%ecx
  802899:	d3 e8                	shr    %cl,%eax
  80289b:	09 e8                	or     %ebp,%eax
  80289d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8028a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028a9:	d3 e0                	shl    %cl,%eax
  8028ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028af:	89 f2                	mov    %esi,%edx
  8028b1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8028b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028b7:	d3 e0                	shl    %cl,%eax
  8028b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028c1:	89 f9                	mov    %edi,%ecx
  8028c3:	d3 e8                	shr    %cl,%eax
  8028c5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028c7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028c9:	89 f2                	mov    %esi,%edx
  8028cb:	f7 74 24 18          	divl   0x18(%esp)
  8028cf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028d1:	f7 64 24 0c          	mull   0xc(%esp)
  8028d5:	89 c5                	mov    %eax,%ebp
  8028d7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028d9:	39 d6                	cmp    %edx,%esi
  8028db:	72 67                	jb     802944 <__umoddi3+0x114>
  8028dd:	74 75                	je     802954 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028e3:	29 e8                	sub    %ebp,%eax
  8028e5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028eb:	d3 e8                	shr    %cl,%eax
  8028ed:	89 f2                	mov    %esi,%edx
  8028ef:	89 f9                	mov    %edi,%ecx
  8028f1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028f3:	09 d0                	or     %edx,%eax
  8028f5:	89 f2                	mov    %esi,%edx
  8028f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028fb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028fd:	83 c4 20             	add    $0x20,%esp
  802900:	5e                   	pop    %esi
  802901:	5f                   	pop    %edi
  802902:	5d                   	pop    %ebp
  802903:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802904:	85 c9                	test   %ecx,%ecx
  802906:	75 0b                	jne    802913 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802908:	b8 01 00 00 00       	mov    $0x1,%eax
  80290d:	31 d2                	xor    %edx,%edx
  80290f:	f7 f1                	div    %ecx
  802911:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802913:	89 f0                	mov    %esi,%eax
  802915:	31 d2                	xor    %edx,%edx
  802917:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802919:	89 f8                	mov    %edi,%eax
  80291b:	e9 3e ff ff ff       	jmp    80285e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802920:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802922:	83 c4 20             	add    $0x20,%esp
  802925:	5e                   	pop    %esi
  802926:	5f                   	pop    %edi
  802927:	5d                   	pop    %ebp
  802928:	c3                   	ret    
  802929:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80292c:	39 f5                	cmp    %esi,%ebp
  80292e:	72 04                	jb     802934 <__umoddi3+0x104>
  802930:	39 f9                	cmp    %edi,%ecx
  802932:	77 06                	ja     80293a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802934:	89 f2                	mov    %esi,%edx
  802936:	29 cf                	sub    %ecx,%edi
  802938:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80293a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80293c:	83 c4 20             	add    $0x20,%esp
  80293f:	5e                   	pop    %esi
  802940:	5f                   	pop    %edi
  802941:	5d                   	pop    %ebp
  802942:	c3                   	ret    
  802943:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802944:	89 d1                	mov    %edx,%ecx
  802946:	89 c5                	mov    %eax,%ebp
  802948:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80294c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802950:	eb 8d                	jmp    8028df <__umoddi3+0xaf>
  802952:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802954:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802958:	72 ea                	jb     802944 <__umoddi3+0x114>
  80295a:	89 f1                	mov    %esi,%ecx
  80295c:	eb 81                	jmp    8028df <__umoddi3+0xaf>
