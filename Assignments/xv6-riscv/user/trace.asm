
user/_trace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	712d                	addi	sp,sp,-288
   2:	ee06                	sd	ra,280(sp)
   4:	ea22                	sd	s0,272(sp)
   6:	e626                	sd	s1,264(sp)
   8:	e24a                	sd	s2,256(sp)
   a:	1200                	addi	s0,sp,288
   c:	892e                	mv	s2,a1
  int i;
  char *nargv[MAXARG];

  if(argc < 3 || (argv[1][0] < '0' || argv[1][0] > '9')){
   e:	4789                	li	a5,2
  10:	00a7dd63          	bge	a5,a0,2a <main+0x2a>
  14:	84aa                	mv	s1,a0
  16:	6588                	ld	a0,8(a1)
  18:	00054783          	lbu	a5,0(a0)
  1c:	fd07879b          	addiw	a5,a5,-48
  20:	0ff7f793          	andi	a5,a5,255
  24:	4725                	li	a4,9
  26:	02f77263          	bgeu	a4,a5,4a <main+0x4a>
    fprintf(2, "Usage: %s mask command\n", argv[0]);
  2a:	00093603          	ld	a2,0(s2)
  2e:	00000597          	auipc	a1,0x0
  32:	7c258593          	addi	a1,a1,1986 # 7f0 <malloc+0xec>
  36:	4509                	li	a0,2
  38:	00000097          	auipc	ra,0x0
  3c:	5e0080e7          	jalr	1504(ra) # 618 <fprintf>
    exit(1);
  40:	4505                	li	a0,1
  42:	00000097          	auipc	ra,0x0
  46:	28c080e7          	jalr	652(ra) # 2ce <exit>
  }

  if (trace(atoi(argv[1])) < 0) {
  4a:	00000097          	auipc	ra,0x0
  4e:	1e8080e7          	jalr	488(ra) # 232 <atoi>
  52:	00000097          	auipc	ra,0x0
  56:	254080e7          	jalr	596(ra) # 2a6 <trace>
  5a:	04054363          	bltz	a0,a0 <main+0xa0>
  5e:	01090793          	addi	a5,s2,16
  62:	ee040713          	addi	a4,s0,-288
  66:	34f5                	addiw	s1,s1,-3
  68:	02049693          	slli	a3,s1,0x20
  6c:	01d6d493          	srli	s1,a3,0x1d
  70:	94be                	add	s1,s1,a5
  72:	10090593          	addi	a1,s2,256
    fprintf(2, "%s: trace failed\n", argv[0]);
    exit(1);
  }
  
  for(i = 2; i < argc && i < MAXARG; i++){
    nargv[i-2] = argv[i];
  76:	6394                	ld	a3,0(a5)
  78:	e314                	sd	a3,0(a4)
  for(i = 2; i < argc && i < MAXARG; i++){
  7a:	00978663          	beq	a5,s1,86 <main+0x86>
  7e:	07a1                	addi	a5,a5,8
  80:	0721                	addi	a4,a4,8
  82:	feb79ae3          	bne	a5,a1,76 <main+0x76>
  }
  exec(nargv[0], nargv);
  86:	ee040593          	addi	a1,s0,-288
  8a:	ee043503          	ld	a0,-288(s0)
  8e:	00000097          	auipc	ra,0x0
  92:	278080e7          	jalr	632(ra) # 306 <exec>
  exit(0);
  96:	4501                	li	a0,0
  98:	00000097          	auipc	ra,0x0
  9c:	236080e7          	jalr	566(ra) # 2ce <exit>
    fprintf(2, "%s: trace failed\n", argv[0]);
  a0:	00093603          	ld	a2,0(s2)
  a4:	00000597          	auipc	a1,0x0
  a8:	76458593          	addi	a1,a1,1892 # 808 <malloc+0x104>
  ac:	4509                	li	a0,2
  ae:	00000097          	auipc	ra,0x0
  b2:	56a080e7          	jalr	1386(ra) # 618 <fprintf>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	216080e7          	jalr	534(ra) # 2ce <exit>

00000000000000c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c6:	87aa                	mv	a5,a0
  c8:	0585                	addi	a1,a1,1
  ca:	0785                	addi	a5,a5,1
  cc:	fff5c703          	lbu	a4,-1(a1)
  d0:	fee78fa3          	sb	a4,-1(a5)
  d4:	fb75                	bnez	a4,c8 <strcpy+0x8>
    ;
  return os;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb91                	beqz	a5,fa <strcmp+0x1e>
  e8:	0005c703          	lbu	a4,0(a1)
  ec:	00f71763          	bne	a4,a5,fa <strcmp+0x1e>
    p++, q++;
  f0:	0505                	addi	a0,a0,1
  f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbe5                	bnez	a5,e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fa:	0005c503          	lbu	a0,0(a1)
}
  fe:	40a7853b          	subw	a0,a5,a0
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strlen>:

uint
strlen(const char *s)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cf91                	beqz	a5,12e <strlen+0x26>
 114:	0505                	addi	a0,a0,1
 116:	87aa                	mv	a5,a0
 118:	4685                	li	a3,1
 11a:	9e89                	subw	a3,a3,a0
 11c:	00f6853b          	addw	a0,a3,a5
 120:	0785                	addi	a5,a5,1
 122:	fff7c703          	lbu	a4,-1(a5)
 126:	fb7d                	bnez	a4,11c <strlen+0x14>
    ;
  return n;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  for(n = 0; s[n]; n++)
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strlen+0x20>

0000000000000132 <memset>:

void*
memset(void *dst, int c, uint n)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 138:	ca19                	beqz	a2,14e <memset+0x1c>
 13a:	87aa                	mv	a5,a0
 13c:	1602                	slli	a2,a2,0x20
 13e:	9201                	srli	a2,a2,0x20
 140:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 144:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 148:	0785                	addi	a5,a5,1
 14a:	fee79de3          	bne	a5,a4,144 <memset+0x12>
  }
  return dst;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strchr>:

char*
strchr(const char *s, char c)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  for(; *s; s++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb99                	beqz	a5,174 <strchr+0x20>
    if(*s == c)
 160:	00f58763          	beq	a1,a5,16e <strchr+0x1a>
  for(; *s; s++)
 164:	0505                	addi	a0,a0,1
 166:	00054783          	lbu	a5,0(a0)
 16a:	fbfd                	bnez	a5,160 <strchr+0xc>
      return (char*)s;
  return 0;
 16c:	4501                	li	a0,0
}
 16e:	6422                	ld	s0,8(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret
  return 0;
 174:	4501                	li	a0,0
 176:	bfe5                	j	16e <strchr+0x1a>

0000000000000178 <gets>:

char*
gets(char *buf, int max)
{
 178:	711d                	addi	sp,sp,-96
 17a:	ec86                	sd	ra,88(sp)
 17c:	e8a2                	sd	s0,80(sp)
 17e:	e4a6                	sd	s1,72(sp)
 180:	e0ca                	sd	s2,64(sp)
 182:	fc4e                	sd	s3,56(sp)
 184:	f852                	sd	s4,48(sp)
 186:	f456                	sd	s5,40(sp)
 188:	f05a                	sd	s6,32(sp)
 18a:	ec5e                	sd	s7,24(sp)
 18c:	1080                	addi	s0,sp,96
 18e:	8baa                	mv	s7,a0
 190:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 192:	892a                	mv	s2,a0
 194:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 196:	4aa9                	li	s5,10
 198:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19a:	89a6                	mv	s3,s1
 19c:	2485                	addiw	s1,s1,1
 19e:	0344d863          	bge	s1,s4,1ce <gets+0x56>
    cc = read(0, &c, 1);
 1a2:	4605                	li	a2,1
 1a4:	faf40593          	addi	a1,s0,-81
 1a8:	4501                	li	a0,0
 1aa:	00000097          	auipc	ra,0x0
 1ae:	13c080e7          	jalr	316(ra) # 2e6 <read>
    if(cc < 1)
 1b2:	00a05e63          	blez	a0,1ce <gets+0x56>
    buf[i++] = c;
 1b6:	faf44783          	lbu	a5,-81(s0)
 1ba:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1be:	01578763          	beq	a5,s5,1cc <gets+0x54>
 1c2:	0905                	addi	s2,s2,1
 1c4:	fd679be3          	bne	a5,s6,19a <gets+0x22>
  for(i=0; i+1 < max; ){
 1c8:	89a6                	mv	s3,s1
 1ca:	a011                	j	1ce <gets+0x56>
 1cc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ce:	99de                	add	s3,s3,s7
 1d0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d4:	855e                	mv	a0,s7
 1d6:	60e6                	ld	ra,88(sp)
 1d8:	6446                	ld	s0,80(sp)
 1da:	64a6                	ld	s1,72(sp)
 1dc:	6906                	ld	s2,64(sp)
 1de:	79e2                	ld	s3,56(sp)
 1e0:	7a42                	ld	s4,48(sp)
 1e2:	7aa2                	ld	s5,40(sp)
 1e4:	7b02                	ld	s6,32(sp)
 1e6:	6be2                	ld	s7,24(sp)
 1e8:	6125                	addi	sp,sp,96
 1ea:	8082                	ret

00000000000001ec <stat>:

int
stat(const char *n, struct stat *st)
{
 1ec:	1101                	addi	sp,sp,-32
 1ee:	ec06                	sd	ra,24(sp)
 1f0:	e822                	sd	s0,16(sp)
 1f2:	e426                	sd	s1,8(sp)
 1f4:	e04a                	sd	s2,0(sp)
 1f6:	1000                	addi	s0,sp,32
 1f8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fa:	4581                	li	a1,0
 1fc:	00000097          	auipc	ra,0x0
 200:	112080e7          	jalr	274(ra) # 30e <open>
  if(fd < 0)
 204:	02054563          	bltz	a0,22e <stat+0x42>
 208:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20a:	85ca                	mv	a1,s2
 20c:	00000097          	auipc	ra,0x0
 210:	11a080e7          	jalr	282(ra) # 326 <fstat>
 214:	892a                	mv	s2,a0
  close(fd);
 216:	8526                	mv	a0,s1
 218:	00000097          	auipc	ra,0x0
 21c:	0de080e7          	jalr	222(ra) # 2f6 <close>
  return r;
}
 220:	854a                	mv	a0,s2
 222:	60e2                	ld	ra,24(sp)
 224:	6442                	ld	s0,16(sp)
 226:	64a2                	ld	s1,8(sp)
 228:	6902                	ld	s2,0(sp)
 22a:	6105                	addi	sp,sp,32
 22c:	8082                	ret
    return -1;
 22e:	597d                	li	s2,-1
 230:	bfc5                	j	220 <stat+0x34>

0000000000000232 <atoi>:

int
atoi(const char *s)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 238:	00054603          	lbu	a2,0(a0)
 23c:	fd06079b          	addiw	a5,a2,-48
 240:	0ff7f793          	andi	a5,a5,255
 244:	4725                	li	a4,9
 246:	02f76963          	bltu	a4,a5,278 <atoi+0x46>
 24a:	86aa                	mv	a3,a0
  n = 0;
 24c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 24e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 250:	0685                	addi	a3,a3,1
 252:	0025179b          	slliw	a5,a0,0x2
 256:	9fa9                	addw	a5,a5,a0
 258:	0017979b          	slliw	a5,a5,0x1
 25c:	9fb1                	addw	a5,a5,a2
 25e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 262:	0006c603          	lbu	a2,0(a3)
 266:	fd06071b          	addiw	a4,a2,-48
 26a:	0ff77713          	andi	a4,a4,255
 26e:	fee5f1e3          	bgeu	a1,a4,250 <atoi+0x1e>
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  n = 0;
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <atoi+0x40>

000000000000027c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 282:	00c05f63          	blez	a2,2a0 <memmove+0x24>
 286:	1602                	slli	a2,a2,0x20
 288:	9201                	srli	a2,a2,0x20
 28a:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 28e:	87aa                	mv	a5,a0
    *dst++ = *src++;
 290:	0585                	addi	a1,a1,1
 292:	0785                	addi	a5,a5,1
 294:	fff5c703          	lbu	a4,-1(a1)
 298:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 29c:	fed79ae3          	bne	a5,a3,290 <memmove+0x14>
  return vdst;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <trace>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global trace
trace:
 li a7, SYS_trace
 2a6:	48e5                	li	a7,25
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <get_process_info>:
.global get_process_info
get_process_info:
 li a7, SYS_get_process_info
 2ae:	48e1                	li	a7,24
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <echo_kernel>:
.global echo_kernel
echo_kernel:
 li a7, SYS_echo_kernel
 2b6:	48dd                	li	a7,23
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <echo_simple>:
.global echo_simple
echo_simple:
 li a7, SYS_echo_simple
 2be:	48d9                	li	a7,22
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <fork>:
.global fork
fork:
 li a7, SYS_fork
 2c6:	4885                	li	a7,1
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ce:	4889                	li	a7,2
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d6:	488d                	li	a7,3
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2de:	4891                	li	a7,4
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <read>:
.global read
read:
 li a7, SYS_read
 2e6:	4895                	li	a7,5
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <write>:
.global write
write:
 li a7, SYS_write
 2ee:	48c1                	li	a7,16
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <close>:
.global close
close:
 li a7, SYS_close
 2f6:	48d5                	li	a7,21
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 2fe:	4899                	li	a7,6
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <exec>:
.global exec
exec:
 li a7, SYS_exec
 306:	489d                	li	a7,7
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <open>:
.global open
open:
 li a7, SYS_open
 30e:	48bd                	li	a7,15
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 316:	48c5                	li	a7,17
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 31e:	48c9                	li	a7,18
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 326:	48a1                	li	a7,8
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <link>:
.global link
link:
 li a7, SYS_link
 32e:	48cd                	li	a7,19
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 336:	48d1                	li	a7,20
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 33e:	48a5                	li	a7,9
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <dup>:
.global dup
dup:
 li a7, SYS_dup
 346:	48a9                	li	a7,10
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 34e:	48ad                	li	a7,11
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 356:	48b1                	li	a7,12
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 35e:	48b5                	li	a7,13
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 366:	48b9                	li	a7,14
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 36e:	1101                	addi	sp,sp,-32
 370:	ec06                	sd	ra,24(sp)
 372:	e822                	sd	s0,16(sp)
 374:	1000                	addi	s0,sp,32
 376:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 37a:	4605                	li	a2,1
 37c:	fef40593          	addi	a1,s0,-17
 380:	00000097          	auipc	ra,0x0
 384:	f6e080e7          	jalr	-146(ra) # 2ee <write>
}
 388:	60e2                	ld	ra,24(sp)
 38a:	6442                	ld	s0,16(sp)
 38c:	6105                	addi	sp,sp,32
 38e:	8082                	ret

0000000000000390 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 390:	7139                	addi	sp,sp,-64
 392:	fc06                	sd	ra,56(sp)
 394:	f822                	sd	s0,48(sp)
 396:	f426                	sd	s1,40(sp)
 398:	f04a                	sd	s2,32(sp)
 39a:	ec4e                	sd	s3,24(sp)
 39c:	0080                	addi	s0,sp,64
 39e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a0:	c299                	beqz	a3,3a6 <printint+0x16>
 3a2:	0805c863          	bltz	a1,432 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a6:	2581                	sext.w	a1,a1
  neg = 0;
 3a8:	4881                	li	a7,0
 3aa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3b0:	2601                	sext.w	a2,a2
 3b2:	00000517          	auipc	a0,0x0
 3b6:	47650513          	addi	a0,a0,1142 # 828 <digits>
 3ba:	883a                	mv	a6,a4
 3bc:	2705                	addiw	a4,a4,1
 3be:	02c5f7bb          	remuw	a5,a1,a2
 3c2:	1782                	slli	a5,a5,0x20
 3c4:	9381                	srli	a5,a5,0x20
 3c6:	97aa                	add	a5,a5,a0
 3c8:	0007c783          	lbu	a5,0(a5)
 3cc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3d0:	0005879b          	sext.w	a5,a1
 3d4:	02c5d5bb          	divuw	a1,a1,a2
 3d8:	0685                	addi	a3,a3,1
 3da:	fec7f0e3          	bgeu	a5,a2,3ba <printint+0x2a>
  if(neg)
 3de:	00088b63          	beqz	a7,3f4 <printint+0x64>
    buf[i++] = '-';
 3e2:	fd040793          	addi	a5,s0,-48
 3e6:	973e                	add	a4,a4,a5
 3e8:	02d00793          	li	a5,45
 3ec:	fef70823          	sb	a5,-16(a4)
 3f0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f4:	02e05863          	blez	a4,424 <printint+0x94>
 3f8:	fc040793          	addi	a5,s0,-64
 3fc:	00e78933          	add	s2,a5,a4
 400:	fff78993          	addi	s3,a5,-1
 404:	99ba                	add	s3,s3,a4
 406:	377d                	addiw	a4,a4,-1
 408:	1702                	slli	a4,a4,0x20
 40a:	9301                	srli	a4,a4,0x20
 40c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 410:	fff94583          	lbu	a1,-1(s2)
 414:	8526                	mv	a0,s1
 416:	00000097          	auipc	ra,0x0
 41a:	f58080e7          	jalr	-168(ra) # 36e <putc>
  while(--i >= 0)
 41e:	197d                	addi	s2,s2,-1
 420:	ff3918e3          	bne	s2,s3,410 <printint+0x80>
}
 424:	70e2                	ld	ra,56(sp)
 426:	7442                	ld	s0,48(sp)
 428:	74a2                	ld	s1,40(sp)
 42a:	7902                	ld	s2,32(sp)
 42c:	69e2                	ld	s3,24(sp)
 42e:	6121                	addi	sp,sp,64
 430:	8082                	ret
    x = -xx;
 432:	40b005bb          	negw	a1,a1
    neg = 1;
 436:	4885                	li	a7,1
    x = -xx;
 438:	bf8d                	j	3aa <printint+0x1a>

000000000000043a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43a:	7119                	addi	sp,sp,-128
 43c:	fc86                	sd	ra,120(sp)
 43e:	f8a2                	sd	s0,112(sp)
 440:	f4a6                	sd	s1,104(sp)
 442:	f0ca                	sd	s2,96(sp)
 444:	ecce                	sd	s3,88(sp)
 446:	e8d2                	sd	s4,80(sp)
 448:	e4d6                	sd	s5,72(sp)
 44a:	e0da                	sd	s6,64(sp)
 44c:	fc5e                	sd	s7,56(sp)
 44e:	f862                	sd	s8,48(sp)
 450:	f466                	sd	s9,40(sp)
 452:	f06a                	sd	s10,32(sp)
 454:	ec6e                	sd	s11,24(sp)
 456:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 458:	0005c903          	lbu	s2,0(a1)
 45c:	18090f63          	beqz	s2,5fa <vprintf+0x1c0>
 460:	8aaa                	mv	s5,a0
 462:	8b32                	mv	s6,a2
 464:	00158493          	addi	s1,a1,1
  state = 0;
 468:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 46a:	02500a13          	li	s4,37
      if(c == 'd'){
 46e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 472:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 476:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 47a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 47e:	00000b97          	auipc	s7,0x0
 482:	3aab8b93          	addi	s7,s7,938 # 828 <digits>
 486:	a839                	j	4a4 <vprintf+0x6a>
        putc(fd, c);
 488:	85ca                	mv	a1,s2
 48a:	8556                	mv	a0,s5
 48c:	00000097          	auipc	ra,0x0
 490:	ee2080e7          	jalr	-286(ra) # 36e <putc>
 494:	a019                	j	49a <vprintf+0x60>
    } else if(state == '%'){
 496:	01498f63          	beq	s3,s4,4b4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 49a:	0485                	addi	s1,s1,1
 49c:	fff4c903          	lbu	s2,-1(s1)
 4a0:	14090d63          	beqz	s2,5fa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a8:	fe0997e3          	bnez	s3,496 <vprintf+0x5c>
      if(c == '%'){
 4ac:	fd479ee3          	bne	a5,s4,488 <vprintf+0x4e>
        state = '%';
 4b0:	89be                	mv	s3,a5
 4b2:	b7e5                	j	49a <vprintf+0x60>
      if(c == 'd'){
 4b4:	05878063          	beq	a5,s8,4f4 <vprintf+0xba>
      } else if(c == 'l') {
 4b8:	05978c63          	beq	a5,s9,510 <vprintf+0xd6>
      } else if(c == 'x') {
 4bc:	07a78863          	beq	a5,s10,52c <vprintf+0xf2>
      } else if(c == 'p') {
 4c0:	09b78463          	beq	a5,s11,548 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4c4:	07300713          	li	a4,115
 4c8:	0ce78663          	beq	a5,a4,594 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4cc:	06300713          	li	a4,99
 4d0:	0ee78e63          	beq	a5,a4,5cc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4d4:	11478863          	beq	a5,s4,5e4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4d8:	85d2                	mv	a1,s4
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	e92080e7          	jalr	-366(ra) # 36e <putc>
        putc(fd, c);
 4e4:	85ca                	mv	a1,s2
 4e6:	8556                	mv	a0,s5
 4e8:	00000097          	auipc	ra,0x0
 4ec:	e86080e7          	jalr	-378(ra) # 36e <putc>
      }
      state = 0;
 4f0:	4981                	li	s3,0
 4f2:	b765                	j	49a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4f4:	008b0913          	addi	s2,s6,8
 4f8:	4685                	li	a3,1
 4fa:	4629                	li	a2,10
 4fc:	000b2583          	lw	a1,0(s6)
 500:	8556                	mv	a0,s5
 502:	00000097          	auipc	ra,0x0
 506:	e8e080e7          	jalr	-370(ra) # 390 <printint>
 50a:	8b4a                	mv	s6,s2
      state = 0;
 50c:	4981                	li	s3,0
 50e:	b771                	j	49a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 510:	008b0913          	addi	s2,s6,8
 514:	4681                	li	a3,0
 516:	4629                	li	a2,10
 518:	000b2583          	lw	a1,0(s6)
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	e72080e7          	jalr	-398(ra) # 390 <printint>
 526:	8b4a                	mv	s6,s2
      state = 0;
 528:	4981                	li	s3,0
 52a:	bf85                	j	49a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 52c:	008b0913          	addi	s2,s6,8
 530:	4681                	li	a3,0
 532:	4641                	li	a2,16
 534:	000b2583          	lw	a1,0(s6)
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	e56080e7          	jalr	-426(ra) # 390 <printint>
 542:	8b4a                	mv	s6,s2
      state = 0;
 544:	4981                	li	s3,0
 546:	bf91                	j	49a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 548:	008b0793          	addi	a5,s6,8
 54c:	f8f43423          	sd	a5,-120(s0)
 550:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 554:	03000593          	li	a1,48
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e14080e7          	jalr	-492(ra) # 36e <putc>
  putc(fd, 'x');
 562:	85ea                	mv	a1,s10
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	e08080e7          	jalr	-504(ra) # 36e <putc>
 56e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 570:	03c9d793          	srli	a5,s3,0x3c
 574:	97de                	add	a5,a5,s7
 576:	0007c583          	lbu	a1,0(a5)
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	df2080e7          	jalr	-526(ra) # 36e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 584:	0992                	slli	s3,s3,0x4
 586:	397d                	addiw	s2,s2,-1
 588:	fe0914e3          	bnez	s2,570 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 58c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 590:	4981                	li	s3,0
 592:	b721                	j	49a <vprintf+0x60>
        s = va_arg(ap, char*);
 594:	008b0993          	addi	s3,s6,8
 598:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 59c:	02090163          	beqz	s2,5be <vprintf+0x184>
        while(*s != 0){
 5a0:	00094583          	lbu	a1,0(s2)
 5a4:	c9a1                	beqz	a1,5f4 <vprintf+0x1ba>
          putc(fd, *s);
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	dc6080e7          	jalr	-570(ra) # 36e <putc>
          s++;
 5b0:	0905                	addi	s2,s2,1
        while(*s != 0){
 5b2:	00094583          	lbu	a1,0(s2)
 5b6:	f9e5                	bnez	a1,5a6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5b8:	8b4e                	mv	s6,s3
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	bdf9                	j	49a <vprintf+0x60>
          s = "(null)";
 5be:	00000917          	auipc	s2,0x0
 5c2:	26290913          	addi	s2,s2,610 # 820 <malloc+0x11c>
        while(*s != 0){
 5c6:	02800593          	li	a1,40
 5ca:	bff1                	j	5a6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5cc:	008b0913          	addi	s2,s6,8
 5d0:	000b4583          	lbu	a1,0(s6)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	d98080e7          	jalr	-616(ra) # 36e <putc>
 5de:	8b4a                	mv	s6,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bd65                	j	49a <vprintf+0x60>
        putc(fd, c);
 5e4:	85d2                	mv	a1,s4
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	d86080e7          	jalr	-634(ra) # 36e <putc>
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b565                	j	49a <vprintf+0x60>
        s = va_arg(ap, char*);
 5f4:	8b4e                	mv	s6,s3
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b54d                	j	49a <vprintf+0x60>
    }
  }
}
 5fa:	70e6                	ld	ra,120(sp)
 5fc:	7446                	ld	s0,112(sp)
 5fe:	74a6                	ld	s1,104(sp)
 600:	7906                	ld	s2,96(sp)
 602:	69e6                	ld	s3,88(sp)
 604:	6a46                	ld	s4,80(sp)
 606:	6aa6                	ld	s5,72(sp)
 608:	6b06                	ld	s6,64(sp)
 60a:	7be2                	ld	s7,56(sp)
 60c:	7c42                	ld	s8,48(sp)
 60e:	7ca2                	ld	s9,40(sp)
 610:	7d02                	ld	s10,32(sp)
 612:	6de2                	ld	s11,24(sp)
 614:	6109                	addi	sp,sp,128
 616:	8082                	ret

0000000000000618 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 618:	715d                	addi	sp,sp,-80
 61a:	ec06                	sd	ra,24(sp)
 61c:	e822                	sd	s0,16(sp)
 61e:	1000                	addi	s0,sp,32
 620:	e010                	sd	a2,0(s0)
 622:	e414                	sd	a3,8(s0)
 624:	e818                	sd	a4,16(s0)
 626:	ec1c                	sd	a5,24(s0)
 628:	03043023          	sd	a6,32(s0)
 62c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 630:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 634:	8622                	mv	a2,s0
 636:	00000097          	auipc	ra,0x0
 63a:	e04080e7          	jalr	-508(ra) # 43a <vprintf>
}
 63e:	60e2                	ld	ra,24(sp)
 640:	6442                	ld	s0,16(sp)
 642:	6161                	addi	sp,sp,80
 644:	8082                	ret

0000000000000646 <printf>:

void
printf(const char *fmt, ...)
{
 646:	711d                	addi	sp,sp,-96
 648:	ec06                	sd	ra,24(sp)
 64a:	e822                	sd	s0,16(sp)
 64c:	1000                	addi	s0,sp,32
 64e:	e40c                	sd	a1,8(s0)
 650:	e810                	sd	a2,16(s0)
 652:	ec14                	sd	a3,24(s0)
 654:	f018                	sd	a4,32(s0)
 656:	f41c                	sd	a5,40(s0)
 658:	03043823          	sd	a6,48(s0)
 65c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 660:	00840613          	addi	a2,s0,8
 664:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 668:	85aa                	mv	a1,a0
 66a:	4505                	li	a0,1
 66c:	00000097          	auipc	ra,0x0
 670:	dce080e7          	jalr	-562(ra) # 43a <vprintf>
}
 674:	60e2                	ld	ra,24(sp)
 676:	6442                	ld	s0,16(sp)
 678:	6125                	addi	sp,sp,96
 67a:	8082                	ret

000000000000067c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67c:	1141                	addi	sp,sp,-16
 67e:	e422                	sd	s0,8(sp)
 680:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 682:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 686:	00000797          	auipc	a5,0x0
 68a:	1ba7b783          	ld	a5,442(a5) # 840 <freep>
 68e:	a805                	j	6be <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 690:	4618                	lw	a4,8(a2)
 692:	9db9                	addw	a1,a1,a4
 694:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 698:	6398                	ld	a4,0(a5)
 69a:	6318                	ld	a4,0(a4)
 69c:	fee53823          	sd	a4,-16(a0)
 6a0:	a091                	j	6e4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a2:	ff852703          	lw	a4,-8(a0)
 6a6:	9e39                	addw	a2,a2,a4
 6a8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6aa:	ff053703          	ld	a4,-16(a0)
 6ae:	e398                	sd	a4,0(a5)
 6b0:	a099                	j	6f6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b2:	6398                	ld	a4,0(a5)
 6b4:	00e7e463          	bltu	a5,a4,6bc <free+0x40>
 6b8:	00e6ea63          	bltu	a3,a4,6cc <free+0x50>
{
 6bc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6be:	fed7fae3          	bgeu	a5,a3,6b2 <free+0x36>
 6c2:	6398                	ld	a4,0(a5)
 6c4:	00e6e463          	bltu	a3,a4,6cc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c8:	fee7eae3          	bltu	a5,a4,6bc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6cc:	ff852583          	lw	a1,-8(a0)
 6d0:	6390                	ld	a2,0(a5)
 6d2:	02059813          	slli	a6,a1,0x20
 6d6:	01c85713          	srli	a4,a6,0x1c
 6da:	9736                	add	a4,a4,a3
 6dc:	fae60ae3          	beq	a2,a4,690 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6e0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e4:	4790                	lw	a2,8(a5)
 6e6:	02061593          	slli	a1,a2,0x20
 6ea:	01c5d713          	srli	a4,a1,0x1c
 6ee:	973e                	add	a4,a4,a5
 6f0:	fae689e3          	beq	a3,a4,6a2 <free+0x26>
  } else
    p->s.ptr = bp;
 6f4:	e394                	sd	a3,0(a5)
  freep = p;
 6f6:	00000717          	auipc	a4,0x0
 6fa:	14f73523          	sd	a5,330(a4) # 840 <freep>
}
 6fe:	6422                	ld	s0,8(sp)
 700:	0141                	addi	sp,sp,16
 702:	8082                	ret

0000000000000704 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 704:	7139                	addi	sp,sp,-64
 706:	fc06                	sd	ra,56(sp)
 708:	f822                	sd	s0,48(sp)
 70a:	f426                	sd	s1,40(sp)
 70c:	f04a                	sd	s2,32(sp)
 70e:	ec4e                	sd	s3,24(sp)
 710:	e852                	sd	s4,16(sp)
 712:	e456                	sd	s5,8(sp)
 714:	e05a                	sd	s6,0(sp)
 716:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 718:	02051493          	slli	s1,a0,0x20
 71c:	9081                	srli	s1,s1,0x20
 71e:	04bd                	addi	s1,s1,15
 720:	8091                	srli	s1,s1,0x4
 722:	0014899b          	addiw	s3,s1,1
 726:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 728:	00000517          	auipc	a0,0x0
 72c:	11853503          	ld	a0,280(a0) # 840 <freep>
 730:	c515                	beqz	a0,75c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 732:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 734:	4798                	lw	a4,8(a5)
 736:	02977f63          	bgeu	a4,s1,774 <malloc+0x70>
 73a:	8a4e                	mv	s4,s3
 73c:	0009871b          	sext.w	a4,s3
 740:	6685                	lui	a3,0x1
 742:	00d77363          	bgeu	a4,a3,748 <malloc+0x44>
 746:	6a05                	lui	s4,0x1
 748:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 74c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 750:	00000917          	auipc	s2,0x0
 754:	0f090913          	addi	s2,s2,240 # 840 <freep>
  if(p == (char*)-1)
 758:	5afd                	li	s5,-1
 75a:	a895                	j	7ce <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 75c:	00000797          	auipc	a5,0x0
 760:	0ec78793          	addi	a5,a5,236 # 848 <base>
 764:	00000717          	auipc	a4,0x0
 768:	0cf73e23          	sd	a5,220(a4) # 840 <freep>
 76c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 76e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 772:	b7e1                	j	73a <malloc+0x36>
      if(p->s.size == nunits)
 774:	02e48c63          	beq	s1,a4,7ac <malloc+0xa8>
        p->s.size -= nunits;
 778:	4137073b          	subw	a4,a4,s3
 77c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 77e:	02071693          	slli	a3,a4,0x20
 782:	01c6d713          	srli	a4,a3,0x1c
 786:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 788:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 78c:	00000717          	auipc	a4,0x0
 790:	0aa73a23          	sd	a0,180(a4) # 840 <freep>
      return (void*)(p + 1);
 794:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 798:	70e2                	ld	ra,56(sp)
 79a:	7442                	ld	s0,48(sp)
 79c:	74a2                	ld	s1,40(sp)
 79e:	7902                	ld	s2,32(sp)
 7a0:	69e2                	ld	s3,24(sp)
 7a2:	6a42                	ld	s4,16(sp)
 7a4:	6aa2                	ld	s5,8(sp)
 7a6:	6b02                	ld	s6,0(sp)
 7a8:	6121                	addi	sp,sp,64
 7aa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ac:	6398                	ld	a4,0(a5)
 7ae:	e118                	sd	a4,0(a0)
 7b0:	bff1                	j	78c <malloc+0x88>
  hp->s.size = nu;
 7b2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b6:	0541                	addi	a0,a0,16
 7b8:	00000097          	auipc	ra,0x0
 7bc:	ec4080e7          	jalr	-316(ra) # 67c <free>
  return freep;
 7c0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c4:	d971                	beqz	a0,798 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c8:	4798                	lw	a4,8(a5)
 7ca:	fa9775e3          	bgeu	a4,s1,774 <malloc+0x70>
    if(p == freep)
 7ce:	00093703          	ld	a4,0(s2)
 7d2:	853e                	mv	a0,a5
 7d4:	fef719e3          	bne	a4,a5,7c6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7d8:	8552                	mv	a0,s4
 7da:	00000097          	auipc	ra,0x0
 7de:	b7c080e7          	jalr	-1156(ra) # 356 <sbrk>
  if(p == (char*)-1)
 7e2:	fd5518e3          	bne	a0,s5,7b2 <malloc+0xae>
        return 0;
 7e6:	4501                	li	a0,0
 7e8:	bf45                	j	798 <malloc+0x94>
