
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 7f 08 00 00       	call   8008b0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 60 2f 80 00 	movl   $0x802f60,(%esp)
  800045:	e8 ba 09 00 00       	call   800a04 <cprintf>
	exit();
  80004a:	e8 a9 08 00 00       	call   8008f8 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
  80005d:	89 c3                	mov    %eax,%ebx
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005f:	b8 00 40 80 00       	mov    $0x804000,%eax
	while (e->code != 0 && e->msg != 0) {
  800064:	eb 07                	jmp    80006d <send_error+0x1c>
		if (e->code == code)
  800066:	39 d1                	cmp    %edx,%ecx
  800068:	74 11                	je     80007b <send_error+0x2a>
			break;
		e++;
  80006a:	83 c0 08             	add    $0x8,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  80006d:	8b 08                	mov    (%eax),%ecx
  80006f:	85 c9                	test   %ecx,%ecx
  800071:	74 5c                	je     8000cf <send_error+0x7e>
  800073:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800077:	75 ed                	jne    800066 <send_error+0x15>
  800079:	eb 04                	jmp    80007f <send_error+0x2e>
		if (e->code == code)
			break;
		e++;
	}

	if (e->code == 0)
  80007b:	85 c9                	test   %ecx,%ecx
  80007d:	74 57                	je     8000d6 <send_error+0x85>
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80007f:	8b 40 04             	mov    0x4(%eax),%eax
  800082:	89 44 24 18          	mov    %eax,0x18(%esp)
  800086:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80008a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800092:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800099:	00 
  80009a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  8000a1:	00 
  8000a2:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  8000a8:	89 34 24             	mov    %esi,(%esp)
  8000ab:	e8 a1 0e 00 00       	call   800f51 <snprintf>
  8000b0:	89 c7                	mov    %eax,%edi
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  8000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	89 04 24             	mov    %eax,(%esp)
  8000bf:	e8 bd 19 00 00       	call   801a81 <write>
		return -1;
  8000c4:	39 f8                	cmp    %edi,%eax
  8000c6:	0f 94 c0             	sete   %al
  8000c9:	0f b6 c0             	movzbl %al,%eax
  8000cc:	48                   	dec    %eax
  8000cd:	eb 0c                	jmp    8000db <send_error+0x8a>
			break;
		e++;
	}

	if (e->code == 0)
		return -1;
  8000cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8000d4:	eb 05                	jmp    8000db <send_error+0x8a>
  8000d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}
  8000db:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <send_data>:
	return 0;
}

static int
send_data(struct http_request *req, int fd)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	81 ec 3c 04 00 00    	sub    $0x43c,%esp
  8000f2:	89 c7                	mov    %eax,%edi
  8000f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// LAB 6: Your code here.
	//panic("send_data not implemented");

	int length;
	int BYTE_INCREMENT = 1024;
	char tmp_buf[BYTE_INCREMENT];
  8000f7:	8d 74 24 1b          	lea    0x1b(%esp),%esi
  8000fb:	83 e6 f0             	and    $0xfffffff0,%esi
	while((length = read(fd, tmp_buf, BYTE_INCREMENT)) > 0) {
  8000fe:	eb 20                	jmp    800120 <send_data+0x3a>
		if (write(req->sock, tmp_buf, length) != length)
  800100:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800104:	89 74 24 04          	mov    %esi,0x4(%esp)
  800108:	8b 07                	mov    (%edi),%eax
  80010a:	89 04 24             	mov    %eax,(%esp)
  80010d:	e8 6f 19 00 00       	call   801a81 <write>
  800112:	39 d8                	cmp    %ebx,%eax
  800114:	74 0a                	je     800120 <send_data+0x3a>
			die("send_data: unable to write data to socket");
  800116:	b8 7c 30 80 00       	mov    $0x80307c,%eax
  80011b:	e8 14 ff ff ff       	call   800034 <die>
	//panic("send_data not implemented");

	int length;
	int BYTE_INCREMENT = 1024;
	char tmp_buf[BYTE_INCREMENT];
	while((length = read(fd, tmp_buf, BYTE_INCREMENT)) > 0) {
  800120:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  800127:	00 
  800128:	89 74 24 04          	mov    %esi,0x4(%esp)
  80012c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012f:	89 04 24             	mov    %eax,(%esp)
  800132:	e8 6f 18 00 00       	call   8019a6 <read>
  800137:	89 c3                	mov    %eax,%ebx
  800139:	85 c0                	test   %eax,%eax
  80013b:	7f c3                	jg     800100 <send_data+0x1a>
		if (write(req->sock, tmp_buf, length) != length)
			die("send_data: unable to write data to socket");
	}

	return 0;
}
  80013d:	b8 00 00 00 00       	mov    $0x0,%eax
  800142:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	81 ec 4c 03 00 00    	sub    $0x34c,%esp
  800156:	89 c7                	mov    %eax,%edi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  800158:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80015f:	00 
  800160:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016a:	89 3c 24             	mov    %edi,(%esp)
  80016d:	e8 34 18 00 00       	call   8019a6 <read>
  800172:	85 c0                	test   %eax,%eax
  800174:	79 1c                	jns    800192 <handle_client+0x48>
			panic("failed to read");
  800176:	c7 44 24 08 64 2f 80 	movl   $0x802f64,0x8(%esp)
  80017d:	00 
  80017e:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  800185:	00 
  800186:	c7 04 24 73 2f 80 00 	movl   $0x802f73,(%esp)
  80018d:	e8 7a 07 00 00       	call   80090c <_panic>

		memset(req, 0, sizeof(req));
  800192:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001a1:	00 
{
	struct http_request con_d;
	int r;
	char buffer[BUFFSIZE];
	int received = -1;
	struct http_request *req = &con_d;
  8001a2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8001a5:	89 04 24             	mov    %eax,(%esp)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			panic("failed to read");

		memset(req, 0, sizeof(req));
  8001a8:	e8 31 0f 00 00       	call   8010de <memset>

		req->sock = sock;
  8001ad:	89 7d dc             	mov    %edi,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  8001b0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  8001b7:	00 
  8001b8:	c7 44 24 04 80 2f 80 	movl   $0x802f80,0x4(%esp)
  8001bf:	00 

		memset(req, 0, sizeof(req));

		req->sock = sock;

		r = http_request_parse(req, buffer);
  8001c0:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8001c6:	89 04 24             	mov    %eax,(%esp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  8001c9:	e8 a9 0e 00 00       	call   801077 <strncmp>
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	0f 85 1f 02 00 00    	jne    8003f5 <handle_client+0x2ab>
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  8001d6:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8001dc:	eb 01                	jmp    8001df <handle_client+0x95>

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  8001de:	43                   	inc    %ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8001df:	8a 03                	mov    (%ebx),%al
  8001e1:	84 c0                	test   %al,%al
  8001e3:	74 04                	je     8001e9 <handle_client+0x9f>
  8001e5:	3c 20                	cmp    $0x20,%al
  8001e7:	75 f5                	jne    8001de <handle_client+0x94>

	if (strncmp(request, "GET ", 4) != 0)
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  8001e9:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  8001ef:	89 85 c4 fc ff ff    	mov    %eax,-0x33c(%ebp)

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
	url_len = request - url;
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	29 c6                	sub    %eax,%esi

	req->url = malloc(url_len + 1);
  8001f9:	8d 46 01             	lea    0x1(%esi),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 e4 22 00 00       	call   8024e8 <malloc>
  800204:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  800207:	89 74 24 08          	mov    %esi,0x8(%esp)

	if (strncmp(request, "GET ", 4) != 0)
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  80020b:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
  800211:	89 54 24 04          	mov    %edx,0x4(%esp)
	while (*request && *request != ' ')
		request++;
	url_len = request - url;

	req->url = malloc(url_len + 1);
	memmove(req->url, url, url_len);
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 0b 0f 00 00       	call   801128 <memmove>
	req->url[url_len] = '\0';
  80021d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800220:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  800224:	8d 73 01             	lea    0x1(%ebx),%esi
  800227:	89 f3                	mov    %esi,%ebx
  800229:	eb 01                	jmp    80022c <handle_client+0xe2>

	version = request;
	while (*request && *request != '\n')
		request++;
  80022b:	43                   	inc    %ebx

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  80022c:	8a 03                	mov    (%ebx),%al
  80022e:	84 c0                	test   %al,%al
  800230:	74 04                	je     800236 <handle_client+0xec>
  800232:	3c 0a                	cmp    $0xa,%al
  800234:	75 f5                	jne    80022b <handle_client+0xe1>
		request++;
	version_len = request - version;
  800236:	29 f3                	sub    %esi,%ebx

	req->version = malloc(version_len + 1);
  800238:	8d 43 01             	lea    0x1(%ebx),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 a5 22 00 00       	call   8024e8 <malloc>
  800243:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  800246:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	e8 d2 0e 00 00       	call   801128 <memmove>
	req->version[version_len] = '\0';
  800256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800259:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
	// set file_size to the size of the file

	// LAB 6: Your code here.
	//panic("send_file not implemented");
	
	if ((fd = open(req->url, O_RDONLY))< 0) {
  80025d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800264:	00 
  800265:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 0c 1c 00 00       	call   801e7c <open>
  800270:	89 c6                	mov    %eax,%esi
  800272:	85 c0                	test   %eax,%eax
  800274:	79 12                	jns    800288 <handle_client+0x13e>
		send_error(req, 404);	
  800276:	ba 94 01 00 00       	mov    $0x194,%edx
  80027b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80027e:	e8 ce fd ff ff       	call   800051 <send_error>
  800283:	e9 3c 01 00 00       	jmp    8003c4 <handle_client+0x27a>
		r = fd;
		goto end;
	}

	if ((r = stat(req->url, &statbuf)) < 0 || statbuf.st_isdir ) {
  800288:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  80028e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800292:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	e8 97 19 00 00       	call   801c34 <stat>
  80029d:	85 c0                	test   %eax,%eax
  80029f:	78 09                	js     8002aa <handle_client+0x160>
  8002a1:	83 bd 54 fd ff ff 00 	cmpl   $0x0,-0x2ac(%ebp)
  8002a8:	74 1e                	je     8002c8 <handle_client+0x17e>
		send_error(req, 404);
  8002aa:	ba 94 01 00 00       	mov    $0x194,%edx
  8002af:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8002b2:	e8 9a fd ff ff       	call   800051 <send_error>
  8002b7:	e9 08 01 00 00       	jmp    8003c4 <handle_client+0x27a>
static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
  8002bc:	3d c8 00 00 00       	cmp    $0xc8,%eax
  8002c1:	74 1a                	je     8002dd <handle_client+0x193>
			break;
		h++;
  8002c3:	83 c3 08             	add    $0x8,%ebx
  8002c6:	eb 05                	jmp    8002cd <handle_client+0x183>
}

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
  8002c8:	bb 10 40 80 00       	mov    $0x804010,%ebx
	while (h->code != 0 && h->header!= 0) {
  8002cd:	8b 03                	mov    (%ebx),%eax
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	0f 84 ed 00 00 00    	je     8003c4 <handle_client+0x27a>
  8002d7:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8002db:	75 df                	jne    8002bc <handle_client+0x172>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  8002dd:	8b 43 04             	mov    0x4(%ebx),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	e8 94 0c 00 00       	call   800f7c <strlen>
  8002e8:	89 85 c0 fc ff ff    	mov    %eax,-0x340(%ebp)
	if (write(req->sock, h->header, len) != len) {
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8002f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	e8 7d 17 00 00       	call   801a81 <write>
  800304:	39 85 c0 fc ff ff    	cmp    %eax,-0x340(%ebp)
  80030a:	0f 84 f4 00 00 00    	je     800404 <handle_client+0x2ba>
		die("Failed to send bytes to client");
  800310:	b8 a8 30 80 00       	mov    $0x8030a8,%eax
  800315:	e8 1a fd ff ff       	call   800034 <die>
  80031a:	e9 e5 00 00 00       	jmp    800404 <handle_client+0x2ba>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  80031f:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  800326:	00 
  800327:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  80032e:	00 
  80032f:	c7 04 24 73 2f 80 00 	movl   $0x802f73,(%esp)
  800336:	e8 d1 05 00 00       	call   80090c <_panic>

	if (write(req->sock, buf, r) != r)
  80033b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033f:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800345:	89 44 24 04          	mov    %eax,0x4(%esp)
  800349:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034c:	89 04 24             	mov    %eax,(%esp)
  80034f:	e8 2d 17 00 00       	call   801a81 <write>
  800354:	39 c3                	cmp    %eax,%ebx
  800356:	0f 84 de 00 00 00    	je     80043a <handle_client+0x2f0>
  80035c:	eb 66                	jmp    8003c4 <handle_client+0x27a>
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
	if (r > 127)
		panic("buffer too small!");
  80035e:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  800365:	00 
  800366:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  80036d:	00 
  80036e:	c7 04 24 73 2f 80 00 	movl   $0x802f73,(%esp)
  800375:	e8 92 05 00 00       	call   80090c <_panic>

	if (write(req->sock, buf, r) != r)
  80037a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80037e:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800384:	89 44 24 04          	mov    %eax,0x4(%esp)
  800388:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038b:	89 04 24             	mov    %eax,(%esp)
  80038e:	e8 ee 16 00 00       	call   801a81 <write>
  800393:	39 c3                	cmp    %eax,%ebx
  800395:	75 2d                	jne    8003c4 <handle_client+0x27a>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  800397:	c7 04 24 aa 2f 80 00 	movl   $0x802faa,(%esp)
  80039e:	e8 d9 0b 00 00       	call   800f7c <strlen>
  8003a3:	89 c3                	mov    %eax,%ebx

	if (write(req->sock, fin, fin_len) != fin_len)
  8003a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a9:	c7 44 24 04 aa 2f 80 	movl   $0x802faa,0x4(%esp)
  8003b0:	00 
  8003b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 c5 16 00 00       	call   801a81 <write>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	0f 84 ac 00 00 00    	je     800470 <handle_client+0x326>
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  8003c4:	89 34 24             	mov    %esi,(%esp)
  8003c7:	e8 76 14 00 00       	call   801842 <close>
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  8003cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 41 20 00 00       	call   802418 <free>
	free(req->version);
  8003d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	e8 36 20 00 00       	call   802418 <free>

		// no keep alive
		break;
	}

	close(sock);
  8003e2:	89 3c 24             	mov    %edi,(%esp)
  8003e5:	e8 58 14 00 00       	call   801842 <close>
}
  8003ea:	81 c4 4c 03 00 00    	add    $0x34c,%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  8003f5:	ba 90 01 00 00       	mov    $0x190,%edx
  8003fa:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8003fd:	e8 4f fc ff ff       	call   800051 <send_error>
  800402:	eb c8                	jmp    8003cc <handle_client+0x282>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  800404:	c7 44 24 0c ff ff ff 	movl   $0xffffffff,0xc(%esp)
  80040b:	ff 
  80040c:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
  800413:	00 
  800414:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80041b:	00 
  80041c:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	e8 27 0b 00 00       	call   800f51 <snprintf>
  80042a:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  80042c:	83 f8 3f             	cmp    $0x3f,%eax
  80042f:	0f 8e 06 ff ff ff    	jle    80033b <handle_client+0x1f1>
  800435:	e9 e5 fe ff ff       	jmp    80031f <handle_client+0x1d5>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  80043a:	c7 44 24 0c ad 2f 80 	movl   $0x802fad,0xc(%esp)
  800441:	00 
  800442:	c7 44 24 08 b7 2f 80 	movl   $0x802fb7,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800451:	00 
  800452:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 f1 0a 00 00       	call   800f51 <snprintf>
  800460:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  800462:	83 f8 7f             	cmp    $0x7f,%eax
  800465:	0f 8e 0f ff ff ff    	jle    80037a <handle_client+0x230>
  80046b:	e9 ee fe ff ff       	jmp    80035e <handle_client+0x214>
		goto end;

	if ((r = send_header_fin(req)) < 0)
		goto end;

	r = send_data(req, fd);
  800470:	89 f2                	mov    %esi,%edx
  800472:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800475:	e8 6c fc ff ff       	call   8000e6 <send_data>
  80047a:	e9 45 ff ff ff       	jmp    8003c4 <handle_client+0x27a>

0080047f <umain>:
	close(sock);
}

void
umain(int argc, char **argv)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	57                   	push   %edi
  800483:	56                   	push   %esi
  800484:	53                   	push   %ebx
  800485:	83 ec 4c             	sub    $0x4c,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  800488:	c7 05 20 40 80 00 ca 	movl   $0x802fca,0x804020
  80048f:	2f 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800492:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800499:	00 
  80049a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8004a1:	00 
  8004a2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8004a9:	e8 85 1c 00 00       	call   802133 <socket>
  8004ae:	89 c6                	mov    %eax,%esi
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	79 0a                	jns    8004be <umain+0x3f>
		die("Failed to create socket");
  8004b4:	b8 d1 2f 80 00       	mov    $0x802fd1,%eax
  8004b9:	e8 76 fb ff ff       	call   800034 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  8004be:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8004c5:	00 
  8004c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004cd:	00 
  8004ce:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8004d1:	89 1c 24             	mov    %ebx,(%esp)
  8004d4:	e8 05 0c 00 00       	call   8010de <memset>
	server.sin_family = AF_INET;			// Internet/IP
  8004d9:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  8004dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004e4:	e8 5c 01 00 00       	call   800645 <htonl>
  8004e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  8004ec:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8004f3:	e8 2d 01 00 00       	call   800625 <htons>
  8004f8:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  8004fc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800503:	00 
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	89 34 24             	mov    %esi,(%esp)
  80050b:	e8 89 1b 00 00       	call   802099 <bind>
  800510:	85 c0                	test   %eax,%eax
  800512:	79 0a                	jns    80051e <umain+0x9f>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  800514:	b8 c8 30 80 00       	mov    $0x8030c8,%eax
  800519:	e8 16 fb ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80051e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800525:	00 
  800526:	89 34 24             	mov    %esi,(%esp)
  800529:	e8 e2 1b 00 00       	call   802110 <listen>
  80052e:	85 c0                	test   %eax,%eax
  800530:	79 0a                	jns    80053c <umain+0xbd>
		die("Failed to listen on server socket");
  800532:	b8 ec 30 80 00       	mov    $0x8030ec,%eax
  800537:	e8 f8 fa ff ff       	call   800034 <die>

	cprintf("Waiting for http connections...\n");
  80053c:	c7 04 24 10 31 80 00 	movl   $0x803110,(%esp)
  800543:	e8 bc 04 00 00       	call   800a04 <cprintf>
	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
  800548:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  80054b:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
  800552:	89 7c 24 08          	mov    %edi,0x8(%esp)

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
					 (struct sockaddr *) &client,
  800556:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	e8 01 1b 00 00       	call   802066 <accept>
  800565:	89 c3                	mov    %eax,%ebx
  800567:	85 c0                	test   %eax,%eax
  800569:	79 0a                	jns    800575 <umain+0xf6>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  80056b:	b8 34 31 80 00       	mov    $0x803134,%eax
  800570:	e8 bf fa ff ff       	call   800034 <die>
		}
		handle_client(clientsock);
  800575:	89 d8                	mov    %ebx,%eax
  800577:	e8 ce fb ff ff       	call   80014a <handle_client>
	}
  80057c:	eb cd                	jmp    80054b <umain+0xcc>
	...

