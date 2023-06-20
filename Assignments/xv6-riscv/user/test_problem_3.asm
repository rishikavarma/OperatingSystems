
user/_test_problem_3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/file.h"
#include "user/user.h"
#include "kernel/processinfo.h"

int main(){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
	struct processinfo p;
	get_process_info(&p);
   8:	fd040513          	addi	a0,s0,-48
   c:	00000097          	auipc	ra,0x0
  10:	23c080e7          	jalr	572(ra) # 248 <get_process_info>
	printf("Process ID -> %d\n", p.pid);
  14:	fd042583          	lw	a1,-48(s0)
  18:	00000517          	auipc	a0,0x0
  1c:	77050513          	addi	a0,a0,1904 # 788 <malloc+0xea>
  20:	00000097          	auipc	ra,0x0
  24:	5c0080e7          	jalr	1472(ra) # 5e0 <printf>
	printf("Process Name -> %s\n",p.name);
  28:	fd440593          	addi	a1,s0,-44
  2c:	00000517          	auipc	a0,0x0
  30:	77450513          	addi	a0,a0,1908 # 7a0 <malloc+0x102>
  34:	00000097          	auipc	ra,0x0
  38:	5ac080e7          	jalr	1452(ra) # 5e0 <printf>
	printf("Memory Size -> %l Bytes\n",p.sz);
  3c:	fe843583          	ld	a1,-24(s0)
  40:	00000517          	auipc	a0,0x0
  44:	77850513          	addi	a0,a0,1912 # 7b8 <malloc+0x11a>
  48:	00000097          	auipc	ra,0x0
  4c:	598080e7          	jalr	1432(ra) # 5e0 <printf>
	exit(0);
  50:	4501                	li	a0,0
  52:	00000097          	auipc	ra,0x0
  56:	216080e7          	jalr	534(ra) # 268 <exit>

000000000000005a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e422                	sd	s0,8(sp)
  5e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  60:	87aa                	mv	a5,a0
  62:	0585                	addi	a1,a1,1
  64:	0785                	addi	a5,a5,1
  66:	fff5c703          	lbu	a4,-1(a1)
  6a:	fee78fa3          	sb	a4,-1(a5)
  6e:	fb75                	bnez	a4,62 <strcpy+0x8>
    ;
  return os;
}
  70:	6422                	ld	s0,8(sp)
  72:	0141                	addi	sp,sp,16
  74:	8082                	ret

0000000000000076 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7c:	00054783          	lbu	a5,0(a0)
  80:	cb91                	beqz	a5,94 <strcmp+0x1e>
  82:	0005c703          	lbu	a4,0(a1)
  86:	00f71763          	bne	a4,a5,94 <strcmp+0x1e>
    p++, q++;
  8a:	0505                	addi	a0,a0,1
  8c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8e:	00054783          	lbu	a5,0(a0)
  92:	fbe5                	bnez	a5,82 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  94:	0005c503          	lbu	a0,0(a1)
}
  98:	40a7853b          	subw	a0,a5,a0
  9c:	6422                	ld	s0,8(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret

00000000000000a2 <strlen>:

uint
strlen(const char *s)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a8:	00054783          	lbu	a5,0(a0)
  ac:	cf91                	beqz	a5,c8 <strlen+0x26>
  ae:	0505                	addi	a0,a0,1
  b0:	87aa                	mv	a5,a0
  b2:	4685                	li	a3,1
  b4:	9e89                	subw	a3,a3,a0
  b6:	00f6853b          	addw	a0,a3,a5
  ba:	0785                	addi	a5,a5,1
  bc:	fff7c703          	lbu	a4,-1(a5)
  c0:	fb7d                	bnez	a4,b6 <strlen+0x14>
    ;
  return n;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret
  for(n = 0; s[n]; n++)
  c8:	4501                	li	a0,0
  ca:	bfe5                	j	c2 <strlen+0x20>

00000000000000cc <memset>:

void*
memset(void *dst, int c, uint n)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d2:	ca19                	beqz	a2,e8 <memset+0x1c>
  d4:	87aa                	mv	a5,a0
  d6:	1602                	slli	a2,a2,0x20
  d8:	9201                	srli	a2,a2,0x20
  da:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  de:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e2:	0785                	addi	a5,a5,1
  e4:	fee79de3          	bne	a5,a4,de <memset+0x12>
  }
  return dst;
}
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strchr>:

