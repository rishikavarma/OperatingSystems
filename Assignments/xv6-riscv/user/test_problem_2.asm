
user/_test_problem_2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/spinlock.h"
#include "kernel/sleeplock.h"
#include "kernel/fs.h"
#include "kernel/file.h"
#include "user/user.h"
int main(int argc, char *argv[]){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
	if(argc<2){
   8:	4785                	li	a5,1
   a:	00a7dc63          	bge	a5,a0,22 <main+0x22>
		printf("Error:Insufficient arguments\n");
		exit(0);
	}
	echo_kernel(argc,argv[0]);
   e:	618c                	ld	a1,0(a1)
  10:	00000097          	auipc	ra,0x0
  14:	222080e7          	jalr	546(ra) # 232 <echo_kernel>
	exit(0);
  18:	4501                	li	a0,0
  1a:	00000097          	auipc	ra,0x0
  1e:	230080e7          	jalr	560(ra) # 24a <exit>
		printf("Error:Insufficient arguments\n");
  22:	00000517          	auipc	a0,0x0
  26:	74650513          	addi	a0,a0,1862 # 768 <malloc+0xe8>
  2a:	00000097          	auipc	ra,0x0
  2e:	598080e7          	jalr	1432(ra) # 5c2 <printf>
		exit(0);
  32:	4501                	li	a0,0
  34:	00000097          	auipc	ra,0x0
  38:	216080e7          	jalr	534(ra) # 24a <exit>

000000000000003c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e422                	sd	s0,8(sp)
  40:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  42:	87aa                	mv	a5,a0
  44:	0585                	addi	a1,a1,1
  46:	0785                	addi	a5,a5,1
  48:	fff5c703          	lbu	a4,-1(a1)
  4c:	fee78fa3          	sb	a4,-1(a5)
  50:	fb75                	bnez	a4,44 <strcpy+0x8>
    ;
  return os;
}
  52:	6422                	ld	s0,8(sp)
  54:	0141                	addi	sp,sp,16
  56:	8082                	ret

0000000000000058 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e422                	sd	s0,8(sp)
  5c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	cb91                	beqz	a5,76 <strcmp+0x1e>
  64:	0005c703          	lbu	a4,0(a1)
  68:	00f71763          	bne	a4,a5,76 <strcmp+0x1e>
    p++, q++;
  6c:	0505                	addi	a0,a0,1
  6e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  70:	00054783          	lbu	a5,0(a0)
  74:	fbe5                	bnez	a5,64 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  76:	0005c503          	lbu	a0,0(a1)
}
  7a:	40a7853b          	subw	a0,a5,a0
  7e:	6422                	ld	s0,8(sp)
  80:	0141                	addi	sp,sp,16
  82:	8082                	ret

0000000000000084 <strlen>:

uint
strlen(const char *s)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	cf91                	beqz	a5,aa <strlen+0x26>
  90:	0505                	addi	a0,a0,1
  92:	87aa                	mv	a5,a0
  94:	4685                	li	a3,1
  96:	9e89                	subw	a3,a3,a0
  98:	00f6853b          	addw	a0,a3,a5
  9c:	0785                	addi	a5,a5,1
  9e:	fff7c703          	lbu	a4,-1(a5)
  a2:	fb7d                	bnez	a4,98 <strlen+0x14>
    ;
  return n;
}
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret
  for(n = 0; s[n]; n++)
  aa:	4501                	li	a0,0
  ac:	bfe5                	j	a4 <strlen+0x20>

00000000000000ae <memset>:

void*
memset(void *dst, int c, uint n)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b4:	ca19                	beqz	a2,ca <memset+0x1c>
  b6:	87aa                	mv	a5,a0
  b8:	1602                	slli	a2,a2,0x20
  ba:	9201                	srli	a2,a2,0x20
  bc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  c4:	0785                	addi	a5,a5,1
  c6:	fee79de3          	bne	a5,a4,c0 <memset+0x12>
  }
  return dst;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strchr>:

char*
strchr(const char *s, char c)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cb99                	beqz	a5,f0 <strchr+0x20>
    if(*s == c)
  dc:	00f58763          	beq	a1,a5,ea <strchr+0x1a>
  for(; *s; s++)
  e0:	0505                	addi	a0,a0,1
  e2:	00054783          	lbu	a5,0(a0)
  e6:	fbfd                	bnez	a5,dc <strchr+0xc>
      return (char*)s;
  return 0;
  e8:	4501                	li	a0,0
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret
  return 0;
  f0:	4501                	li	a0,0
  f2:	bfe5                	j	ea <strchr+0x1a>