00800580 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80058f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800593:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800596:	c7 45 dc 00 50 80 00 	movl   $0x805000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  80059d:	b2 00                	mov    $0x0,%dl
  80059f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8005a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a5:	8a 00                	mov    (%eax),%al
  8005a7:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  8005aa:	0f b6 c0             	movzbl %al,%eax
  8005ad:	8d 34 80             	lea    (%eax,%eax,4),%esi
  8005b0:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  8005b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b6:	66 c1 e8 0b          	shr    $0xb,%ax
  8005ba:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005bd:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  8005bf:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8005c2:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  8005c5:	d1 e7                	shl    %edi
  8005c7:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  8005ca:	89 f9                	mov    %edi,%ecx
  8005cc:	28 cb                	sub    %cl,%bl
  8005ce:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  8005d0:	8d 4f 30             	lea    0x30(%edi),%ecx
  8005d3:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  8005d7:	42                   	inc    %edx
    } while(*ap);
  8005d8:	84 c0                	test   %al,%al
  8005da:	75 c6                	jne    8005a2 <inet_ntoa+0x22>
  8005dc:	88 d0                	mov    %dl,%al
  8005de:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e1:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005e4:	eb 0b                	jmp    8005f1 <inet_ntoa+0x71>
    while(i--)
  8005e6:	48                   	dec    %eax
      *rp++ = inv[i];
  8005e7:	0f b6 f0             	movzbl %al,%esi
  8005ea:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  8005ee:	88 19                	mov    %bl,(%ecx)
  8005f0:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8005f1:	84 c0                	test   %al,%al
  8005f3:	75 f1                	jne    8005e6 <inet_ntoa+0x66>
  8005f5:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8005f8:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8005fb:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  8005fe:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800601:	fe 45 e3             	incb   -0x1d(%ebp)
  800604:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  800608:	77 0b                	ja     800615 <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  80060a:	42                   	inc    %edx
  80060b:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  80060e:	ff 45 d8             	incl   -0x28(%ebp)
  800611:	88 c2                	mov    %al,%dl
  800613:	eb 8d                	jmp    8005a2 <inet_ntoa+0x22>
  }
  *--rp = 0;
  800615:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  800618:	b8 00 50 80 00       	mov    $0x805000,%eax
  80061d:	83 c4 1c             	add    $0x1c,%esp
  800620:	5b                   	pop    %ebx
  800621:	5e                   	pop    %esi
  800622:	5f                   	pop    %edi
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80062f:	5d                   	pop    %ebp
  800630:	c3                   	ret    

00800631 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  800637:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 e2 ff ff ff       	call   800625 <htons>
}
  800643:	c9                   	leave  
  800644:	c3                   	ret    

00800645 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  80064b:	89 d1                	mov    %edx,%ecx
  80064d:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800650:	89 d0                	mov    %edx,%eax
  800652:	c1 e0 18             	shl    $0x18,%eax
  800655:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  800657:	89 d1                	mov    %edx,%ecx
  800659:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80065f:	c1 e1 08             	shl    $0x8,%ecx
  800662:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  800664:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80066a:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  80066d:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	57                   	push   %edi
  800675:	56                   	push   %esi
  800676:	53                   	push   %ebx
  800677:	83 ec 24             	sub    $0x24,%esp
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  80067d:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800680:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800683:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800686:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800689:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80068c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80068f:	80 f9 09             	cmp    $0x9,%cl
  800692:	0f 87 8f 01 00 00    	ja     800827 <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800698:	83 fa 30             	cmp    $0x30,%edx
  80069b:	75 28                	jne    8006c5 <inet_aton+0x54>
      c = *++cp;
  80069d:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8006a1:	83 fa 78             	cmp    $0x78,%edx
  8006a4:	74 0f                	je     8006b5 <inet_aton+0x44>
  8006a6:	83 fa 58             	cmp    $0x58,%edx
  8006a9:	74 0a                	je     8006b5 <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8006ab:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8006ac:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8006b3:	eb 17                	jmp    8006cc <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8006b5:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8006b9:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8006bc:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  8006c3:	eb 07                	jmp    8006cc <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  8006c5:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  8006cc:	40                   	inc    %eax
  8006cd:	be 00 00 00 00       	mov    $0x0,%esi
  8006d2:	eb 01                	jmp    8006d5 <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8006d4:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  8006d5:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8006d8:	88 d1                	mov    %dl,%cl
  8006da:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8006dd:	80 fb 09             	cmp    $0x9,%bl
  8006e0:	77 0d                	ja     8006ef <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  8006e2:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8006e6:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8006ea:	0f be 10             	movsbl (%eax),%edx
  8006ed:	eb e5                	jmp    8006d4 <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  8006ef:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8006f3:	75 30                	jne    800725 <inet_aton+0xb4>
  8006f5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8006f8:	88 5d da             	mov    %bl,-0x26(%ebp)
  8006fb:	80 fb 05             	cmp    $0x5,%bl
  8006fe:	76 08                	jbe    800708 <inet_aton+0x97>
  800700:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800703:	80 fb 05             	cmp    $0x5,%bl
  800706:	77 23                	ja     80072b <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800708:	89 f1                	mov    %esi,%ecx
  80070a:	c1 e1 04             	shl    $0x4,%ecx
  80070d:	8d 72 0a             	lea    0xa(%edx),%esi
  800710:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  800714:	19 d2                	sbb    %edx,%edx
  800716:	83 e2 20             	and    $0x20,%edx
  800719:	83 c2 41             	add    $0x41,%edx
  80071c:	29 d6                	sub    %edx,%esi
  80071e:	09 ce                	or     %ecx,%esi
        c = *++cp;
  800720:	0f be 10             	movsbl (%eax),%edx
  800723:	eb af                	jmp    8006d4 <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  800725:	89 d0                	mov    %edx,%eax
  800727:	89 f3                	mov    %esi,%ebx
  800729:	eb 04                	jmp    80072f <inet_aton+0xbe>
  80072b:	89 d0                	mov    %edx,%eax
  80072d:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  80072f:	83 f8 2e             	cmp    $0x2e,%eax
  800732:	75 23                	jne    800757 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800734:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800737:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  80073a:	0f 83 ee 00 00 00    	jae    80082e <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  800740:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800743:	89 1a                	mov    %ebx,(%edx)
  800745:	83 c2 04             	add    $0x4,%edx
  800748:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  80074b:	8d 47 01             	lea    0x1(%edi),%eax
  80074e:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  800752:	e9 35 ff ff ff       	jmp    80068c <inet_aton+0x1b>
  800757:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  800759:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80075b:	85 d2                	test   %edx,%edx
  80075d:	74 33                	je     800792 <inet_aton+0x121>
  80075f:	80 f9 1f             	cmp    $0x1f,%cl
  800762:	0f 86 cd 00 00 00    	jbe    800835 <inet_aton+0x1c4>
  800768:	84 d2                	test   %dl,%dl
  80076a:	0f 88 cc 00 00 00    	js     80083c <inet_aton+0x1cb>
  800770:	83 fa 20             	cmp    $0x20,%edx
  800773:	74 1d                	je     800792 <inet_aton+0x121>
  800775:	83 fa 0c             	cmp    $0xc,%edx
  800778:	74 18                	je     800792 <inet_aton+0x121>
  80077a:	83 fa 0a             	cmp    $0xa,%edx
  80077d:	74 13                	je     800792 <inet_aton+0x121>
  80077f:	83 fa 0d             	cmp    $0xd,%edx
  800782:	74 0e                	je     800792 <inet_aton+0x121>
  800784:	83 fa 09             	cmp    $0x9,%edx
  800787:	74 09                	je     800792 <inet_aton+0x121>
  800789:	83 fa 0b             	cmp    $0xb,%edx
  80078c:	0f 85 b1 00 00 00    	jne    800843 <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  800792:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800795:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800798:	29 d1                	sub    %edx,%ecx
  80079a:	89 ca                	mov    %ecx,%edx
  80079c:	c1 fa 02             	sar    $0x2,%edx
  80079f:	42                   	inc    %edx
  switch (n) {
  8007a0:	83 fa 02             	cmp    $0x2,%edx
  8007a3:	74 1b                	je     8007c0 <inet_aton+0x14f>
  8007a5:	83 fa 02             	cmp    $0x2,%edx
  8007a8:	7f 0a                	jg     8007b4 <inet_aton+0x143>
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	0f 84 98 00 00 00    	je     80084a <inet_aton+0x1d9>
  8007b2:	eb 59                	jmp    80080d <inet_aton+0x19c>
  8007b4:	83 fa 03             	cmp    $0x3,%edx
  8007b7:	74 1c                	je     8007d5 <inet_aton+0x164>
  8007b9:	83 fa 04             	cmp    $0x4,%edx
  8007bc:	75 4f                	jne    80080d <inet_aton+0x19c>
  8007be:	eb 2e                	jmp    8007ee <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8007c0:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  8007c5:	0f 87 86 00 00 00    	ja     800851 <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  8007cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ce:	c1 e3 18             	shl    $0x18,%ebx
  8007d1:	09 c3                	or     %eax,%ebx
    break;
  8007d3:	eb 38                	jmp    80080d <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8007d5:	3d ff ff 00 00       	cmp    $0xffff,%eax
  8007da:	77 7c                	ja     800858 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8007dc:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8007df:	c1 e3 10             	shl    $0x10,%ebx
  8007e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e5:	c1 e2 18             	shl    $0x18,%edx
  8007e8:	09 d3                	or     %edx,%ebx
  8007ea:	09 c3                	or     %eax,%ebx
    break;
  8007ec:	eb 1f                	jmp    80080d <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8007ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007f3:	77 6a                	ja     80085f <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8007f5:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8007f8:	c1 e3 10             	shl    $0x10,%ebx
  8007fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fe:	c1 e2 18             	shl    $0x18,%edx
  800801:	09 d3                	or     %edx,%ebx
  800803:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800806:	c1 e2 08             	shl    $0x8,%edx
  800809:	09 d3                	or     %edx,%ebx
  80080b:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  80080d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800811:	74 53                	je     800866 <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  800813:	89 1c 24             	mov    %ebx,(%esp)
  800816:	e8 2a fe ff ff       	call   800645 <htonl>
  80081b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80081e:	89 03                	mov    %eax,(%ebx)
  return (1);
  800820:	b8 01 00 00 00       	mov    $0x1,%eax
  800825:	eb 44                	jmp    80086b <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 3d                	jmp    80086b <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
  800833:	eb 36                	jmp    80086b <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	eb 2f                	jmp    80086b <inet_aton+0x1fa>
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 28                	jmp    80086b <inet_aton+0x1fa>
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 21                	jmp    80086b <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
  80084f:	eb 1a                	jmp    80086b <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 13                	jmp    80086b <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	eb 0c                	jmp    80086b <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
  800864:	eb 05                	jmp    80086b <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800866:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80086b:	83 c4 24             	add    $0x24,%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800879:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 e6 fd ff ff       	call   800671 <inet_aton>
  80088b:	85 c0                	test   %eax,%eax
  80088d:	74 05                	je     800894 <inet_addr+0x21>
    return (val.s_addr);
  80088f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800892:	eb 05                	jmp    800899 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  800894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	e8 99 fd ff ff       	call   800645 <htonl>
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    
	...

008008b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	56                   	push   %esi
  8008b4:	53                   	push   %ebx
  8008b5:	83 ec 10             	sub    $0x10,%esp
  8008b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8008be:	e8 a0 0a 00 00       	call   801363 <sys_getenvid>
  8008c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8008c8:	c1 e0 07             	shl    $0x7,%eax
  8008cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8008d0:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8008d5:	85 f6                	test   %esi,%esi
  8008d7:	7e 07                	jle    8008e0 <libmain+0x30>
		binaryname = argv[0];
  8008d9:	8b 03                	mov    (%ebx),%eax
  8008db:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	89 34 24             	mov    %esi,(%esp)
  8008e7:	e8 93 fb ff ff       	call   80047f <umain>

	// exit gracefully
	exit();
  8008ec:	e8 07 00 00 00       	call   8008f8 <exit>
}
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8008fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800905:	e8 07 0a 00 00       	call   801311 <sys_env_destroy>
}
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800914:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800917:	8b 1d 20 40 80 00    	mov    0x804020,%ebx
  80091d:	e8 41 0a 00 00       	call   801363 <sys_getenvid>
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 54 24 10          	mov    %edx,0x10(%esp)
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
  80092c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800930:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	c7 04 24 88 31 80 00 	movl   $0x803188,(%esp)
  80093f:	e8 c0 00 00 00       	call   800a04 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800944:	89 74 24 04          	mov    %esi,0x4(%esp)
  800948:	8b 45 10             	mov    0x10(%ebp),%eax
  80094b:	89 04 24             	mov    %eax,(%esp)
  80094e:	e8 50 00 00 00       	call   8009a3 <vcprintf>
	cprintf("\n");
  800953:	c7 04 24 ab 2f 80 00 	movl   $0x802fab,(%esp)
  80095a:	e8 a5 00 00 00       	call   800a04 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80095f:	cc                   	int3   
  800960:	eb fd                	jmp    80095f <_panic+0x53>
	...