char*
strchr(const char *s, char c)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb99                	beqz	a5,10e <strchr+0x20>
    if(*s == c)
  fa:	00f58763          	beq	a1,a5,108 <strchr+0x1a>
  for(; *s; s++)
  fe:	0505                	addi	a0,a0,1
 100:	00054783          	lbu	a5,0(a0)
 104:	fbfd                	bnez	a5,fa <strchr+0xc>
      return (char*)s;
  return 0;
 106:	4501                	li	a0,0
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  return 0;
 10e:	4501                	li	a0,0
 110:	bfe5                	j	108 <strchr+0x1a>

0000000000000112 <gets>:

char*
gets(char *buf, int max)
{
 112:	711d                	addi	sp,sp,-96
 114:	ec86                	sd	ra,88(sp)
 116:	e8a2                	sd	s0,80(sp)
 118:	e4a6                	sd	s1,72(sp)
 11a:	e0ca                	sd	s2,64(sp)
 11c:	fc4e                	sd	s3,56(sp)
 11e:	f852                	sd	s4,48(sp)
 120:	f456                	sd	s5,40(sp)
 122:	f05a                	sd	s6,32(sp)
 124:	ec5e                	sd	s7,24(sp)
 126:	1080                	addi	s0,sp,96
 128:	8baa                	mv	s7,a0
 12a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12c:	892a                	mv	s2,a0
 12e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 130:	4aa9                	li	s5,10
 132:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 134:	89a6                	mv	s3,s1
 136:	2485                	addiw	s1,s1,1
 138:	0344d863          	bge	s1,s4,168 <gets+0x56>
    cc = read(0, &c, 1);
 13c:	4605                	li	a2,1
 13e:	faf40593          	addi	a1,s0,-81
 142:	4501                	li	a0,0
 144:	00000097          	auipc	ra,0x0
 148:	13c080e7          	jalr	316(ra) # 280 <read>
    if(cc < 1)
 14c:	00a05e63          	blez	a0,168 <gets+0x56>
    buf[i++] = c;
 150:	faf44783          	lbu	a5,-81(s0)
 154:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 158:	01578763          	beq	a5,s5,166 <gets+0x54>
 15c:	0905                	addi	s2,s2,1
 15e:	fd679be3          	bne	a5,s6,134 <gets+0x22>
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	a011                	j	168 <gets+0x56>
 166:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 168:	99de                	add	s3,s3,s7
 16a:	00098023          	sb	zero,0(s3)
  return buf;
}
 16e:	855e                	mv	a0,s7
 170:	60e6                	ld	ra,88(sp)
 172:	6446                	ld	s0,80(sp)
 174:	64a6                	ld	s1,72(sp)
 176:	6906                	ld	s2,64(sp)
 178:	79e2                	ld	s3,56(sp)
 17a:	7a42                	ld	s4,48(sp)
 17c:	7aa2                	ld	s5,40(sp)
 17e:	7b02                	ld	s6,32(sp)
 180:	6be2                	ld	s7,24(sp)
 182:	6125                	addi	sp,sp,96
 184:	8082                	ret

0000000000000186 <stat>:

int
stat(const char *n, struct stat *st)
{
 186:	1101                	addi	sp,sp,-32
 188:	ec06                	sd	ra,24(sp)
 18a:	e822                	sd	s0,16(sp)
 18c:	e426                	sd	s1,8(sp)
 18e:	e04a                	sd	s2,0(sp)
 190:	1000                	addi	s0,sp,32
 192:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 194:	4581                	li	a1,0
 196:	00000097          	auipc	ra,0x0
 19a:	112080e7          	jalr	274(ra) # 2a8 <open>
  if(fd < 0)
 19e:	02054563          	bltz	a0,1c8 <stat+0x42>
 1a2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a4:	85ca                	mv	a1,s2
 1a6:	00000097          	auipc	ra,0x0
 1aa:	11a080e7          	jalr	282(ra) # 2c0 <fstat>
 1ae:	892a                	mv	s2,a0
  close(fd);
 1b0:	8526                	mv	a0,s1
 1b2:	00000097          	auipc	ra,0x0
 1b6:	0de080e7          	jalr	222(ra) # 290 <close>
  return r;
}
 1ba:	854a                	mv	a0,s2
 1bc:	60e2                	ld	ra,24(sp)
 1be:	6442                	ld	s0,16(sp)
 1c0:	64a2                	ld	s1,8(sp)
 1c2:	6902                	ld	s2,0(sp)
 1c4:	6105                	addi	sp,sp,32
 1c6:	8082                	ret
    return -1;
 1c8:	597d                	li	s2,-1
 1ca:	bfc5                	j	1ba <stat+0x34>

