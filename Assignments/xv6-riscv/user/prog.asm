
user/_prog:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
	int i;
	for(i = 1; i<argc; i++){
   e:	4785                	li	a5,1
  10:	02a7d963          	bge	a5,a0,42 <main+0x42>
  14:	00858493          	addi	s1,a1,8
  18:	ffe5091b          	addiw	s2,a0,-2
  1c:	02091793          	slli	a5,s2,0x20
  20:	01d7d913          	srli	s2,a5,0x1d
  24:	05c1                	addi	a1,a1,16
  26:	992e                	add	s2,s2,a1
		printf("%s\n", argv[i]);
  28:	00000997          	auipc	s3,0x0
  2c:	75098993          	addi	s3,s3,1872 # 778 <malloc+0xe8>
  30:	608c                	ld	a1,0(s1)
  32:	854e                	mv	a0,s3
  34:	00000097          	auipc	ra,0x0
  38:	59e080e7          	jalr	1438(ra) # 5d2 <printf>
	for(i = 1; i<argc; i++){
  3c:	04a1                	addi	s1,s1,8
  3e:	ff2499e3          	bne	s1,s2,30 <main+0x30>
	}
	exit(0);
  42:	4501                	li	a0,0
  44:	00000097          	auipc	ra,0x0
  48:	216080e7          	jalr	534(ra) # 25a <exit>

000000000000004c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  4c:	1141                	addi	sp,sp,-16
  4e:	e422                	sd	s0,8(sp)
  50:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  52:	87aa                	mv	a5,a0
  54:	0585                	addi	a1,a1,1
  56:	0785                	addi	a5,a5,1
  58:	fff5c703          	lbu	a4,-1(a1)
  5c:	fee78fa3          	sb	a4,-1(a5)
  60:	fb75                	bnez	a4,54 <strcpy+0x8>
    ;
  return os;
}
  62:	6422                	ld	s0,8(sp)
  64:	0141                	addi	sp,sp,16
  66:	8082                	ret