00800964 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	83 ec 14             	sub    $0x14,%esp
  80096b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80096e:	8b 03                	mov    (%ebx),%eax
  800970:	8b 55 08             	mov    0x8(%ebp),%edx
  800973:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800977:	40                   	inc    %eax
  800978:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80097a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80097f:	75 19                	jne    80099a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800981:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800988:	00 
  800989:	8d 43 08             	lea    0x8(%ebx),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 40 09 00 00       	call   8012d4 <sys_cputs>
		b->idx = 0;
  800994:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80099a:	ff 43 04             	incl   0x4(%ebx)
}
  80099d:	83 c4 14             	add    $0x14,%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009b3:	00 00 00 
	b.cnt = 0;
  8009b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	c7 04 24 64 09 80 00 	movl   $0x800964,(%esp)
  8009df:	e8 82 01 00 00       	call   800b66 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	e8 d8 08 00 00       	call   8012d4 <sys_cputs>

	return b.cnt;
}
  8009fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a0a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	89 04 24             	mov    %eax,(%esp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    
	...

00800a20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	83 ec 3c             	sub    $0x3c,%esp
  800a29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a2c:	89 d7                	mov    %edx,%edi
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a3d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a40:	85 c0                	test   %eax,%eax
  800a42:	75 08                	jne    800a4c <printnum+0x2c>
  800a44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a47:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a4a:	77 57                	ja     800aa3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a4c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a50:	4b                   	dec    %ebx
  800a51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a55:	8b 45 10             	mov    0x10(%ebp),%eax
  800a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a60:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a6b:	00 
  800a6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a6f:	89 04 24             	mov    %eax,(%esp)
  800a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a79:	e8 82 22 00 00       	call   802d00 <__udivdi3>
  800a7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a82:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a86:	89 04 24             	mov    %eax,(%esp)
  800a89:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8d:	89 fa                	mov    %edi,%edx
  800a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a92:	e8 89 ff ff ff       	call   800a20 <printnum>
  800a97:	eb 0f                	jmp    800aa8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9d:	89 34 24             	mov    %esi,(%esp)
  800aa0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800aa3:	4b                   	dec    %ebx
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	7f f1                	jg     800a99 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800aa8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ab0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800abe:	00 
  800abf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ac2:	89 04 24             	mov    %eax,(%esp)
  800ac5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acc:	e8 4f 23 00 00       	call   802e20 <__umoddi3>
  800ad1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad5:	0f be 80 ab 31 80 00 	movsbl 0x8031ab(%eax),%eax
  800adc:	89 04 24             	mov    %eax,(%esp)
  800adf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800ae2:	83 c4 3c             	add    $0x3c,%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800aed:	83 fa 01             	cmp    $0x1,%edx
  800af0:	7e 0e                	jle    800b00 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800af2:	8b 10                	mov    (%eax),%edx
  800af4:	8d 4a 08             	lea    0x8(%edx),%ecx
  800af7:	89 08                	mov    %ecx,(%eax)
  800af9:	8b 02                	mov    (%edx),%eax
  800afb:	8b 52 04             	mov    0x4(%edx),%edx
  800afe:	eb 22                	jmp    800b22 <getuint+0x38>
	else if (lflag)
  800b00:	85 d2                	test   %edx,%edx
  800b02:	74 10                	je     800b14 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b04:	8b 10                	mov    (%eax),%edx
  800b06:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b09:	89 08                	mov    %ecx,(%eax)
  800b0b:	8b 02                	mov    (%edx),%eax
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	eb 0e                	jmp    800b22 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b19:	89 08                	mov    %ecx,(%eax)
  800b1b:	8b 02                	mov    (%edx),%eax
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b2a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b2d:	8b 10                	mov    (%eax),%edx
  800b2f:	3b 50 04             	cmp    0x4(%eax),%edx
  800b32:	73 08                	jae    800b3c <sprintputch+0x18>
		*b->buf++ = ch;
  800b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b37:	88 0a                	mov    %cl,(%edx)
  800b39:	42                   	inc    %edx
  800b3a:	89 10                	mov    %edx,(%eax)
}
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b44:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	89 04 24             	mov    %eax,(%esp)
  800b5f:	e8 02 00 00 00       	call   800b66 <vprintfmt>
	va_end(ap);
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 4c             	sub    $0x4c,%esp
  800b6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b72:	8b 75 10             	mov    0x10(%ebp),%esi
  800b75:	eb 12                	jmp    800b89 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800b77:	85 c0                	test   %eax,%eax
  800b79:	0f 84 6b 03 00 00    	je     800eea <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800b7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b89:	0f b6 06             	movzbl (%esi),%eax
  800b8c:	46                   	inc    %esi
  800b8d:	83 f8 25             	cmp    $0x25,%eax
  800b90:	75 e5                	jne    800b77 <vprintfmt+0x11>
  800b92:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b96:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800b9d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800ba2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ba9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bae:	eb 26                	jmp    800bd6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800bb3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800bb7:	eb 1d                	jmp    800bd6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bbc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800bc0:	eb 14                	jmp    800bd6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800bc5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800bcc:	eb 08                	jmp    800bd6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800bce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800bd1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd6:	0f b6 06             	movzbl (%esi),%eax
  800bd9:	8d 56 01             	lea    0x1(%esi),%edx
  800bdc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bdf:	8a 16                	mov    (%esi),%dl
  800be1:	83 ea 23             	sub    $0x23,%edx
  800be4:	80 fa 55             	cmp    $0x55,%dl
  800be7:	0f 87 e1 02 00 00    	ja     800ece <vprintfmt+0x368>
  800bed:	0f b6 d2             	movzbl %dl,%edx
  800bf0:	ff 24 95 e0 32 80 00 	jmp    *0x8032e0(,%edx,4)
  800bf7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800bff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800c02:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800c06:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c09:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c0c:	83 fa 09             	cmp    $0x9,%edx
  800c0f:	77 2a                	ja     800c3b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c11:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c12:	eb eb                	jmp    800bff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c14:	8b 45 14             	mov    0x14(%ebp),%eax
  800c17:	8d 50 04             	lea    0x4(%eax),%edx
  800c1a:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c22:	eb 17                	jmp    800c3b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c28:	78 98                	js     800bc2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c2a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c2d:	eb a7                	jmp    800bd6 <vprintfmt+0x70>
  800c2f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c32:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c39:	eb 9b                	jmp    800bd6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c3b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c3f:	79 95                	jns    800bd6 <vprintfmt+0x70>
  800c41:	eb 8b                	jmp    800bce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c43:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c44:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c47:	eb 8d                	jmp    800bd6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c49:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4c:	8d 50 04             	lea    0x4(%eax),%edx
  800c4f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c56:	8b 00                	mov    (%eax),%eax
  800c58:	89 04 24             	mov    %eax,(%esp)
  800c5b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800c61:	e9 23 ff ff ff       	jmp    800b89 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c66:	8b 45 14             	mov    0x14(%ebp),%eax
  800c69:	8d 50 04             	lea    0x4(%eax),%edx
  800c6c:	89 55 14             	mov    %edx,0x14(%ebp)
  800c6f:	8b 00                	mov    (%eax),%eax
  800c71:	85 c0                	test   %eax,%eax
  800c73:	79 02                	jns    800c77 <vprintfmt+0x111>
  800c75:	f7 d8                	neg    %eax
  800c77:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c79:	83 f8 11             	cmp    $0x11,%eax
  800c7c:	7f 0b                	jg     800c89 <vprintfmt+0x123>
  800c7e:	8b 04 85 40 34 80 00 	mov    0x803440(,%eax,4),%eax
  800c85:	85 c0                	test   %eax,%eax
  800c87:	75 23                	jne    800cac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800c89:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c8d:	c7 44 24 08 c3 31 80 	movl   $0x8031c3,0x8(%esp)
  800c94:	00 
  800c95:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	89 04 24             	mov    %eax,(%esp)
  800c9f:	e8 9a fe ff ff       	call   800b3e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ca7:	e9 dd fe ff ff       	jmp    800b89 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb0:	c7 44 24 08 7d 35 80 	movl   $0x80357d,0x8(%esp)
  800cb7:	00 
  800cb8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 14 24             	mov    %edx,(%esp)
  800cc2:	e8 77 fe ff ff       	call   800b3e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cca:	e9 ba fe ff ff       	jmp    800b89 <vprintfmt+0x23>
  800ccf:	89 f9                	mov    %edi,%ecx
  800cd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800cd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cda:	8d 50 04             	lea    0x4(%eax),%edx
  800cdd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ce0:	8b 30                	mov    (%eax),%esi
  800ce2:	85 f6                	test   %esi,%esi
  800ce4:	75 05                	jne    800ceb <vprintfmt+0x185>
				p = "(null)";
  800ce6:	be bc 31 80 00       	mov    $0x8031bc,%esi
			if (width > 0 && padc != '-')
  800ceb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800cef:	0f 8e 84 00 00 00    	jle    800d79 <vprintfmt+0x213>
  800cf5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800cf9:	74 7e                	je     800d79 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800cfb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cff:	89 34 24             	mov    %esi,(%esp)
  800d02:	e8 8b 02 00 00       	call   800f92 <strnlen>
  800d07:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d0a:	29 c2                	sub    %eax,%edx
  800d0c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d0f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800d13:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d16:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	89 d3                	mov    %edx,%ebx
  800d1d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d1f:	eb 0b                	jmp    800d2c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d25:	89 3c 24             	mov    %edi,(%esp)
  800d28:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d2b:	4b                   	dec    %ebx
  800d2c:	85 db                	test   %ebx,%ebx
  800d2e:	7f f1                	jg     800d21 <vprintfmt+0x1bb>
  800d30:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	79 05                	jns    800d44 <vprintfmt+0x1de>
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d47:	29 c2                	sub    %eax,%edx
  800d49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d4c:	eb 2b                	jmp    800d79 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d4e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d52:	74 18                	je     800d6c <vprintfmt+0x206>
  800d54:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d57:	83 fa 5e             	cmp    $0x5e,%edx
  800d5a:	76 10                	jbe    800d6c <vprintfmt+0x206>
					putch('?', putdat);
  800d5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d60:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800d67:	ff 55 08             	call   *0x8(%ebp)
  800d6a:	eb 0a                	jmp    800d76 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800d6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d70:	89 04 24             	mov    %eax,(%esp)
  800d73:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d76:	ff 4d e4             	decl   -0x1c(%ebp)
  800d79:	0f be 06             	movsbl (%esi),%eax
  800d7c:	46                   	inc    %esi
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	74 21                	je     800da2 <vprintfmt+0x23c>
  800d81:	85 ff                	test   %edi,%edi
  800d83:	78 c9                	js     800d4e <vprintfmt+0x1e8>
  800d85:	4f                   	dec    %edi
  800d86:	79 c6                	jns    800d4e <vprintfmt+0x1e8>
  800d88:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d90:	eb 18                	jmp    800daa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800d92:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d96:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800d9d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800d9f:	4b                   	dec    %ebx
  800da0:	eb 08                	jmp    800daa <vprintfmt+0x244>
  800da2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800daa:	85 db                	test   %ebx,%ebx
  800dac:	7f e4                	jg     800d92 <vprintfmt+0x22c>
  800dae:	89 7d 08             	mov    %edi,0x8(%ebp)
  800db1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800db3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800db6:	e9 ce fd ff ff       	jmp    800b89 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800dbb:	83 f9 01             	cmp    $0x1,%ecx
  800dbe:	7e 10                	jle    800dd0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800dc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc3:	8d 50 08             	lea    0x8(%eax),%edx
  800dc6:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc9:	8b 30                	mov    (%eax),%esi
  800dcb:	8b 78 04             	mov    0x4(%eax),%edi
  800dce:	eb 26                	jmp    800df6 <vprintfmt+0x290>
	else if (lflag)
  800dd0:	85 c9                	test   %ecx,%ecx
  800dd2:	74 12                	je     800de6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800dd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd7:	8d 50 04             	lea    0x4(%eax),%edx
  800dda:	89 55 14             	mov    %edx,0x14(%ebp)
  800ddd:	8b 30                	mov    (%eax),%esi
  800ddf:	89 f7                	mov    %esi,%edi
  800de1:	c1 ff 1f             	sar    $0x1f,%edi
  800de4:	eb 10                	jmp    800df6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800de6:	8b 45 14             	mov    0x14(%ebp),%eax
  800de9:	8d 50 04             	lea    0x4(%eax),%edx
  800dec:	89 55 14             	mov    %edx,0x14(%ebp)
  800def:	8b 30                	mov    (%eax),%esi
  800df1:	89 f7                	mov    %esi,%edi
  800df3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800df6:	85 ff                	test   %edi,%edi
  800df8:	78 0a                	js     800e04 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dff:	e9 8c 00 00 00       	jmp    800e90 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e08:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e0f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e12:	f7 de                	neg    %esi
  800e14:	83 d7 00             	adc    $0x0,%edi
  800e17:	f7 df                	neg    %edi
			}
			base = 10;
  800e19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1e:	eb 70                	jmp    800e90 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e20:	89 ca                	mov    %ecx,%edx
  800e22:	8d 45 14             	lea    0x14(%ebp),%eax
  800e25:	e8 c0 fc ff ff       	call   800aea <getuint>
  800e2a:	89 c6                	mov    %eax,%esi
  800e2c:	89 d7                	mov    %edx,%edi
			base = 10;
  800e2e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800e33:	eb 5b                	jmp    800e90 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800e35:	89 ca                	mov    %ecx,%edx
  800e37:	8d 45 14             	lea    0x14(%ebp),%eax
  800e3a:	e8 ab fc ff ff       	call   800aea <getuint>
  800e3f:	89 c6                	mov    %eax,%esi
  800e41:	89 d7                	mov    %edx,%edi
			base = 8;
  800e43:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800e48:	eb 46                	jmp    800e90 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800e4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e4e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e55:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e5c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e63:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e66:	8b 45 14             	mov    0x14(%ebp),%eax
  800e69:	8d 50 04             	lea    0x4(%eax),%edx
  800e6c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e6f:	8b 30                	mov    (%eax),%esi
  800e71:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e76:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800e7b:	eb 13                	jmp    800e90 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e7d:	89 ca                	mov    %ecx,%edx
  800e7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e82:	e8 63 fc ff ff       	call   800aea <getuint>
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	89 d7                	mov    %edx,%edi
			base = 16;
  800e8b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e90:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800e94:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea3:	89 34 24             	mov    %esi,(%esp)
  800ea6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eaa:	89 da                	mov    %ebx,%edx
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	e8 6c fb ff ff       	call   800a20 <printnum>
			break;
  800eb4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eb7:	e9 cd fc ff ff       	jmp    800b89 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ebc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec0:	89 04 24             	mov    %eax,(%esp)
  800ec3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ec6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ec9:	e9 bb fc ff ff       	jmp    800b89 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ece:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ed9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800edc:	eb 01                	jmp    800edf <vprintfmt+0x379>
  800ede:	4e                   	dec    %esi
  800edf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ee3:	75 f9                	jne    800ede <vprintfmt+0x378>
  800ee5:	e9 9f fc ff ff       	jmp    800b89 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800eea:	83 c4 4c             	add    $0x4c,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 28             	sub    $0x28,%esp
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800efe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f01:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f05:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	74 30                	je     800f43 <vsnprintf+0x51>
  800f13:	85 d2                	test   %edx,%edx
  800f15:	7e 33                	jle    800f4a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f17:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2c:	c7 04 24 24 0b 80 00 	movl   $0x800b24,(%esp)
  800f33:	e8 2e fc ff ff       	call   800b66 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f41:	eb 0c                	jmp    800f4f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f48:	eb 05                	jmp    800f4f <vsnprintf+0x5d>
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f57:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6f:	89 04 24             	mov    %eax,(%esp)
  800f72:	e8 7b ff ff ff       	call   800ef2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    
  800f79:	00 00                	add    %al,(%eax)
	...

00800f7c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  800f87:	eb 01                	jmp    800f8a <strlen+0xe>
		n++;
  800f89:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f8e:	75 f9                	jne    800f89 <strlen+0xd>
		n++;
	return n;
}
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800f98:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	eb 01                	jmp    800fa3 <strnlen+0x11>
		n++;
  800fa2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa3:	39 d0                	cmp    %edx,%eax
  800fa5:	74 06                	je     800fad <strnlen+0x1b>
  800fa7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fab:	75 f5                	jne    800fa2 <strnlen+0x10>
		n++;
	return n;
}
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	53                   	push   %ebx
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fc1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fc4:	42                   	inc    %edx
  800fc5:	84 c9                	test   %cl,%cl
  800fc7:	75 f5                	jne    800fbe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fc9:	5b                   	pop    %ebx
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fd6:	89 1c 24             	mov    %ebx,(%esp)
  800fd9:	e8 9e ff ff ff       	call   800f7c <strlen>
	strcpy(dst + len, src);
  800fde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe5:	01 d8                	add    %ebx,%eax
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	e8 c0 ff ff ff       	call   800faf <strcpy>
	return dst;
}
  800fef:	89 d8                	mov    %ebx,%eax
  800ff1:	83 c4 08             	add    $0x8,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801005:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100a:	eb 0c                	jmp    801018 <strncpy+0x21>
		*dst++ = *src;
  80100c:	8a 1a                	mov    (%edx),%bl
  80100e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801011:	80 3a 01             	cmpb   $0x1,(%edx)
  801014:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801017:	41                   	inc    %ecx
  801018:	39 f1                	cmp    %esi,%ecx
  80101a:	75 f0                	jne    80100c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	8b 75 08             	mov    0x8(%ebp),%esi
  801028:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80102e:	85 d2                	test   %edx,%edx
  801030:	75 0a                	jne    80103c <strlcpy+0x1c>
  801032:	89 f0                	mov    %esi,%eax
  801034:	eb 1a                	jmp    801050 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801036:	88 18                	mov    %bl,(%eax)
  801038:	40                   	inc    %eax
  801039:	41                   	inc    %ecx
  80103a:	eb 02                	jmp    80103e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80103c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80103e:	4a                   	dec    %edx
  80103f:	74 0a                	je     80104b <strlcpy+0x2b>
  801041:	8a 19                	mov    (%ecx),%bl
  801043:	84 db                	test   %bl,%bl
  801045:	75 ef                	jne    801036 <strlcpy+0x16>
  801047:	89 c2                	mov    %eax,%edx
  801049:	eb 02                	jmp    80104d <strlcpy+0x2d>
  80104b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80104d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801050:	29 f0                	sub    %esi,%eax
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80105f:	eb 02                	jmp    801063 <strcmp+0xd>
		p++, q++;
  801061:	41                   	inc    %ecx
  801062:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801063:	8a 01                	mov    (%ecx),%al
  801065:	84 c0                	test   %al,%al
  801067:	74 04                	je     80106d <strcmp+0x17>
  801069:	3a 02                	cmp    (%edx),%al
  80106b:	74 f4                	je     801061 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80106d:	0f b6 c0             	movzbl %al,%eax
  801070:	0f b6 12             	movzbl (%edx),%edx
  801073:	29 d0                	sub    %edx,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	53                   	push   %ebx
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801081:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801084:	eb 03                	jmp    801089 <strncmp+0x12>
		n--, p++, q++;
  801086:	4a                   	dec    %edx
  801087:	40                   	inc    %eax
  801088:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801089:	85 d2                	test   %edx,%edx
  80108b:	74 14                	je     8010a1 <strncmp+0x2a>
  80108d:	8a 18                	mov    (%eax),%bl
  80108f:	84 db                	test   %bl,%bl
  801091:	74 04                	je     801097 <strncmp+0x20>
  801093:	3a 19                	cmp    (%ecx),%bl
  801095:	74 ef                	je     801086 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801097:	0f b6 00             	movzbl (%eax),%eax
  80109a:	0f b6 11             	movzbl (%ecx),%edx
  80109d:	29 d0                	sub    %edx,%eax
  80109f:	eb 05                	jmp    8010a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010b2:	eb 05                	jmp    8010b9 <strchr+0x10>
		if (*s == c)
  8010b4:	38 ca                	cmp    %cl,%dl
  8010b6:	74 0c                	je     8010c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010b8:	40                   	inc    %eax
  8010b9:	8a 10                	mov    (%eax),%dl
  8010bb:	84 d2                	test   %dl,%dl
  8010bd:	75 f5                	jne    8010b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010cf:	eb 05                	jmp    8010d6 <strfind+0x10>
		if (*s == c)
  8010d1:	38 ca                	cmp    %cl,%dl
  8010d3:	74 07                	je     8010dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010d5:	40                   	inc    %eax
  8010d6:	8a 10                	mov    (%eax),%dl
  8010d8:	84 d2                	test   %dl,%dl
  8010da:	75 f5                	jne    8010d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010ed:	85 c9                	test   %ecx,%ecx
  8010ef:	74 30                	je     801121 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010f7:	75 25                	jne    80111e <memset+0x40>
  8010f9:	f6 c1 03             	test   $0x3,%cl
  8010fc:	75 20                	jne    80111e <memset+0x40>
		c &= 0xFF;
  8010fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801101:	89 d3                	mov    %edx,%ebx
  801103:	c1 e3 08             	shl    $0x8,%ebx
  801106:	89 d6                	mov    %edx,%esi
  801108:	c1 e6 18             	shl    $0x18,%esi
  80110b:	89 d0                	mov    %edx,%eax
  80110d:	c1 e0 10             	shl    $0x10,%eax
  801110:	09 f0                	or     %esi,%eax
  801112:	09 d0                	or     %edx,%eax
  801114:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801116:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801119:	fc                   	cld    
  80111a:	f3 ab                	rep stos %eax,%es:(%edi)
  80111c:	eb 03                	jmp    801121 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80111e:	fc                   	cld    
  80111f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801121:	89 f8                	mov    %edi,%eax
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	8b 75 0c             	mov    0xc(%ebp),%esi
  801133:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801136:	39 c6                	cmp    %eax,%esi
  801138:	73 34                	jae    80116e <memmove+0x46>
  80113a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80113d:	39 d0                	cmp    %edx,%eax
  80113f:	73 2d                	jae    80116e <memmove+0x46>
		s += n;
		d += n;
  801141:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801144:	f6 c2 03             	test   $0x3,%dl
  801147:	75 1b                	jne    801164 <memmove+0x3c>
  801149:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80114f:	75 13                	jne    801164 <memmove+0x3c>
  801151:	f6 c1 03             	test   $0x3,%cl
  801154:	75 0e                	jne    801164 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801156:	83 ef 04             	sub    $0x4,%edi
  801159:	8d 72 fc             	lea    -0x4(%edx),%esi
  80115c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80115f:	fd                   	std    
  801160:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801162:	eb 07                	jmp    80116b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801164:	4f                   	dec    %edi
  801165:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801168:	fd                   	std    
  801169:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80116b:	fc                   	cld    
  80116c:	eb 20                	jmp    80118e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80116e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801174:	75 13                	jne    801189 <memmove+0x61>
  801176:	a8 03                	test   $0x3,%al
  801178:	75 0f                	jne    801189 <memmove+0x61>
  80117a:	f6 c1 03             	test   $0x3,%cl
  80117d:	75 0a                	jne    801189 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80117f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801182:	89 c7                	mov    %eax,%edi
  801184:	fc                   	cld    
  801185:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801187:	eb 05                	jmp    80118e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801189:	89 c7                	mov    %eax,%edi
  80118b:	fc                   	cld    
  80118c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801198:	8b 45 10             	mov    0x10(%ebp),%eax
  80119b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	89 04 24             	mov    %eax,(%esp)
  8011ac:	e8 77 ff ff ff       	call   801128 <memmove>
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c7:	eb 16                	jmp    8011df <memcmp+0x2c>
		if (*s1 != *s2)
  8011c9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011cc:	42                   	inc    %edx
  8011cd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011d1:	38 c8                	cmp    %cl,%al
  8011d3:	74 0a                	je     8011df <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011d5:	0f b6 c0             	movzbl %al,%eax
  8011d8:	0f b6 c9             	movzbl %cl,%ecx
  8011db:	29 c8                	sub    %ecx,%eax
  8011dd:	eb 09                	jmp    8011e8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011df:	39 da                	cmp    %ebx,%edx
  8011e1:	75 e6                	jne    8011c9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8011fb:	eb 05                	jmp    801202 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8011fd:	38 08                	cmp    %cl,(%eax)
  8011ff:	74 05                	je     801206 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801201:	40                   	inc    %eax
  801202:	39 d0                	cmp    %edx,%eax
  801204:	72 f7                	jb     8011fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	8b 55 08             	mov    0x8(%ebp),%edx
  801211:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801214:	eb 01                	jmp    801217 <strtol+0xf>
		s++;
  801216:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801217:	8a 02                	mov    (%edx),%al
  801219:	3c 20                	cmp    $0x20,%al
  80121b:	74 f9                	je     801216 <strtol+0xe>
  80121d:	3c 09                	cmp    $0x9,%al
  80121f:	74 f5                	je     801216 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801221:	3c 2b                	cmp    $0x2b,%al
  801223:	75 08                	jne    80122d <strtol+0x25>
		s++;
  801225:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801226:	bf 00 00 00 00       	mov    $0x0,%edi
  80122b:	eb 13                	jmp    801240 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80122d:	3c 2d                	cmp    $0x2d,%al
  80122f:	75 0a                	jne    80123b <strtol+0x33>
		s++, neg = 1;
  801231:	8d 52 01             	lea    0x1(%edx),%edx
  801234:	bf 01 00 00 00       	mov    $0x1,%edi
  801239:	eb 05                	jmp    801240 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80123b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801240:	85 db                	test   %ebx,%ebx
  801242:	74 05                	je     801249 <strtol+0x41>
  801244:	83 fb 10             	cmp    $0x10,%ebx
  801247:	75 28                	jne    801271 <strtol+0x69>
  801249:	8a 02                	mov    (%edx),%al
  80124b:	3c 30                	cmp    $0x30,%al
  80124d:	75 10                	jne    80125f <strtol+0x57>
  80124f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801253:	75 0a                	jne    80125f <strtol+0x57>
		s += 2, base = 16;
  801255:	83 c2 02             	add    $0x2,%edx
  801258:	bb 10 00 00 00       	mov    $0x10,%ebx
  80125d:	eb 12                	jmp    801271 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80125f:	85 db                	test   %ebx,%ebx
  801261:	75 0e                	jne    801271 <strtol+0x69>
  801263:	3c 30                	cmp    $0x30,%al
  801265:	75 05                	jne    80126c <strtol+0x64>
		s++, base = 8;
  801267:	42                   	inc    %edx
  801268:	b3 08                	mov    $0x8,%bl
  80126a:	eb 05                	jmp    801271 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80126c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801278:	8a 0a                	mov    (%edx),%cl
  80127a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80127d:	80 fb 09             	cmp    $0x9,%bl
  801280:	77 08                	ja     80128a <strtol+0x82>
			dig = *s - '0';
  801282:	0f be c9             	movsbl %cl,%ecx
  801285:	83 e9 30             	sub    $0x30,%ecx
  801288:	eb 1e                	jmp    8012a8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80128a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80128d:	80 fb 19             	cmp    $0x19,%bl
  801290:	77 08                	ja     80129a <strtol+0x92>
			dig = *s - 'a' + 10;
  801292:	0f be c9             	movsbl %cl,%ecx
  801295:	83 e9 57             	sub    $0x57,%ecx
  801298:	eb 0e                	jmp    8012a8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80129a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80129d:	80 fb 19             	cmp    $0x19,%bl
  8012a0:	77 12                	ja     8012b4 <strtol+0xac>
			dig = *s - 'A' + 10;
  8012a2:	0f be c9             	movsbl %cl,%ecx
  8012a5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012a8:	39 f1                	cmp    %esi,%ecx
  8012aa:	7d 0c                	jge    8012b8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012ac:	42                   	inc    %edx
  8012ad:	0f af c6             	imul   %esi,%eax
  8012b0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012b2:	eb c4                	jmp    801278 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012b4:	89 c1                	mov    %eax,%ecx
  8012b6:	eb 02                	jmp    8012ba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012b8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012be:	74 05                	je     8012c5 <strtol+0xbd>
		*endptr = (char *) s;
  8012c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012c5:	85 ff                	test   %edi,%edi
  8012c7:	74 04                	je     8012cd <strtol+0xc5>
  8012c9:	89 c8                	mov    %ecx,%eax
  8012cb:	f7 d8                	neg    %eax
}
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
	...