00000000000001cc <atoi>:

int
atoi(const char *s)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d2:	00054603          	lbu	a2,0(a0)
 1d6:	fd06079b          	addiw	a5,a2,-48
 1da:	0ff7f793          	andi	a5,a5,255
 1de:	4725                	li	a4,9
 1e0:	02f76963          	bltu	a4,a5,212 <atoi+0x46>
 1e4:	86aa                	mv	a3,a0
  n = 0;
 1e6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1e8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ea:	0685                	addi	a3,a3,1
 1ec:	0025179b          	slliw	a5,a0,0x2
 1f0:	9fa9                	addw	a5,a5,a0
 1f2:	0017979b          	slliw	a5,a5,0x1
 1f6:	9fb1                	addw	a5,a5,a2
 1f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1fc:	0006c603          	lbu	a2,0(a3)
 200:	fd06071b          	addiw	a4,a2,-48
 204:	0ff77713          	andi	a4,a4,255
 208:	fee5f1e3          	bgeu	a1,a4,1ea <atoi+0x1e>
  return n;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  n = 0;
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <atoi+0x40>

0000000000000216 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 21c:	00c05f63          	blez	a2,23a <memmove+0x24>
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 228:	87aa                	mv	a5,a0
    *dst++ = *src++;
 22a:	0585                	addi	a1,a1,1
 22c:	0785                	addi	a5,a5,1
 22e:	fff5c703          	lbu	a4,-1(a1)
 232:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 236:	fed79ae3          	bne	a5,a3,22a <memmove+0x14>
  return vdst;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret

0000000000000240 <trace>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global trace
trace:
 li a7, SYS_trace
 240:	48e5                	li	a7,25
 ecall
 242:	00000073          	ecall
 ret
 246:	8082                	ret

0000000000000248 <get_process_info>:
.global get_process_info
get_process_info:
 li a7, SYS_get_process_info
 248:	48e1                	li	a7,24
 ecall
 24a:	00000073          	ecall
 ret
 24e:	8082                	ret

0000000000000250 <echo_kernel>:
.global echo_kernel
echo_kernel:
 li a7, SYS_echo_kernel
 250:	48dd                	li	a7,23
 ecall
 252:	00000073          	ecall
 ret
 256:	8082                	ret

0000000000000258 <echo_simple>:
.global echo_simple
echo_simple:
 li a7, SYS_echo_simple
 258:	48d9                	li	a7,22
 ecall
 25a:	00000073          	ecall
 ret
 25e:	8082                	ret

0000000000000260 <fork>:
.global fork
fork:
 li a7, SYS_fork
 260:	4885                	li	a7,1
 ecall
 262:	00000073          	ecall
 ret
 266:	8082                	ret

0000000000000268 <exit>:
.global exit
exit:
 li a7, SYS_exit
 268:	4889                	li	a7,2
 ecall
 26a:	00000073          	ecall
 ret
 26e:	8082                	ret

0000000000000270 <wait>:
.global wait
wait:
 li a7, SYS_wait
 270:	488d                	li	a7,3
 ecall
 272:	00000073          	ecall
 ret
 276:	8082                	ret

0000000000000278 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 278:	4891                	li	a7,4
 ecall
 27a:	00000073          	ecall
 ret
 27e:	8082                	ret

0000000000000280 <read>:
.global read
read:
 li a7, SYS_read
 280:	4895                	li	a7,5
 ecall
 282:	00000073          	ecall
 ret
 286:	8082                	ret

0000000000000288 <write>:
.global write
write:
 li a7, SYS_write
 288:	48c1                	li	a7,16
 ecall
 28a:	00000073          	ecall
 ret
 28e:	8082                	ret

0000000000000290 <close>:
.global close
close:
 li a7, SYS_close
 290:	48d5                	li	a7,21
 ecall
 292:	00000073          	ecall
 ret
 296:	8082                	ret