00000000000000f4 <gets>:

char*
gets(char *buf, int max)
{
  f4:	711d                	addi	sp,sp,-96
  f6:	ec86                	sd	ra,88(sp)
  f8:	e8a2                	sd	s0,80(sp)
  fa:	e4a6                	sd	s1,72(sp)
  fc:	e0ca                	sd	s2,64(sp)
  fe:	fc4e                	sd	s3,56(sp)
 100:	f852                	sd	s4,48(sp)
 102:	f456                	sd	s5,40(sp)
 104:	f05a                	sd	s6,32(sp)
 106:	ec5e                	sd	s7,24(sp)
 108:	1080                	addi	s0,sp,96
 10a:	8baa                	mv	s7,a0
 10c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 10e:	892a                	mv	s2,a0
 110:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 112:	4aa9                	li	s5,10
 114:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 116:	89a6                	mv	s3,s1
 118:	2485                	addiw	s1,s1,1
 11a:	0344d863          	bge	s1,s4,14a <gets+0x56>
    cc = read(0, &c, 1);
 11e:	4605                	li	a2,1
 120:	faf40593          	addi	a1,s0,-81
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	13c080e7          	jalr	316(ra) # 262 <read>
    if(cc < 1)
 12e:	00a05e63          	blez	a0,14a <gets+0x56>
    buf[i++] = c;
 132:	faf44783          	lbu	a5,-81(s0)
 136:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 13a:	01578763          	beq	a5,s5,148 <gets+0x54>
 13e:	0905                	addi	s2,s2,1
 140:	fd679be3          	bne	a5,s6,116 <gets+0x22>
  for(i=0; i+1 < max; ){
 144:	89a6                	mv	s3,s1
 146:	a011                	j	14a <gets+0x56>
 148:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 14a:	99de                	add	s3,s3,s7
 14c:	00098023          	sb	zero,0(s3)
  return buf;
}
 150:	855e                	mv	a0,s7
 152:	60e6                	ld	ra,88(sp)
 154:	6446                	ld	s0,80(sp)
 156:	64a6                	ld	s1,72(sp)
 158:	6906                	ld	s2,64(sp)
 15a:	79e2                	ld	s3,56(sp)
 15c:	7a42                	ld	s4,48(sp)
 15e:	7aa2                	ld	s5,40(sp)
 160:	7b02                	ld	s6,32(sp)
 162:	6be2                	ld	s7,24(sp)
 164:	6125                	addi	sp,sp,96
 166:	8082                	ret

0000000000000168 <stat>:

int
stat(const char *n, struct stat *st)
{
 168:	1101                	addi	sp,sp,-32
 16a:	ec06                	sd	ra,24(sp)
 16c:	e822                	sd	s0,16(sp)
 16e:	e426                	sd	s1,8(sp)
 170:	e04a                	sd	s2,0(sp)
 172:	1000                	addi	s0,sp,32
 174:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 176:	4581                	li	a1,0
 178:	00000097          	auipc	ra,0x0
 17c:	112080e7          	jalr	274(ra) # 28a <open>
  if(fd < 0)
 180:	02054563          	bltz	a0,1aa <stat+0x42>
 184:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 186:	85ca                	mv	a1,s2
 188:	00000097          	auipc	ra,0x0
 18c:	11a080e7          	jalr	282(ra) # 2a2 <fstat>
 190:	892a                	mv	s2,a0
  close(fd);
 192:	8526                	mv	a0,s1
 194:	00000097          	auipc	ra,0x0
 198:	0de080e7          	jalr	222(ra) # 272 <close>
  return r;
}
 19c:	854a                	mv	a0,s2
 19e:	60e2                	ld	ra,24(sp)
 1a0:	6442                	ld	s0,16(sp)
 1a2:	64a2                	ld	s1,8(sp)
 1a4:	6902                	ld	s2,0(sp)
 1a6:	6105                	addi	sp,sp,32
 1a8:	8082                	ret
    return -1;
 1aa:	597d                	li	s2,-1
 1ac:	bfc5                	j	19c <stat+0x34>

00000000000001ae <atoi>:

int
atoi(const char *s)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b4:	00054603          	lbu	a2,0(a0)
 1b8:	fd06079b          	addiw	a5,a2,-48
 1bc:	0ff7f793          	andi	a5,a5,255
 1c0:	4725                	li	a4,9
 1c2:	02f76963          	bltu	a4,a5,1f4 <atoi+0x46>
 1c6:	86aa                	mv	a3,a0
  n = 0;
 1c8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ca:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1cc:	0685                	addi	a3,a3,1
 1ce:	0025179b          	slliw	a5,a0,0x2
 1d2:	9fa9                	addw	a5,a5,a0
 1d4:	0017979b          	slliw	a5,a5,0x1
 1d8:	9fb1                	addw	a5,a5,a2
 1da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1de:	0006c603          	lbu	a2,0(a3)
 1e2:	fd06071b          	addiw	a4,a2,-48
 1e6:	0ff77713          	andi	a4,a4,255
 1ea:	fee5f1e3          	bgeu	a1,a4,1cc <atoi+0x1e>
  return n;
}
 1ee:	6422                	ld	s0,8(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret
  n = 0;
 1f4:	4501                	li	a0,0
 1f6:	bfe5                	j	1ee <atoi+0x40>

00000000000001f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1fe:	00c05f63          	blez	a2,21c <memmove+0x24>
 202:	1602                	slli	a2,a2,0x20
 204:	9201                	srli	a2,a2,0x20
 206:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 20a:	87aa                	mv	a5,a0
    *dst++ = *src++;
 20c:	0585                	addi	a1,a1,1
 20e:	0785                	addi	a5,a5,1
 210:	fff5c703          	lbu	a4,-1(a1)
 214:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 218:	fed79ae3          	bne	a5,a3,20c <memmove+0x14>
  return vdst;
}
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret

0000000000000222 <trace>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global trace
trace:
 li a7, SYS_trace
 222:	48e5                	li	a7,25
 ecall
 224:	00000073          	ecall
 ret
 228:	8082                	ret

000000000000022a <get_process_info>:
.global get_process_info
get_process_info:
 li a7, SYS_get_process_info
 22a:	48e1                	li	a7,24
 ecall
 22c:	00000073          	ecall
 ret
 230:	8082                	ret

0000000000000232 <echo_kernel>:
.global echo_kernel
echo_kernel:
 li a7, SYS_echo_kernel
 232:	48dd                	li	a7,23
 ecall
 234:	00000073          	ecall
 ret
 238:	8082                	ret

000000000000023a <echo_simple>:
.global echo_simple
echo_simple:
 li a7, SYS_echo_simple
 23a:	48d9                	li	a7,22
 ecall
 23c:	00000073          	ecall
 ret
 240:	8082                	ret

0000000000000242 <fork>:
.global fork
fork:
 li a7, SYS_fork
 242:	4885                	li	a7,1
 ecall
 244:	00000073          	ecall
 ret
 248:	8082                	ret

000000000000024a <exit>:
.global exit
exit:
 li a7, SYS_exit
 24a:	4889                	li	a7,2
 ecall
 24c:	00000073          	ecall
 ret
 250:	8082                	ret

0000000000000252 <wait>:
.global wait
wait:
 li a7, SYS_wait
 252:	488d                	li	a7,3
 ecall
 254:	00000073          	ecall
 ret
 258:	8082                	ret

000000000000025a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 25a:	4891                	li	a7,4
 ecall
 25c:	00000073          	ecall
 ret
 260:	8082                	ret

0000000000000262 <read>:
.global read
read:
 li a7, SYS_read
 262:	4895                	li	a7,5
 ecall
 264:	00000073          	ecall
 ret
 268:	8082                	ret

000000000000026a <write>:
.global write
write:
 li a7, SYS_write
 26a:	48c1                	li	a7,16
 ecall
 26c:	00000073          	ecall
 ret
 270:	8082                	ret

0000000000000272 <close>:
.global close
close:
 li a7, SYS_close
 272:	48d5                	li	a7,21
 ecall
 274:	00000073          	ecall
 ret
 278:	8082                	ret

000000000000027a <kill>:
.global kill
kill:
 li a7, SYS_kill
 27a:	4899                	li	a7,6
 ecall
 27c:	00000073          	ecall
 ret
 280:	8082                	ret