008012d4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e5:	89 c3                	mov    %eax,%ebx
  8012e7:	89 c7                	mov    %eax,%edi
  8012e9:	89 c6                	mov    %eax,%esi
  8012eb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801302:	89 d1                	mov    %edx,%ecx
  801304:	89 d3                	mov    %edx,%ebx
  801306:	89 d7                	mov    %edx,%edi
  801308:	89 d6                	mov    %edx,%esi
  80130a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5f                   	pop    %edi
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	57                   	push   %edi
  801315:	56                   	push   %esi
  801316:	53                   	push   %ebx
  801317:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80131a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80131f:	b8 03 00 00 00       	mov    $0x3,%eax
  801324:	8b 55 08             	mov    0x8(%ebp),%edx
  801327:	89 cb                	mov    %ecx,%ebx
  801329:	89 cf                	mov    %ecx,%edi
  80132b:	89 ce                	mov    %ecx,%esi
  80132d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80132f:	85 c0                	test   %eax,%eax
  801331:	7e 28                	jle    80135b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801333:	89 44 24 10          	mov    %eax,0x10(%esp)
  801337:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80133e:	00 
  80133f:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  801356:	e8 b1 f5 ff ff       	call   80090c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80135b:	83 c4 2c             	add    $0x2c,%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801369:	ba 00 00 00 00       	mov    $0x0,%edx
  80136e:	b8 02 00 00 00       	mov    $0x2,%eax
  801373:	89 d1                	mov    %edx,%ecx
  801375:	89 d3                	mov    %edx,%ebx
  801377:	89 d7                	mov    %edx,%edi
  801379:	89 d6                	mov    %edx,%esi
  80137b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <sys_yield>:

void
sys_yield(void)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801388:	ba 00 00 00 00       	mov    $0x0,%edx
  80138d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801392:	89 d1                	mov    %edx,%ecx
  801394:	89 d3                	mov    %edx,%ebx
  801396:	89 d7                	mov    %edx,%edi
  801398:	89 d6                	mov    %edx,%esi
  80139a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5f                   	pop    %edi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	57                   	push   %edi
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013aa:	be 00 00 00 00       	mov    $0x0,%esi
  8013af:	b8 04 00 00 00       	mov    $0x4,%eax
  8013b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bd:	89 f7                	mov    %esi,%edi
  8013bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	7e 28                	jle    8013ed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8013d0:	00 
  8013d1:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  8013e8:	e8 1f f5 ff ff       	call   80090c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013ed:	83 c4 2c             	add    $0x2c,%esp
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5f                   	pop    %edi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	57                   	push   %edi
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013fe:	b8 05 00 00 00       	mov    $0x5,%eax
  801403:	8b 75 18             	mov    0x18(%ebp),%esi
  801406:	8b 7d 14             	mov    0x14(%ebp),%edi
  801409:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80140c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140f:	8b 55 08             	mov    0x8(%ebp),%edx
  801412:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801414:	85 c0                	test   %eax,%eax
  801416:	7e 28                	jle    801440 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801418:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801423:	00 
  801424:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  80142b:	00 
  80142c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801433:	00 
  801434:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  80143b:	e8 cc f4 ff ff       	call   80090c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801440:	83 c4 2c             	add    $0x2c,%esp
  801443:	5b                   	pop    %ebx
  801444:	5e                   	pop    %esi
  801445:	5f                   	pop    %edi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	57                   	push   %edi
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801451:	bb 00 00 00 00       	mov    $0x0,%ebx
  801456:	b8 06 00 00 00       	mov    $0x6,%eax
  80145b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145e:	8b 55 08             	mov    0x8(%ebp),%edx
  801461:	89 df                	mov    %ebx,%edi
  801463:	89 de                	mov    %ebx,%esi
  801465:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801467:	85 c0                	test   %eax,%eax
  801469:	7e 28                	jle    801493 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80146b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801476:	00 
  801477:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  80147e:	00 
  80147f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801486:	00 
  801487:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  80148e:	e8 79 f4 ff ff       	call   80090c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801493:	83 c4 2c             	add    $0x2c,%esp
  801496:	5b                   	pop    %ebx
  801497:	5e                   	pop    %esi
  801498:	5f                   	pop    %edi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	57                   	push   %edi
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b4:	89 df                	mov    %ebx,%edi
  8014b6:	89 de                	mov    %ebx,%esi
  8014b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	7e 28                	jle    8014e6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014c2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8014c9:	00 
  8014ca:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  8014d1:	00 
  8014d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014d9:	00 
  8014da:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  8014e1:	e8 26 f4 ff ff       	call   80090c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014e6:	83 c4 2c             	add    $0x2c,%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fc:	b8 09 00 00 00       	mov    $0x9,%eax
  801501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801504:	8b 55 08             	mov    0x8(%ebp),%edx
  801507:	89 df                	mov    %ebx,%edi
  801509:	89 de                	mov    %ebx,%esi
  80150b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80150d:	85 c0                	test   %eax,%eax
  80150f:	7e 28                	jle    801539 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801511:	89 44 24 10          	mov    %eax,0x10(%esp)
  801515:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80151c:	00 
  80151d:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  801524:	00 
  801525:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80152c:	00 
  80152d:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  801534:	e8 d3 f3 ff ff       	call   80090c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801539:	83 c4 2c             	add    $0x2c,%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5f                   	pop    %edi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80154f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801557:	8b 55 08             	mov    0x8(%ebp),%edx
  80155a:	89 df                	mov    %ebx,%edi
  80155c:	89 de                	mov    %ebx,%esi
  80155e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801560:	85 c0                	test   %eax,%eax
  801562:	7e 28                	jle    80158c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801564:	89 44 24 10          	mov    %eax,0x10(%esp)
  801568:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80156f:	00 
  801570:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  801577:	00 
  801578:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80157f:	00 
  801580:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  801587:	e8 80 f3 ff ff       	call   80090c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80158c:	83 c4 2c             	add    $0x2c,%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5f                   	pop    %edi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	57                   	push   %edi
  801598:	56                   	push   %esi
  801599:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80159a:	be 00 00 00 00       	mov    $0x0,%esi
  80159f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8015a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5f                   	pop    %edi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	57                   	push   %edi
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8015ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8015cd:	89 cb                	mov    %ecx,%ebx
  8015cf:	89 cf                	mov    %ecx,%edi
  8015d1:	89 ce                	mov    %ecx,%esi
  8015d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	7e 28                	jle    801601 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015dd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8015e4:	00 
  8015e5:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  8015ec:	00 
  8015ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015f4:	00 
  8015f5:	c7 04 24 c4 34 80 00 	movl   $0x8034c4,(%esp)
  8015fc:	e8 0b f3 ff ff       	call   80090c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801601:	83 c4 2c             	add    $0x2c,%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5f                   	pop    %edi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	57                   	push   %edi
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80160f:	ba 00 00 00 00       	mov    $0x0,%edx
  801614:	b8 0e 00 00 00       	mov    $0xe,%eax
  801619:	89 d1                	mov    %edx,%ecx
  80161b:	89 d3                	mov    %edx,%ebx
  80161d:	89 d7                	mov    %edx,%edi
  80161f:	89 d6                	mov    %edx,%esi
  801621:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	57                   	push   %edi
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80162e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801633:	b8 10 00 00 00       	mov    $0x10,%eax
  801638:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163b:	8b 55 08             	mov    0x8(%ebp),%edx
  80163e:	89 df                	mov    %ebx,%edi
  801640:	89 de                	mov    %ebx,%esi
  801642:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5f                   	pop    %edi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	57                   	push   %edi
  80164d:	56                   	push   %esi
  80164e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80164f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801654:	b8 0f 00 00 00       	mov    $0xf,%eax
  801659:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165c:	8b 55 08             	mov    0x8(%ebp),%edx
  80165f:	89 df                	mov    %ebx,%edi
  801661:	89 de                	mov    %ebx,%esi
  801663:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  801665:	5b                   	pop    %ebx
  801666:	5e                   	pop    %esi
  801667:	5f                   	pop    %edi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	57                   	push   %edi
  80166e:	56                   	push   %esi
  80166f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801670:	b9 00 00 00 00       	mov    $0x0,%ecx
  801675:	b8 11 00 00 00       	mov    $0x11,%eax
  80167a:	8b 55 08             	mov    0x8(%ebp),%edx
  80167d:	89 cb                	mov    %ecx,%ebx
  80167f:	89 cf                	mov    %ecx,%edi
  801681:	89 ce                	mov    %ecx,%esi
  801683:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    
	...

0080168c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	05 00 00 00 30       	add    $0x30000000,%eax
  801697:	c1 e8 0c             	shr    $0xc,%eax
}
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	89 04 24             	mov    %eax,(%esp)
  8016a8:	e8 df ff ff ff       	call   80168c <fd2num>
  8016ad:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016b2:	c1 e0 0c             	shl    $0xc,%eax
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016c3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	c1 ea 16             	shr    $0x16,%edx
  8016ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016d1:	f6 c2 01             	test   $0x1,%dl
  8016d4:	74 11                	je     8016e7 <fd_alloc+0x30>
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	c1 ea 0c             	shr    $0xc,%edx
  8016db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016e2:	f6 c2 01             	test   $0x1,%dl
  8016e5:	75 09                	jne    8016f0 <fd_alloc+0x39>
			*fd_store = fd;
  8016e7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ee:	eb 17                	jmp    801707 <fd_alloc+0x50>
  8016f0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016fa:	75 c7                	jne    8016c3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801702:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801707:	5b                   	pop    %ebx
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801710:	83 f8 1f             	cmp    $0x1f,%eax
  801713:	77 36                	ja     80174b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801715:	05 00 00 0d 00       	add    $0xd0000,%eax
  80171a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	c1 ea 16             	shr    $0x16,%edx
  801722:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801729:	f6 c2 01             	test   $0x1,%dl
  80172c:	74 24                	je     801752 <fd_lookup+0x48>
  80172e:	89 c2                	mov    %eax,%edx
  801730:	c1 ea 0c             	shr    $0xc,%edx
  801733:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80173a:	f6 c2 01             	test   $0x1,%dl
  80173d:	74 1a                	je     801759 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80173f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801742:	89 02                	mov    %eax,(%edx)
	return 0;
  801744:	b8 00 00 00 00       	mov    $0x0,%eax
  801749:	eb 13                	jmp    80175e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80174b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801750:	eb 0c                	jmp    80175e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801757:	eb 05                	jmp    80175e <fd_lookup+0x54>
  801759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	53                   	push   %ebx
  801764:	83 ec 14             	sub    $0x14,%esp
  801767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	eb 0e                	jmp    801782 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801774:	39 08                	cmp    %ecx,(%eax)
  801776:	75 09                	jne    801781 <dev_lookup+0x21>
			*dev = devtab[i];
  801778:	89 03                	mov    %eax,(%ebx)
			return 0;
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
  80177f:	eb 33                	jmp    8017b4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801781:	42                   	inc    %edx
  801782:	8b 04 95 50 35 80 00 	mov    0x803550(,%edx,4),%eax
  801789:	85 c0                	test   %eax,%eax
  80178b:	75 e7                	jne    801774 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80178d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801792:	8b 40 48             	mov    0x48(%eax),%eax
  801795:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179d:	c7 04 24 d4 34 80 00 	movl   $0x8034d4,(%esp)
  8017a4:	e8 5b f2 ff ff       	call   800a04 <cprintf>
	*dev = 0;
  8017a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017b4:	83 c4 14             	add    $0x14,%esp
  8017b7:	5b                   	pop    %ebx
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	83 ec 30             	sub    $0x30,%esp
  8017c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c5:	8a 45 0c             	mov    0xc(%ebp),%al
  8017c8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017cb:	89 34 24             	mov    %esi,(%esp)
  8017ce:	e8 b9 fe ff ff       	call   80168c <fd2num>
  8017d3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 28 ff ff ff       	call   80170a <fd_lookup>
  8017e2:	89 c3                	mov    %eax,%ebx
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 05                	js     8017ed <fd_close+0x33>
	    || fd != fd2)
  8017e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017eb:	74 0d                	je     8017fa <fd_close+0x40>
		return (must_exist ? r : 0);
  8017ed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8017f1:	75 46                	jne    801839 <fd_close+0x7f>
  8017f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f8:	eb 3f                	jmp    801839 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 06                	mov    (%esi),%eax
  801803:	89 04 24             	mov    %eax,(%esp)
  801806:	e8 55 ff ff ff       	call   801760 <dev_lookup>
  80180b:	89 c3                	mov    %eax,%ebx
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 18                	js     801829 <fd_close+0x6f>
		if (dev->dev_close)
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	8b 40 10             	mov    0x10(%eax),%eax
  801817:	85 c0                	test   %eax,%eax
  801819:	74 09                	je     801824 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80181b:	89 34 24             	mov    %esi,(%esp)
  80181e:	ff d0                	call   *%eax
  801820:	89 c3                	mov    %eax,%ebx
  801822:	eb 05                	jmp    801829 <fd_close+0x6f>
		else
			r = 0;
  801824:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801829:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801834:	e8 0f fc ff ff       	call   801448 <sys_page_unmap>
	return r;
}
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	83 c4 30             	add    $0x30,%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 b0 fe ff ff       	call   80170a <fd_lookup>
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 13                	js     801871 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80185e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801865:	00 
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	89 04 24             	mov    %eax,(%esp)
  80186c:	e8 49 ff ff ff       	call   8017ba <fd_close>
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <close_all>:

void
close_all(void)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80187a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80187f:	89 1c 24             	mov    %ebx,(%esp)
  801882:	e8 bb ff ff ff       	call   801842 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801887:	43                   	inc    %ebx
  801888:	83 fb 20             	cmp    $0x20,%ebx
  80188b:	75 f2                	jne    80187f <close_all+0xc>
		close(i);
}
  80188d:	83 c4 14             	add    $0x14,%esp
  801890:	5b                   	pop    %ebx
  801891:	5d                   	pop    %ebp
  801892:	c3                   	ret    

00801893 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	83 ec 4c             	sub    $0x4c,%esp
  80189c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80189f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	89 04 24             	mov    %eax,(%esp)
  8018ac:	e8 59 fe ff ff       	call   80170a <fd_lookup>
  8018b1:	89 c3                	mov    %eax,%ebx
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	0f 88 e1 00 00 00    	js     80199c <dup+0x109>
		return r;
	close(newfdnum);
  8018bb:	89 3c 24             	mov    %edi,(%esp)
  8018be:	e8 7f ff ff ff       	call   801842 <close>

	newfd = INDEX2FD(newfdnum);
  8018c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8018c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8018cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 c5 fd ff ff       	call   80169c <fd2data>
  8018d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8018d9:	89 34 24             	mov    %esi,(%esp)
  8018dc:	e8 bb fd ff ff       	call   80169c <fd2data>
  8018e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018e4:	89 d8                	mov    %ebx,%eax
  8018e6:	c1 e8 16             	shr    $0x16,%eax
  8018e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018f0:	a8 01                	test   $0x1,%al
  8018f2:	74 46                	je     80193a <dup+0xa7>
  8018f4:	89 d8                	mov    %ebx,%eax
  8018f6:	c1 e8 0c             	shr    $0xc,%eax
  8018f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801900:	f6 c2 01             	test   $0x1,%dl
  801903:	74 35                	je     80193a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801905:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80190c:	25 07 0e 00 00       	and    $0xe07,%eax
  801911:	89 44 24 10          	mov    %eax,0x10(%esp)
  801915:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801918:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80191c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801923:	00 
  801924:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801928:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192f:	e8 c1 fa ff ff       	call   8013f5 <sys_page_map>
  801934:	89 c3                	mov    %eax,%ebx
  801936:	85 c0                	test   %eax,%eax
  801938:	78 3b                	js     801975 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80193a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193d:	89 c2                	mov    %eax,%edx
  80193f:	c1 ea 0c             	shr    $0xc,%edx
  801942:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801949:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80194f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801953:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801957:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80195e:	00 
  80195f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801963:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196a:	e8 86 fa ff ff       	call   8013f5 <sys_page_map>
  80196f:	89 c3                	mov    %eax,%ebx
  801971:	85 c0                	test   %eax,%eax
  801973:	79 25                	jns    80199a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801975:	89 74 24 04          	mov    %esi,0x4(%esp)
  801979:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801980:	e8 c3 fa ff ff       	call   801448 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801985:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801993:	e8 b0 fa ff ff       	call   801448 <sys_page_unmap>
	return r;
  801998:	eb 02                	jmp    80199c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80199a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80199c:	89 d8                	mov    %ebx,%eax
  80199e:	83 c4 4c             	add    $0x4c,%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5e                   	pop    %esi
  8019a3:	5f                   	pop    %edi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 24             	sub    $0x24,%esp
  8019ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b7:	89 1c 24             	mov    %ebx,(%esp)
  8019ba:	e8 4b fd ff ff       	call   80170a <fd_lookup>
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 6d                	js     801a30 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cd:	8b 00                	mov    (%eax),%eax
  8019cf:	89 04 24             	mov    %eax,(%esp)
  8019d2:	e8 89 fd ff ff       	call   801760 <dev_lookup>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 55                	js     801a30 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019de:	8b 50 08             	mov    0x8(%eax),%edx
  8019e1:	83 e2 03             	and    $0x3,%edx
  8019e4:	83 fa 01             	cmp    $0x1,%edx
  8019e7:	75 23                	jne    801a0c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019e9:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8019ee:	8b 40 48             	mov    0x48(%eax),%eax
  8019f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f9:	c7 04 24 15 35 80 00 	movl   $0x803515,(%esp)
  801a00:	e8 ff ef ff ff       	call   800a04 <cprintf>
		return -E_INVAL;
  801a05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a0a:	eb 24                	jmp    801a30 <read+0x8a>
	}
	if (!dev->dev_read)
  801a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0f:	8b 52 08             	mov    0x8(%edx),%edx
  801a12:	85 d2                	test   %edx,%edx
  801a14:	74 15                	je     801a2b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a16:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a20:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a24:	89 04 24             	mov    %eax,(%esp)
  801a27:	ff d2                	call   *%edx
  801a29:	eb 05                	jmp    801a30 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a2b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801a30:	83 c4 24             	add    $0x24,%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 1c             	sub    $0x1c,%esp
  801a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a42:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4a:	eb 23                	jmp    801a6f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a4c:	89 f0                	mov    %esi,%eax
  801a4e:	29 d8                	sub    %ebx,%eax
  801a50:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a57:	01 d8                	add    %ebx,%eax
  801a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5d:	89 3c 24             	mov    %edi,(%esp)
  801a60:	e8 41 ff ff ff       	call   8019a6 <read>
		if (m < 0)
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 10                	js     801a79 <readn+0x43>
			return m;
		if (m == 0)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	74 0a                	je     801a77 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a6d:	01 c3                	add    %eax,%ebx
  801a6f:	39 f3                	cmp    %esi,%ebx
  801a71:	72 d9                	jb     801a4c <readn+0x16>
  801a73:	89 d8                	mov    %ebx,%eax
  801a75:	eb 02                	jmp    801a79 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a77:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a79:	83 c4 1c             	add    $0x1c,%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5f                   	pop    %edi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	53                   	push   %ebx
  801a85:	83 ec 24             	sub    $0x24,%esp
  801a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a92:	89 1c 24             	mov    %ebx,(%esp)
  801a95:	e8 70 fc ff ff       	call   80170a <fd_lookup>
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	78 68                	js     801b06 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa8:	8b 00                	mov    (%eax),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 ae fc ff ff       	call   801760 <dev_lookup>
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 50                	js     801b06 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801abd:	75 23                	jne    801ae2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801abf:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801ac4:	8b 40 48             	mov    0x48(%eax),%eax
  801ac7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acf:	c7 04 24 31 35 80 00 	movl   $0x803531,(%esp)
  801ad6:	e8 29 ef ff ff       	call   800a04 <cprintf>
		return -E_INVAL;
  801adb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ae0:	eb 24                	jmp    801b06 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae5:	8b 52 0c             	mov    0xc(%edx),%edx
  801ae8:	85 d2                	test   %edx,%edx
  801aea:	74 15                	je     801b01 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801aec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801af3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801afa:	89 04 24             	mov    %eax,(%esp)
  801afd:	ff d2                	call   *%edx
  801aff:	eb 05                	jmp    801b06 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b06:	83 c4 24             	add    $0x24,%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <seek>:

int
seek(int fdnum, off_t offset)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b12:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 e6 fb ff ff       	call   80170a <fd_lookup>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 0e                	js     801b36 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b28:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 24             	sub    $0x24,%esp
  801b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b49:	89 1c 24             	mov    %ebx,(%esp)
  801b4c:	e8 b9 fb ff ff       	call   80170a <fd_lookup>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 61                	js     801bb6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5f:	8b 00                	mov    (%eax),%eax
  801b61:	89 04 24             	mov    %eax,(%esp)
  801b64:	e8 f7 fb ff ff       	call   801760 <dev_lookup>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 49                	js     801bb6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b70:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b74:	75 23                	jne    801b99 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b76:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b7b:	8b 40 48             	mov    0x48(%eax),%eax
  801b7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b86:	c7 04 24 f4 34 80 00 	movl   $0x8034f4,(%esp)
  801b8d:	e8 72 ee ff ff       	call   800a04 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b97:	eb 1d                	jmp    801bb6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b9c:	8b 52 18             	mov    0x18(%edx),%edx
  801b9f:	85 d2                	test   %edx,%edx
  801ba1:	74 0e                	je     801bb1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801baa:	89 04 24             	mov    %eax,(%esp)
  801bad:	ff d2                	call   *%edx
  801baf:	eb 05                	jmp    801bb6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bb1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801bb6:	83 c4 24             	add    $0x24,%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 24             	sub    $0x24,%esp
  801bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd0:	89 04 24             	mov    %eax,(%esp)
  801bd3:	e8 32 fb ff ff       	call   80170a <fd_lookup>
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 52                	js     801c2e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be6:	8b 00                	mov    (%eax),%eax
  801be8:	89 04 24             	mov    %eax,(%esp)
  801beb:	e8 70 fb ff ff       	call   801760 <dev_lookup>
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	78 3a                	js     801c2e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bfb:	74 2c                	je     801c29 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bfd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c00:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c07:	00 00 00 
	stat->st_isdir = 0;
  801c0a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c11:	00 00 00 
	stat->st_dev = dev;
  801c14:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c21:	89 14 24             	mov    %edx,(%esp)
  801c24:	ff 50 14             	call   *0x14(%eax)
  801c27:	eb 05                	jmp    801c2e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c29:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c2e:	83 c4 24             	add    $0x24,%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c43:	00 
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	89 04 24             	mov    %eax,(%esp)
  801c4a:	e8 2d 02 00 00       	call   801e7c <open>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 1b                	js     801c70 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5c:	89 1c 24             	mov    %ebx,(%esp)
  801c5f:	e8 58 ff ff ff       	call   801bbc <fstat>
  801c64:	89 c6                	mov    %eax,%esi
	close(fd);
  801c66:	89 1c 24             	mov    %ebx,(%esp)
  801c69:	e8 d4 fb ff ff       	call   801842 <close>
	return r;
  801c6e:	89 f3                	mov    %esi,%ebx
}
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    
  801c79:	00 00                	add    %al,(%eax)
	...

00801c7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 10             	sub    $0x10,%esp
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c88:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801c8f:	75 11                	jne    801ca2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c98:	e8 e6 0f 00 00       	call   802c83 <ipc_find_env>
  801c9d:	a3 10 50 80 00       	mov    %eax,0x805010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ca2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ca9:	00 
  801caa:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801cb1:	00 
  801cb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb6:	a1 10 50 80 00       	mov    0x805010,%eax
  801cbb:	89 04 24             	mov    %eax,(%esp)
  801cbe:	e8 52 0f 00 00       	call   802c15 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cca:	00 
  801ccb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ccf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd6:	e8 d1 0e 00 00       	call   802bac <ipc_recv>
}
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	8b 40 0c             	mov    0xc(%eax),%eax
  801cee:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf6:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801d00:	b8 02 00 00 00       	mov    $0x2,%eax
  801d05:	e8 72 ff ff ff       	call   801c7c <fsipc>
}
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	8b 40 0c             	mov    0xc(%eax),%eax
  801d18:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d22:	b8 06 00 00 00       	mov    $0x6,%eax
  801d27:	e8 50 ff ff ff       	call   801c7c <fsipc>
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	53                   	push   %ebx
  801d32:	83 ec 14             	sub    $0x14,%esp
  801d35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d43:	ba 00 00 00 00       	mov    $0x0,%edx
  801d48:	b8 05 00 00 00       	mov    $0x5,%eax
  801d4d:	e8 2a ff ff ff       	call   801c7c <fsipc>
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 2b                	js     801d81 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d56:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d5d:	00 
  801d5e:	89 1c 24             	mov    %ebx,(%esp)
  801d61:	e8 49 f2 ff ff       	call   800faf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d66:	a1 80 60 80 00       	mov    0x806080,%eax
  801d6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d71:	a1 84 60 80 00       	mov    0x806084,%eax
  801d76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d81:	83 c4 14             	add    $0x14,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 18             	sub    $0x18,%esp
  801d8d:	8b 55 10             	mov    0x10(%ebp),%edx
  801d90:	89 d0                	mov    %edx,%eax
  801d92:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801d98:	76 05                	jbe    801d9f <devfile_write+0x18>
  801d9a:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  801da2:	8b 52 0c             	mov    0xc(%edx),%edx
  801da5:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801dab:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801db0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbb:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801dc2:	e8 61 f3 ff ff       	call   801128 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcc:	b8 04 00 00 00       	mov    $0x4,%eax
  801dd1:	e8 a6 fe ff ff       	call   801c7c <fsipc>
}
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	56                   	push   %esi
  801ddc:	53                   	push   %ebx
  801ddd:	83 ec 10             	sub    $0x10,%esp
  801de0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	8b 40 0c             	mov    0xc(%eax),%eax
  801de9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dee:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801df4:	ba 00 00 00 00       	mov    $0x0,%edx
  801df9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dfe:	e8 79 fe ff ff       	call   801c7c <fsipc>
  801e03:	89 c3                	mov    %eax,%ebx
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 6a                	js     801e73 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e09:	39 c6                	cmp    %eax,%esi
  801e0b:	73 24                	jae    801e31 <devfile_read+0x59>
  801e0d:	c7 44 24 0c 64 35 80 	movl   $0x803564,0xc(%esp)
  801e14:	00 
  801e15:	c7 44 24 08 6b 35 80 	movl   $0x80356b,0x8(%esp)
  801e1c:	00 
  801e1d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e24:	00 
  801e25:	c7 04 24 80 35 80 00 	movl   $0x803580,(%esp)
  801e2c:	e8 db ea ff ff       	call   80090c <_panic>
	assert(r <= PGSIZE);
  801e31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e36:	7e 24                	jle    801e5c <devfile_read+0x84>
  801e38:	c7 44 24 0c 8b 35 80 	movl   $0x80358b,0xc(%esp)
  801e3f:	00 
  801e40:	c7 44 24 08 6b 35 80 	movl   $0x80356b,0x8(%esp)
  801e47:	00 
  801e48:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e4f:	00 
  801e50:	c7 04 24 80 35 80 00 	movl   $0x803580,(%esp)
  801e57:	e8 b0 ea ff ff       	call   80090c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e60:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e67:	00 
  801e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6b:	89 04 24             	mov    %eax,(%esp)
  801e6e:	e8 b5 f2 ff ff       	call   801128 <memmove>
	return r;
}
  801e73:	89 d8                	mov    %ebx,%eax
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 20             	sub    $0x20,%esp
  801e84:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e87:	89 34 24             	mov    %esi,(%esp)
  801e8a:	e8 ed f0 ff ff       	call   800f7c <strlen>
  801e8f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e94:	7f 60                	jg     801ef6 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e99:	89 04 24             	mov    %eax,(%esp)
  801e9c:	e8 16 f8 ff ff       	call   8016b7 <fd_alloc>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	78 54                	js     801efb <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ea7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eab:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801eb2:	e8 f8 f0 ff ff       	call   800faf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eba:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ebf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec7:	e8 b0 fd ff ff       	call   801c7c <fsipc>
  801ecc:	89 c3                	mov    %eax,%ebx
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	79 15                	jns    801ee7 <open+0x6b>
		fd_close(fd, 0);
  801ed2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ed9:	00 
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 d5 f8 ff ff       	call   8017ba <fd_close>
		return r;
  801ee5:	eb 14                	jmp    801efb <open+0x7f>
	}

	return fd2num(fd);
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	89 04 24             	mov    %eax,(%esp)
  801eed:	e8 9a f7 ff ff       	call   80168c <fd2num>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	eb 05                	jmp    801efb <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ef6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801efb:	89 d8                	mov    %ebx,%eax
  801efd:	83 c4 20             	add    $0x20,%esp
  801f00:	5b                   	pop    %ebx
  801f01:	5e                   	pop    %esi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0f:	b8 08 00 00 00       	mov    $0x8,%eax
  801f14:	e8 63 fd ff ff       	call   801c7c <fsipc>
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    
	...

00801f1c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f22:	c7 44 24 04 97 35 80 	movl   $0x803597,0x4(%esp)
  801f29:	00 
  801f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2d:	89 04 24             	mov    %eax,(%esp)
  801f30:	e8 7a f0 ff ff       	call   800faf <strcpy>
	return 0;
}
  801f35:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	53                   	push   %ebx
  801f40:	83 ec 14             	sub    $0x14,%esp
  801f43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f46:	89 1c 24             	mov    %ebx,(%esp)
  801f49:	e8 6e 0d 00 00       	call   802cbc <pageref>
  801f4e:	83 f8 01             	cmp    $0x1,%eax
  801f51:	75 0d                	jne    801f60 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801f53:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f56:	89 04 24             	mov    %eax,(%esp)
  801f59:	e8 1f 03 00 00       	call   80227d <nsipc_close>
  801f5e:	eb 05                	jmp    801f65 <devsock_close+0x29>
	else
		return 0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f65:	83 c4 14             	add    $0x14,%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    