0000000000000298 <kill>:
.global kill
kill:
 li a7, SYS_kill
 298:	4899                	li	a7,6
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2a0:	489d                	li	a7,7
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <open>:
.global open
open:
 li a7, SYS_open
 2a8:	48bd                	li	a7,15
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2b0:	48c5                	li	a7,17
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2b8:	48c9                	li	a7,18
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2c0:	48a1                	li	a7,8
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <link>:
.global link
link:
 li a7, SYS_link
 2c8:	48cd                	li	a7,19
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2d0:	48d1                	li	a7,20
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2d8:	48a5                	li	a7,9
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2e0:	48a9                	li	a7,10
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2e8:	48ad                	li	a7,11
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2f0:	48b1                	li	a7,12
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2f8:	48b5                	li	a7,13
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 300:	48b9                	li	a7,14
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 308:	1101                	addi	sp,sp,-32
 30a:	ec06                	sd	ra,24(sp)
 30c:	e822                	sd	s0,16(sp)
 30e:	1000                	addi	s0,sp,32
 310:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 314:	4605                	li	a2,1
 316:	fef40593          	addi	a1,s0,-17
 31a:	00000097          	auipc	ra,0x0
 31e:	f6e080e7          	jalr	-146(ra) # 288 <write>
}
 322:	60e2                	ld	ra,24(sp)
 324:	6442                	ld	s0,16(sp)
 326:	6105                	addi	sp,sp,32
 328:	8082                	ret

000000000000032a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 32a:	7139                	addi	sp,sp,-64
 32c:	fc06                	sd	ra,56(sp)
 32e:	f822                	sd	s0,48(sp)
 330:	f426                	sd	s1,40(sp)
 332:	f04a                	sd	s2,32(sp)
 334:	ec4e                	sd	s3,24(sp)
 336:	0080                	addi	s0,sp,64
 338:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 33a:	c299                	beqz	a3,340 <printint+0x16>
 33c:	0805c863          	bltz	a1,3cc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 340:	2581                	sext.w	a1,a1
  neg = 0;
 342:	4881                	li	a7,0
 344:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 348:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 34a:	2601                	sext.w	a2,a2
 34c:	00000517          	auipc	a0,0x0
 350:	49450513          	addi	a0,a0,1172 # 7e0 <digits>
 354:	883a                	mv	a6,a4
 356:	2705                	addiw	a4,a4,1
 358:	02c5f7bb          	remuw	a5,a1,a2
 35c:	1782                	slli	a5,a5,0x20
 35e:	9381                	srli	a5,a5,0x20
 360:	97aa                	add	a5,a5,a0
 362:	0007c783          	lbu	a5,0(a5)
 366:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 36a:	0005879b          	sext.w	a5,a1
 36e:	02c5d5bb          	divuw	a1,a1,a2
 372:	0685                	addi	a3,a3,1
 374:	fec7f0e3          	bgeu	a5,a2,354 <printint+0x2a>
  if(neg)
 378:	00088b63          	beqz	a7,38e <printint+0x64>
    buf[i++] = '-';
 37c:	fd040793          	addi	a5,s0,-48
 380:	973e                	add	a4,a4,a5
 382:	02d00793          	li	a5,45
 386:	fef70823          	sb	a5,-16(a4)
 38a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 38e:	02e05863          	blez	a4,3be <printint+0x94>
 392:	fc040793          	addi	a5,s0,-64
 396:	00e78933          	add	s2,a5,a4
 39a:	fff78993          	addi	s3,a5,-1
 39e:	99ba                	add	s3,s3,a4
 3a0:	377d                	addiw	a4,a4,-1
 3a2:	1702                	slli	a4,a4,0x20
 3a4:	9301                	srli	a4,a4,0x20
 3a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3aa:	fff94583          	lbu	a1,-1(s2)
 3ae:	8526                	mv	a0,s1
 3b0:	00000097          	auipc	ra,0x0
 3b4:	f58080e7          	jalr	-168(ra) # 308 <putc>
  while(--i >= 0)
 3b8:	197d                	addi	s2,s2,-1
 3ba:	ff3918e3          	bne	s2,s3,3aa <printint+0x80>
}
 3be:	70e2                	ld	ra,56(sp)
 3c0:	7442                	ld	s0,48(sp)
 3c2:	74a2                	ld	s1,40(sp)
 3c4:	7902                	ld	s2,32(sp)
 3c6:	69e2                	ld	s3,24(sp)
 3c8:	6121                	addi	sp,sp,64
 3ca:	8082                	ret
    x = -xx;
 3cc:	40b005bb          	negw	a1,a1
    neg = 1;
 3d0:	4885                	li	a7,1
    x = -xx;
 3d2:	bf8d                	j	344 <printint+0x1a>

