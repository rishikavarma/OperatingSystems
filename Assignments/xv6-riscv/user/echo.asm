
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	02099793          	slli	a5,s3,0x20
  22:	01d7d993          	srli	s3,a5,0x1d
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00000a17          	auipc	s4,0x0
  2e:	786a0a13          	addi	s4,s4,1926 # 7b0 <malloc+0xe8>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	094080e7          	jalr	148(ra) # cc <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	26a080e7          	jalr	618(ra) # 2b2 <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	256080e7          	jalr	598(ra) # 2b2 <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00000597          	auipc	a1,0x0
  6c:	75058593          	addi	a1,a1,1872 # 7b8 <malloc+0xf0>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	240080e7          	jalr	576(ra) # 2b2 <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	216080e7          	jalr	534(ra) # 292 <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ca19                	beqz	a2,112 <memset+0x1c>
  fe:	87aa                	mv	a5,a0
 100:	1602                	slli	a2,a2,0x20
 102:	9201                	srli	a2,a2,0x20
 104:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 108:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10c:	0785                	addi	a5,a5,1
 10e:	fee79de3          	bne	a5,a4,108 <memset+0x12>
  }
  return dst;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strchr>:

char*
strchr(const char *s, char c)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb99                	beqz	a5,138 <strchr+0x20>
    if(*s == c)
 124:	00f58763          	beq	a1,a5,132 <strchr+0x1a>
  for(; *s; s++)
 128:	0505                	addi	a0,a0,1
 12a:	00054783          	lbu	a5,0(a0)
 12e:	fbfd                	bnez	a5,124 <strchr+0xc>
      return (char*)s;
  return 0;
 130:	4501                	li	a0,0
}
 132:	6422                	ld	s0,8(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret
  return 0;
 138:	4501                	li	a0,0
 13a:	bfe5                	j	132 <strchr+0x1a>

000000000000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	711d                	addi	sp,sp,-96
 13e:	ec86                	sd	ra,88(sp)
 140:	e8a2                	sd	s0,80(sp)
 142:	e4a6                	sd	s1,72(sp)
 144:	e0ca                	sd	s2,64(sp)
 146:	fc4e                	sd	s3,56(sp)
 148:	f852                	sd	s4,48(sp)
 14a:	f456                	sd	s5,40(sp)
 14c:	f05a                	sd	s6,32(sp)
 14e:	ec5e                	sd	s7,24(sp)
 150:	1080                	addi	s0,sp,96
 152:	8baa                	mv	s7,a0
 154:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 156:	892a                	mv	s2,a0
 158:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15a:	4aa9                	li	s5,10
 15c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15e:	89a6                	mv	s3,s1
 160:	2485                	addiw	s1,s1,1
 162:	0344d863          	bge	s1,s4,192 <gets+0x56>
    cc = read(0, &c, 1);
 166:	4605                	li	a2,1
 168:	faf40593          	addi	a1,s0,-81
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	13c080e7          	jalr	316(ra) # 2aa <read>
    if(cc < 1)
 176:	00a05e63          	blez	a0,192 <gets+0x56>
    buf[i++] = c;
 17a:	faf44783          	lbu	a5,-81(s0)
 17e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 182:	01578763          	beq	a5,s5,190 <gets+0x54>
 186:	0905                	addi	s2,s2,1
 188:	fd679be3          	bne	a5,s6,15e <gets+0x22>
  for(i=0; i+1 < max; ){
 18c:	89a6                	mv	s3,s1
 18e:	a011                	j	192 <gets+0x56>
 190:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 192:	99de                	add	s3,s3,s7
 194:	00098023          	sb	zero,0(s3)
  return buf;
}
 198:	855e                	mv	a0,s7
 19a:	60e6                	ld	ra,88(sp)
 19c:	6446                	ld	s0,80(sp)
 19e:	64a6                	ld	s1,72(sp)
 1a0:	6906                	ld	s2,64(sp)
 1a2:	79e2                	ld	s3,56(sp)
 1a4:	7a42                	ld	s4,48(sp)
 1a6:	7aa2                	ld	s5,40(sp)
 1a8:	7b02                	ld	s6,32(sp)
 1aa:	6be2                	ld	s7,24(sp)
 1ac:	6125                	addi	sp,sp,96
 1ae:	8082                	ret

00000000000001b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b0:	1101                	addi	sp,sp,-32
 1b2:	ec06                	sd	ra,24(sp)
 1b4:	e822                	sd	s0,16(sp)
 1b6:	e426                	sd	s1,8(sp)
 1b8:	e04a                	sd	s2,0(sp)
 1ba:	1000                	addi	s0,sp,32
 1bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1be:	4581                	li	a1,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	112080e7          	jalr	274(ra) # 2d2 <open>
  if(fd < 0)
 1c8:	02054563          	bltz	a0,1f2 <stat+0x42>
 1cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ce:	85ca                	mv	a1,s2
 1d0:	00000097          	auipc	ra,0x0
 1d4:	11a080e7          	jalr	282(ra) # 2ea <fstat>
 1d8:	892a                	mv	s2,a0
  close(fd);
 1da:	8526                	mv	a0,s1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	0de080e7          	jalr	222(ra) # 2ba <close>
  return r;
}
 1e4:	854a                	mv	a0,s2
 1e6:	60e2                	ld	ra,24(sp)
 1e8:	6442                	ld	s0,16(sp)
 1ea:	64a2                	ld	s1,8(sp)
 1ec:	6902                	ld	s2,0(sp)
 1ee:	6105                	addi	sp,sp,32
 1f0:	8082                	ret
    return -1;
 1f2:	597d                	li	s2,-1
 1f4:	bfc5                	j	1e4 <stat+0x34>