00801f6b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f78:	00 
  801f79:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f8d:	89 04 24             	mov    %eax,(%esp)
  801f90:	e8 e3 03 00 00       	call   802378 <nsipc_send>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f9d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fa4:	00 
  801fa5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb6:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb9:	89 04 24             	mov    %eax,(%esp)
  801fbc:	e8 37 03 00 00       	call   8022f8 <nsipc_recv>
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 20             	sub    $0x20,%esp
  801fcb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd0:	89 04 24             	mov    %eax,(%esp)
  801fd3:	e8 df f6 ff ff       	call   8016b7 <fd_alloc>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	78 21                	js     801fff <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fde:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fe5:	00 
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff4:	e8 a8 f3 ff ff       	call   8013a1 <sys_page_alloc>
  801ff9:	89 c3                	mov    %eax,%ebx
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	79 0a                	jns    802009 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801fff:	89 34 24             	mov    %esi,(%esp)
  802002:	e8 76 02 00 00       	call   80227d <nsipc_close>
		return r;
  802007:	eb 22                	jmp    80202b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802009:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802017:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80201e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802021:	89 04 24             	mov    %eax,(%esp)
  802024:	e8 63 f6 ff ff       	call   80168c <fd2num>
  802029:	89 c3                	mov    %eax,%ebx
}
  80202b:	89 d8                	mov    %ebx,%eax
  80202d:	83 c4 20             	add    $0x20,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80203a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80203d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 c1 f6 ff ff       	call   80170a <fd_lookup>
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 17                	js     802064 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80204d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802050:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802056:	39 10                	cmp    %edx,(%eax)
  802058:	75 05                	jne    80205f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80205a:	8b 40 0c             	mov    0xc(%eax),%eax
  80205d:	eb 05                	jmp    802064 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80205f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802064:	c9                   	leave  
  802065:	c3                   	ret    

00802066 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80206c:	8b 45 08             	mov    0x8(%ebp),%eax
  80206f:	e8 c0 ff ff ff       	call   802034 <fd2sockid>
  802074:	85 c0                	test   %eax,%eax
  802076:	78 1f                	js     802097 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802078:	8b 55 10             	mov    0x10(%ebp),%edx
  80207b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80207f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802082:	89 54 24 04          	mov    %edx,0x4(%esp)
  802086:	89 04 24             	mov    %eax,(%esp)
  802089:	e8 38 01 00 00       	call   8021c6 <nsipc_accept>
  80208e:	85 c0                	test   %eax,%eax
  802090:	78 05                	js     802097 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802092:	e8 2c ff ff ff       	call   801fc3 <alloc_sockfd>
}
  802097:	c9                   	leave  
  802098:	c3                   	ret    

00802099 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	e8 8d ff ff ff       	call   802034 <fd2sockid>
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 16                	js     8020c1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8020ab:	8b 55 10             	mov    0x10(%ebp),%edx
  8020ae:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b9:	89 04 24             	mov    %eax,(%esp)
  8020bc:	e8 5b 01 00 00       	call   80221c <nsipc_bind>
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <shutdown>:

int
shutdown(int s, int how)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cc:	e8 63 ff ff ff       	call   802034 <fd2sockid>
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	78 0f                	js     8020e4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020dc:	89 04 24             	mov    %eax,(%esp)
  8020df:	e8 77 01 00 00       	call   80225b <nsipc_shutdown>
}
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ef:	e8 40 ff ff ff       	call   802034 <fd2sockid>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 16                	js     80210e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020f8:	8b 55 10             	mov    0x10(%ebp),%edx
  8020fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  802102:	89 54 24 04          	mov    %edx,0x4(%esp)
  802106:	89 04 24             	mov    %eax,(%esp)
  802109:	e8 89 01 00 00       	call   802297 <nsipc_connect>
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <listen>:

int
listen(int s, int backlog)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	e8 16 ff ff ff       	call   802034 <fd2sockid>
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 0f                	js     802131 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802122:	8b 55 0c             	mov    0xc(%ebp),%edx
  802125:	89 54 24 04          	mov    %edx,0x4(%esp)
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 a5 01 00 00       	call   8022d6 <nsipc_listen>
}
  802131:	c9                   	leave  
  802132:	c3                   	ret    

00802133 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802139:	8b 45 10             	mov    0x10(%ebp),%eax
  80213c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802140:	8b 45 0c             	mov    0xc(%ebp),%eax
  802143:	89 44 24 04          	mov    %eax,0x4(%esp)
  802147:	8b 45 08             	mov    0x8(%ebp),%eax
  80214a:	89 04 24             	mov    %eax,(%esp)
  80214d:	e8 99 02 00 00       	call   8023eb <nsipc_socket>
  802152:	85 c0                	test   %eax,%eax
  802154:	78 05                	js     80215b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802156:	e8 68 fe ff ff       	call   801fc3 <alloc_sockfd>
}
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    
  80215d:	00 00                	add    %al,(%eax)
	...

00802160 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	53                   	push   %ebx
  802164:	83 ec 14             	sub    $0x14,%esp
  802167:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802169:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  802170:	75 11                	jne    802183 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802172:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802179:	e8 05 0b 00 00       	call   802c83 <ipc_find_env>
  80217e:	a3 14 50 80 00       	mov    %eax,0x805014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802183:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80218a:	00 
  80218b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802192:	00 
  802193:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802197:	a1 14 50 80 00       	mov    0x805014,%eax
  80219c:	89 04 24             	mov    %eax,(%esp)
  80219f:	e8 71 0a 00 00       	call   802c15 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021ab:	00 
  8021ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021b3:	00 
  8021b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021bb:	e8 ec 09 00 00       	call   802bac <ipc_recv>
}
  8021c0:	83 c4 14             	add    $0x14,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    

008021c6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	56                   	push   %esi
  8021ca:	53                   	push   %ebx
  8021cb:	83 ec 10             	sub    $0x10,%esp
  8021ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021d9:	8b 06                	mov    (%esi),%eax
  8021db:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e5:	e8 76 ff ff ff       	call   802160 <nsipc>
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	78 23                	js     802213 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021f0:	a1 10 70 80 00       	mov    0x807010,%eax
  8021f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021f9:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802200:	00 
  802201:	8b 45 0c             	mov    0xc(%ebp),%eax
  802204:	89 04 24             	mov    %eax,(%esp)
  802207:	e8 1c ef ff ff       	call   801128 <memmove>
		*addrlen = ret->ret_addrlen;
  80220c:	a1 10 70 80 00       	mov    0x807010,%eax
  802211:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802213:	89 d8                	mov    %ebx,%eax
  802215:	83 c4 10             	add    $0x10,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    

0080221c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	53                   	push   %ebx
  802220:	83 ec 14             	sub    $0x14,%esp
  802223:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80222e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802232:	8b 45 0c             	mov    0xc(%ebp),%eax
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802240:	e8 e3 ee ff ff       	call   801128 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802245:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80224b:	b8 02 00 00 00       	mov    $0x2,%eax
  802250:	e8 0b ff ff ff       	call   802160 <nsipc>
}
  802255:	83 c4 14             	add    $0x14,%esp
  802258:	5b                   	pop    %ebx
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802261:	8b 45 08             	mov    0x8(%ebp),%eax
  802264:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802269:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802271:	b8 03 00 00 00       	mov    $0x3,%eax
  802276:	e8 e5 fe ff ff       	call   802160 <nsipc>
}
  80227b:	c9                   	leave  
  80227c:	c3                   	ret    

0080227d <nsipc_close>:

int
nsipc_close(int s)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802283:	8b 45 08             	mov    0x8(%ebp),%eax
  802286:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80228b:	b8 04 00 00 00       	mov    $0x4,%eax
  802290:	e8 cb fe ff ff       	call   802160 <nsipc>
}
  802295:	c9                   	leave  
  802296:	c3                   	ret    

00802297 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	53                   	push   %ebx
  80229b:	83 ec 14             	sub    $0x14,%esp
  80229e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b4:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8022bb:	e8 68 ee ff ff       	call   801128 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022c0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8022c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8022cb:	e8 90 fe ff ff       	call   802160 <nsipc>
}
  8022d0:	83 c4 14             	add    $0x14,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022df:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8022f1:	e8 6a fe ff ff       	call   802160 <nsipc>
}
  8022f6:	c9                   	leave  
  8022f7:	c3                   	ret    

008022f8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	56                   	push   %esi
  8022fc:	53                   	push   %ebx
  8022fd:	83 ec 10             	sub    $0x10,%esp
  802300:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802303:	8b 45 08             	mov    0x8(%ebp),%eax
  802306:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80230b:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802311:	8b 45 14             	mov    0x14(%ebp),%eax
  802314:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802319:	b8 07 00 00 00       	mov    $0x7,%eax
  80231e:	e8 3d fe ff ff       	call   802160 <nsipc>
  802323:	89 c3                	mov    %eax,%ebx
  802325:	85 c0                	test   %eax,%eax
  802327:	78 46                	js     80236f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802329:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80232e:	7f 04                	jg     802334 <nsipc_recv+0x3c>
  802330:	39 c6                	cmp    %eax,%esi
  802332:	7d 24                	jge    802358 <nsipc_recv+0x60>
  802334:	c7 44 24 0c a3 35 80 	movl   $0x8035a3,0xc(%esp)
  80233b:	00 
  80233c:	c7 44 24 08 6b 35 80 	movl   $0x80356b,0x8(%esp)
  802343:	00 
  802344:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80234b:	00 
  80234c:	c7 04 24 b8 35 80 00 	movl   $0x8035b8,(%esp)
  802353:	e8 b4 e5 ff ff       	call   80090c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80235c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802363:	00 
  802364:	8b 45 0c             	mov    0xc(%ebp),%eax
  802367:	89 04 24             	mov    %eax,(%esp)
  80236a:	e8 b9 ed ff ff       	call   801128 <memmove>
	}

	return r;
}
  80236f:	89 d8                	mov    %ebx,%eax
  802371:	83 c4 10             	add    $0x10,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    

00802378 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	53                   	push   %ebx
  80237c:	83 ec 14             	sub    $0x14,%esp
  80237f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802382:	8b 45 08             	mov    0x8(%ebp),%eax
  802385:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80238a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802390:	7e 24                	jle    8023b6 <nsipc_send+0x3e>
  802392:	c7 44 24 0c c4 35 80 	movl   $0x8035c4,0xc(%esp)
  802399:	00 
  80239a:	c7 44 24 08 6b 35 80 	movl   $0x80356b,0x8(%esp)
  8023a1:	00 
  8023a2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8023a9:	00 
  8023aa:	c7 04 24 b8 35 80 00 	movl   $0x8035b8,(%esp)
  8023b1:	e8 56 e5 ff ff       	call   80090c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c1:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8023c8:	e8 5b ed ff ff       	call   801128 <memmove>
	nsipcbuf.send.req_size = size;
  8023cd:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023db:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e0:	e8 7b fd ff ff       	call   802160 <nsipc>
}
  8023e5:	83 c4 14             	add    $0x14,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    

008023eb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023fc:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802401:	8b 45 10             	mov    0x10(%ebp),%eax
  802404:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802409:	b8 09 00 00 00       	mov    $0x9,%eax
  80240e:	e8 4d fd ff ff       	call   802160 <nsipc>
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    
  802415:	00 00                	add    %al,(%eax)
	...

00802418 <free>:
	return v;
}

void
free(void *v)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	53                   	push   %ebx
  80241c:	83 ec 14             	sub    $0x14,%esp
  80241f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802422:	85 db                	test   %ebx,%ebx
  802424:	0f 84 b8 00 00 00    	je     8024e2 <free+0xca>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  80242a:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  802430:	76 08                	jbe    80243a <free+0x22>
  802432:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  802438:	76 24                	jbe    80245e <free+0x46>
  80243a:	c7 44 24 0c d0 35 80 	movl   $0x8035d0,0xc(%esp)
  802441:	00 
  802442:	c7 44 24 08 6b 35 80 	movl   $0x80356b,0x8(%esp)
  802449:	00 
  80244a:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  802451:	00 
  802452:	c7 04 24 fe 35 80 00 	movl   $0x8035fe,(%esp)
  802459:	e8 ae e4 ff ff       	call   80090c <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  80245e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802464:	eb 4a                	jmp    8024b0 <free+0x98>
		sys_page_unmap(0, c);
  802466:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80246a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802471:	e8 d2 ef ff ff       	call   801448 <sys_page_unmap>
		c += PGSIZE;
  802476:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  80247c:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  802482:	76 08                	jbe    80248c <free+0x74>
  802484:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  80248a:	76 24                	jbe    8024b0 <free+0x98>
  80248c:	c7 44 24 0c 0b 36 80 	movl   $0x80360b,0xc(%esp)
  802493:	00 
  802494:	c7 44 24 08 6b 35 80 	movl   $0x80356b,0x8(%esp)
  80249b:	00 
  80249c:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  8024a3:	00 
  8024a4:	c7 04 24 fe 35 80 00 	movl   $0x8035fe,(%esp)
  8024ab:	e8 5c e4 ff ff       	call   80090c <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8024b0:	89 d8                	mov    %ebx,%eax
  8024b2:	c1 e8 0c             	shr    $0xc,%eax
  8024b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8024bc:	f6 c4 02             	test   $0x2,%ah
  8024bf:	75 a5                	jne    802466 <free+0x4e>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8024c1:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8024c7:	48                   	dec    %eax
  8024c8:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	75 10                	jne    8024e2 <free+0xca>
		sys_page_unmap(0, c);
  8024d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024dd:	e8 66 ef ff ff       	call   801448 <sys_page_unmap>
}
  8024e2:	83 c4 14             	add    $0x14,%esp
  8024e5:	5b                   	pop    %ebx
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    

008024e8 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	57                   	push   %edi
  8024ec:	56                   	push   %esi
  8024ed:	53                   	push   %ebx
  8024ee:	83 ec 2c             	sub    $0x2c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  8024f1:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  8024f8:	75 0a                	jne    802504 <malloc+0x1c>
		mptr = mbegin;
  8024fa:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  802501:	00 00 08 

	n = ROUNDUP(n, 4);
  802504:	8b 45 08             	mov    0x8(%ebp),%eax
  802507:	83 c0 03             	add    $0x3,%eax
  80250a:	83 e0 fc             	and    $0xfffffffc,%eax
  80250d:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if (n >= MAXMALLOC)
  802510:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  802515:	0f 87 6a 01 00 00    	ja     802685 <malloc+0x19d>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  80251b:	a1 18 50 80 00       	mov    0x805018,%eax
  802520:	89 c2                	mov    %eax,%edx
  802522:	a9 ff 0f 00 00       	test   $0xfff,%eax
  802527:	74 4d                	je     802576 <malloc+0x8e>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802529:	89 c3                	mov    %eax,%ebx
  80252b:	c1 eb 0c             	shr    $0xc,%ebx
  80252e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802531:	8d 4c 30 03          	lea    0x3(%eax,%esi,1),%ecx
  802535:	c1 e9 0c             	shr    $0xc,%ecx
  802538:	39 cb                	cmp    %ecx,%ebx
  80253a:	75 1e                	jne    80255a <malloc+0x72>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  80253c:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  802542:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802548:	ff 42 fc             	incl   -0x4(%edx)
			v = mptr;
			mptr += n;
  80254b:	89 f2                	mov    %esi,%edx
  80254d:	01 c2                	add    %eax,%edx
  80254f:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  802555:	e9 30 01 00 00       	jmp    80268a <malloc+0x1a2>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  80255a:	89 04 24             	mov    %eax,(%esp)
  80255d:	e8 b6 fe ff ff       	call   802418 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802562:	a1 18 50 80 00       	mov    0x805018,%eax
  802567:	05 00 10 00 00       	add    $0x1000,%eax
  80256c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802571:	a3 18 50 80 00       	mov    %eax,0x805018
  802576:	8b 1d 18 50 80 00    	mov    0x805018,%ebx
	return 1;
}

void*
malloc(size_t n)
{
  80257c:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802586:	83 c6 04             	add    $0x4,%esi
  802589:	eb 05                	jmp    802590 <malloc+0xa8>
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  80258b:	bb 00 00 00 08       	mov    $0x8000000,%ebx
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802590:	89 df                	mov    %ebx,%edi
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802592:	89 75 e4             	mov    %esi,-0x1c(%ebp)
static uint8_t *mptr;

static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;
  802595:	89 d8                	mov    %ebx,%eax
			return 0;
	return 1;
}

void*
malloc(size_t n)
  802597:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80259a:	eb 2e                	jmp    8025ca <malloc+0xe2>
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  80259c:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  8025a1:	77 30                	ja     8025d3 <malloc+0xeb>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  8025a3:	89 c2                	mov    %eax,%edx
  8025a5:	c1 ea 16             	shr    $0x16,%edx
  8025a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025af:	f6 c2 01             	test   $0x1,%dl
  8025b2:	74 11                	je     8025c5 <malloc+0xdd>
  8025b4:	89 c2                	mov    %eax,%edx
  8025b6:	c1 ea 0c             	shr    $0xc,%edx
  8025b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8025c0:	f6 c2 01             	test   $0x1,%dl
  8025c3:	75 0e                	jne    8025d3 <malloc+0xeb>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8025c5:	05 00 10 00 00       	add    $0x1000,%eax
  8025ca:	39 c1                	cmp    %eax,%ecx
  8025cc:	77 ce                	ja     80259c <malloc+0xb4>
  8025ce:	e9 84 00 00 00       	jmp    802657 <malloc+0x16f>
  8025d3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  8025d9:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
  8025df:	75 af                	jne    802590 <malloc+0xa8>
			mptr = mbegin;
			if (++nwrap == 2)
  8025e1:	ff 4d dc             	decl   -0x24(%ebp)
  8025e4:	75 a5                	jne    80258b <malloc+0xa3>
  8025e6:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8025ed:	00 00 08 
				return 0;	/* out of address space */
  8025f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f5:	e9 90 00 00 00       	jmp    80268a <malloc+0x1a2>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8025fa:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
  802600:	39 fe                	cmp    %edi,%esi
  802602:	19 c0                	sbb    %eax,%eax
  802604:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802609:	83 c8 07             	or     $0x7,%eax
  80260c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802610:	03 15 18 50 80 00    	add    0x805018,%edx
  802616:	89 54 24 04          	mov    %edx,0x4(%esp)
  80261a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802621:	e8 7b ed ff ff       	call   8013a1 <sys_page_alloc>
  802626:	85 c0                	test   %eax,%eax
  802628:	78 22                	js     80264c <malloc+0x164>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80262a:	89 f3                	mov    %esi,%ebx
  80262c:	eb 37                	jmp    802665 <malloc+0x17d>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  80262e:	89 d8                	mov    %ebx,%eax
  802630:	03 05 18 50 80 00    	add    0x805018,%eax
  802636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80263a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802641:	e8 02 ee ff ff       	call   801448 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802646:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  80264c:	85 db                	test   %ebx,%ebx
  80264e:	79 de                	jns    80262e <malloc+0x146>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802650:	b8 00 00 00 00       	mov    $0x0,%eax
  802655:	eb 33                	jmp    80268a <malloc+0x1a2>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802657:	89 3d 18 50 80 00    	mov    %edi,0x805018
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80265d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802665:	89 da                	mov    %ebx,%edx
  802667:	39 fb                	cmp    %edi,%ebx
  802669:	72 8f                	jb     8025fa <malloc+0x112>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  80266b:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802670:	c7 44 18 fc 02 00 00 	movl   $0x2,-0x4(%eax,%ebx,1)
  802677:	00 
	v = mptr;
	mptr += n;
  802678:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80267b:	01 c2                	add    %eax,%edx
  80267d:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  802683:	eb 05                	jmp    80268a <malloc+0x1a2>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  802685:	b8 00 00 00 00       	mov    $0x0,%eax
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  80268a:	83 c4 2c             	add    $0x2c,%esp
  80268d:	5b                   	pop    %ebx
  80268e:	5e                   	pop    %esi
  80268f:	5f                   	pop    %edi
  802690:	5d                   	pop    %ebp
  802691:	c3                   	ret    
	...