00000000000003d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3d4:	7119                	addi	sp,sp,-128
 3d6:	fc86                	sd	ra,120(sp)
 3d8:	f8a2                	sd	s0,112(sp)
 3da:	f4a6                	sd	s1,104(sp)
 3dc:	f0ca                	sd	s2,96(sp)
 3de:	ecce                	sd	s3,88(sp)
 3e0:	e8d2                	sd	s4,80(sp)
 3e2:	e4d6                	sd	s5,72(sp)
 3e4:	e0da                	sd	s6,64(sp)
 3e6:	fc5e                	sd	s7,56(sp)
 3e8:	f862                	sd	s8,48(sp)
 3ea:	f466                	sd	s9,40(sp)
 3ec:	f06a                	sd	s10,32(sp)
 3ee:	ec6e                	sd	s11,24(sp)
 3f0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3f2:	0005c903          	lbu	s2,0(a1)
 3f6:	18090f63          	beqz	s2,594 <vprintf+0x1c0>
 3fa:	8aaa                	mv	s5,a0
 3fc:	8b32                	mv	s6,a2
 3fe:	00158493          	addi	s1,a1,1
  state = 0;
 402:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 404:	02500a13          	li	s4,37
      if(c == 'd'){
 408:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 40c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 410:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 414:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 418:	00000b97          	auipc	s7,0x0
 41c:	3c8b8b93          	addi	s7,s7,968 # 7e0 <digits>
 420:	a839                	j	43e <vprintf+0x6a>
        putc(fd, c);
 422:	85ca                	mv	a1,s2
 424:	8556                	mv	a0,s5
 426:	00000097          	auipc	ra,0x0
 42a:	ee2080e7          	jalr	-286(ra) # 308 <putc>
 42e:	a019                	j	434 <vprintf+0x60>
    } else if(state == '%'){
 430:	01498f63          	beq	s3,s4,44e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 434:	0485                	addi	s1,s1,1
 436:	fff4c903          	lbu	s2,-1(s1)
 43a:	14090d63          	beqz	s2,594 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 43e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 442:	fe0997e3          	bnez	s3,430 <vprintf+0x5c>
      if(c == '%'){
 446:	fd479ee3          	bne	a5,s4,422 <vprintf+0x4e>
        state = '%';
 44a:	89be                	mv	s3,a5
 44c:	b7e5                	j	434 <vprintf+0x60>
      if(c == 'd'){
 44e:	05878063          	beq	a5,s8,48e <vprintf+0xba>
      } else if(c == 'l') {
 452:	05978c63          	beq	a5,s9,4aa <vprintf+0xd6>
      } else if(c == 'x') {
 456:	07a78863          	beq	a5,s10,4c6 <vprintf+0xf2>
      } else if(c == 'p') {
 45a:	09b78463          	beq	a5,s11,4e2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 45e:	07300713          	li	a4,115
 462:	0ce78663          	beq	a5,a4,52e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 466:	06300713          	li	a4,99
 46a:	0ee78e63          	beq	a5,a4,566 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 46e:	11478863          	beq	a5,s4,57e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 472:	85d2                	mv	a1,s4
 474:	8556                	mv	a0,s5
 476:	00000097          	auipc	ra,0x0
 47a:	e92080e7          	jalr	-366(ra) # 308 <putc>
        putc(fd, c);
 47e:	85ca                	mv	a1,s2
 480:	8556                	mv	a0,s5
 482:	00000097          	auipc	ra,0x0
 486:	e86080e7          	jalr	-378(ra) # 308 <putc>
      }
      state = 0;
 48a:	4981                	li	s3,0
 48c:	b765                	j	434 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 48e:	008b0913          	addi	s2,s6,8
 492:	4685                	li	a3,1
 494:	4629                	li	a2,10
 496:	000b2583          	lw	a1,0(s6)
 49a:	8556                	mv	a0,s5
 49c:	00000097          	auipc	ra,0x0
 4a0:	e8e080e7          	jalr	-370(ra) # 32a <printint>
 4a4:	8b4a                	mv	s6,s2
      state = 0;
 4a6:	4981                	li	s3,0
 4a8:	b771                	j	434 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4aa:	008b0913          	addi	s2,s6,8
 4ae:	4681                	li	a3,0
 4b0:	4629                	li	a2,10
 4b2:	000b2583          	lw	a1,0(s6)
 4b6:	8556                	mv	a0,s5
 4b8:	00000097          	auipc	ra,0x0
 4bc:	e72080e7          	jalr	-398(ra) # 32a <printint>
 4c0:	8b4a                	mv	s6,s2
      state = 0;
 4c2:	4981                	li	s3,0
 4c4:	bf85                	j	434 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4c6:	008b0913          	addi	s2,s6,8
 4ca:	4681                	li	a3,0
 4cc:	4641                	li	a2,16
 4ce:	000b2583          	lw	a1,0(s6)
 4d2:	8556                	mv	a0,s5
 4d4:	00000097          	auipc	ra,0x0
 4d8:	e56080e7          	jalr	-426(ra) # 32a <printint>
 4dc:	8b4a                	mv	s6,s2
      state = 0;
 4de:	4981                	li	s3,0
 4e0:	bf91                	j	434 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4e2:	008b0793          	addi	a5,s6,8
 4e6:	f8f43423          	sd	a5,-120(s0)
 4ea:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4ee:	03000593          	li	a1,48
 4f2:	8556                	mv	a0,s5
 4f4:	00000097          	auipc	ra,0x0
 4f8:	e14080e7          	jalr	-492(ra) # 308 <putc>
  putc(fd, 'x');
 4fc:	85ea                	mv	a1,s10
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	e08080e7          	jalr	-504(ra) # 308 <putc>
 508:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 50a:	03c9d793          	srli	a5,s3,0x3c
 50e:	97de                	add	a5,a5,s7
 510:	0007c583          	lbu	a1,0(a5)
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	df2080e7          	jalr	-526(ra) # 308 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 51e:	0992                	slli	s3,s3,0x4
 520:	397d                	addiw	s2,s2,-1
 522:	fe0914e3          	bnez	s2,50a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 526:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b721                	j	434 <vprintf+0x60>
        s = va_arg(ap, char*);
 52e:	008b0993          	addi	s3,s6,8
 532:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 536:	02090163          	beqz	s2,558 <vprintf+0x184>
        while(*s != 0){
 53a:	00094583          	lbu	a1,0(s2)
 53e:	c9a1                	beqz	a1,58e <vprintf+0x1ba>
          putc(fd, *s);
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	dc6080e7          	jalr	-570(ra) # 308 <putc>
          s++;
 54a:	0905                	addi	s2,s2,1
        while(*s != 0){
 54c:	00094583          	lbu	a1,0(s2)
 550:	f9e5                	bnez	a1,540 <vprintf+0x16c>
        s = va_arg(ap, char*);
 552:	8b4e                	mv	s6,s3
      state = 0;
 554:	4981                	li	s3,0
 556:	bdf9                	j	434 <vprintf+0x60>
          s = "(null)";
 558:	00000917          	auipc	s2,0x0
 55c:	28090913          	addi	s2,s2,640 # 7d8 <malloc+0x13a>
        while(*s != 0){
 560:	02800593          	li	a1,40
 564:	bff1                	j	540 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 566:	008b0913          	addi	s2,s6,8
 56a:	000b4583          	lbu	a1,0(s6)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	d98080e7          	jalr	-616(ra) # 308 <putc>
 578:	8b4a                	mv	s6,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	bd65                	j	434 <vprintf+0x60>
        putc(fd, c);
 57e:	85d2                	mv	a1,s4
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	d86080e7          	jalr	-634(ra) # 308 <putc>
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b565                	j	434 <vprintf+0x60>
        s = va_arg(ap, char*);
 58e:	8b4e                	mv	s6,s3
      state = 0;
 590:	4981                	li	s3,0
 592:	b54d                	j	434 <vprintf+0x60>
    }
  }
}
 594:	70e6                	ld	ra,120(sp)
 596:	7446                	ld	s0,112(sp)
 598:	74a6                	ld	s1,104(sp)
 59a:	7906                	ld	s2,96(sp)
 59c:	69e6                	ld	s3,88(sp)
 59e:	6a46                	ld	s4,80(sp)
 5a0:	6aa6                	ld	s5,72(sp)
 5a2:	6b06                	ld	s6,64(sp)
 5a4:	7be2                	ld	s7,56(sp)
 5a6:	7c42                	ld	s8,48(sp)
 5a8:	7ca2                	ld	s9,40(sp)
 5aa:	7d02                	ld	s10,32(sp)
 5ac:	6de2                	ld	s11,24(sp)
 5ae:	6109                	addi	sp,sp,128
 5b0:	8082                	ret

00000000000005b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5b2:	715d                	addi	sp,sp,-80
 5b4:	ec06                	sd	ra,24(sp)
 5b6:	e822                	sd	s0,16(sp)
 5b8:	1000                	addi	s0,sp,32
 5ba:	e010                	sd	a2,0(s0)
 5bc:	e414                	sd	a3,8(s0)
 5be:	e818                	sd	a4,16(s0)
 5c0:	ec1c                	sd	a5,24(s0)
 5c2:	03043023          	sd	a6,32(s0)
 5c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5ce:	8622                	mv	a2,s0
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e04080e7          	jalr	-508(ra) # 3d4 <vprintf>
}
 5d8:	60e2                	ld	ra,24(sp)
 5da:	6442                	ld	s0,16(sp)
 5dc:	6161                	addi	sp,sp,80
 5de:	8082                	ret

00000000000005e0 <printf>:

void
printf(const char *fmt, ...)
{
 5e0:	711d                	addi	sp,sp,-96
 5e2:	ec06                	sd	ra,24(sp)
 5e4:	e822                	sd	s0,16(sp)
 5e6:	1000                	addi	s0,sp,32
 5e8:	e40c                	sd	a1,8(s0)
 5ea:	e810                	sd	a2,16(s0)
 5ec:	ec14                	sd	a3,24(s0)
 5ee:	f018                	sd	a4,32(s0)
 5f0:	f41c                	sd	a5,40(s0)
 5f2:	03043823          	sd	a6,48(s0)
 5f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 5fa:	00840613          	addi	a2,s0,8
 5fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 602:	85aa                	mv	a1,a0
 604:	4505                	li	a0,1
 606:	00000097          	auipc	ra,0x0
 60a:	dce080e7          	jalr	-562(ra) # 3d4 <vprintf>
}
 60e:	60e2                	ld	ra,24(sp)
 610:	6442                	ld	s0,16(sp)
 612:	6125                	addi	sp,sp,96
 614:	8082                	ret

0000000000000616 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 616:	1141                	addi	sp,sp,-16
 618:	e422                	sd	s0,8(sp)
 61a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 61c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 620:	00000797          	auipc	a5,0x0
 624:	1d87b783          	ld	a5,472(a5) # 7f8 <freep>
 628:	a805                	j	658 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 62a:	4618                	lw	a4,8(a2)
 62c:	9db9                	addw	a1,a1,a4
 62e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 632:	6398                	ld	a4,0(a5)
 634:	6318                	ld	a4,0(a4)
 636:	fee53823          	sd	a4,-16(a0)
 63a:	a091                	j	67e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 63c:	ff852703          	lw	a4,-8(a0)
 640:	9e39                	addw	a2,a2,a4
 642:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 644:	ff053703          	ld	a4,-16(a0)
 648:	e398                	sd	a4,0(a5)
 64a:	a099                	j	690 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 64c:	6398                	ld	a4,0(a5)
 64e:	00e7e463          	bltu	a5,a4,656 <free+0x40>
 652:	00e6ea63          	bltu	a3,a4,666 <free+0x50>
{
 656:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 658:	fed7fae3          	bgeu	a5,a3,64c <free+0x36>
 65c:	6398                	ld	a4,0(a5)
 65e:	00e6e463          	bltu	a3,a4,666 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 662:	fee7eae3          	bltu	a5,a4,656 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 666:	ff852583          	lw	a1,-8(a0)
 66a:	6390                	ld	a2,0(a5)
 66c:	02059813          	slli	a6,a1,0x20
 670:	01c85713          	srli	a4,a6,0x1c
 674:	9736                	add	a4,a4,a3
 676:	fae60ae3          	beq	a2,a4,62a <free+0x14>
    bp->s.ptr = p->s.ptr;
 67a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 67e:	4790                	lw	a2,8(a5)
 680:	02061593          	slli	a1,a2,0x20
 684:	01c5d713          	srli	a4,a1,0x1c
 688:	973e                	add	a4,a4,a5
 68a:	fae689e3          	beq	a3,a4,63c <free+0x26>
  } else
    p->s.ptr = bp;
 68e:	e394                	sd	a3,0(a5)
  freep = p;
 690:	00000717          	auipc	a4,0x0
 694:	16f73423          	sd	a5,360(a4) # 7f8 <freep>
}
 698:	6422                	ld	s0,8(sp)
 69a:	0141                	addi	sp,sp,16
 69c:	8082                	ret