00000000000001f6 <atoi>:

int
atoi(const char *s)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fc:	00054603          	lbu	a2,0(a0)
 200:	fd06079b          	addiw	a5,a2,-48
 204:	0ff7f793          	andi	a5,a5,255
 208:	4725                	li	a4,9
 20a:	02f76963          	bltu	a4,a5,23c <atoi+0x46>
 20e:	86aa                	mv	a3,a0
  n = 0;
 210:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 212:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 214:	0685                	addi	a3,a3,1
 216:	0025179b          	slliw	a5,a0,0x2
 21a:	9fa9                	addw	a5,a5,a0
 21c:	0017979b          	slliw	a5,a5,0x1
 220:	9fb1                	addw	a5,a5,a2
 222:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 226:	0006c603          	lbu	a2,0(a3)
 22a:	fd06071b          	addiw	a4,a2,-48
 22e:	0ff77713          	andi	a4,a4,255
 232:	fee5f1e3          	bgeu	a1,a4,214 <atoi+0x1e>
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  n = 0;
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <atoi+0x40>

0000000000000240 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 246:	00c05f63          	blez	a2,264 <memmove+0x24>
 24a:	1602                	slli	a2,a2,0x20
 24c:	9201                	srli	a2,a2,0x20
 24e:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 252:	87aa                	mv	a5,a0
    *dst++ = *src++;
 254:	0585                	addi	a1,a1,1
 256:	0785                	addi	a5,a5,1
 258:	fff5c703          	lbu	a4,-1(a1)
 25c:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 260:	fed79ae3          	bne	a5,a3,254 <memmove+0x14>
  return vdst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret

000000000000026a <trace>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global trace
trace:
 li a7, SYS_trace
 26a:	48e5                	li	a7,25
 ecall
 26c:	00000073          	ecall
 ret
 270:	8082                	ret

0000000000000272 <get_process_info>:
.global get_process_info
get_process_info:
 li a7, SYS_get_process_info
 272:	48e1                	li	a7,24
 ecall
 274:	00000073          	ecall
 ret
 278:	8082                	ret