0000000000000282 <exec>:
.global exec
exec:
 li a7, SYS_exec
 282:	489d                	li	a7,7
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <open>:
.global open
open:
 li a7, SYS_open
 28a:	48bd                	li	a7,15
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 292:	48c5                	li	a7,17
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 29a:	48c9                	li	a7,18
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2a2:	48a1                	li	a7,8
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <link>:
.global link
link:
 li a7, SYS_link
 2aa:	48cd                	li	a7,19
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2b2:	48d1                	li	a7,20
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2ba:	48a5                	li	a7,9
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2c2:	48a9                	li	a7,10
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2ca:	48ad                	li	a7,11
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2d2:	48b1                	li	a7,12
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2da:	48b5                	li	a7,13
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 2e2:	48b9                	li	a7,14
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 2ea:	1101                	addi	sp,sp,-32
 2ec:	ec06                	sd	ra,24(sp)
 2ee:	e822                	sd	s0,16(sp)
 2f0:	1000                	addi	s0,sp,32
 2f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 2f6:	4605                	li	a2,1
 2f8:	fef40593          	addi	a1,s0,-17
 2fc:	00000097          	auipc	ra,0x0
 300:	f6e080e7          	jalr	-146(ra) # 26a <write>
}
 304:	60e2                	ld	ra,24(sp)
 306:	6442                	ld	s0,16(sp)
 308:	6105                	addi	sp,sp,32
 30a:	8082                	ret

000000000000030c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 30c:	7139                	addi	sp,sp,-64
 30e:	fc06                	sd	ra,56(sp)
 310:	f822                	sd	s0,48(sp)
 312:	f426                	sd	s1,40(sp)
 314:	f04a                	sd	s2,32(sp)
 316:	ec4e                	sd	s3,24(sp)
 318:	0080                	addi	s0,sp,64
 31a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 31c:	c299                	beqz	a3,322 <printint+0x16>
 31e:	0805c863          	bltz	a1,3ae <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 322:	2581                	sext.w	a1,a1
  neg = 0;
 324:	4881                	li	a7,0
 326:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 32a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 32c:	2601                	sext.w	a2,a2
 32e:	00000517          	auipc	a0,0x0
 332:	46250513          	addi	a0,a0,1122 # 790 <digits>
 336:	883a                	mv	a6,a4
 338:	2705                	addiw	a4,a4,1
 33a:	02c5f7bb          	remuw	a5,a1,a2
 33e:	1782                	slli	a5,a5,0x20
 340:	9381                	srli	a5,a5,0x20
 342:	97aa                	add	a5,a5,a0
 344:	0007c783          	lbu	a5,0(a5)
 348:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 34c:	0005879b          	sext.w	a5,a1
 350:	02c5d5bb          	divuw	a1,a1,a2
 354:	0685                	addi	a3,a3,1
 356:	fec7f0e3          	bgeu	a5,a2,336 <printint+0x2a>
  if(neg)
 35a:	00088b63          	beqz	a7,370 <printint+0x64>
    buf[i++] = '-';
 35e:	fd040793          	addi	a5,s0,-48
 362:	973e                	add	a4,a4,a5
 364:	02d00793          	li	a5,45
 368:	fef70823          	sb	a5,-16(a4)
 36c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 370:	02e05863          	blez	a4,3a0 <printint+0x94>
 374:	fc040793          	addi	a5,s0,-64
 378:	00e78933          	add	s2,a5,a4
 37c:	fff78993          	addi	s3,a5,-1
 380:	99ba                	add	s3,s3,a4
 382:	377d                	addiw	a4,a4,-1
 384:	1702                	slli	a4,a4,0x20
 386:	9301                	srli	a4,a4,0x20
 388:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 38c:	fff94583          	lbu	a1,-1(s2)
 390:	8526                	mv	a0,s1
 392:	00000097          	auipc	ra,0x0
 396:	f58080e7          	jalr	-168(ra) # 2ea <putc>
  while(--i >= 0)
 39a:	197d                	addi	s2,s2,-1
 39c:	ff3918e3          	bne	s2,s3,38c <printint+0x80>
}
 3a0:	70e2                	ld	ra,56(sp)
 3a2:	7442                	ld	s0,48(sp)
 3a4:	74a2                	ld	s1,40(sp)
 3a6:	7902                	ld	s2,32(sp)
 3a8:	69e2                	ld	s3,24(sp)
 3aa:	6121                	addi	sp,sp,64
 3ac:	8082                	ret
    x = -xx;
 3ae:	40b005bb          	negw	a1,a1
    neg = 1;
 3b2:	4885                	li	a7,1
    x = -xx;
 3b4:	bf8d                	j	326 <printint+0x1a>