000000000000069e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 69e:	7139                	addi	sp,sp,-64
 6a0:	fc06                	sd	ra,56(sp)
 6a2:	f822                	sd	s0,48(sp)
 6a4:	f426                	sd	s1,40(sp)
 6a6:	f04a                	sd	s2,32(sp)
 6a8:	ec4e                	sd	s3,24(sp)
 6aa:	e852                	sd	s4,16(sp)
 6ac:	e456                	sd	s5,8(sp)
 6ae:	e05a                	sd	s6,0(sp)
 6b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6b2:	02051493          	slli	s1,a0,0x20
 6b6:	9081                	srli	s1,s1,0x20
 6b8:	04bd                	addi	s1,s1,15
 6ba:	8091                	srli	s1,s1,0x4
 6bc:	0014899b          	addiw	s3,s1,1
 6c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6c2:	00000517          	auipc	a0,0x0
 6c6:	13653503          	ld	a0,310(a0) # 7f8 <freep>
 6ca:	c515                	beqz	a0,6f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6ce:	4798                	lw	a4,8(a5)
 6d0:	02977f63          	bgeu	a4,s1,70e <malloc+0x70>
 6d4:	8a4e                	mv	s4,s3
 6d6:	0009871b          	sext.w	a4,s3
 6da:	6685                	lui	a3,0x1
 6dc:	00d77363          	bgeu	a4,a3,6e2 <malloc+0x44>
 6e0:	6a05                	lui	s4,0x1
 6e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6ea:	00000917          	auipc	s2,0x0
 6ee:	10e90913          	addi	s2,s2,270 # 7f8 <freep>
  if(p == (char*)-1)
 6f2:	5afd                	li	s5,-1
 6f4:	a895                	j	768 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 6f6:	00000797          	auipc	a5,0x0
 6fa:	10a78793          	addi	a5,a5,266 # 800 <base>
 6fe:	00000717          	auipc	a4,0x0
 702:	0ef73d23          	sd	a5,250(a4) # 7f8 <freep>
 706:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 708:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 70c:	b7e1                	j	6d4 <malloc+0x36>
      if(p->s.size == nunits)
 70e:	02e48c63          	beq	s1,a4,746 <malloc+0xa8>
        p->s.size -= nunits;
 712:	4137073b          	subw	a4,a4,s3
 716:	c798                	sw	a4,8(a5)
        p += p->s.size;
 718:	02071693          	slli	a3,a4,0x20
 71c:	01c6d713          	srli	a4,a3,0x1c
 720:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 722:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 726:	00000717          	auipc	a4,0x0
 72a:	0ca73923          	sd	a0,210(a4) # 7f8 <freep>
      return (void*)(p + 1);
 72e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 732:	70e2                	ld	ra,56(sp)
 734:	7442                	ld	s0,48(sp)
 736:	74a2                	ld	s1,40(sp)
 738:	7902                	ld	s2,32(sp)
 73a:	69e2                	ld	s3,24(sp)
 73c:	6a42                	ld	s4,16(sp)
 73e:	6aa2                	ld	s5,8(sp)
 740:	6b02                	ld	s6,0(sp)
 742:	6121                	addi	sp,sp,64
 744:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 746:	6398                	ld	a4,0(a5)
 748:	e118                	sd	a4,0(a0)
 74a:	bff1                	j	726 <malloc+0x88>
  hp->s.size = nu;
 74c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 750:	0541                	addi	a0,a0,16
 752:	00000097          	auipc	ra,0x0
 756:	ec4080e7          	jalr	-316(ra) # 616 <free>
  return freep;
 75a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 75e:	d971                	beqz	a0,732 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 760:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 762:	4798                	lw	a4,8(a5)
 764:	fa9775e3          	bgeu	a4,s1,70e <malloc+0x70>
    if(p == freep)
 768:	00093703          	ld	a4,0(s2)
 76c:	853e                	mv	a0,a5
 76e:	fef719e3          	bne	a4,a5,760 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 772:	8552                	mv	a0,s4
 774:	00000097          	auipc	ra,0x0
 778:	b7c080e7          	jalr	-1156(ra) # 2f0 <sbrk>
  if(p == (char*)-1)
 77c:	fd5518e3          	bne	a0,s5,74c <malloc+0xae>
        return 0;
 780:	4501                	li	a0,0
 782:	bf45                	j	732 <malloc+0x94>