000000000000027a <echo_kernel>:
.global echo_kernel
echo_kernel:
 li a7, SYS_echo_kernel
 27a:	48dd                	li	a7,23
 ecall
 27c:	00000073          	ecall
 ret
 280:	8082                	ret

0000000000000282 <echo_simple>:
.global echo_simple
echo_simple:
 li a7, SYS_echo_simple
 282:	48d9                	li	a7,22
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <fork>:
.global fork
fork:
 li a7, SYS_fork
 28a:	4885                	li	a7,1
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <exit>:
.global exit
exit:
 li a7, SYS_exit
 292:	4889                	li	a7,2
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <wait>:
.global wait
wait:
 li a7, SYS_wait
 29a:	488d                	li	a7,3
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2a2:	4891                	li	a7,4
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <read>:
.global read
read:
 li a7, SYS_read
 2aa:	4895                	li	a7,5
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <write>:
.global write
write:
 li a7, SYS_write
 2b2:	48c1                	li	a7,16
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <close>:
.global close
close:
 li a7, SYS_close
 2ba:	48d5                	li	a7,21
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2c2:	4899                	li	a7,6
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ca:	489d                	li	a7,7
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <open>:
.global open
open:
 li a7, SYS_open
 2d2:	48bd                	li	a7,15
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2da:	48c5                	li	a7,17
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2e2:	48c9                	li	a7,18
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2ea:	48a1                	li	a7,8
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <link>:
.global link
link:
 li a7, SYS_link
 2f2:	48cd                	li	a7,19
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2fa:	48d1                	li	a7,20
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 302:	48a5                	li	a7,9
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <dup>:
.global dup
dup:
 li a7, SYS_dup
 30a:	48a9                	li	a7,10
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 312:	48ad                	li	a7,11
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 31a:	48b1                	li	a7,12
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 322:	48b5                	li	a7,13
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 32a:	48b9                	li	a7,14
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 332:	1101                	addi	sp,sp,-32
 334:	ec06                	sd	ra,24(sp)
 336:	e822                	sd	s0,16(sp)
 338:	1000                	addi	s0,sp,32
 33a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 33e:	4605                	li	a2,1
 340:	fef40593          	addi	a1,s0,-17
 344:	00000097          	auipc	ra,0x0
 348:	f6e080e7          	jalr	-146(ra) # 2b2 <write>
}
 34c:	60e2                	ld	ra,24(sp)
 34e:	6442                	ld	s0,16(sp)
 350:	6105                	addi	sp,sp,32
 352:	8082                	ret