00802694 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802694:	55                   	push   %ebp
  802695:	89 e5                	mov    %esp,%ebp
  802697:	56                   	push   %esi
  802698:	53                   	push   %ebx
  802699:	83 ec 10             	sub    $0x10,%esp
  80269c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80269f:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a2:	89 04 24             	mov    %eax,(%esp)
  8026a5:	e8 f2 ef ff ff       	call   80169c <fd2data>
  8026aa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8026ac:	c7 44 24 04 23 36 80 	movl   $0x803623,0x4(%esp)
  8026b3:	00 
  8026b4:	89 34 24             	mov    %esi,(%esp)
  8026b7:	e8 f3 e8 ff ff       	call   800faf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8026bf:	2b 03                	sub    (%ebx),%eax
  8026c1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8026c7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8026ce:	00 00 00 
	stat->st_dev = &devpipe;
  8026d1:	c7 86 88 00 00 00 5c 	movl   $0x80405c,0x88(%esi)
  8026d8:	40 80 00 
	return 0;
}
  8026db:	b8 00 00 00 00       	mov    $0x0,%eax
  8026e0:	83 c4 10             	add    $0x10,%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5e                   	pop    %esi
  8026e5:	5d                   	pop    %ebp
  8026e6:	c3                   	ret    

008026e7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	53                   	push   %ebx
  8026eb:	83 ec 14             	sub    $0x14,%esp
  8026ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8026f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026fc:	e8 47 ed ff ff       	call   801448 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802701:	89 1c 24             	mov    %ebx,(%esp)
  802704:	e8 93 ef ff ff       	call   80169c <fd2data>
  802709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80270d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802714:	e8 2f ed ff ff       	call   801448 <sys_page_unmap>
}
  802719:	83 c4 14             	add    $0x14,%esp
  80271c:	5b                   	pop    %ebx
  80271d:	5d                   	pop    %ebp
  80271e:	c3                   	ret    

0080271f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80271f:	55                   	push   %ebp
  802720:	89 e5                	mov    %esp,%ebp
  802722:	57                   	push   %edi
  802723:	56                   	push   %esi
  802724:	53                   	push   %ebx
  802725:	83 ec 2c             	sub    $0x2c,%esp
  802728:	89 c7                	mov    %eax,%edi
  80272a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80272d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802732:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802735:	89 3c 24             	mov    %edi,(%esp)
  802738:	e8 7f 05 00 00       	call   802cbc <pageref>
  80273d:	89 c6                	mov    %eax,%esi
  80273f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802742:	89 04 24             	mov    %eax,(%esp)
  802745:	e8 72 05 00 00       	call   802cbc <pageref>
  80274a:	39 c6                	cmp    %eax,%esi
  80274c:	0f 94 c0             	sete   %al
  80274f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802752:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802758:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80275b:	39 cb                	cmp    %ecx,%ebx
  80275d:	75 08                	jne    802767 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80275f:	83 c4 2c             	add    $0x2c,%esp
  802762:	5b                   	pop    %ebx
  802763:	5e                   	pop    %esi
  802764:	5f                   	pop    %edi
  802765:	5d                   	pop    %ebp
  802766:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802767:	83 f8 01             	cmp    $0x1,%eax
  80276a:	75 c1                	jne    80272d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80276c:	8b 42 58             	mov    0x58(%edx),%eax
  80276f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802776:	00 
  802777:	89 44 24 08          	mov    %eax,0x8(%esp)
  80277b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80277f:	c7 04 24 2a 36 80 00 	movl   $0x80362a,(%esp)
  802786:	e8 79 e2 ff ff       	call   800a04 <cprintf>
  80278b:	eb a0                	jmp    80272d <_pipeisclosed+0xe>

0080278d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80278d:	55                   	push   %ebp
  80278e:	89 e5                	mov    %esp,%ebp
  802790:	57                   	push   %edi
  802791:	56                   	push   %esi
  802792:	53                   	push   %ebx
  802793:	83 ec 1c             	sub    $0x1c,%esp
  802796:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802799:	89 34 24             	mov    %esi,(%esp)
  80279c:	e8 fb ee ff ff       	call   80169c <fd2data>
  8027a1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8027a8:	eb 3c                	jmp    8027e6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8027aa:	89 da                	mov    %ebx,%edx
  8027ac:	89 f0                	mov    %esi,%eax
  8027ae:	e8 6c ff ff ff       	call   80271f <_pipeisclosed>
  8027b3:	85 c0                	test   %eax,%eax
  8027b5:	75 38                	jne    8027ef <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8027b7:	e8 c6 eb ff ff       	call   801382 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8027bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8027bf:	8b 13                	mov    (%ebx),%edx
  8027c1:	83 c2 20             	add    $0x20,%edx
  8027c4:	39 d0                	cmp    %edx,%eax
  8027c6:	73 e2                	jae    8027aa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8027c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027cb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8027ce:	89 c2                	mov    %eax,%edx
  8027d0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8027d6:	79 05                	jns    8027dd <devpipe_write+0x50>
  8027d8:	4a                   	dec    %edx
  8027d9:	83 ca e0             	or     $0xffffffe0,%edx
  8027dc:	42                   	inc    %edx
  8027dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8027e1:	40                   	inc    %eax
  8027e2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027e5:	47                   	inc    %edi
  8027e6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8027e9:	75 d1                	jne    8027bc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8027eb:	89 f8                	mov    %edi,%eax
  8027ed:	eb 05                	jmp    8027f4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8027ef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8027f4:	83 c4 1c             	add    $0x1c,%esp
  8027f7:	5b                   	pop    %ebx
  8027f8:	5e                   	pop    %esi
  8027f9:	5f                   	pop    %edi
  8027fa:	5d                   	pop    %ebp
  8027fb:	c3                   	ret    

008027fc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027fc:	55                   	push   %ebp
  8027fd:	89 e5                	mov    %esp,%ebp
  8027ff:	57                   	push   %edi
  802800:	56                   	push   %esi
  802801:	53                   	push   %ebx
  802802:	83 ec 1c             	sub    $0x1c,%esp
  802805:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802808:	89 3c 24             	mov    %edi,(%esp)
  80280b:	e8 8c ee ff ff       	call   80169c <fd2data>
  802810:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802812:	be 00 00 00 00       	mov    $0x0,%esi
  802817:	eb 3a                	jmp    802853 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802819:	85 f6                	test   %esi,%esi
  80281b:	74 04                	je     802821 <devpipe_read+0x25>
				return i;
  80281d:	89 f0                	mov    %esi,%eax
  80281f:	eb 40                	jmp    802861 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802821:	89 da                	mov    %ebx,%edx
  802823:	89 f8                	mov    %edi,%eax
  802825:	e8 f5 fe ff ff       	call   80271f <_pipeisclosed>
  80282a:	85 c0                	test   %eax,%eax
  80282c:	75 2e                	jne    80285c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80282e:	e8 4f eb ff ff       	call   801382 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802833:	8b 03                	mov    (%ebx),%eax
  802835:	3b 43 04             	cmp    0x4(%ebx),%eax
  802838:	74 df                	je     802819 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80283a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80283f:	79 05                	jns    802846 <devpipe_read+0x4a>
  802841:	48                   	dec    %eax
  802842:	83 c8 e0             	or     $0xffffffe0,%eax
  802845:	40                   	inc    %eax
  802846:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80284a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80284d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802850:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802852:	46                   	inc    %esi
  802853:	3b 75 10             	cmp    0x10(%ebp),%esi
  802856:	75 db                	jne    802833 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802858:	89 f0                	mov    %esi,%eax
  80285a:	eb 05                	jmp    802861 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80285c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802861:	83 c4 1c             	add    $0x1c,%esp
  802864:	5b                   	pop    %ebx
  802865:	5e                   	pop    %esi
  802866:	5f                   	pop    %edi
  802867:	5d                   	pop    %ebp
  802868:	c3                   	ret    

00802869 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802869:	55                   	push   %ebp
  80286a:	89 e5                	mov    %esp,%ebp
  80286c:	57                   	push   %edi
  80286d:	56                   	push   %esi
  80286e:	53                   	push   %ebx
  80286f:	83 ec 3c             	sub    $0x3c,%esp
  802872:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802875:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802878:	89 04 24             	mov    %eax,(%esp)
  80287b:	e8 37 ee ff ff       	call   8016b7 <fd_alloc>
  802880:	89 c3                	mov    %eax,%ebx
  802882:	85 c0                	test   %eax,%eax
  802884:	0f 88 45 01 00 00    	js     8029cf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80288a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802891:	00 
  802892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802895:	89 44 24 04          	mov    %eax,0x4(%esp)
  802899:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028a0:	e8 fc ea ff ff       	call   8013a1 <sys_page_alloc>
  8028a5:	89 c3                	mov    %eax,%ebx
  8028a7:	85 c0                	test   %eax,%eax
  8028a9:	0f 88 20 01 00 00    	js     8029cf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8028af:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8028b2:	89 04 24             	mov    %eax,(%esp)
  8028b5:	e8 fd ed ff ff       	call   8016b7 <fd_alloc>
  8028ba:	89 c3                	mov    %eax,%ebx
  8028bc:	85 c0                	test   %eax,%eax
  8028be:	0f 88 f8 00 00 00    	js     8029bc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028c4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028cb:	00 
  8028cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028da:	e8 c2 ea ff ff       	call   8013a1 <sys_page_alloc>
  8028df:	89 c3                	mov    %eax,%ebx
  8028e1:	85 c0                	test   %eax,%eax
  8028e3:	0f 88 d3 00 00 00    	js     8029bc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8028e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028ec:	89 04 24             	mov    %eax,(%esp)
  8028ef:	e8 a8 ed ff ff       	call   80169c <fd2data>
  8028f4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028f6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028fd:	00 
  8028fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802902:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802909:	e8 93 ea ff ff       	call   8013a1 <sys_page_alloc>
  80290e:	89 c3                	mov    %eax,%ebx
  802910:	85 c0                	test   %eax,%eax
  802912:	0f 88 91 00 00 00    	js     8029a9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802918:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80291b:	89 04 24             	mov    %eax,(%esp)
  80291e:	e8 79 ed ff ff       	call   80169c <fd2data>
  802923:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80292a:	00 
  80292b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80292f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802936:	00 
  802937:	89 74 24 04          	mov    %esi,0x4(%esp)
  80293b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802942:	e8 ae ea ff ff       	call   8013f5 <sys_page_map>
  802947:	89 c3                	mov    %eax,%ebx
  802949:	85 c0                	test   %eax,%eax
  80294b:	78 4c                	js     802999 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80294d:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802953:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802956:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802958:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80295b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802962:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802968:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80296b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80296d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802970:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80297a:	89 04 24             	mov    %eax,(%esp)
  80297d:	e8 0a ed ff ff       	call   80168c <fd2num>
  802982:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802984:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802987:	89 04 24             	mov    %eax,(%esp)
  80298a:	e8 fd ec ff ff       	call   80168c <fd2num>
  80298f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802992:	bb 00 00 00 00       	mov    $0x0,%ebx
  802997:	eb 36                	jmp    8029cf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802999:	89 74 24 04          	mov    %esi,0x4(%esp)
  80299d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029a4:	e8 9f ea ff ff       	call   801448 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8029a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029b7:	e8 8c ea ff ff       	call   801448 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8029bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029ca:	e8 79 ea ff ff       	call   801448 <sys_page_unmap>
    err:
	return r;
}
  8029cf:	89 d8                	mov    %ebx,%eax
  8029d1:	83 c4 3c             	add    $0x3c,%esp
  8029d4:	5b                   	pop    %ebx
  8029d5:	5e                   	pop    %esi
  8029d6:	5f                   	pop    %edi
  8029d7:	5d                   	pop    %ebp
  8029d8:	c3                   	ret    

008029d9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8029d9:	55                   	push   %ebp
  8029da:	89 e5                	mov    %esp,%ebp
  8029dc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8029e9:	89 04 24             	mov    %eax,(%esp)
  8029ec:	e8 19 ed ff ff       	call   80170a <fd_lookup>
  8029f1:	85 c0                	test   %eax,%eax
  8029f3:	78 15                	js     802a0a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8029f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029f8:	89 04 24             	mov    %eax,(%esp)
  8029fb:	e8 9c ec ff ff       	call   80169c <fd2data>
	return _pipeisclosed(fd, p);
  802a00:	89 c2                	mov    %eax,%edx
  802a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a05:	e8 15 fd ff ff       	call   80271f <_pipeisclosed>
}
  802a0a:	c9                   	leave  
  802a0b:	c3                   	ret    

00802a0c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802a0c:	55                   	push   %ebp
  802a0d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a14:	5d                   	pop    %ebp
  802a15:	c3                   	ret    

00802a16 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802a16:	55                   	push   %ebp
  802a17:	89 e5                	mov    %esp,%ebp
  802a19:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802a1c:	c7 44 24 04 42 36 80 	movl   $0x803642,0x4(%esp)
  802a23:	00 
  802a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a27:	89 04 24             	mov    %eax,(%esp)
  802a2a:	e8 80 e5 ff ff       	call   800faf <strcpy>
	return 0;
}
  802a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a34:	c9                   	leave  
  802a35:	c3                   	ret    

00802a36 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802a36:	55                   	push   %ebp
  802a37:	89 e5                	mov    %esp,%ebp
  802a39:	57                   	push   %edi
  802a3a:	56                   	push   %esi
  802a3b:	53                   	push   %ebx
  802a3c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802a42:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802a47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802a4d:	eb 30                	jmp    802a7f <devcons_write+0x49>
		m = n - tot;
  802a4f:	8b 75 10             	mov    0x10(%ebp),%esi
  802a52:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802a54:	83 fe 7f             	cmp    $0x7f,%esi
  802a57:	76 05                	jbe    802a5e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802a59:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802a5e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802a62:	03 45 0c             	add    0xc(%ebp),%eax
  802a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a69:	89 3c 24             	mov    %edi,(%esp)
  802a6c:	e8 b7 e6 ff ff       	call   801128 <memmove>
		sys_cputs(buf, m);
  802a71:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a75:	89 3c 24             	mov    %edi,(%esp)
  802a78:	e8 57 e8 ff ff       	call   8012d4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802a7d:	01 f3                	add    %esi,%ebx
  802a7f:	89 d8                	mov    %ebx,%eax
  802a81:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802a84:	72 c9                	jb     802a4f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802a86:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802a8c:	5b                   	pop    %ebx
  802a8d:	5e                   	pop    %esi
  802a8e:	5f                   	pop    %edi
  802a8f:	5d                   	pop    %ebp
  802a90:	c3                   	ret    

00802a91 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802a91:	55                   	push   %ebp
  802a92:	89 e5                	mov    %esp,%ebp
  802a94:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802a97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a9b:	75 07                	jne    802aa4 <devcons_read+0x13>
  802a9d:	eb 25                	jmp    802ac4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802a9f:	e8 de e8 ff ff       	call   801382 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802aa4:	e8 49 e8 ff ff       	call   8012f2 <sys_cgetc>
  802aa9:	85 c0                	test   %eax,%eax
  802aab:	74 f2                	je     802a9f <devcons_read+0xe>
  802aad:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802aaf:	85 c0                	test   %eax,%eax
  802ab1:	78 1d                	js     802ad0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802ab3:	83 f8 04             	cmp    $0x4,%eax
  802ab6:	74 13                	je     802acb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  802abb:	88 10                	mov    %dl,(%eax)
	return 1;
  802abd:	b8 01 00 00 00       	mov    $0x1,%eax
  802ac2:	eb 0c                	jmp    802ad0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  802ac9:	eb 05                	jmp    802ad0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802acb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802ad0:	c9                   	leave  
  802ad1:	c3                   	ret    

00802ad2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802ad2:	55                   	push   %ebp
  802ad3:	89 e5                	mov    %esp,%ebp
  802ad5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  802adb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802ade:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802ae5:	00 
  802ae6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802ae9:	89 04 24             	mov    %eax,(%esp)
  802aec:	e8 e3 e7 ff ff       	call   8012d4 <sys_cputs>
}
  802af1:	c9                   	leave  
  802af2:	c3                   	ret    

00802af3 <getchar>:

int
getchar(void)
{
  802af3:	55                   	push   %ebp
  802af4:	89 e5                	mov    %esp,%ebp
  802af6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802af9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802b00:	00 
  802b01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b0f:	e8 92 ee ff ff       	call   8019a6 <read>
	if (r < 0)
  802b14:	85 c0                	test   %eax,%eax
  802b16:	78 0f                	js     802b27 <getchar+0x34>
		return r;
	if (r < 1)
  802b18:	85 c0                	test   %eax,%eax
  802b1a:	7e 06                	jle    802b22 <getchar+0x2f>
		return -E_EOF;
	return c;
  802b1c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802b20:	eb 05                	jmp    802b27 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802b22:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802b27:	c9                   	leave  
  802b28:	c3                   	ret    

00802b29 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802b29:	55                   	push   %ebp
  802b2a:	89 e5                	mov    %esp,%ebp
  802b2c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b36:	8b 45 08             	mov    0x8(%ebp),%eax
  802b39:	89 04 24             	mov    %eax,(%esp)
  802b3c:	e8 c9 eb ff ff       	call   80170a <fd_lookup>
  802b41:	85 c0                	test   %eax,%eax
  802b43:	78 11                	js     802b56 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b48:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802b4e:	39 10                	cmp    %edx,(%eax)
  802b50:	0f 94 c0             	sete   %al
  802b53:	0f b6 c0             	movzbl %al,%eax
}
  802b56:	c9                   	leave  
  802b57:	c3                   	ret    

00802b58 <opencons>:

int
opencons(void)
{
  802b58:	55                   	push   %ebp
  802b59:	89 e5                	mov    %esp,%ebp
  802b5b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802b5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b61:	89 04 24             	mov    %eax,(%esp)
  802b64:	e8 4e eb ff ff       	call   8016b7 <fd_alloc>
  802b69:	85 c0                	test   %eax,%eax
  802b6b:	78 3c                	js     802ba9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802b6d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802b74:	00 
  802b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b83:	e8 19 e8 ff ff       	call   8013a1 <sys_page_alloc>
  802b88:	85 c0                	test   %eax,%eax
  802b8a:	78 1d                	js     802ba9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802b8c:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b95:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802ba1:	89 04 24             	mov    %eax,(%esp)
  802ba4:	e8 e3 ea ff ff       	call   80168c <fd2num>
}
  802ba9:	c9                   	leave  
  802baa:	c3                   	ret    
	...

00802bac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802bac:	55                   	push   %ebp
  802bad:	89 e5                	mov    %esp,%ebp
  802baf:	56                   	push   %esi
  802bb0:	53                   	push   %ebx
  802bb1:	83 ec 10             	sub    $0x10,%esp
  802bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bba:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802bbd:	85 c0                	test   %eax,%eax
  802bbf:	75 05                	jne    802bc6 <ipc_recv+0x1a>
  802bc1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802bc6:	89 04 24             	mov    %eax,(%esp)
  802bc9:	e8 e9 e9 ff ff       	call   8015b7 <sys_ipc_recv>
	if (from_env_store != NULL)
  802bce:	85 db                	test   %ebx,%ebx
  802bd0:	74 0b                	je     802bdd <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802bd2:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802bd8:	8b 52 74             	mov    0x74(%edx),%edx
  802bdb:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802bdd:	85 f6                	test   %esi,%esi
  802bdf:	74 0b                	je     802bec <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802be1:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802be7:	8b 52 78             	mov    0x78(%edx),%edx
  802bea:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802bec:	85 c0                	test   %eax,%eax
  802bee:	79 16                	jns    802c06 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802bf0:	85 db                	test   %ebx,%ebx
  802bf2:	74 06                	je     802bfa <ipc_recv+0x4e>
			*from_env_store = 0;
  802bf4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802bfa:	85 f6                	test   %esi,%esi
  802bfc:	74 10                	je     802c0e <ipc_recv+0x62>
			*perm_store = 0;
  802bfe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802c04:	eb 08                	jmp    802c0e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802c06:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802c0b:	8b 40 70             	mov    0x70(%eax),%eax
}
  802c0e:	83 c4 10             	add    $0x10,%esp
  802c11:	5b                   	pop    %ebx
  802c12:	5e                   	pop    %esi
  802c13:	5d                   	pop    %ebp
  802c14:	c3                   	ret    

00802c15 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802c15:	55                   	push   %ebp
  802c16:	89 e5                	mov    %esp,%ebp
  802c18:	57                   	push   %edi
  802c19:	56                   	push   %esi
  802c1a:	53                   	push   %ebx
  802c1b:	83 ec 1c             	sub    $0x1c,%esp
  802c1e:	8b 75 08             	mov    0x8(%ebp),%esi
  802c21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802c27:	eb 2a                	jmp    802c53 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802c29:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c2c:	74 20                	je     802c4e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802c2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c32:	c7 44 24 08 50 36 80 	movl   $0x803650,0x8(%esp)
  802c39:	00 
  802c3a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802c41:	00 
  802c42:	c7 04 24 78 36 80 00 	movl   $0x803678,(%esp)
  802c49:	e8 be dc ff ff       	call   80090c <_panic>
		sys_yield();
  802c4e:	e8 2f e7 ff ff       	call   801382 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802c53:	85 db                	test   %ebx,%ebx
  802c55:	75 07                	jne    802c5e <ipc_send+0x49>
  802c57:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802c5c:	eb 02                	jmp    802c60 <ipc_send+0x4b>
  802c5e:	89 d8                	mov    %ebx,%eax
  802c60:	8b 55 14             	mov    0x14(%ebp),%edx
  802c63:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802c67:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c6b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c6f:	89 34 24             	mov    %esi,(%esp)
  802c72:	e8 1d e9 ff ff       	call   801594 <sys_ipc_try_send>
  802c77:	85 c0                	test   %eax,%eax
  802c79:	78 ae                	js     802c29 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802c7b:	83 c4 1c             	add    $0x1c,%esp
  802c7e:	5b                   	pop    %ebx
  802c7f:	5e                   	pop    %esi
  802c80:	5f                   	pop    %edi
  802c81:	5d                   	pop    %ebp
  802c82:	c3                   	ret    

00802c83 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c83:	55                   	push   %ebp
  802c84:	89 e5                	mov    %esp,%ebp
  802c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802c89:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c8e:	89 c2                	mov    %eax,%edx
  802c90:	c1 e2 07             	shl    $0x7,%edx
  802c93:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c99:	8b 52 50             	mov    0x50(%edx),%edx
  802c9c:	39 ca                	cmp    %ecx,%edx
  802c9e:	75 0d                	jne    802cad <ipc_find_env+0x2a>
			return envs[i].env_id;
  802ca0:	c1 e0 07             	shl    $0x7,%eax
  802ca3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802ca8:	8b 40 40             	mov    0x40(%eax),%eax
  802cab:	eb 0c                	jmp    802cb9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802cad:	40                   	inc    %eax
  802cae:	3d 00 04 00 00       	cmp    $0x400,%eax
  802cb3:	75 d9                	jne    802c8e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802cb5:	66 b8 00 00          	mov    $0x0,%ax
}
  802cb9:	5d                   	pop    %ebp
  802cba:	c3                   	ret    
	...

00802cbc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802cbc:	55                   	push   %ebp
  802cbd:	89 e5                	mov    %esp,%ebp
  802cbf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802cc2:	89 c2                	mov    %eax,%edx
  802cc4:	c1 ea 16             	shr    $0x16,%edx
  802cc7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cce:	f6 c2 01             	test   $0x1,%dl
  802cd1:	74 1e                	je     802cf1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802cd3:	c1 e8 0c             	shr    $0xc,%eax
  802cd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802cdd:	a8 01                	test   $0x1,%al
  802cdf:	74 17                	je     802cf8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ce1:	c1 e8 0c             	shr    $0xc,%eax
  802ce4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802ceb:	ef 
  802cec:	0f b7 c0             	movzwl %ax,%eax
  802cef:	eb 0c                	jmp    802cfd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  802cf6:	eb 05                	jmp    802cfd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802cf8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802cfd:	5d                   	pop    %ebp
  802cfe:	c3                   	ret    
	...

00802d00 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802d00:	55                   	push   %ebp
  802d01:	57                   	push   %edi
  802d02:	56                   	push   %esi
  802d03:	83 ec 10             	sub    $0x10,%esp
  802d06:	8b 74 24 20          	mov    0x20(%esp),%esi
  802d0a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802d0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d12:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802d16:	89 cd                	mov    %ecx,%ebp
  802d18:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802d1c:	85 c0                	test   %eax,%eax
  802d1e:	75 2c                	jne    802d4c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802d20:	39 f9                	cmp    %edi,%ecx
  802d22:	77 68                	ja     802d8c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802d24:	85 c9                	test   %ecx,%ecx
  802d26:	75 0b                	jne    802d33 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802d28:	b8 01 00 00 00       	mov    $0x1,%eax
  802d2d:	31 d2                	xor    %edx,%edx
  802d2f:	f7 f1                	div    %ecx
  802d31:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802d33:	31 d2                	xor    %edx,%edx
  802d35:	89 f8                	mov    %edi,%eax
  802d37:	f7 f1                	div    %ecx
  802d39:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d3b:	89 f0                	mov    %esi,%eax
  802d3d:	f7 f1                	div    %ecx
  802d3f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d41:	89 f0                	mov    %esi,%eax
  802d43:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d45:	83 c4 10             	add    $0x10,%esp
  802d48:	5e                   	pop    %esi
  802d49:	5f                   	pop    %edi
  802d4a:	5d                   	pop    %ebp
  802d4b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802d4c:	39 f8                	cmp    %edi,%eax
  802d4e:	77 2c                	ja     802d7c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802d50:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802d53:	83 f6 1f             	xor    $0x1f,%esi
  802d56:	75 4c                	jne    802da4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d58:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d5a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d5f:	72 0a                	jb     802d6b <__udivdi3+0x6b>
  802d61:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802d65:	0f 87 ad 00 00 00    	ja     802e18 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d6b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d70:	89 f0                	mov    %esi,%eax
  802d72:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d74:	83 c4 10             	add    $0x10,%esp
  802d77:	5e                   	pop    %esi
  802d78:	5f                   	pop    %edi
  802d79:	5d                   	pop    %ebp
  802d7a:	c3                   	ret    
  802d7b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802d7c:	31 ff                	xor    %edi,%edi
  802d7e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d80:	89 f0                	mov    %esi,%eax
  802d82:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d84:	83 c4 10             	add    $0x10,%esp
  802d87:	5e                   	pop    %esi
  802d88:	5f                   	pop    %edi
  802d89:	5d                   	pop    %ebp
  802d8a:	c3                   	ret    
  802d8b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d8c:	89 fa                	mov    %edi,%edx
  802d8e:	89 f0                	mov    %esi,%eax
  802d90:	f7 f1                	div    %ecx
  802d92:	89 c6                	mov    %eax,%esi
  802d94:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d96:	89 f0                	mov    %esi,%eax
  802d98:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d9a:	83 c4 10             	add    $0x10,%esp
  802d9d:	5e                   	pop    %esi
  802d9e:	5f                   	pop    %edi
  802d9f:	5d                   	pop    %ebp
  802da0:	c3                   	ret    
  802da1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802da4:	89 f1                	mov    %esi,%ecx
  802da6:	d3 e0                	shl    %cl,%eax
  802da8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802dac:	b8 20 00 00 00       	mov    $0x20,%eax
  802db1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802db3:	89 ea                	mov    %ebp,%edx
  802db5:	88 c1                	mov    %al,%cl
  802db7:	d3 ea                	shr    %cl,%edx
  802db9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802dbd:	09 ca                	or     %ecx,%edx
  802dbf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802dc3:	89 f1                	mov    %esi,%ecx
  802dc5:	d3 e5                	shl    %cl,%ebp
  802dc7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802dcb:	89 fd                	mov    %edi,%ebp
  802dcd:	88 c1                	mov    %al,%cl
  802dcf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802dd1:	89 fa                	mov    %edi,%edx
  802dd3:	89 f1                	mov    %esi,%ecx
  802dd5:	d3 e2                	shl    %cl,%edx
  802dd7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802ddb:	88 c1                	mov    %al,%cl
  802ddd:	d3 ef                	shr    %cl,%edi
  802ddf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802de1:	89 f8                	mov    %edi,%eax
  802de3:	89 ea                	mov    %ebp,%edx
  802de5:	f7 74 24 08          	divl   0x8(%esp)
  802de9:	89 d1                	mov    %edx,%ecx
  802deb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802ded:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802df1:	39 d1                	cmp    %edx,%ecx
  802df3:	72 17                	jb     802e0c <__udivdi3+0x10c>
  802df5:	74 09                	je     802e00 <__udivdi3+0x100>
  802df7:	89 fe                	mov    %edi,%esi
  802df9:	31 ff                	xor    %edi,%edi
  802dfb:	e9 41 ff ff ff       	jmp    802d41 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802e00:	8b 54 24 04          	mov    0x4(%esp),%edx
  802e04:	89 f1                	mov    %esi,%ecx
  802e06:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802e08:	39 c2                	cmp    %eax,%edx
  802e0a:	73 eb                	jae    802df7 <__udivdi3+0xf7>
		{
		  q0--;
  802e0c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802e0f:	31 ff                	xor    %edi,%edi
  802e11:	e9 2b ff ff ff       	jmp    802d41 <__udivdi3+0x41>
  802e16:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802e18:	31 f6                	xor    %esi,%esi
  802e1a:	e9 22 ff ff ff       	jmp    802d41 <__udivdi3+0x41>
	...

00802e20 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802e20:	55                   	push   %ebp
  802e21:	57                   	push   %edi
  802e22:	56                   	push   %esi
  802e23:	83 ec 20             	sub    $0x20,%esp
  802e26:	8b 44 24 30          	mov    0x30(%esp),%eax
  802e2a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802e2e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802e32:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802e36:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802e3a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802e3e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802e40:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802e42:	85 ed                	test   %ebp,%ebp
  802e44:	75 16                	jne    802e5c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802e46:	39 f1                	cmp    %esi,%ecx
  802e48:	0f 86 a6 00 00 00    	jbe    802ef4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802e4e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802e50:	89 d0                	mov    %edx,%eax
  802e52:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802e54:	83 c4 20             	add    $0x20,%esp
  802e57:	5e                   	pop    %esi
  802e58:	5f                   	pop    %edi
  802e59:	5d                   	pop    %ebp
  802e5a:	c3                   	ret    
  802e5b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802e5c:	39 f5                	cmp    %esi,%ebp
  802e5e:	0f 87 ac 00 00 00    	ja     802f10 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802e64:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802e67:	83 f0 1f             	xor    $0x1f,%eax
  802e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e6e:	0f 84 a8 00 00 00    	je     802f1c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802e74:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802e78:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802e7a:	bf 20 00 00 00       	mov    $0x20,%edi
  802e7f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802e83:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802e87:	89 f9                	mov    %edi,%ecx
  802e89:	d3 e8                	shr    %cl,%eax
  802e8b:	09 e8                	or     %ebp,%eax
  802e8d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802e91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802e95:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802e99:	d3 e0                	shl    %cl,%eax
  802e9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802e9f:	89 f2                	mov    %esi,%edx
  802ea1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ea3:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ea7:	d3 e0                	shl    %cl,%eax
  802ea9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ead:	8b 44 24 14          	mov    0x14(%esp),%eax
  802eb1:	89 f9                	mov    %edi,%ecx
  802eb3:	d3 e8                	shr    %cl,%eax
  802eb5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802eb7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802eb9:	89 f2                	mov    %esi,%edx
  802ebb:	f7 74 24 18          	divl   0x18(%esp)
  802ebf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ec1:	f7 64 24 0c          	mull   0xc(%esp)
  802ec5:	89 c5                	mov    %eax,%ebp
  802ec7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ec9:	39 d6                	cmp    %edx,%esi
  802ecb:	72 67                	jb     802f34 <__umoddi3+0x114>
  802ecd:	74 75                	je     802f44 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802ecf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802ed3:	29 e8                	sub    %ebp,%eax
  802ed5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802ed7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802edb:	d3 e8                	shr    %cl,%eax
  802edd:	89 f2                	mov    %esi,%edx
  802edf:	89 f9                	mov    %edi,%ecx
  802ee1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802ee3:	09 d0                	or     %edx,%eax
  802ee5:	89 f2                	mov    %esi,%edx
  802ee7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802eeb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802eed:	83 c4 20             	add    $0x20,%esp
  802ef0:	5e                   	pop    %esi
  802ef1:	5f                   	pop    %edi
  802ef2:	5d                   	pop    %ebp
  802ef3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ef4:	85 c9                	test   %ecx,%ecx
  802ef6:	75 0b                	jne    802f03 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ef8:	b8 01 00 00 00       	mov    $0x1,%eax
  802efd:	31 d2                	xor    %edx,%edx
  802eff:	f7 f1                	div    %ecx
  802f01:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802f03:	89 f0                	mov    %esi,%eax
  802f05:	31 d2                	xor    %edx,%edx
  802f07:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802f09:	89 f8                	mov    %edi,%eax
  802f0b:	e9 3e ff ff ff       	jmp    802e4e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802f10:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802f12:	83 c4 20             	add    $0x20,%esp
  802f15:	5e                   	pop    %esi
  802f16:	5f                   	pop    %edi
  802f17:	5d                   	pop    %ebp
  802f18:	c3                   	ret    
  802f19:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f1c:	39 f5                	cmp    %esi,%ebp
  802f1e:	72 04                	jb     802f24 <__umoddi3+0x104>
  802f20:	39 f9                	cmp    %edi,%ecx
  802f22:	77 06                	ja     802f2a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f24:	89 f2                	mov    %esi,%edx
  802f26:	29 cf                	sub    %ecx,%edi
  802f28:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802f2a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802f2c:	83 c4 20             	add    $0x20,%esp
  802f2f:	5e                   	pop    %esi
  802f30:	5f                   	pop    %edi
  802f31:	5d                   	pop    %ebp
  802f32:	c3                   	ret    
  802f33:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802f34:	89 d1                	mov    %edx,%ecx
  802f36:	89 c5                	mov    %eax,%ebp
  802f38:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802f3c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802f40:	eb 8d                	jmp    802ecf <__umoddi3+0xaf>
  802f42:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802f44:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802f48:	72 ea                	jb     802f34 <__umoddi3+0x114>
  802f4a:	89 f1                	mov    %esi,%ecx
  802f4c:	eb 81                	jmp    802ecf <__umoddi3+0xaf>