00000000000003b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3b6:	7119                	addi	sp,sp,-128
 3b8:	fc86                	sd	ra,120(sp)
 3ba:	f8a2                	sd	s0,112(sp)
 3bc:	f4a6                	sd	s1,104(sp)
 3be:	f0ca                	sd	s2,96(sp)
 3c0:	ecce                	sd	s3,88(sp)
 3c2:	e8d2                	sd	s4,80(sp)
 3c4:	e4d6                	sd	s5,72(sp)
 3c6:	e0da                	sd	s6,64(sp)
 3c8:	fc5e                	sd	s7,56(sp)
 3ca:	f862                	sd	s8,48(sp)
 3cc:	f466                	sd	s9,40(sp)
 3ce:	f06a                	sd	s10,32(sp)
 3d0:	ec6e                	sd	s11,24(sp)
 3d2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3d4:	0005c903          	lbu	s2,0(a1)
 3d8:	18090f63          	beqz	s2,576 <vprintf+0x1c0>
 3dc:	8aaa                	mv	s5,a0
 3de:	8b32                	mv	s6,a2
 3e0:	00158493          	addi	s1,a1,1
  state = 0;
 3e4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3e6:	02500a13          	li	s4,37
      if(c == 'd'){
 3ea:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 3ee:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 3f2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 3f6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 3fa:	00000b97          	auipc	s7,0x0
 3fe:	396b8b93          	addi	s7,s7,918 # 790 <digits>
 402:	a839                	j	420 <vprintf+0x6a>
        putc(fd, c);
 404:	85ca                	mv	a1,s2
 406:	8556                	mv	a0,s5
 408:	00000097          	auipc	ra,0x0
 40c:	ee2080e7          	jalr	-286(ra) # 2ea <putc>
 410:	a019                	j	416 <vprintf+0x60>
    } else if(state == '%'){
 412:	01498f63          	beq	s3,s4,430 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 416:	0485                	addi	s1,s1,1
 418:	fff4c903          	lbu	s2,-1(s1)
 41c:	14090d63          	beqz	s2,576 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 420:	0009079b          	sext.w	a5,s2
    if(state == 0){
 424:	fe0997e3          	bnez	s3,412 <vprintf+0x5c>
      if(c == '%'){
 428:	fd479ee3          	bne	a5,s4,404 <vprintf+0x4e>
        state = '%';
 42c:	89be                	mv	s3,a5
 42e:	b7e5                	j	416 <vprintf+0x60>
      if(c == 'd'){
 430:	05878063          	beq	a5,s8,470 <vprintf+0xba>
      } else if(c == 'l') {
 434:	05978c63          	beq	a5,s9,48c <vprintf+0xd6>
      } else if(c == 'x') {
 438:	07a78863          	beq	a5,s10,4a8 <vprintf+0xf2>
      } else if(c == 'p') {
 43c:	09b78463          	beq	a5,s11,4c4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 440:	07300713          	li	a4,115
 444:	0ce78663          	beq	a5,a4,510 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 448:	06300713          	li	a4,99
 44c:	0ee78e63          	beq	a5,a4,548 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 450:	11478863          	beq	a5,s4,560 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 454:	85d2                	mv	a1,s4
 456:	8556                	mv	a0,s5
 458:	00000097          	auipc	ra,0x0
 45c:	e92080e7          	jalr	-366(ra) # 2ea <putc>
        putc(fd, c);
 460:	85ca                	mv	a1,s2
 462:	8556                	mv	a0,s5
 464:	00000097          	auipc	ra,0x0
 468:	e86080e7          	jalr	-378(ra) # 2ea <putc>
      }
      state = 0;
 46c:	4981                	li	s3,0
 46e:	b765                	j	416 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 470:	008b0913          	addi	s2,s6,8
 474:	4685                	li	a3,1
 476:	4629                	li	a2,10
 478:	000b2583          	lw	a1,0(s6)
 47c:	8556                	mv	a0,s5
 47e:	00000097          	auipc	ra,0x0
 482:	e8e080e7          	jalr	-370(ra) # 30c <printint>
 486:	8b4a                	mv	s6,s2
      state = 0;
 488:	4981                	li	s3,0
 48a:	b771                	j	416 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 48c:	008b0913          	addi	s2,s6,8
 490:	4681                	li	a3,0
 492:	4629                	li	a2,10
 494:	000b2583          	lw	a1,0(s6)
 498:	8556                	mv	a0,s5
 49a:	00000097          	auipc	ra,0x0
 49e:	e72080e7          	jalr	-398(ra) # 30c <printint>
 4a2:	8b4a                	mv	s6,s2
      state = 0;
 4a4:	4981                	li	s3,0
 4a6:	bf85                	j	416 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4a8:	008b0913          	addi	s2,s6,8
 4ac:	4681                	li	a3,0
 4ae:	4641                	li	a2,16
 4b0:	000b2583          	lw	a1,0(s6)
 4b4:	8556                	mv	a0,s5
 4b6:	00000097          	auipc	ra,0x0
 4ba:	e56080e7          	jalr	-426(ra) # 30c <printint>
 4be:	8b4a                	mv	s6,s2
      state = 0;
 4c0:	4981                	li	s3,0
 4c2:	bf91                	j	416 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4c4:	008b0793          	addi	a5,s6,8
 4c8:	f8f43423          	sd	a5,-120(s0)
 4cc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4d0:	03000593          	li	a1,48
 4d4:	8556                	mv	a0,s5
 4d6:	00000097          	auipc	ra,0x0
 4da:	e14080e7          	jalr	-492(ra) # 2ea <putc>
  putc(fd, 'x');
 4de:	85ea                	mv	a1,s10
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	e08080e7          	jalr	-504(ra) # 2ea <putc>
 4ea:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ec:	03c9d793          	srli	a5,s3,0x3c
 4f0:	97de                	add	a5,a5,s7
 4f2:	0007c583          	lbu	a1,0(a5)
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	df2080e7          	jalr	-526(ra) # 2ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 500:	0992                	slli	s3,s3,0x4
 502:	397d                	addiw	s2,s2,-1
 504:	fe0914e3          	bnez	s2,4ec <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 508:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 50c:	4981                	li	s3,0
 50e:	b721                	j	416 <vprintf+0x60>
        s = va_arg(ap, char*);
 510:	008b0993          	addi	s3,s6,8
 514:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 518:	02090163          	beqz	s2,53a <vprintf+0x184>
        while(*s != 0){
 51c:	00094583          	lbu	a1,0(s2)
 520:	c9a1                	beqz	a1,570 <vprintf+0x1ba>
          putc(fd, *s);
 522:	8556                	mv	a0,s5
 524:	00000097          	auipc	ra,0x0
 528:	dc6080e7          	jalr	-570(ra) # 2ea <putc>
          s++;
 52c:	0905                	addi	s2,s2,1
        while(*s != 0){
 52e:	00094583          	lbu	a1,0(s2)
 532:	f9e5                	bnez	a1,522 <vprintf+0x16c>
        s = va_arg(ap, char*);
 534:	8b4e                	mv	s6,s3
      state = 0;
 536:	4981                	li	s3,0
 538:	bdf9                	j	416 <vprintf+0x60>
          s = "(null)";
 53a:	00000917          	auipc	s2,0x0
 53e:	24e90913          	addi	s2,s2,590 # 788 <malloc+0x108>
        while(*s != 0){
 542:	02800593          	li	a1,40
 546:	bff1                	j	522 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 548:	008b0913          	addi	s2,s6,8
 54c:	000b4583          	lbu	a1,0(s6)
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	d98080e7          	jalr	-616(ra) # 2ea <putc>
 55a:	8b4a                	mv	s6,s2
      state = 0;
 55c:	4981                	li	s3,0
 55e:	bd65                	j	416 <vprintf+0x60>
        putc(fd, c);
 560:	85d2                	mv	a1,s4
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	d86080e7          	jalr	-634(ra) # 2ea <putc>
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b565                	j	416 <vprintf+0x60>
        s = va_arg(ap, char*);
 570:	8b4e                	mv	s6,s3
      state = 0;
 572:	4981                	li	s3,0
 574:	b54d                	j	416 <vprintf+0x60>
    }
  }
}
 576:	70e6                	ld	ra,120(sp)
 578:	7446                	ld	s0,112(sp)
 57a:	74a6                	ld	s1,104(sp)
 57c:	7906                	ld	s2,96(sp)
 57e:	69e6                	ld	s3,88(sp)
 580:	6a46                	ld	s4,80(sp)
 582:	6aa6                	ld	s5,72(sp)
 584:	6b06                	ld	s6,64(sp)
 586:	7be2                	ld	s7,56(sp)
 588:	7c42                	ld	s8,48(sp)
 58a:	7ca2                	ld	s9,40(sp)
 58c:	7d02                	ld	s10,32(sp)
 58e:	6de2                	ld	s11,24(sp)
 590:	6109                	addi	sp,sp,128
 592:	8082                	ret

0000000000000594 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 594:	715d                	addi	sp,sp,-80
 596:	ec06                	sd	ra,24(sp)
 598:	e822                	sd	s0,16(sp)
 59a:	1000                	addi	s0,sp,32
 59c:	e010                	sd	a2,0(s0)
 59e:	e414                	sd	a3,8(s0)
 5a0:	e818                	sd	a4,16(s0)
 5a2:	ec1c                	sd	a5,24(s0)
 5a4:	03043023          	sd	a6,32(s0)
 5a8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5b0:	8622                	mv	a2,s0
 5b2:	00000097          	auipc	ra,0x0
 5b6:	e04080e7          	jalr	-508(ra) # 3b6 <vprintf>
}
 5ba:	60e2                	ld	ra,24(sp)
 5bc:	6442                	ld	s0,16(sp)
 5be:	6161                	addi	sp,sp,80
 5c0:	8082                	ret

00000000000005c2 <printf>:

void
printf(const char *fmt, ...)
{
 5c2:	711d                	addi	sp,sp,-96
 5c4:	ec06                	sd	ra,24(sp)
 5c6:	e822                	sd	s0,16(sp)
 5c8:	1000                	addi	s0,sp,32
 5ca:	e40c                	sd	a1,8(s0)
 5cc:	e810                	sd	a2,16(s0)
 5ce:	ec14                	sd	a3,24(s0)
 5d0:	f018                	sd	a4,32(s0)
 5d2:	f41c                	sd	a5,40(s0)
 5d4:	03043823          	sd	a6,48(s0)
 5d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 5dc:	00840613          	addi	a2,s0,8
 5e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 5e4:	85aa                	mv	a1,a0
 5e6:	4505                	li	a0,1
 5e8:	00000097          	auipc	ra,0x0
 5ec:	dce080e7          	jalr	-562(ra) # 3b6 <vprintf>
}
 5f0:	60e2                	ld	ra,24(sp)
 5f2:	6442                	ld	s0,16(sp)
 5f4:	6125                	addi	sp,sp,96
 5f6:	8082                	ret

00000000000005f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f8:	1141                	addi	sp,sp,-16
 5fa:	e422                	sd	s0,8(sp)
 5fc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5fe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 602:	00000797          	auipc	a5,0x0
 606:	1a67b783          	ld	a5,422(a5) # 7a8 <freep>
 60a:	a805                	j	63a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 60c:	4618                	lw	a4,8(a2)
 60e:	9db9                	addw	a1,a1,a4
 610:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 614:	6398                	ld	a4,0(a5)
 616:	6318                	ld	a4,0(a4)
 618:	fee53823          	sd	a4,-16(a0)
 61c:	a091                	j	660 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 61e:	ff852703          	lw	a4,-8(a0)
 622:	9e39                	addw	a2,a2,a4
 624:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 626:	ff053703          	ld	a4,-16(a0)
 62a:	e398                	sd	a4,0(a5)
 62c:	a099                	j	672 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 62e:	6398                	ld	a4,0(a5)
 630:	00e7e463          	bltu	a5,a4,638 <free+0x40>
 634:	00e6ea63          	bltu	a3,a4,648 <free+0x50>
{
 638:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63a:	fed7fae3          	bgeu	a5,a3,62e <free+0x36>
 63e:	6398                	ld	a4,0(a5)
 640:	00e6e463          	bltu	a3,a4,648 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 644:	fee7eae3          	bltu	a5,a4,638 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 648:	ff852583          	lw	a1,-8(a0)
 64c:	6390                	ld	a2,0(a5)
 64e:	02059813          	slli	a6,a1,0x20
 652:	01c85713          	srli	a4,a6,0x1c
 656:	9736                	add	a4,a4,a3
 658:	fae60ae3          	beq	a2,a4,60c <free+0x14>
    bp->s.ptr = p->s.ptr;
 65c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 660:	4790                	lw	a2,8(a5)
 662:	02061593          	slli	a1,a2,0x20
 666:	01c5d713          	srli	a4,a1,0x1c
 66a:	973e                	add	a4,a4,a5
 66c:	fae689e3          	beq	a3,a4,61e <free+0x26>
  } else
    p->s.ptr = bp;
 670:	e394                	sd	a3,0(a5)
  freep = p;
 672:	00000717          	auipc	a4,0x0
 676:	12f73b23          	sd	a5,310(a4) # 7a8 <freep>
}
 67a:	6422                	ld	s0,8(sp)
 67c:	0141                	addi	sp,sp,16
 67e:	8082                	ret

0000000000000680 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 680:	7139                	addi	sp,sp,-64
 682:	fc06                	sd	ra,56(sp)
 684:	f822                	sd	s0,48(sp)
 686:	f426                	sd	s1,40(sp)
 688:	f04a                	sd	s2,32(sp)
 68a:	ec4e                	sd	s3,24(sp)
 68c:	e852                	sd	s4,16(sp)
 68e:	e456                	sd	s5,8(sp)
 690:	e05a                	sd	s6,0(sp)
 692:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 694:	02051493          	slli	s1,a0,0x20
 698:	9081                	srli	s1,s1,0x20
 69a:	04bd                	addi	s1,s1,15
 69c:	8091                	srli	s1,s1,0x4
 69e:	0014899b          	addiw	s3,s1,1
 6a2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6a4:	00000517          	auipc	a0,0x0
 6a8:	10453503          	ld	a0,260(a0) # 7a8 <freep>
 6ac:	c515                	beqz	a0,6d8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6b0:	4798                	lw	a4,8(a5)
 6b2:	02977f63          	bgeu	a4,s1,6f0 <malloc+0x70>
 6b6:	8a4e                	mv	s4,s3
 6b8:	0009871b          	sext.w	a4,s3
 6bc:	6685                	lui	a3,0x1
 6be:	00d77363          	bgeu	a4,a3,6c4 <malloc+0x44>
 6c2:	6a05                	lui	s4,0x1
 6c4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6c8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6cc:	00000917          	auipc	s2,0x0
 6d0:	0dc90913          	addi	s2,s2,220 # 7a8 <freep>
  if(p == (char*)-1)
 6d4:	5afd                	li	s5,-1
 6d6:	a895                	j	74a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 6d8:	00000797          	auipc	a5,0x0
 6dc:	0d878793          	addi	a5,a5,216 # 7b0 <base>
 6e0:	00000717          	auipc	a4,0x0
 6e4:	0cf73423          	sd	a5,200(a4) # 7a8 <freep>
 6e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 6ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 6ee:	b7e1                	j	6b6 <malloc+0x36>
      if(p->s.size == nunits)
 6f0:	02e48c63          	beq	s1,a4,728 <malloc+0xa8>
        p->s.size -= nunits;
 6f4:	4137073b          	subw	a4,a4,s3
 6f8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 6fa:	02071693          	slli	a3,a4,0x20
 6fe:	01c6d713          	srli	a4,a3,0x1c
 702:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 704:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 708:	00000717          	auipc	a4,0x0
 70c:	0aa73023          	sd	a0,160(a4) # 7a8 <freep>
      return (void*)(p + 1);
 710:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 714:	70e2                	ld	ra,56(sp)
 716:	7442                	ld	s0,48(sp)
 718:	74a2                	ld	s1,40(sp)
 71a:	7902                	ld	s2,32(sp)
 71c:	69e2                	ld	s3,24(sp)
 71e:	6a42                	ld	s4,16(sp)
 720:	6aa2                	ld	s5,8(sp)
 722:	6b02                	ld	s6,0(sp)
 724:	6121                	addi	sp,sp,64
 726:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 728:	6398                	ld	a4,0(a5)
 72a:	e118                	sd	a4,0(a0)
 72c:	bff1                	j	708 <malloc+0x88>
  hp->s.size = nu;
 72e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 732:	0541                	addi	a0,a0,16
 734:	00000097          	auipc	ra,0x0
 738:	ec4080e7          	jalr	-316(ra) # 5f8 <free>
  return freep;
 73c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 740:	d971                	beqz	a0,714 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 742:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 744:	4798                	lw	a4,8(a5)
 746:	fa9775e3          	bgeu	a4,s1,6f0 <malloc+0x70>
    if(p == freep)
 74a:	00093703          	ld	a4,0(s2)
 74e:	853e                	mv	a0,a5
 750:	fef719e3          	bne	a4,a5,742 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 754:	8552                	mv	a0,s4
 756:	00000097          	auipc	ra,0x0
 75a:	b7c080e7          	jalr	-1156(ra) # 2d2 <sbrk>
  if(p == (char*)-1)
 75e:	fd5518e3          	bne	a0,s5,72e <malloc+0xae>
        return 0;
 762:	4501                	li	a0,0
 764:	bf45                	j	714 <malloc+0x94>