0000000000000068 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e422                	sd	s0,8(sp)
  6c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  6e:	00054783          	lbu	a5,0(a0)
  72:	cb91                	beqz	a5,86 <strcmp+0x1e>
  74:	0005c703          	lbu	a4,0(a1)
  78:	00f71763          	bne	a4,a5,86 <strcmp+0x1e>
    p++, q++;
  7c:	0505                	addi	a0,a0,1
  7e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  80:	00054783          	lbu	a5,0(a0)
  84:	fbe5                	bnez	a5,74 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  86:	0005c503          	lbu	a0,0(a1)
}
  8a:	40a7853b          	subw	a0,a5,a0
  8e:	6422                	ld	s0,8(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <strlen>:

uint
strlen(const char *s)
{
  94:	1141                	addi	sp,sp,-16
  96:	e422                	sd	s0,8(sp)
  98:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  9a:	00054783          	lbu	a5,0(a0)
  9e:	cf91                	beqz	a5,ba <strlen+0x26>
  a0:	0505                	addi	a0,a0,1
  a2:	87aa                	mv	a5,a0
  a4:	4685                	li	a3,1
  a6:	9e89                	subw	a3,a3,a0
  a8:	00f6853b          	addw	a0,a3,a5
  ac:	0785                	addi	a5,a5,1
  ae:	fff7c703          	lbu	a4,-1(a5)
  b2:	fb7d                	bnez	a4,a8 <strlen+0x14>
    ;
  return n;
}
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret
  for(n = 0; s[n]; n++)
  ba:	4501                	li	a0,0
  bc:	bfe5                	j	b4 <strlen+0x20>

00000000000000be <memset>:

void*
memset(void *dst, int c, uint n)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c4:	ca19                	beqz	a2,da <memset+0x1c>
  c6:	87aa                	mv	a5,a0
  c8:	1602                	slli	a2,a2,0x20
  ca:	9201                	srli	a2,a2,0x20
  cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d4:	0785                	addi	a5,a5,1
  d6:	fee79de3          	bne	a5,a4,d0 <memset+0x12>
  }
  return dst;
}
  da:	6422                	ld	s0,8(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret

00000000000000e0 <strchr>:

char*
strchr(const char *s, char c)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e422                	sd	s0,8(sp)
  e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	cb99                	beqz	a5,100 <strchr+0x20>
    if(*s == c)
  ec:	00f58763          	beq	a1,a5,fa <strchr+0x1a>
  for(; *s; s++)
  f0:	0505                	addi	a0,a0,1
  f2:	00054783          	lbu	a5,0(a0)
  f6:	fbfd                	bnez	a5,ec <strchr+0xc>
      return (char*)s;
  return 0;
  f8:	4501                	li	a0,0
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret
  return 0;
 100:	4501                	li	a0,0
 102:	bfe5                	j	fa <strchr+0x1a>

0000000000000104 <gets>:

char*
gets(char *buf, int max)
{
 104:	711d                	addi	sp,sp,-96
 106:	ec86                	sd	ra,88(sp)
 108:	e8a2                	sd	s0,80(sp)
 10a:	e4a6                	sd	s1,72(sp)
 10c:	e0ca                	sd	s2,64(sp)
 10e:	fc4e                	sd	s3,56(sp)
 110:	f852                	sd	s4,48(sp)
 112:	f456                	sd	s5,40(sp)
 114:	f05a                	sd	s6,32(sp)
 116:	ec5e                	sd	s7,24(sp)
 118:	1080                	addi	s0,sp,96
 11a:	8baa                	mv	s7,a0
 11c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11e:	892a                	mv	s2,a0
 120:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 122:	4aa9                	li	s5,10
 124:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 126:	89a6                	mv	s3,s1
 128:	2485                	addiw	s1,s1,1
 12a:	0344d863          	bge	s1,s4,15a <gets+0x56>
    cc = read(0, &c, 1);
 12e:	4605                	li	a2,1
 130:	faf40593          	addi	a1,s0,-81
 134:	4501                	li	a0,0
 136:	00000097          	auipc	ra,0x0
 13a:	13c080e7          	jalr	316(ra) # 272 <read>
    if(cc < 1)
 13e:	00a05e63          	blez	a0,15a <gets+0x56>
    buf[i++] = c;
 142:	faf44783          	lbu	a5,-81(s0)
 146:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 14a:	01578763          	beq	a5,s5,158 <gets+0x54>
 14e:	0905                	addi	s2,s2,1
 150:	fd679be3          	bne	a5,s6,126 <gets+0x22>
  for(i=0; i+1 < max; ){
 154:	89a6                	mv	s3,s1
 156:	a011                	j	15a <gets+0x56>
 158:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 15a:	99de                	add	s3,s3,s7
 15c:	00098023          	sb	zero,0(s3)
  return buf;
}
 160:	855e                	mv	a0,s7
 162:	60e6                	ld	ra,88(sp)
 164:	6446                	ld	s0,80(sp)
 166:	64a6                	ld	s1,72(sp)
 168:	6906                	ld	s2,64(sp)
 16a:	79e2                	ld	s3,56(sp)
 16c:	7a42                	ld	s4,48(sp)
 16e:	7aa2                	ld	s5,40(sp)
 170:	7b02                	ld	s6,32(sp)
 172:	6be2                	ld	s7,24(sp)
 174:	6125                	addi	sp,sp,96
 176:	8082                	ret

0000000000000178 <stat>:

int
stat(const char *n, struct stat *st)
{
 178:	1101                	addi	sp,sp,-32
 17a:	ec06                	sd	ra,24(sp)
 17c:	e822                	sd	s0,16(sp)
 17e:	e426                	sd	s1,8(sp)
 180:	e04a                	sd	s2,0(sp)
 182:	1000                	addi	s0,sp,32
 184:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 186:	4581                	li	a1,0
 188:	00000097          	auipc	ra,0x0
 18c:	112080e7          	jalr	274(ra) # 29a <open>
  if(fd < 0)
 190:	02054563          	bltz	a0,1ba <stat+0x42>
 194:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 196:	85ca                	mv	a1,s2
 198:	00000097          	auipc	ra,0x0
 19c:	11a080e7          	jalr	282(ra) # 2b2 <fstat>
 1a0:	892a                	mv	s2,a0
  close(fd);
 1a2:	8526                	mv	a0,s1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	0de080e7          	jalr	222(ra) # 282 <close>
  return r;
}
 1ac:	854a                	mv	a0,s2
 1ae:	60e2                	ld	ra,24(sp)
 1b0:	6442                	ld	s0,16(sp)
 1b2:	64a2                	ld	s1,8(sp)
 1b4:	6902                	ld	s2,0(sp)
 1b6:	6105                	addi	sp,sp,32
 1b8:	8082                	ret
    return -1;
 1ba:	597d                	li	s2,-1
 1bc:	bfc5                	j	1ac <stat+0x34>

00000000000001be <atoi>:

int
atoi(const char *s)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c4:	00054603          	lbu	a2,0(a0)
 1c8:	fd06079b          	addiw	a5,a2,-48
 1cc:	0ff7f793          	andi	a5,a5,255
 1d0:	4725                	li	a4,9
 1d2:	02f76963          	bltu	a4,a5,204 <atoi+0x46>
 1d6:	86aa                	mv	a3,a0
  n = 0;
 1d8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1da:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1dc:	0685                	addi	a3,a3,1
 1de:	0025179b          	slliw	a5,a0,0x2
 1e2:	9fa9                	addw	a5,a5,a0
 1e4:	0017979b          	slliw	a5,a5,0x1
 1e8:	9fb1                	addw	a5,a5,a2
 1ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ee:	0006c603          	lbu	a2,0(a3)
 1f2:	fd06071b          	addiw	a4,a2,-48
 1f6:	0ff77713          	andi	a4,a4,255
 1fa:	fee5f1e3          	bgeu	a1,a4,1dc <atoi+0x1e>
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  n = 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <atoi+0x40>

0000000000000208 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 20e:	00c05f63          	blez	a2,22c <memmove+0x24>
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 21a:	87aa                	mv	a5,a0
    *dst++ = *src++;
 21c:	0585                	addi	a1,a1,1
 21e:	0785                	addi	a5,a5,1
 220:	fff5c703          	lbu	a4,-1(a1)
 224:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 228:	fed79ae3          	bne	a5,a3,21c <memmove+0x14>
  return vdst;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <trace>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global trace
trace:
 li a7, SYS_trace
 232:	48e5                	li	a7,25
 ecall
 234:	00000073          	ecall
 ret
 238:	8082                	ret

000000000000023a <get_process_info>:
.global get_process_info
get_process_info:
 li a7, SYS_get_process_info
 23a:	48e1                	li	a7,24
 ecall
 23c:	00000073          	ecall
 ret
 240:	8082                	ret

0000000000000242 <echo_kernel>:
.global echo_kernel
echo_kernel:
 li a7, SYS_echo_kernel
 242:	48dd                	li	a7,23
 ecall
 244:	00000073          	ecall
 ret
 248:	8082                	ret

000000000000024a <echo_simple>:
.global echo_simple
echo_simple:
 li a7, SYS_echo_simple
 24a:	48d9                	li	a7,22
 ecall
 24c:	00000073          	ecall
 ret
 250:	8082                	ret

0000000000000252 <fork>:
.global fork
fork:
 li a7, SYS_fork
 252:	4885                	li	a7,1
 ecall
 254:	00000073          	ecall
 ret
 258:	8082                	ret

000000000000025a <exit>:
.global exit
exit:
 li a7, SYS_exit
 25a:	4889                	li	a7,2
 ecall
 25c:	00000073          	ecall
 ret
 260:	8082                	ret

0000000000000262 <wait>:
.global wait
wait:
 li a7, SYS_wait
 262:	488d                	li	a7,3
 ecall
 264:	00000073          	ecall
 ret
 268:	8082                	ret

000000000000026a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 26a:	4891                	li	a7,4
 ecall
 26c:	00000073          	ecall
 ret
 270:	8082                	ret

0000000000000272 <read>:
.global read
read:
 li a7, SYS_read
 272:	4895                	li	a7,5
 ecall
 274:	00000073          	ecall
 ret
 278:	8082                	ret

000000000000027a <write>:
.global write
write:
 li a7, SYS_write
 27a:	48c1                	li	a7,16
 ecall
 27c:	00000073          	ecall
 ret
 280:	8082                	ret

0000000000000282 <close>:
.global close
close:
 li a7, SYS_close
 282:	48d5                	li	a7,21
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <kill>:
.global kill
kill:
 li a7, SYS_kill
 28a:	4899                	li	a7,6
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <exec>:
.global exec
exec:
 li a7, SYS_exec
 292:	489d                	li	a7,7
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <open>:
.global open
open:
 li a7, SYS_open
 29a:	48bd                	li	a7,15
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2a2:	48c5                	li	a7,17
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2aa:	48c9                	li	a7,18
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2b2:	48a1                	li	a7,8
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <link>:
.global link
link:
 li a7, SYS_link
 2ba:	48cd                	li	a7,19
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2c2:	48d1                	li	a7,20
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2ca:	48a5                	li	a7,9
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2d2:	48a9                	li	a7,10
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2da:	48ad                	li	a7,11
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2e2:	48b1                	li	a7,12
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2ea:	48b5                	li	a7,13
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 2f2:	48b9                	li	a7,14
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 2fa:	1101                	addi	sp,sp,-32
 2fc:	ec06                	sd	ra,24(sp)
 2fe:	e822                	sd	s0,16(sp)
 300:	1000                	addi	s0,sp,32
 302:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 306:	4605                	li	a2,1
 308:	fef40593          	addi	a1,s0,-17
 30c:	00000097          	auipc	ra,0x0
 310:	f6e080e7          	jalr	-146(ra) # 27a <write>
}
 314:	60e2                	ld	ra,24(sp)
 316:	6442                	ld	s0,16(sp)
 318:	6105                	addi	sp,sp,32
 31a:	8082                	ret

000000000000031c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 31c:	7139                	addi	sp,sp,-64
 31e:	fc06                	sd	ra,56(sp)
 320:	f822                	sd	s0,48(sp)
 322:	f426                	sd	s1,40(sp)
 324:	f04a                	sd	s2,32(sp)
 326:	ec4e                	sd	s3,24(sp)
 328:	0080                	addi	s0,sp,64
 32a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 32c:	c299                	beqz	a3,332 <printint+0x16>
 32e:	0805c863          	bltz	a1,3be <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 332:	2581                	sext.w	a1,a1
  neg = 0;
 334:	4881                	li	a7,0
 336:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 33a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 33c:	2601                	sext.w	a2,a2
 33e:	00000517          	auipc	a0,0x0
 342:	44a50513          	addi	a0,a0,1098 # 788 <digits>
 346:	883a                	mv	a6,a4
 348:	2705                	addiw	a4,a4,1
 34a:	02c5f7bb          	remuw	a5,a1,a2
 34e:	1782                	slli	a5,a5,0x20
 350:	9381                	srli	a5,a5,0x20
 352:	97aa                	add	a5,a5,a0
 354:	0007c783          	lbu	a5,0(a5)
 358:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 35c:	0005879b          	sext.w	a5,a1
 360:	02c5d5bb          	divuw	a1,a1,a2
 364:	0685                	addi	a3,a3,1
 366:	fec7f0e3          	bgeu	a5,a2,346 <printint+0x2a>
  if(neg)
 36a:	00088b63          	beqz	a7,380 <printint+0x64>
    buf[i++] = '-';
 36e:	fd040793          	addi	a5,s0,-48
 372:	973e                	add	a4,a4,a5
 374:	02d00793          	li	a5,45
 378:	fef70823          	sb	a5,-16(a4)
 37c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 380:	02e05863          	blez	a4,3b0 <printint+0x94>
 384:	fc040793          	addi	a5,s0,-64
 388:	00e78933          	add	s2,a5,a4
 38c:	fff78993          	addi	s3,a5,-1
 390:	99ba                	add	s3,s3,a4
 392:	377d                	addiw	a4,a4,-1
 394:	1702                	slli	a4,a4,0x20
 396:	9301                	srli	a4,a4,0x20
 398:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 39c:	fff94583          	lbu	a1,-1(s2)
 3a0:	8526                	mv	a0,s1
 3a2:	00000097          	auipc	ra,0x0
 3a6:	f58080e7          	jalr	-168(ra) # 2fa <putc>
  while(--i >= 0)
 3aa:	197d                	addi	s2,s2,-1
 3ac:	ff3918e3          	bne	s2,s3,39c <printint+0x80>
}
 3b0:	70e2                	ld	ra,56(sp)
 3b2:	7442                	ld	s0,48(sp)
 3b4:	74a2                	ld	s1,40(sp)
 3b6:	7902                	ld	s2,32(sp)
 3b8:	69e2                	ld	s3,24(sp)
 3ba:	6121                	addi	sp,sp,64
 3bc:	8082                	ret
    x = -xx;
 3be:	40b005bb          	negw	a1,a1
    neg = 1;
 3c2:	4885                	li	a7,1
    x = -xx;
 3c4:	bf8d                	j	336 <printint+0x1a>