0000000000000354 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 354:	7139                	addi	sp,sp,-64
 356:	fc06                	sd	ra,56(sp)
 358:	f822                	sd	s0,48(sp)
 35a:	f426                	sd	s1,40(sp)
 35c:	f04a                	sd	s2,32(sp)
 35e:	ec4e                	sd	s3,24(sp)
 360:	0080                	addi	s0,sp,64
 362:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 364:	c299                	beqz	a3,36a <printint+0x16>
 366:	0805c863          	bltz	a1,3f6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 36a:	2581                	sext.w	a1,a1
  neg = 0;
 36c:	4881                	li	a7,0
 36e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 372:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 374:	2601                	sext.w	a2,a2
 376:	00000517          	auipc	a0,0x0
 37a:	45250513          	addi	a0,a0,1106 # 7c8 <digits>
 37e:	883a                	mv	a6,a4
 380:	2705                	addiw	a4,a4,1
 382:	02c5f7bb          	remuw	a5,a1,a2
 386:	1782                	slli	a5,a5,0x20
 388:	9381                	srli	a5,a5,0x20
 38a:	97aa                	add	a5,a5,a0
 38c:	0007c783          	lbu	a5,0(a5)
 390:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 394:	0005879b          	sext.w	a5,a1
 398:	02c5d5bb          	divuw	a1,a1,a2
 39c:	0685                	addi	a3,a3,1
 39e:	fec7f0e3          	bgeu	a5,a2,37e <printint+0x2a>
  if(neg)
 3a2:	00088b63          	beqz	a7,3b8 <printint+0x64>
    buf[i++] = '-';
 3a6:	fd040793          	addi	a5,s0,-48
 3aa:	973e                	add	a4,a4,a5
 3ac:	02d00793          	li	a5,45
 3b0:	fef70823          	sb	a5,-16(a4)
 3b4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3b8:	02e05863          	blez	a4,3e8 <printint+0x94>
 3bc:	fc040793          	addi	a5,s0,-64
 3c0:	00e78933          	add	s2,a5,a4
 3c4:	fff78993          	addi	s3,a5,-1
 3c8:	99ba                	add	s3,s3,a4
 3ca:	377d                	addiw	a4,a4,-1
 3cc:	1702                	slli	a4,a4,0x20
 3ce:	9301                	srli	a4,a4,0x20
 3d0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3d4:	fff94583          	lbu	a1,-1(s2)
 3d8:	8526                	mv	a0,s1
 3da:	00000097          	auipc	ra,0x0
 3de:	f58080e7          	jalr	-168(ra) # 332 <putc>
  while(--i >= 0)
 3e2:	197d                	addi	s2,s2,-1
 3e4:	ff3918e3          	bne	s2,s3,3d4 <printint+0x80>
}
 3e8:	70e2                	ld	ra,56(sp)
 3ea:	7442                	ld	s0,48(sp)
 3ec:	74a2                	ld	s1,40(sp)
 3ee:	7902                	ld	s2,32(sp)
 3f0:	69e2                	ld	s3,24(sp)
 3f2:	6121                	addi	sp,sp,64
 3f4:	8082                	ret
    x = -xx;
 3f6:	40b005bb          	negw	a1,a1
    neg = 1;
 3fa:	4885                	li	a7,1
    x = -xx;
 3fc:	bf8d                	j	36e <printint+0x1a>