00000000000003c6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3c6:	7119                	addi	sp,sp,-128
 3c8:	fc86                	sd	ra,120(sp)
 3ca:	f8a2                	sd	s0,112(sp)
 3cc:	f4a6                	sd	s1,104(sp)
 3ce:	f0ca                	sd	s2,96(sp)
 3d0:	ecce                	sd	s3,88(sp)
 3d2:	e8d2                	sd	s4,80(sp)
 3d4:	e4d6                	sd	s5,72(sp)
 3d6:	e0da                	sd	s6,64(sp)
 3d8:	fc5e                	sd	s7,56(sp)
 3da:	f862                	sd	s8,48(sp)
 3dc:	f466                	sd	s9,40(sp)
 3de:	f06a                	sd	s10,32(sp)
 3e0:	ec6e                	sd	s11,24(sp)
 3e2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3e4:	0005c903          	lbu	s2,0(a1)
 3e8:	18090f63          	beqz	s2,586 <vprintf+0x1c0>
 3ec:	8aaa                	mv	s5,a0
 3ee:	8b32                	mv	s6,a2
 3f0:	00158493          	addi	s1,a1,1
  state = 0;
 3f4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3f6:	02500a13          	li	s4,37
      if(c == 'd'){
 3fa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 3fe:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 402:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 406:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 40a:	00000b97          	auipc	s7,0x0
 40e:	37eb8b93          	addi	s7,s7,894 # 788 <digits>
 412:	a839                	j	430 <vprintf+0x6a>
        putc(fd, c);
 414:	85ca                	mv	a1,s2
 416:	8556                	mv	a0,s5
 418:	00000097          	auipc	ra,0x0
 41c:	ee2080e7          	jalr	-286(ra) # 2fa <putc>
 420:	a019                	j	426 <vprintf+0x60>
    } else if(state == '%'){
 422:	01498f63          	beq	s3,s4,440 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 426:	0485                	addi	s1,s1,1
 428:	fff4c903          	lbu	s2,-1(s1)
 42c:	14090d63          	beqz	s2,586 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 430:	0009079b          	sext.w	a5,s2
    if(state == 0){
 434:	fe0997e3          	bnez	s3,422 <vprintf+0x5c>
      if(c == '%'){
 438:	fd479ee3          	bne	a5,s4,414 <vprintf+0x4e>
        state = '%';
 43c:	89be                	mv	s3,a5
 43e:	b7e5                	j	426 <vprintf+0x60>
      if(c == 'd'){
 440:	05878063          	beq	a5,s8,480 <vprintf+0xba>
      } else if(c == 'l') {
 444:	05978c63          	beq	a5,s9,49c <vprintf+0xd6>
      } else if(c == 'x') {
 448:	07a78863          	beq	a5,s10,4b8 <vprintf+0xf2>
      } else if(c == 'p') {
 44c:	09b78463          	beq	a5,s11,4d4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 450:	07300713          	li	a4,115
 454:	0ce78663          	beq	a5,a4,520 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 458:	06300713          	li	a4,99
 45c:	0ee78e63          	beq	a5,a4,558 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 460:	11478863          	beq	a5,s4,570 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 464:	85d2                	mv	a1,s4
 466:	8556                	mv	a0,s5
 468:	00000097          	auipc	ra,0x0
 46c:	e92080e7          	jalr	-366(ra) # 2fa <putc>
        putc(fd, c);
 470:	85ca                	mv	a1,s2
 472:	8556                	mv	a0,s5
 474:	00000097          	auipc	ra,0x0
 478:	e86080e7          	jalr	-378(ra) # 2fa <putc>
      }
      state = 0;
 47c:	4981                	li	s3,0
 47e:	b765                	j	426 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 480:	008b0913          	addi	s2,s6,8
 484:	4685                	li	a3,1
 486:	4629                	li	a2,10
 488:	000b2583          	lw	a1,0(s6)
 48c:	8556                	mv	a0,s5
 48e:	00000097          	auipc	ra,0x0
 492:	e8e080e7          	jalr	-370(ra) # 31c <printint>
 496:	8b4a                	mv	s6,s2
      state = 0;
 498:	4981                	li	s3,0
 49a:	b771                	j	426 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 49c:	008b0913          	addi	s2,s6,8
 4a0:	4681                	li	a3,0
 4a2:	4629                	li	a2,10
 4a4:	000b2583          	lw	a1,0(s6)
 4a8:	8556                	mv	a0,s5
 4aa:	00000097          	auipc	ra,0x0
 4ae:	e72080e7          	jalr	-398(ra) # 31c <printint>
 4b2:	8b4a                	mv	s6,s2
      state = 0;
 4b4:	4981                	li	s3,0
 4b6:	bf85                	j	426 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4b8:	008b0913          	addi	s2,s6,8
 4bc:	4681                	li	a3,0
 4be:	4641                	li	a2,16
 4c0:	000b2583          	lw	a1,0(s6)
 4c4:	8556                	mv	a0,s5
 4c6:	00000097          	auipc	ra,0x0
 4ca:	e56080e7          	jalr	-426(ra) # 31c <printint>
 4ce:	8b4a                	mv	s6,s2
      state = 0;
 4d0:	4981                	li	s3,0
 4d2:	bf91                	j	426 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4d4:	008b0793          	addi	a5,s6,8
 4d8:	f8f43423          	sd	a5,-120(s0)
 4dc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4e0:	03000593          	li	a1,48
 4e4:	8556                	mv	a0,s5
 4e6:	00000097          	auipc	ra,0x0
 4ea:	e14080e7          	jalr	-492(ra) # 2fa <putc>
  putc(fd, 'x');
 4ee:	85ea                	mv	a1,s10
 4f0:	8556                	mv	a0,s5
 4f2:	00000097          	auipc	ra,0x0
 4f6:	e08080e7          	jalr	-504(ra) # 2fa <putc>
 4fa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4fc:	03c9d793          	srli	a5,s3,0x3c
 500:	97de                	add	a5,a5,s7
 502:	0007c583          	lbu	a1,0(a5)
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	df2080e7          	jalr	-526(ra) # 2fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 510:	0992                	slli	s3,s3,0x4
 512:	397d                	addiw	s2,s2,-1
 514:	fe0914e3          	bnez	s2,4fc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 518:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 51c:	4981                	li	s3,0
 51e:	b721                	j	426 <vprintf+0x60>
        s = va_arg(ap, char*);
 520:	008b0993          	addi	s3,s6,8
 524:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 528:	02090163          	beqz	s2,54a <vprintf+0x184>
        while(*s != 0){
 52c:	00094583          	lbu	a1,0(s2)
 530:	c9a1                	beqz	a1,580 <vprintf+0x1ba>
          putc(fd, *s);
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	dc6080e7          	jalr	-570(ra) # 2fa <putc>
          s++;
 53c:	0905                	addi	s2,s2,1
        while(*s != 0){
 53e:	00094583          	lbu	a1,0(s2)
 542:	f9e5                	bnez	a1,532 <vprintf+0x16c>
        s = va_arg(ap, char*);
 544:	8b4e                	mv	s6,s3
      state = 0;
 546:	4981                	li	s3,0
 548:	bdf9                	j	426 <vprintf+0x60>
          s = "(null)";
 54a:	00000917          	auipc	s2,0x0
 54e:	23690913          	addi	s2,s2,566 # 780 <malloc+0xf0>
        while(*s != 0){
 552:	02800593          	li	a1,40
 556:	bff1                	j	532 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 558:	008b0913          	addi	s2,s6,8
 55c:	000b4583          	lbu	a1,0(s6)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	d98080e7          	jalr	-616(ra) # 2fa <putc>
 56a:	8b4a                	mv	s6,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	bd65                	j	426 <vprintf+0x60>
        putc(fd, c);
 570:	85d2                	mv	a1,s4
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	d86080e7          	jalr	-634(ra) # 2fa <putc>
      state = 0;
 57c:	4981                	li	s3,0
 57e:	b565                	j	426 <vprintf+0x60>
        s = va_arg(ap, char*);
 580:	8b4e                	mv	s6,s3
      state = 0;
 582:	4981                	li	s3,0
 584:	b54d                	j	426 <vprintf+0x60>
    }
  }
}
 586:	70e6                	ld	ra,120(sp)
 588:	7446                	ld	s0,112(sp)
 58a:	74a6                	ld	s1,104(sp)
 58c:	7906                	ld	s2,96(sp)
 58e:	69e6                	ld	s3,88(sp)
 590:	6a46                	ld	s4,80(sp)
 592:	6aa6                	ld	s5,72(sp)
 594:	6b06                	ld	s6,64(sp)
 596:	7be2                	ld	s7,56(sp)
 598:	7c42                	ld	s8,48(sp)
 59a:	7ca2                	ld	s9,40(sp)
 59c:	7d02                	ld	s10,32(sp)
 59e:	6de2                	ld	s11,24(sp)
 5a0:	6109                	addi	sp,sp,128
 5a2:	8082                	ret

00000000000005a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5a4:	715d                	addi	sp,sp,-80
 5a6:	ec06                	sd	ra,24(sp)
 5a8:	e822                	sd	s0,16(sp)
 5aa:	1000                	addi	s0,sp,32
 5ac:	e010                	sd	a2,0(s0)
 5ae:	e414                	sd	a3,8(s0)
 5b0:	e818                	sd	a4,16(s0)
 5b2:	ec1c                	sd	a5,24(s0)
 5b4:	03043023          	sd	a6,32(s0)
 5b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5c0:	8622                	mv	a2,s0
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e04080e7          	jalr	-508(ra) # 3c6 <vprintf>
}
 5ca:	60e2                	ld	ra,24(sp)
 5cc:	6442                	ld	s0,16(sp)
 5ce:	6161                	addi	sp,sp,80
 5d0:	8082                	ret

00000000000005d2 <printf>:

void
printf(const char *fmt, ...)
{
 5d2:	711d                	addi	sp,sp,-96
 5d4:	ec06                	sd	ra,24(sp)
 5d6:	e822                	sd	s0,16(sp)
 5d8:	1000                	addi	s0,sp,32
 5da:	e40c                	sd	a1,8(s0)
 5dc:	e810                	sd	a2,16(s0)
 5de:	ec14                	sd	a3,24(s0)
 5e0:	f018                	sd	a4,32(s0)
 5e2:	f41c                	sd	a5,40(s0)
 5e4:	03043823          	sd	a6,48(s0)
 5e8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 5ec:	00840613          	addi	a2,s0,8
 5f0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 5f4:	85aa                	mv	a1,a0
 5f6:	4505                	li	a0,1
 5f8:	00000097          	auipc	ra,0x0
 5fc:	dce080e7          	jalr	-562(ra) # 3c6 <vprintf>
}
 600:	60e2                	ld	ra,24(sp)
 602:	6442                	ld	s0,16(sp)
 604:	6125                	addi	sp,sp,96
 606:	8082                	ret

0000000000000608 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 608:	1141                	addi	sp,sp,-16
 60a:	e422                	sd	s0,8(sp)
 60c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 60e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 612:	00000797          	auipc	a5,0x0
 616:	18e7b783          	ld	a5,398(a5) # 7a0 <freep>
 61a:	a805                	j	64a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 61c:	4618                	lw	a4,8(a2)
 61e:	9db9                	addw	a1,a1,a4
 620:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 624:	6398                	ld	a4,0(a5)
 626:	6318                	ld	a4,0(a4)
 628:	fee53823          	sd	a4,-16(a0)
 62c:	a091                	j	670 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 62e:	ff852703          	lw	a4,-8(a0)
 632:	9e39                	addw	a2,a2,a4
 634:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 636:	ff053703          	ld	a4,-16(a0)
 63a:	e398                	sd	a4,0(a5)
 63c:	a099                	j	682 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 63e:	6398                	ld	a4,0(a5)
 640:	00e7e463          	bltu	a5,a4,648 <free+0x40>
 644:	00e6ea63          	bltu	a3,a4,658 <free+0x50>
{
 648:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64a:	fed7fae3          	bgeu	a5,a3,63e <free+0x36>
 64e:	6398                	ld	a4,0(a5)
 650:	00e6e463          	bltu	a3,a4,658 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 654:	fee7eae3          	bltu	a5,a4,648 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 658:	ff852583          	lw	a1,-8(a0)
 65c:	6390                	ld	a2,0(a5)
 65e:	02059813          	slli	a6,a1,0x20
 662:	01c85713          	srli	a4,a6,0x1c
 666:	9736                	add	a4,a4,a3
 668:	fae60ae3          	beq	a2,a4,61c <free+0x14>
    bp->s.ptr = p->s.ptr;
 66c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 670:	4790                	lw	a2,8(a5)
 672:	02061593          	slli	a1,a2,0x20
 676:	01c5d713          	srli	a4,a1,0x1c
 67a:	973e                	add	a4,a4,a5
 67c:	fae689e3          	beq	a3,a4,62e <free+0x26>
  } else
    p->s.ptr = bp;
 680:	e394                	sd	a3,0(a5)
  freep = p;
 682:	00000717          	auipc	a4,0x0
 686:	10f73f23          	sd	a5,286(a4) # 7a0 <freep>
}
 68a:	6422                	ld	s0,8(sp)
 68c:	0141                	addi	sp,sp,16
 68e:	8082                	ret

0000000000000690 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 690:	7139                	addi	sp,sp,-64
 692:	fc06                	sd	ra,56(sp)
 694:	f822                	sd	s0,48(sp)
 696:	f426                	sd	s1,40(sp)
 698:	f04a                	sd	s2,32(sp)
 69a:	ec4e                	sd	s3,24(sp)
 69c:	e852                	sd	s4,16(sp)
 69e:	e456                	sd	s5,8(sp)
 6a0:	e05a                	sd	s6,0(sp)
 6a2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6a4:	02051493          	slli	s1,a0,0x20
 6a8:	9081                	srli	s1,s1,0x20
 6aa:	04bd                	addi	s1,s1,15
 6ac:	8091                	srli	s1,s1,0x4
 6ae:	0014899b          	addiw	s3,s1,1
 6b2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6b4:	00000517          	auipc	a0,0x0
 6b8:	0ec53503          	ld	a0,236(a0) # 7a0 <freep>
 6bc:	c515                	beqz	a0,6e8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6c0:	4798                	lw	a4,8(a5)
 6c2:	02977f63          	bgeu	a4,s1,700 <malloc+0x70>
 6c6:	8a4e                	mv	s4,s3
 6c8:	0009871b          	sext.w	a4,s3
 6cc:	6685                	lui	a3,0x1
 6ce:	00d77363          	bgeu	a4,a3,6d4 <malloc+0x44>
 6d2:	6a05                	lui	s4,0x1
 6d4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6d8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6dc:	00000917          	auipc	s2,0x0
 6e0:	0c490913          	addi	s2,s2,196 # 7a0 <freep>
  if(p == (char*)-1)
 6e4:	5afd                	li	s5,-1
 6e6:	a895                	j	75a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 6e8:	00000797          	auipc	a5,0x0
 6ec:	0c078793          	addi	a5,a5,192 # 7a8 <base>
 6f0:	00000717          	auipc	a4,0x0
 6f4:	0af73823          	sd	a5,176(a4) # 7a0 <freep>
 6f8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 6fa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 6fe:	b7e1                	j	6c6 <malloc+0x36>
      if(p->s.size == nunits)
 700:	02e48c63          	beq	s1,a4,738 <malloc+0xa8>
        p->s.size -= nunits;
 704:	4137073b          	subw	a4,a4,s3
 708:	c798                	sw	a4,8(a5)
        p += p->s.size;
 70a:	02071693          	slli	a3,a4,0x20
 70e:	01c6d713          	srli	a4,a3,0x1c
 712:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 714:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 718:	00000717          	auipc	a4,0x0
 71c:	08a73423          	sd	a0,136(a4) # 7a0 <freep>
      return (void*)(p + 1);
 720:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 724:	70e2                	ld	ra,56(sp)
 726:	7442                	ld	s0,48(sp)
 728:	74a2                	ld	s1,40(sp)
 72a:	7902                	ld	s2,32(sp)
 72c:	69e2                	ld	s3,24(sp)
 72e:	6a42                	ld	s4,16(sp)
 730:	6aa2                	ld	s5,8(sp)
 732:	6b02                	ld	s6,0(sp)
 734:	6121                	addi	sp,sp,64
 736:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 738:	6398                	ld	a4,0(a5)
 73a:	e118                	sd	a4,0(a0)
 73c:	bff1                	j	718 <malloc+0x88>
  hp->s.size = nu;
 73e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 742:	0541                	addi	a0,a0,16
 744:	00000097          	auipc	ra,0x0
 748:	ec4080e7          	jalr	-316(ra) # 608 <free>
  return freep;
 74c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 750:	d971                	beqz	a0,724 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 752:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 754:	4798                	lw	a4,8(a5)
 756:	fa9775e3          	bgeu	a4,s1,700 <malloc+0x70>
    if(p == freep)
 75a:	00093703          	ld	a4,0(s2)
 75e:	853e                	mv	a0,a5
 760:	fef719e3          	bne	a4,a5,752 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 764:	8552                	mv	a0,s4
 766:	00000097          	auipc	ra,0x0
 76a:	b7c080e7          	jalr	-1156(ra) # 2e2 <sbrk>
  if(p == (char*)-1)
 76e:	fd5518e3          	bne	a0,s5,73e <malloc+0xae>
        return 0;
 772:	4501                	li	a0,0
 774:	bf45                	j	724 <malloc+0x94>