00000000000003fe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3fe:	7119                	addi	sp,sp,-128
 400:	fc86                	sd	ra,120(sp)
 402:	f8a2                	sd	s0,112(sp)
 404:	f4a6                	sd	s1,104(sp)
 406:	f0ca                	sd	s2,96(sp)
 408:	ecce                	sd	s3,88(sp)
 40a:	e8d2                	sd	s4,80(sp)
 40c:	e4d6                	sd	s5,72(sp)
 40e:	e0da                	sd	s6,64(sp)
 410:	fc5e                	sd	s7,56(sp)
 412:	f862                	sd	s8,48(sp)
 414:	f466                	sd	s9,40(sp)
 416:	f06a                	sd	s10,32(sp)
 418:	ec6e                	sd	s11,24(sp)
 41a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 41c:	0005c903          	lbu	s2,0(a1)
 420:	18090f63          	beqz	s2,5be <vprintf+0x1c0>
 424:	8aaa                	mv	s5,a0
 426:	8b32                	mv	s6,a2
 428:	00158493          	addi	s1,a1,1
  state = 0;
 42c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 42e:	02500a13          	li	s4,37
      if(c == 'd'){
 432:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 436:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 43a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 43e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 442:	00000b97          	auipc	s7,0x0
 446:	386b8b93          	addi	s7,s7,902 # 7c8 <digits>
 44a:	a839                	j	468 <vprintf+0x6a>
        putc(fd, c);
 44c:	85ca                	mv	a1,s2
 44e:	8556                	mv	a0,s5
 450:	00000097          	auipc	ra,0x0
 454:	ee2080e7          	jalr	-286(ra) # 332 <putc>
 458:	a019                	j	45e <vprintf+0x60>
    } else if(state == '%'){
 45a:	01498f63          	beq	s3,s4,478 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 45e:	0485                	addi	s1,s1,1
 460:	fff4c903          	lbu	s2,-1(s1)
 464:	14090d63          	beqz	s2,5be <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 468:	0009079b          	sext.w	a5,s2
    if(state == 0){
 46c:	fe0997e3          	bnez	s3,45a <vprintf+0x5c>
      if(c == '%'){
 470:	fd479ee3          	bne	a5,s4,44c <vprintf+0x4e>
        state = '%';
 474:	89be                	mv	s3,a5
 476:	b7e5                	j	45e <vprintf+0x60>
      if(c == 'd'){
 478:	05878063          	beq	a5,s8,4b8 <vprintf+0xba>
      } else if(c == 'l') {
 47c:	05978c63          	beq	a5,s9,4d4 <vprintf+0xd6>
      } else if(c == 'x') {
 480:	07a78863          	beq	a5,s10,4f0 <vprintf+0xf2>
      } else if(c == 'p') {
 484:	09b78463          	beq	a5,s11,50c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 488:	07300713          	li	a4,115
 48c:	0ce78663          	beq	a5,a4,558 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 490:	06300713          	li	a4,99
 494:	0ee78e63          	beq	a5,a4,590 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 498:	11478863          	beq	a5,s4,5a8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 49c:	85d2                	mv	a1,s4
 49e:	8556                	mv	a0,s5
 4a0:	00000097          	auipc	ra,0x0
 4a4:	e92080e7          	jalr	-366(ra) # 332 <putc>
        putc(fd, c);
 4a8:	85ca                	mv	a1,s2
 4aa:	8556                	mv	a0,s5
 4ac:	00000097          	auipc	ra,0x0
 4b0:	e86080e7          	jalr	-378(ra) # 332 <putc>
      }
      state = 0;
 4b4:	4981                	li	s3,0
 4b6:	b765                	j	45e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4b8:	008b0913          	addi	s2,s6,8
 4bc:	4685                	li	a3,1
 4be:	4629                	li	a2,10
 4c0:	000b2583          	lw	a1,0(s6)
 4c4:	8556                	mv	a0,s5
 4c6:	00000097          	auipc	ra,0x0
 4ca:	e8e080e7          	jalr	-370(ra) # 354 <printint>
 4ce:	8b4a                	mv	s6,s2
      state = 0;
 4d0:	4981                	li	s3,0
 4d2:	b771                	j	45e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4d4:	008b0913          	addi	s2,s6,8
 4d8:	4681                	li	a3,0
 4da:	4629                	li	a2,10
 4dc:	000b2583          	lw	a1,0(s6)
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	e72080e7          	jalr	-398(ra) # 354 <printint>
 4ea:	8b4a                	mv	s6,s2
      state = 0;
 4ec:	4981                	li	s3,0
 4ee:	bf85                	j	45e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4f0:	008b0913          	addi	s2,s6,8
 4f4:	4681                	li	a3,0
 4f6:	4641                	li	a2,16
 4f8:	000b2583          	lw	a1,0(s6)
 4fc:	8556                	mv	a0,s5
 4fe:	00000097          	auipc	ra,0x0
 502:	e56080e7          	jalr	-426(ra) # 354 <printint>
 506:	8b4a                	mv	s6,s2
      state = 0;
 508:	4981                	li	s3,0
 50a:	bf91                	j	45e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 50c:	008b0793          	addi	a5,s6,8
 510:	f8f43423          	sd	a5,-120(s0)
 514:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 518:	03000593          	li	a1,48
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	e14080e7          	jalr	-492(ra) # 332 <putc>
  putc(fd, 'x');
 526:	85ea                	mv	a1,s10
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e08080e7          	jalr	-504(ra) # 332 <putc>
 532:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 534:	03c9d793          	srli	a5,s3,0x3c
 538:	97de                	add	a5,a5,s7
 53a:	0007c583          	lbu	a1,0(a5)
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	df2080e7          	jalr	-526(ra) # 332 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 548:	0992                	slli	s3,s3,0x4
 54a:	397d                	addiw	s2,s2,-1
 54c:	fe0914e3          	bnez	s2,534 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 550:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 554:	4981                	li	s3,0
 556:	b721                	j	45e <vprintf+0x60>
        s = va_arg(ap, char*);
 558:	008b0993          	addi	s3,s6,8
 55c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 560:	02090163          	beqz	s2,582 <vprintf+0x184>
        while(*s != 0){
 564:	00094583          	lbu	a1,0(s2)
 568:	c9a1                	beqz	a1,5b8 <vprintf+0x1ba>
          putc(fd, *s);
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	dc6080e7          	jalr	-570(ra) # 332 <putc>
          s++;
 574:	0905                	addi	s2,s2,1
        while(*s != 0){
 576:	00094583          	lbu	a1,0(s2)
 57a:	f9e5                	bnez	a1,56a <vprintf+0x16c>
        s = va_arg(ap, char*);
 57c:	8b4e                	mv	s6,s3
      state = 0;
 57e:	4981                	li	s3,0
 580:	bdf9                	j	45e <vprintf+0x60>
          s = "(null)";
 582:	00000917          	auipc	s2,0x0
 586:	23e90913          	addi	s2,s2,574 # 7c0 <malloc+0xf8>
        while(*s != 0){
 58a:	02800593          	li	a1,40
 58e:	bff1                	j	56a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 590:	008b0913          	addi	s2,s6,8
 594:	000b4583          	lbu	a1,0(s6)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	d98080e7          	jalr	-616(ra) # 332 <putc>
 5a2:	8b4a                	mv	s6,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bd65                	j	45e <vprintf+0x60>
        putc(fd, c);
 5a8:	85d2                	mv	a1,s4
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	d86080e7          	jalr	-634(ra) # 332 <putc>
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b565                	j	45e <vprintf+0x60>
        s = va_arg(ap, char*);
 5b8:	8b4e                	mv	s6,s3
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	b54d                	j	45e <vprintf+0x60>
    }
  }
}
 5be:	70e6                	ld	ra,120(sp)
 5c0:	7446                	ld	s0,112(sp)
 5c2:	74a6                	ld	s1,104(sp)
 5c4:	7906                	ld	s2,96(sp)
 5c6:	69e6                	ld	s3,88(sp)
 5c8:	6a46                	ld	s4,80(sp)
 5ca:	6aa6                	ld	s5,72(sp)
 5cc:	6b06                	ld	s6,64(sp)
 5ce:	7be2                	ld	s7,56(sp)
 5d0:	7c42                	ld	s8,48(sp)
 5d2:	7ca2                	ld	s9,40(sp)
 5d4:	7d02                	ld	s10,32(sp)
 5d6:	6de2                	ld	s11,24(sp)
 5d8:	6109                	addi	sp,sp,128
 5da:	8082                	ret

00000000000005dc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5dc:	715d                	addi	sp,sp,-80
 5de:	ec06                	sd	ra,24(sp)
 5e0:	e822                	sd	s0,16(sp)
 5e2:	1000                	addi	s0,sp,32
 5e4:	e010                	sd	a2,0(s0)
 5e6:	e414                	sd	a3,8(s0)
 5e8:	e818                	sd	a4,16(s0)
 5ea:	ec1c                	sd	a5,24(s0)
 5ec:	03043023          	sd	a6,32(s0)
 5f0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5f4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5f8:	8622                	mv	a2,s0
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e04080e7          	jalr	-508(ra) # 3fe <vprintf>
}
 602:	60e2                	ld	ra,24(sp)
 604:	6442                	ld	s0,16(sp)
 606:	6161                	addi	sp,sp,80
 608:	8082                	ret

000000000000060a <printf>:

void
printf(const char *fmt, ...)
{
 60a:	711d                	addi	sp,sp,-96
 60c:	ec06                	sd	ra,24(sp)
 60e:	e822                	sd	s0,16(sp)
 610:	1000                	addi	s0,sp,32
 612:	e40c                	sd	a1,8(s0)
 614:	e810                	sd	a2,16(s0)
 616:	ec14                	sd	a3,24(s0)
 618:	f018                	sd	a4,32(s0)
 61a:	f41c                	sd	a5,40(s0)
 61c:	03043823          	sd	a6,48(s0)
 620:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 624:	00840613          	addi	a2,s0,8
 628:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 62c:	85aa                	mv	a1,a0
 62e:	4505                	li	a0,1
 630:	00000097          	auipc	ra,0x0
 634:	dce080e7          	jalr	-562(ra) # 3fe <vprintf>
}
 638:	60e2                	ld	ra,24(sp)
 63a:	6442                	ld	s0,16(sp)
 63c:	6125                	addi	sp,sp,96
 63e:	8082                	ret

0000000000000640 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 640:	1141                	addi	sp,sp,-16
 642:	e422                	sd	s0,8(sp)
 644:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 646:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64a:	00000797          	auipc	a5,0x0
 64e:	1967b783          	ld	a5,406(a5) # 7e0 <freep>
 652:	a805                	j	682 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 654:	4618                	lw	a4,8(a2)
 656:	9db9                	addw	a1,a1,a4
 658:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 65c:	6398                	ld	a4,0(a5)
 65e:	6318                	ld	a4,0(a4)
 660:	fee53823          	sd	a4,-16(a0)
 664:	a091                	j	6a8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 666:	ff852703          	lw	a4,-8(a0)
 66a:	9e39                	addw	a2,a2,a4
 66c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 66e:	ff053703          	ld	a4,-16(a0)
 672:	e398                	sd	a4,0(a5)
 674:	a099                	j	6ba <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 676:	6398                	ld	a4,0(a5)
 678:	00e7e463          	bltu	a5,a4,680 <free+0x40>
 67c:	00e6ea63          	bltu	a3,a4,690 <free+0x50>
{
 680:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 682:	fed7fae3          	bgeu	a5,a3,676 <free+0x36>
 686:	6398                	ld	a4,0(a5)
 688:	00e6e463          	bltu	a3,a4,690 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68c:	fee7eae3          	bltu	a5,a4,680 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 690:	ff852583          	lw	a1,-8(a0)
 694:	6390                	ld	a2,0(a5)
 696:	02059813          	slli	a6,a1,0x20
 69a:	01c85713          	srli	a4,a6,0x1c
 69e:	9736                	add	a4,a4,a3
 6a0:	fae60ae3          	beq	a2,a4,654 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6a4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6a8:	4790                	lw	a2,8(a5)
 6aa:	02061593          	slli	a1,a2,0x20
 6ae:	01c5d713          	srli	a4,a1,0x1c
 6b2:	973e                	add	a4,a4,a5
 6b4:	fae689e3          	beq	a3,a4,666 <free+0x26>
  } else
    p->s.ptr = bp;
 6b8:	e394                	sd	a3,0(a5)
  freep = p;
 6ba:	00000717          	auipc	a4,0x0
 6be:	12f73323          	sd	a5,294(a4) # 7e0 <freep>
}
 6c2:	6422                	ld	s0,8(sp)
 6c4:	0141                	addi	sp,sp,16
 6c6:	8082                	ret

00000000000006c8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6c8:	7139                	addi	sp,sp,-64
 6ca:	fc06                	sd	ra,56(sp)
 6cc:	f822                	sd	s0,48(sp)
 6ce:	f426                	sd	s1,40(sp)
 6d0:	f04a                	sd	s2,32(sp)
 6d2:	ec4e                	sd	s3,24(sp)
 6d4:	e852                	sd	s4,16(sp)
 6d6:	e456                	sd	s5,8(sp)
 6d8:	e05a                	sd	s6,0(sp)
 6da:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6dc:	02051493          	slli	s1,a0,0x20
 6e0:	9081                	srli	s1,s1,0x20
 6e2:	04bd                	addi	s1,s1,15
 6e4:	8091                	srli	s1,s1,0x4
 6e6:	0014899b          	addiw	s3,s1,1
 6ea:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6ec:	00000517          	auipc	a0,0x0
 6f0:	0f453503          	ld	a0,244(a0) # 7e0 <freep>
 6f4:	c515                	beqz	a0,720 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6f8:	4798                	lw	a4,8(a5)
 6fa:	02977f63          	bgeu	a4,s1,738 <malloc+0x70>
 6fe:	8a4e                	mv	s4,s3
 700:	0009871b          	sext.w	a4,s3
 704:	6685                	lui	a3,0x1
 706:	00d77363          	bgeu	a4,a3,70c <malloc+0x44>
 70a:	6a05                	lui	s4,0x1
 70c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 710:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 714:	00000917          	auipc	s2,0x0
 718:	0cc90913          	addi	s2,s2,204 # 7e0 <freep>
  if(p == (char*)-1)
 71c:	5afd                	li	s5,-1
 71e:	a895                	j	792 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 720:	00000797          	auipc	a5,0x0
 724:	0c878793          	addi	a5,a5,200 # 7e8 <base>
 728:	00000717          	auipc	a4,0x0
 72c:	0af73c23          	sd	a5,184(a4) # 7e0 <freep>
 730:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 732:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 736:	b7e1                	j	6fe <malloc+0x36>
      if(p->s.size == nunits)
 738:	02e48c63          	beq	s1,a4,770 <malloc+0xa8>
        p->s.size -= nunits;
 73c:	4137073b          	subw	a4,a4,s3
 740:	c798                	sw	a4,8(a5)
        p += p->s.size;
 742:	02071693          	slli	a3,a4,0x20
 746:	01c6d713          	srli	a4,a3,0x1c
 74a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 74c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 750:	00000717          	auipc	a4,0x0
 754:	08a73823          	sd	a0,144(a4) # 7e0 <freep>
      return (void*)(p + 1);
 758:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 75c:	70e2                	ld	ra,56(sp)
 75e:	7442                	ld	s0,48(sp)
 760:	74a2                	ld	s1,40(sp)
 762:	7902                	ld	s2,32(sp)
 764:	69e2                	ld	s3,24(sp)
 766:	6a42                	ld	s4,16(sp)
 768:	6aa2                	ld	s5,8(sp)
 76a:	6b02                	ld	s6,0(sp)
 76c:	6121                	addi	sp,sp,64
 76e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 770:	6398                	ld	a4,0(a5)
 772:	e118                	sd	a4,0(a0)
 774:	bff1                	j	750 <malloc+0x88>
  hp->s.size = nu;
 776:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 77a:	0541                	addi	a0,a0,16
 77c:	00000097          	auipc	ra,0x0
 780:	ec4080e7          	jalr	-316(ra) # 640 <free>
  return freep;
 784:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 788:	d971                	beqz	a0,75c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 78c:	4798                	lw	a4,8(a5)
 78e:	fa9775e3          	bgeu	a4,s1,738 <malloc+0x70>
    if(p == freep)
 792:	00093703          	ld	a4,0(s2)
 796:	853e                	mv	a0,a5
 798:	fef719e3          	bne	a4,a5,78a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 79c:	8552                	mv	a0,s4
 79e:	00000097          	auipc	ra,0x0
 7a2:	b7c080e7          	jalr	-1156(ra) # 31a <sbrk>
  if(p == (char*)-1)
 7a6:	fd5518e3          	bne	a0,s5,776 <malloc+0xae>
        return 0;
 7aa:	4501                	li	a0,0
 7ac:	bf45                	j	75c <malloc+0x94>
