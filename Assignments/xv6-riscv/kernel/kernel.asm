
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	80010113          	addi	sp,sp,-2048 # 80009800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fb660613          	addi	a2,a2,-74 # 80009000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	06478793          	addi	a5,a5,100 # 800060c0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87e3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	c6278793          	addi	a5,a5,-926 # 80000d08 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  timerinit();
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	f58080e7          	jalr	-168(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000cc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000d0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000d2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000d4:	30200073          	mret
}
    800000d8:	60a2                	ld	ra,8(sp)
    800000da:	6402                	ld	s0,0(sp)
    800000dc:	0141                	addi	sp,sp,16
    800000de:	8082                	ret

00000000800000e0 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800000e0:	7159                	addi	sp,sp,-112
    800000e2:	f486                	sd	ra,104(sp)
    800000e4:	f0a2                	sd	s0,96(sp)
    800000e6:	eca6                	sd	s1,88(sp)
    800000e8:	e8ca                	sd	s2,80(sp)
    800000ea:	e4ce                	sd	s3,72(sp)
    800000ec:	e0d2                	sd	s4,64(sp)
    800000ee:	fc56                	sd	s5,56(sp)
    800000f0:	f85a                	sd	s6,48(sp)
    800000f2:	f45e                	sd	s7,40(sp)
    800000f4:	f062                	sd	s8,32(sp)
    800000f6:	ec66                	sd	s9,24(sp)
    800000f8:	e86a                	sd	s10,16(sp)
    800000fa:	1880                	addi	s0,sp,112
    800000fc:	8aaa                	mv	s5,a0
    800000fe:	8a2e                	mv	s4,a1
    80000100:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000102:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000106:	00011517          	auipc	a0,0x11
    8000010a:	6fa50513          	addi	a0,a0,1786 # 80011800 <cons>
    8000010e:	00001097          	auipc	ra,0x1
    80000112:	9b0080e7          	jalr	-1616(ra) # 80000abe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000116:	00011497          	auipc	s1,0x11
    8000011a:	6ea48493          	addi	s1,s1,1770 # 80011800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000011e:	00011917          	auipc	s2,0x11
    80000122:	77a90913          	addi	s2,s2,1914 # 80011898 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000126:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000128:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000012a:	4ca9                	li	s9,10
  while(n > 0){
    8000012c:	07305863          	blez	s3,8000019c <consoleread+0xbc>
    while(cons.r == cons.w){
    80000130:	0984a783          	lw	a5,152(s1)
    80000134:	09c4a703          	lw	a4,156(s1)
    80000138:	02f71463          	bne	a4,a5,80000160 <consoleread+0x80>
      if(myproc()->killed){
    8000013c:	00001097          	auipc	ra,0x1
    80000140:	6f2080e7          	jalr	1778(ra) # 8000182e <myproc>
    80000144:	591c                	lw	a5,48(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	e8c080e7          	jalr	-372(ra) # 80001fd8 <sleep>
    while(cons.r == cons.w){
    80000154:	0984a783          	lw	a5,152(s1)
    80000158:	09c4a703          	lw	a4,156(s1)
    8000015c:	fef700e3          	beq	a4,a5,8000013c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000160:	0017871b          	addiw	a4,a5,1
    80000164:	08e4ac23          	sw	a4,152(s1)
    80000168:	07f7f713          	andi	a4,a5,127
    8000016c:	9726                	add	a4,a4,s1
    8000016e:	01874703          	lbu	a4,24(a4)
    80000172:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000176:	077d0563          	beq	s10,s7,800001e0 <consoleread+0x100>
    cbuf = c;
    8000017a:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000017e:	4685                	li	a3,1
    80000180:	f9f40613          	addi	a2,s0,-97
    80000184:	85d2                	mv	a1,s4
    80000186:	8556                	mv	a0,s5
    80000188:	00002097          	auipc	ra,0x2
    8000018c:	0aa080e7          	jalr	170(ra) # 80002232 <either_copyout>
    80000190:	01850663          	beq	a0,s8,8000019c <consoleread+0xbc>
    dst++;
    80000194:	0a05                	addi	s4,s4,1
    --n;
    80000196:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000198:	f99d1ae3          	bne	s10,s9,8000012c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000019c:	00011517          	auipc	a0,0x11
    800001a0:	66450513          	addi	a0,a0,1636 # 80011800 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	96e080e7          	jalr	-1682(ra) # 80000b12 <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00011517          	auipc	a0,0x11
    800001b6:	64e50513          	addi	a0,a0,1614 # 80011800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	958080e7          	jalr	-1704(ra) # 80000b12 <release>
        return -1;
    800001c2:	557d                	li	a0,-1
}
    800001c4:	70a6                	ld	ra,104(sp)
    800001c6:	7406                	ld	s0,96(sp)
    800001c8:	64e6                	ld	s1,88(sp)
    800001ca:	6946                	ld	s2,80(sp)
    800001cc:	69a6                	ld	s3,72(sp)
    800001ce:	6a06                	ld	s4,64(sp)
    800001d0:	7ae2                	ld	s5,56(sp)
    800001d2:	7b42                	ld	s6,48(sp)
    800001d4:	7ba2                	ld	s7,40(sp)
    800001d6:	7c02                	ld	s8,32(sp)
    800001d8:	6ce2                	ld	s9,24(sp)
    800001da:	6d42                	ld	s10,16(sp)
    800001dc:	6165                	addi	sp,sp,112
    800001de:	8082                	ret
      if(n < target){
    800001e0:	0009871b          	sext.w	a4,s3
    800001e4:	fb677ce3          	bgeu	a4,s6,8000019c <consoleread+0xbc>
        cons.r--;
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	6af72823          	sw	a5,1712(a4) # 80011898 <cons+0x98>
    800001f0:	b775                	j	8000019c <consoleread+0xbc>

00000000800001f2 <consputc>:
  if(panicked){
    800001f2:	00026797          	auipc	a5,0x26
    800001f6:	e0e7a783          	lw	a5,-498(a5) # 80026000 <panicked>
    800001fa:	c391                	beqz	a5,800001fe <consputc+0xc>
    for(;;)
    800001fc:	a001                	j	800001fc <consputc+0xa>
{
    800001fe:	1141                	addi	sp,sp,-16
    80000200:	e406                	sd	ra,8(sp)
    80000202:	e022                	sd	s0,0(sp)
    80000204:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000206:	10000793          	li	a5,256
    8000020a:	00f50a63          	beq	a0,a5,8000021e <consputc+0x2c>
    uartputc(c);
    8000020e:	00000097          	auipc	ra,0x0
    80000212:	5cc080e7          	jalr	1484(ra) # 800007da <uartputc>
}
    80000216:	60a2                	ld	ra,8(sp)
    80000218:	6402                	ld	s0,0(sp)
    8000021a:	0141                	addi	sp,sp,16
    8000021c:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    8000021e:	4521                	li	a0,8
    80000220:	00000097          	auipc	ra,0x0
    80000224:	5ba080e7          	jalr	1466(ra) # 800007da <uartputc>
    80000228:	02000513          	li	a0,32
    8000022c:	00000097          	auipc	ra,0x0
    80000230:	5ae080e7          	jalr	1454(ra) # 800007da <uartputc>
    80000234:	4521                	li	a0,8
    80000236:	00000097          	auipc	ra,0x0
    8000023a:	5a4080e7          	jalr	1444(ra) # 800007da <uartputc>
    8000023e:	bfe1                	j	80000216 <consputc+0x24>

0000000080000240 <consolewrite>:
{
    80000240:	715d                	addi	sp,sp,-80
    80000242:	e486                	sd	ra,72(sp)
    80000244:	e0a2                	sd	s0,64(sp)
    80000246:	fc26                	sd	s1,56(sp)
    80000248:	f84a                	sd	s2,48(sp)
    8000024a:	f44e                	sd	s3,40(sp)
    8000024c:	f052                	sd	s4,32(sp)
    8000024e:	ec56                	sd	s5,24(sp)
    80000250:	0880                	addi	s0,sp,80
    80000252:	89aa                	mv	s3,a0
    80000254:	84ae                	mv	s1,a1
    80000256:	8ab2                	mv	s5,a2
  acquire(&cons.lock);
    80000258:	00011517          	auipc	a0,0x11
    8000025c:	5a850513          	addi	a0,a0,1448 # 80011800 <cons>
    80000260:	00001097          	auipc	ra,0x1
    80000264:	85e080e7          	jalr	-1954(ra) # 80000abe <acquire>
  for(i = 0; i < n; i++){
    80000268:	03505e63          	blez	s5,800002a4 <consolewrite+0x64>
    8000026c:	00148913          	addi	s2,s1,1
    80000270:	fffa879b          	addiw	a5,s5,-1
    80000274:	1782                	slli	a5,a5,0x20
    80000276:	9381                	srli	a5,a5,0x20
    80000278:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000027a:	5a7d                	li	s4,-1
    8000027c:	4685                	li	a3,1
    8000027e:	8626                	mv	a2,s1
    80000280:	85ce                	mv	a1,s3
    80000282:	fbf40513          	addi	a0,s0,-65
    80000286:	00002097          	auipc	ra,0x2
    8000028a:	002080e7          	jalr	2(ra) # 80002288 <either_copyin>
    8000028e:	01450b63          	beq	a0,s4,800002a4 <consolewrite+0x64>
    consputc(c);
    80000292:	fbf44503          	lbu	a0,-65(s0)
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	f5c080e7          	jalr	-164(ra) # 800001f2 <consputc>
  for(i = 0; i < n; i++){
    8000029e:	0485                	addi	s1,s1,1
    800002a0:	fd249ee3          	bne	s1,s2,8000027c <consolewrite+0x3c>
  release(&cons.lock);
    800002a4:	00011517          	auipc	a0,0x11
    800002a8:	55c50513          	addi	a0,a0,1372 # 80011800 <cons>
    800002ac:	00001097          	auipc	ra,0x1
    800002b0:	866080e7          	jalr	-1946(ra) # 80000b12 <release>
}
    800002b4:	8556                	mv	a0,s5
    800002b6:	60a6                	ld	ra,72(sp)
    800002b8:	6406                	ld	s0,64(sp)
    800002ba:	74e2                	ld	s1,56(sp)
    800002bc:	7942                	ld	s2,48(sp)
    800002be:	79a2                	ld	s3,40(sp)
    800002c0:	7a02                	ld	s4,32(sp)
    800002c2:	6ae2                	ld	s5,24(sp)
    800002c4:	6161                	addi	sp,sp,80
    800002c6:	8082                	ret

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	52a50513          	addi	a0,a0,1322 # 80011800 <cons>
    800002de:	00000097          	auipc	ra,0x0
    800002e2:	7e0080e7          	jalr	2016(ra) # 80000abe <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	fe2080e7          	jalr	-30(ra) # 800022de <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	4fc50513          	addi	a0,a0,1276 # 80011800 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	806080e7          	jalr	-2042(ra) # 80000b12 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	4d870713          	addi	a4,a4,1240 # 80011800 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	ea8080e7          	jalr	-344(ra) # 800001f2 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4ae78793          	addi	a5,a5,1198 # 80011800 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5187a783          	lw	a5,1304(a5) # 80011898 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	46c70713          	addi	a4,a4,1132 # 80011800 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	45c48493          	addi	s1,s1,1116 # 80011800 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	e28080e7          	jalr	-472(ra) # 800001f2 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	42070713          	addi	a4,a4,1056 # 80011800 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4af72523          	sw	a5,1194(a4) # 800118a0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	df0080e7          	jalr	-528(ra) # 800001f2 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	dde080e7          	jalr	-546(ra) # 800001f2 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	3e478793          	addi	a5,a5,996 # 80011800 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	44c7ae23          	sw	a2,1116(a5) # 8001189c <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	45050513          	addi	a0,a0,1104 # 80011898 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	d08080e7          	jalr	-760(ra) # 80002158 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00007597          	auipc	a1,0x7
    80000466:	cb658593          	addi	a1,a1,-842 # 80007118 <userret+0x88>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	39650513          	addi	a0,a0,918 # 80011800 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	53e080e7          	jalr	1342(ra) # 800009b0 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	32a080e7          	jalr	810(ra) # 800007a4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	5be78793          	addi	a5,a5,1470 # 80021a40 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c5670713          	addi	a4,a4,-938 # 800000e0 <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	dac70713          	addi	a4,a4,-596 # 80000240 <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00007617          	auipc	a2,0x7
    800004c8:	72c60613          	addi	a2,a2,1836 # 80007bf0 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	ccc080e7          	jalr	-820(ra) # 800001f2 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3607a623          	sw	zero,876(a5) # 800118c0 <pr+0x18>
  printf("panic: ");
    8000055c:	00007517          	auipc	a0,0x7
    80000560:	bc450513          	addi	a0,a0,-1084 # 80007120 <userret+0x90>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00007517          	auipc	a0,0x7
    8000057a:	57a50513          	addi	a0,a0,1402 # 80007af0 <userret+0xa60>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00026717          	auipc	a4,0x26
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80026000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	2fcdad83          	lw	s11,764(s11) # 800118c0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	14050f63          	beqz	a0,8000073e <printf+0x1ac>
    800005e4:	4981                	li	s3,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b93          	li	s7,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00007b17          	auipc	s6,0x7
    800005f4:	600b0b13          	addi	s6,s6,1536 # 80007bf0 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2a650513          	addi	a0,a0,678 # 800118a8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	4b4080e7          	jalr	1204(ra) # 80000abe <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00007517          	auipc	a0,0x7
    80000618:	b1c50513          	addi	a0,a0,-1252 # 80007130 <userret+0xa0>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	bce080e7          	jalr	-1074(ra) # 800001f2 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2985                	addiw	s3,s3,1
    8000062e:	013a07b3          	add	a5,s4,s3
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050463          	beqz	a0,8000073e <printf+0x1ac>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2985                	addiw	s3,s3,1
    80000640:	013a07b3          	add	a5,s4,s3
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000064c:	cbed                	beqz	a5,8000073e <printf+0x1ac>
    switch(c){
    8000064e:	05778a63          	beq	a5,s7,800006a2 <printf+0x110>
    80000652:	02fbf663          	bgeu	s7,a5,8000067e <printf+0xec>
    80000656:	09978863          	beq	a5,s9,800006e6 <printf+0x154>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79563          	bne	a5,a4,80000728 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	09578f63          	beq	a5,s5,8000071c <printf+0x18a>
    80000682:	0b879363          	bne	a5,s8,80000728 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	b3c080e7          	jalr	-1220(ra) # 800001f2 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	b30080e7          	jalr	-1232(ra) # 800001f2 <consputc>
    800006ca:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c95793          	srli	a5,s2,0x3c
    800006d0:	97da                	add	a5,a5,s6
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	b1c080e7          	jalr	-1252(ra) # 800001f2 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0912                	slli	s2,s2,0x4
    800006e0:	34fd                	addiw	s1,s1,-1
    800006e2:	f4ed                	bnez	s1,800006cc <printf+0x13a>
    800006e4:	b7a1                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e6:	f8843783          	ld	a5,-120(s0)
    800006ea:	00878713          	addi	a4,a5,8
    800006ee:	f8e43423          	sd	a4,-120(s0)
    800006f2:	6384                	ld	s1,0(a5)
    800006f4:	cc89                	beqz	s1,8000070e <printf+0x17c>
      for(; *s; s++)
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	d90d                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    800006fc:	00000097          	auipc	ra,0x0
    80000700:	af6080e7          	jalr	-1290(ra) # 800001f2 <consputc>
      for(; *s; s++)
    80000704:	0485                	addi	s1,s1,1
    80000706:	0004c503          	lbu	a0,0(s1)
    8000070a:	f96d                	bnez	a0,800006fc <printf+0x16a>
    8000070c:	b705                	j	8000062c <printf+0x9a>
        s = "(null)";
    8000070e:	00007497          	auipc	s1,0x7
    80000712:	a1a48493          	addi	s1,s1,-1510 # 80007128 <userret+0x98>
      for(; *s; s++)
    80000716:	02800513          	li	a0,40
    8000071a:	b7cd                	j	800006fc <printf+0x16a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	ad4080e7          	jalr	-1324(ra) # 800001f2 <consputc>
      break;
    80000726:	b719                	j	8000062c <printf+0x9a>
      consputc('%');
    80000728:	8556                	mv	a0,s5
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	ac8080e7          	jalr	-1336(ra) # 800001f2 <consputc>
      consputc(c);
    80000732:	8526                	mv	a0,s1
    80000734:	00000097          	auipc	ra,0x0
    80000738:	abe080e7          	jalr	-1346(ra) # 800001f2 <consputc>
      break;
    8000073c:	bdc5                	j	8000062c <printf+0x9a>
  if(locking)
    8000073e:	020d9163          	bnez	s11,80000760 <printf+0x1ce>
}
    80000742:	70e6                	ld	ra,120(sp)
    80000744:	7446                	ld	s0,112(sp)
    80000746:	74a6                	ld	s1,104(sp)
    80000748:	7906                	ld	s2,96(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7ca2                	ld	s9,40(sp)
    80000758:	7d02                	ld	s10,32(sp)
    8000075a:	6de2                	ld	s11,24(sp)
    8000075c:	6129                	addi	sp,sp,192
    8000075e:	8082                	ret
    release(&pr.lock);
    80000760:	00011517          	auipc	a0,0x11
    80000764:	14850513          	addi	a0,a0,328 # 800118a8 <pr>
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	3aa080e7          	jalr	938(ra) # 80000b12 <release>
}
    80000770:	bfc9                	j	80000742 <printf+0x1b0>

0000000080000772 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000772:	1101                	addi	sp,sp,-32
    80000774:	ec06                	sd	ra,24(sp)
    80000776:	e822                	sd	s0,16(sp)
    80000778:	e426                	sd	s1,8(sp)
    8000077a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077c:	00011497          	auipc	s1,0x11
    80000780:	12c48493          	addi	s1,s1,300 # 800118a8 <pr>
    80000784:	00007597          	auipc	a1,0x7
    80000788:	9bc58593          	addi	a1,a1,-1604 # 80007140 <userret+0xb0>
    8000078c:	8526                	mv	a0,s1
    8000078e:	00000097          	auipc	ra,0x0
    80000792:	222080e7          	jalr	546(ra) # 800009b0 <initlock>
  pr.locking = 1;
    80000796:	4785                	li	a5,1
    80000798:	cc9c                	sw	a5,24(s1)
}
    8000079a:	60e2                	ld	ra,24(sp)
    8000079c:	6442                	ld	s0,16(sp)
    8000079e:	64a2                	ld	s1,8(sp)
    800007a0:	6105                	addi	sp,sp,32
    800007a2:	8082                	ret

00000000800007a4 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007a4:	1141                	addi	sp,sp,-16
    800007a6:	e422                	sd	s0,8(sp)
    800007a8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007aa:	100007b7          	lui	a5,0x10000
    800007ae:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007b2:	f8000713          	li	a4,-128
    800007b6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ba:	470d                	li	a4,3
    800007bc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007c4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007c8:	471d                	li	a4,7
    800007ca:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007ce:	4705                	li	a4,1
    800007d0:	00e780a3          	sb	a4,1(a5)
}
    800007d4:	6422                	ld	s0,8(sp)
    800007d6:	0141                	addi	sp,sp,16
    800007d8:	8082                	ret

00000000800007da <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007da:	1141                	addi	sp,sp,-16
    800007dc:	e422                	sd	s0,8(sp)
    800007de:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007e0:	10000737          	lui	a4,0x10000
    800007e4:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007e8:	0207f793          	andi	a5,a5,32
    800007ec:	dfe5                	beqz	a5,800007e4 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800007ee:	0ff57513          	andi	a0,a0,255
    800007f2:	100007b7          	lui	a5,0x10000
    800007f6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800007fa:	6422                	ld	s0,8(sp)
    800007fc:	0141                	addi	sp,sp,16
    800007fe:	8082                	ret

0000000080000800 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000800:	1141                	addi	sp,sp,-16
    80000802:	e422                	sd	s0,8(sp)
    80000804:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000806:	100007b7          	lui	a5,0x10000
    8000080a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000080e:	8b85                	andi	a5,a5,1
    80000810:	cb91                	beqz	a5,80000824 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000812:	100007b7          	lui	a5,0x10000
    80000816:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000081a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000081e:	6422                	ld	s0,8(sp)
    80000820:	0141                	addi	sp,sp,16
    80000822:	8082                	ret
    return -1;
    80000824:	557d                	li	a0,-1
    80000826:	bfe5                	j	8000081e <uartgetc+0x1e>

0000000080000828 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000828:	1101                	addi	sp,sp,-32
    8000082a:	ec06                	sd	ra,24(sp)
    8000082c:	e822                	sd	s0,16(sp)
    8000082e:	e426                	sd	s1,8(sp)
    80000830:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000832:	54fd                	li	s1,-1
    80000834:	a029                	j	8000083e <uartintr+0x16>
      break;
    consoleintr(c);
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	a92080e7          	jalr	-1390(ra) # 800002c8 <consoleintr>
    int c = uartgetc();
    8000083e:	00000097          	auipc	ra,0x0
    80000842:	fc2080e7          	jalr	-62(ra) # 80000800 <uartgetc>
    if(c == -1)
    80000846:	fe9518e3          	bne	a0,s1,80000836 <uartintr+0xe>
  }
}
    8000084a:	60e2                	ld	ra,24(sp)
    8000084c:	6442                	ld	s0,16(sp)
    8000084e:	64a2                	ld	s1,8(sp)
    80000850:	6105                	addi	sp,sp,32
    80000852:	8082                	ret

0000000080000854 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	e04a                	sd	s2,0(sp)
    8000085e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000860:	03451793          	slli	a5,a0,0x34
    80000864:	ebb9                	bnez	a5,800008ba <kfree+0x66>
    80000866:	84aa                	mv	s1,a0
    80000868:	00025797          	auipc	a5,0x25
    8000086c:	7b478793          	addi	a5,a5,1972 # 8002601c <end>
    80000870:	04f56563          	bltu	a0,a5,800008ba <kfree+0x66>
    80000874:	47c5                	li	a5,17
    80000876:	07ee                	slli	a5,a5,0x1b
    80000878:	04f57163          	bgeu	a0,a5,800008ba <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000087c:	6605                	lui	a2,0x1
    8000087e:	4585                	li	a1,1
    80000880:	00000097          	auipc	ra,0x0
    80000884:	2da080e7          	jalr	730(ra) # 80000b5a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000888:	00011917          	auipc	s2,0x11
    8000088c:	04090913          	addi	s2,s2,64 # 800118c8 <kmem>
    80000890:	854a                	mv	a0,s2
    80000892:	00000097          	auipc	ra,0x0
    80000896:	22c080e7          	jalr	556(ra) # 80000abe <acquire>
  r->next = kmem.freelist;
    8000089a:	01893783          	ld	a5,24(s2)
    8000089e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008a0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800008a4:	854a                	mv	a0,s2
    800008a6:	00000097          	auipc	ra,0x0
    800008aa:	26c080e7          	jalr	620(ra) # 80000b12 <release>
}
    800008ae:	60e2                	ld	ra,24(sp)
    800008b0:	6442                	ld	s0,16(sp)
    800008b2:	64a2                	ld	s1,8(sp)
    800008b4:	6902                	ld	s2,0(sp)
    800008b6:	6105                	addi	sp,sp,32
    800008b8:	8082                	ret
    panic("kfree");
    800008ba:	00007517          	auipc	a0,0x7
    800008be:	88e50513          	addi	a0,a0,-1906 # 80007148 <userret+0xb8>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	c86080e7          	jalr	-890(ra) # 80000548 <panic>

00000000800008ca <freerange>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800008da:	6785                	lui	a5,0x1
    800008dc:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800008e0:	94aa                	add	s1,s1,a0
    800008e2:	757d                	lui	a0,0xfffff
    800008e4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008e6:	94be                	add	s1,s1,a5
    800008e8:	0095ee63          	bltu	a1,s1,80000904 <freerange+0x3a>
    800008ec:	892e                	mv	s2,a1
    kfree(p);
    800008ee:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008f0:	6985                	lui	s3,0x1
    kfree(p);
    800008f2:	01448533          	add	a0,s1,s4
    800008f6:	00000097          	auipc	ra,0x0
    800008fa:	f5e080e7          	jalr	-162(ra) # 80000854 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008fe:	94ce                	add	s1,s1,s3
    80000900:	fe9979e3          	bgeu	s2,s1,800008f2 <freerange+0x28>
}
    80000904:	70a2                	ld	ra,40(sp)
    80000906:	7402                	ld	s0,32(sp)
    80000908:	64e2                	ld	s1,24(sp)
    8000090a:	6942                	ld	s2,16(sp)
    8000090c:	69a2                	ld	s3,8(sp)
    8000090e:	6a02                	ld	s4,0(sp)
    80000910:	6145                	addi	sp,sp,48
    80000912:	8082                	ret

0000000080000914 <kinit>:
{
    80000914:	1141                	addi	sp,sp,-16
    80000916:	e406                	sd	ra,8(sp)
    80000918:	e022                	sd	s0,0(sp)
    8000091a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    8000091c:	00007597          	auipc	a1,0x7
    80000920:	83458593          	addi	a1,a1,-1996 # 80007150 <userret+0xc0>
    80000924:	00011517          	auipc	a0,0x11
    80000928:	fa450513          	addi	a0,a0,-92 # 800118c8 <kmem>
    8000092c:	00000097          	auipc	ra,0x0
    80000930:	084080e7          	jalr	132(ra) # 800009b0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000934:	45c5                	li	a1,17
    80000936:	05ee                	slli	a1,a1,0x1b
    80000938:	00025517          	auipc	a0,0x25
    8000093c:	6e450513          	addi	a0,a0,1764 # 8002601c <end>
    80000940:	00000097          	auipc	ra,0x0
    80000944:	f8a080e7          	jalr	-118(ra) # 800008ca <freerange>
}
    80000948:	60a2                	ld	ra,8(sp)
    8000094a:	6402                	ld	s0,0(sp)
    8000094c:	0141                	addi	sp,sp,16
    8000094e:	8082                	ret

0000000080000950 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000950:	1101                	addi	sp,sp,-32
    80000952:	ec06                	sd	ra,24(sp)
    80000954:	e822                	sd	s0,16(sp)
    80000956:	e426                	sd	s1,8(sp)
    80000958:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000095a:	00011497          	auipc	s1,0x11
    8000095e:	f6e48493          	addi	s1,s1,-146 # 800118c8 <kmem>
    80000962:	8526                	mv	a0,s1
    80000964:	00000097          	auipc	ra,0x0
    80000968:	15a080e7          	jalr	346(ra) # 80000abe <acquire>
  r = kmem.freelist;
    8000096c:	6c84                	ld	s1,24(s1)
  if(r)
    8000096e:	c885                	beqz	s1,8000099e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000970:	609c                	ld	a5,0(s1)
    80000972:	00011517          	auipc	a0,0x11
    80000976:	f5650513          	addi	a0,a0,-170 # 800118c8 <kmem>
    8000097a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    8000097c:	00000097          	auipc	ra,0x0
    80000980:	196080e7          	jalr	406(ra) # 80000b12 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000984:	6605                	lui	a2,0x1
    80000986:	4595                	li	a1,5
    80000988:	8526                	mv	a0,s1
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	1d0080e7          	jalr	464(ra) # 80000b5a <memset>
  return (void*)r;
}
    80000992:	8526                	mv	a0,s1
    80000994:	60e2                	ld	ra,24(sp)
    80000996:	6442                	ld	s0,16(sp)
    80000998:	64a2                	ld	s1,8(sp)
    8000099a:	6105                	addi	sp,sp,32
    8000099c:	8082                	ret
  release(&kmem.lock);
    8000099e:	00011517          	auipc	a0,0x11
    800009a2:	f2a50513          	addi	a0,a0,-214 # 800118c8 <kmem>
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	16c080e7          	jalr	364(ra) # 80000b12 <release>
  if(r)
    800009ae:	b7d5                	j	80000992 <kalloc+0x42>

00000000800009b0 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800009b0:	1141                	addi	sp,sp,-16
    800009b2:	e422                	sd	s0,8(sp)
    800009b4:	0800                	addi	s0,sp,16
  lk->name = name;
    800009b6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009b8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009bc:	00053823          	sd	zero,16(a0)
}
    800009c0:	6422                	ld	s0,8(sp)
    800009c2:	0141                	addi	sp,sp,16
    800009c4:	8082                	ret

00000000800009c6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800009c6:	1101                	addi	sp,sp,-32
    800009c8:	ec06                	sd	ra,24(sp)
    800009ca:	e822                	sd	s0,16(sp)
    800009cc:	e426                	sd	s1,8(sp)
    800009ce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800009d0:	100024f3          	csrr	s1,sstatus
    800009d4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800009d8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800009da:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800009de:	00001097          	auipc	ra,0x1
    800009e2:	e34080e7          	jalr	-460(ra) # 80001812 <mycpu>
    800009e6:	5d3c                	lw	a5,120(a0)
    800009e8:	cf89                	beqz	a5,80000a02 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800009ea:	00001097          	auipc	ra,0x1
    800009ee:	e28080e7          	jalr	-472(ra) # 80001812 <mycpu>
    800009f2:	5d3c                	lw	a5,120(a0)
    800009f4:	2785                	addiw	a5,a5,1
    800009f6:	dd3c                	sw	a5,120(a0)
}
    800009f8:	60e2                	ld	ra,24(sp)
    800009fa:	6442                	ld	s0,16(sp)
    800009fc:	64a2                	ld	s1,8(sp)
    800009fe:	6105                	addi	sp,sp,32
    80000a00:	8082                	ret
    mycpu()->intena = old;
    80000a02:	00001097          	auipc	ra,0x1
    80000a06:	e10080e7          	jalr	-496(ra) # 80001812 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a0a:	8085                	srli	s1,s1,0x1
    80000a0c:	8885                	andi	s1,s1,1
    80000a0e:	dd64                	sw	s1,124(a0)
    80000a10:	bfe9                	j	800009ea <push_off+0x24>

0000000080000a12 <pop_off>:

void
pop_off(void)
{
    80000a12:	1141                	addi	sp,sp,-16
    80000a14:	e406                	sd	ra,8(sp)
    80000a16:	e022                	sd	s0,0(sp)
    80000a18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000a1a:	00001097          	auipc	ra,0x1
    80000a1e:	df8080e7          	jalr	-520(ra) # 80001812 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a26:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000a28:	eb9d                	bnez	a5,80000a5e <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000a2a:	5d3c                	lw	a5,120(a0)
    80000a2c:	37fd                	addiw	a5,a5,-1
    80000a2e:	0007871b          	sext.w	a4,a5
    80000a32:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000a34:	02074d63          	bltz	a4,80000a6e <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000a38:	ef19                	bnez	a4,80000a56 <pop_off+0x44>
    80000a3a:	5d7c                	lw	a5,124(a0)
    80000a3c:	cf89                	beqz	a5,80000a56 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000a3e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000a42:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000a46:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000a4e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a52:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000a56:	60a2                	ld	ra,8(sp)
    80000a58:	6402                	ld	s0,0(sp)
    80000a5a:	0141                	addi	sp,sp,16
    80000a5c:	8082                	ret
    panic("pop_off - interruptible");
    80000a5e:	00006517          	auipc	a0,0x6
    80000a62:	6fa50513          	addi	a0,a0,1786 # 80007158 <userret+0xc8>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ae2080e7          	jalr	-1310(ra) # 80000548 <panic>
    panic("pop_off");
    80000a6e:	00006517          	auipc	a0,0x6
    80000a72:	70250513          	addi	a0,a0,1794 # 80007170 <userret+0xe0>
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	ad2080e7          	jalr	-1326(ra) # 80000548 <panic>

0000000080000a7e <holding>:
{
    80000a7e:	1101                	addi	sp,sp,-32
    80000a80:	ec06                	sd	ra,24(sp)
    80000a82:	e822                	sd	s0,16(sp)
    80000a84:	e426                	sd	s1,8(sp)
    80000a86:	1000                	addi	s0,sp,32
    80000a88:	84aa                	mv	s1,a0
  push_off();
    80000a8a:	00000097          	auipc	ra,0x0
    80000a8e:	f3c080e7          	jalr	-196(ra) # 800009c6 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000a92:	409c                	lw	a5,0(s1)
    80000a94:	ef81                	bnez	a5,80000aac <holding+0x2e>
    80000a96:	4481                	li	s1,0
  pop_off();
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	f7a080e7          	jalr	-134(ra) # 80000a12 <pop_off>
}
    80000aa0:	8526                	mv	a0,s1
    80000aa2:	60e2                	ld	ra,24(sp)
    80000aa4:	6442                	ld	s0,16(sp)
    80000aa6:	64a2                	ld	s1,8(sp)
    80000aa8:	6105                	addi	sp,sp,32
    80000aaa:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000aac:	6884                	ld	s1,16(s1)
    80000aae:	00001097          	auipc	ra,0x1
    80000ab2:	d64080e7          	jalr	-668(ra) # 80001812 <mycpu>
    80000ab6:	8c89                	sub	s1,s1,a0
    80000ab8:	0014b493          	seqz	s1,s1
    80000abc:	bff1                	j	80000a98 <holding+0x1a>

0000000080000abe <acquire>:
{
    80000abe:	1101                	addi	sp,sp,-32
    80000ac0:	ec06                	sd	ra,24(sp)
    80000ac2:	e822                	sd	s0,16(sp)
    80000ac4:	e426                	sd	s1,8(sp)
    80000ac6:	1000                	addi	s0,sp,32
    80000ac8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	efc080e7          	jalr	-260(ra) # 800009c6 <push_off>
  if(holding(lk))
    80000ad2:	8526                	mv	a0,s1
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	faa080e7          	jalr	-86(ra) # 80000a7e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000adc:	4705                	li	a4,1
  if(holding(lk))
    80000ade:	e115                	bnez	a0,80000b02 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ae0:	87ba                	mv	a5,a4
    80000ae2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000ae6:	2781                	sext.w	a5,a5
    80000ae8:	ffe5                	bnez	a5,80000ae0 <acquire+0x22>
  __sync_synchronize();
    80000aea:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000aee:	00001097          	auipc	ra,0x1
    80000af2:	d24080e7          	jalr	-732(ra) # 80001812 <mycpu>
    80000af6:	e888                	sd	a0,16(s1)
}
    80000af8:	60e2                	ld	ra,24(sp)
    80000afa:	6442                	ld	s0,16(sp)
    80000afc:	64a2                	ld	s1,8(sp)
    80000afe:	6105                	addi	sp,sp,32
    80000b00:	8082                	ret
    panic("acquire");
    80000b02:	00006517          	auipc	a0,0x6
    80000b06:	67650513          	addi	a0,a0,1654 # 80007178 <userret+0xe8>
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	a3e080e7          	jalr	-1474(ra) # 80000548 <panic>

0000000080000b12 <release>:
{
    80000b12:	1101                	addi	sp,sp,-32
    80000b14:	ec06                	sd	ra,24(sp)
    80000b16:	e822                	sd	s0,16(sp)
    80000b18:	e426                	sd	s1,8(sp)
    80000b1a:	1000                	addi	s0,sp,32
    80000b1c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	f60080e7          	jalr	-160(ra) # 80000a7e <holding>
    80000b26:	c115                	beqz	a0,80000b4a <release+0x38>
  lk->cpu = 0;
    80000b28:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b2c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b30:	0f50000f          	fence	iorw,ow
    80000b34:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	eda080e7          	jalr	-294(ra) # 80000a12 <pop_off>
}
    80000b40:	60e2                	ld	ra,24(sp)
    80000b42:	6442                	ld	s0,16(sp)
    80000b44:	64a2                	ld	s1,8(sp)
    80000b46:	6105                	addi	sp,sp,32
    80000b48:	8082                	ret
    panic("release");
    80000b4a:	00006517          	auipc	a0,0x6
    80000b4e:	63650513          	addi	a0,a0,1590 # 80007180 <userret+0xf0>
    80000b52:	00000097          	auipc	ra,0x0
    80000b56:	9f6080e7          	jalr	-1546(ra) # 80000548 <panic>

0000000080000b5a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e422                	sd	s0,8(sp)
    80000b5e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000b60:	ca19                	beqz	a2,80000b76 <memset+0x1c>
    80000b62:	87aa                	mv	a5,a0
    80000b64:	1602                	slli	a2,a2,0x20
    80000b66:	9201                	srli	a2,a2,0x20
    80000b68:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000b6c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000b70:	0785                	addi	a5,a5,1
    80000b72:	fee79de3          	bne	a5,a4,80000b6c <memset+0x12>
  }
  return dst;
}
    80000b76:	6422                	ld	s0,8(sp)
    80000b78:	0141                	addi	sp,sp,16
    80000b7a:	8082                	ret

0000000080000b7c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000b7c:	1141                	addi	sp,sp,-16
    80000b7e:	e422                	sd	s0,8(sp)
    80000b80:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000b82:	ca05                	beqz	a2,80000bb2 <memcmp+0x36>
    80000b84:	fff6069b          	addiw	a3,a2,-1
    80000b88:	1682                	slli	a3,a3,0x20
    80000b8a:	9281                	srli	a3,a3,0x20
    80000b8c:	0685                	addi	a3,a3,1
    80000b8e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000b90:	00054783          	lbu	a5,0(a0)
    80000b94:	0005c703          	lbu	a4,0(a1)
    80000b98:	00e79863          	bne	a5,a4,80000ba8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000b9c:	0505                	addi	a0,a0,1
    80000b9e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ba0:	fed518e3          	bne	a0,a3,80000b90 <memcmp+0x14>
  }

  return 0;
    80000ba4:	4501                	li	a0,0
    80000ba6:	a019                	j	80000bac <memcmp+0x30>
      return *s1 - *s2;
    80000ba8:	40e7853b          	subw	a0,a5,a4
}
    80000bac:	6422                	ld	s0,8(sp)
    80000bae:	0141                	addi	sp,sp,16
    80000bb0:	8082                	ret
  return 0;
    80000bb2:	4501                	li	a0,0
    80000bb4:	bfe5                	j	80000bac <memcmp+0x30>

0000000080000bb6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000bb6:	1141                	addi	sp,sp,-16
    80000bb8:	e422                	sd	s0,8(sp)
    80000bba:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000bbc:	02a5e563          	bltu	a1,a0,80000be6 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000bc0:	fff6069b          	addiw	a3,a2,-1
    80000bc4:	ce11                	beqz	a2,80000be0 <memmove+0x2a>
    80000bc6:	1682                	slli	a3,a3,0x20
    80000bc8:	9281                	srli	a3,a3,0x20
    80000bca:	0685                	addi	a3,a3,1
    80000bcc:	96ae                	add	a3,a3,a1
    80000bce:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000bd0:	0585                	addi	a1,a1,1
    80000bd2:	0785                	addi	a5,a5,1
    80000bd4:	fff5c703          	lbu	a4,-1(a1)
    80000bd8:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000bdc:	fed59ae3          	bne	a1,a3,80000bd0 <memmove+0x1a>

  return dst;
}
    80000be0:	6422                	ld	s0,8(sp)
    80000be2:	0141                	addi	sp,sp,16
    80000be4:	8082                	ret
  if(s < d && s + n > d){
    80000be6:	02061713          	slli	a4,a2,0x20
    80000bea:	9301                	srli	a4,a4,0x20
    80000bec:	00e587b3          	add	a5,a1,a4
    80000bf0:	fcf578e3          	bgeu	a0,a5,80000bc0 <memmove+0xa>
    d += n;
    80000bf4:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000bf6:	fff6069b          	addiw	a3,a2,-1
    80000bfa:	d27d                	beqz	a2,80000be0 <memmove+0x2a>
    80000bfc:	02069613          	slli	a2,a3,0x20
    80000c00:	9201                	srli	a2,a2,0x20
    80000c02:	fff64613          	not	a2,a2
    80000c06:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000c08:	17fd                	addi	a5,a5,-1
    80000c0a:	177d                	addi	a4,a4,-1
    80000c0c:	0007c683          	lbu	a3,0(a5)
    80000c10:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000c14:	fef61ae3          	bne	a2,a5,80000c08 <memmove+0x52>
    80000c18:	b7e1                	j	80000be0 <memmove+0x2a>

0000000080000c1a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000c1a:	1141                	addi	sp,sp,-16
    80000c1c:	e406                	sd	ra,8(sp)
    80000c1e:	e022                	sd	s0,0(sp)
    80000c20:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	f94080e7          	jalr	-108(ra) # 80000bb6 <memmove>
}
    80000c2a:	60a2                	ld	ra,8(sp)
    80000c2c:	6402                	ld	s0,0(sp)
    80000c2e:	0141                	addi	sp,sp,16
    80000c30:	8082                	ret

0000000080000c32 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000c32:	1141                	addi	sp,sp,-16
    80000c34:	e422                	sd	s0,8(sp)
    80000c36:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000c38:	ce11                	beqz	a2,80000c54 <strncmp+0x22>
    80000c3a:	00054783          	lbu	a5,0(a0)
    80000c3e:	cf89                	beqz	a5,80000c58 <strncmp+0x26>
    80000c40:	0005c703          	lbu	a4,0(a1)
    80000c44:	00f71a63          	bne	a4,a5,80000c58 <strncmp+0x26>
    n--, p++, q++;
    80000c48:	367d                	addiw	a2,a2,-1
    80000c4a:	0505                	addi	a0,a0,1
    80000c4c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000c4e:	f675                	bnez	a2,80000c3a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000c50:	4501                	li	a0,0
    80000c52:	a809                	j	80000c64 <strncmp+0x32>
    80000c54:	4501                	li	a0,0
    80000c56:	a039                	j	80000c64 <strncmp+0x32>
  if(n == 0)
    80000c58:	ca09                	beqz	a2,80000c6a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000c5a:	00054503          	lbu	a0,0(a0)
    80000c5e:	0005c783          	lbu	a5,0(a1)
    80000c62:	9d1d                	subw	a0,a0,a5
}
    80000c64:	6422                	ld	s0,8(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    return 0;
    80000c6a:	4501                	li	a0,0
    80000c6c:	bfe5                	j	80000c64 <strncmp+0x32>

0000000080000c6e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000c6e:	1141                	addi	sp,sp,-16
    80000c70:	e422                	sd	s0,8(sp)
    80000c72:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000c74:	872a                	mv	a4,a0
    80000c76:	8832                	mv	a6,a2
    80000c78:	367d                	addiw	a2,a2,-1
    80000c7a:	01005963          	blez	a6,80000c8c <strncpy+0x1e>
    80000c7e:	0705                	addi	a4,a4,1
    80000c80:	0005c783          	lbu	a5,0(a1)
    80000c84:	fef70fa3          	sb	a5,-1(a4)
    80000c88:	0585                	addi	a1,a1,1
    80000c8a:	f7f5                	bnez	a5,80000c76 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000c8c:	86ba                	mv	a3,a4
    80000c8e:	00c05c63          	blez	a2,80000ca6 <strncpy+0x38>
    *s++ = 0;
    80000c92:	0685                	addi	a3,a3,1
    80000c94:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000c98:	fff6c793          	not	a5,a3
    80000c9c:	9fb9                	addw	a5,a5,a4
    80000c9e:	010787bb          	addw	a5,a5,a6
    80000ca2:	fef048e3          	bgtz	a5,80000c92 <strncpy+0x24>
  return os;
}
    80000ca6:	6422                	ld	s0,8(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret

0000000080000cac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000cac:	1141                	addi	sp,sp,-16
    80000cae:	e422                	sd	s0,8(sp)
    80000cb0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000cb2:	02c05363          	blez	a2,80000cd8 <safestrcpy+0x2c>
    80000cb6:	fff6069b          	addiw	a3,a2,-1
    80000cba:	1682                	slli	a3,a3,0x20
    80000cbc:	9281                	srli	a3,a3,0x20
    80000cbe:	96ae                	add	a3,a3,a1
    80000cc0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000cc2:	00d58963          	beq	a1,a3,80000cd4 <safestrcpy+0x28>
    80000cc6:	0585                	addi	a1,a1,1
    80000cc8:	0785                	addi	a5,a5,1
    80000cca:	fff5c703          	lbu	a4,-1(a1)
    80000cce:	fee78fa3          	sb	a4,-1(a5)
    80000cd2:	fb65                	bnez	a4,80000cc2 <safestrcpy+0x16>
    ;
  *s = 0;
    80000cd4:	00078023          	sb	zero,0(a5)
  return os;
}
    80000cd8:	6422                	ld	s0,8(sp)
    80000cda:	0141                	addi	sp,sp,16
    80000cdc:	8082                	ret

0000000080000cde <strlen>:

int
strlen(const char *s)
{
    80000cde:	1141                	addi	sp,sp,-16
    80000ce0:	e422                	sd	s0,8(sp)
    80000ce2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ce4:	00054783          	lbu	a5,0(a0)
    80000ce8:	cf91                	beqz	a5,80000d04 <strlen+0x26>
    80000cea:	0505                	addi	a0,a0,1
    80000cec:	87aa                	mv	a5,a0
    80000cee:	4685                	li	a3,1
    80000cf0:	9e89                	subw	a3,a3,a0
    80000cf2:	00f6853b          	addw	a0,a3,a5
    80000cf6:	0785                	addi	a5,a5,1
    80000cf8:	fff7c703          	lbu	a4,-1(a5)
    80000cfc:	fb7d                	bnez	a4,80000cf2 <strlen+0x14>
    ;
  return n;
}
    80000cfe:	6422                	ld	s0,8(sp)
    80000d00:	0141                	addi	sp,sp,16
    80000d02:	8082                	ret
  for(n = 0; s[n]; n++)
    80000d04:	4501                	li	a0,0
    80000d06:	bfe5                	j	80000cfe <strlen+0x20>

0000000080000d08 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000d08:	1141                	addi	sp,sp,-16
    80000d0a:	e406                	sd	ra,8(sp)
    80000d0c:	e022                	sd	s0,0(sp)
    80000d0e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000d10:	00001097          	auipc	ra,0x1
    80000d14:	af2080e7          	jalr	-1294(ra) # 80001802 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000d18:	00025717          	auipc	a4,0x25
    80000d1c:	2ec70713          	addi	a4,a4,748 # 80026004 <started>
  if(cpuid() == 0){
    80000d20:	c139                	beqz	a0,80000d66 <main+0x5e>
    while(started == 0)
    80000d22:	431c                	lw	a5,0(a4)
    80000d24:	2781                	sext.w	a5,a5
    80000d26:	dff5                	beqz	a5,80000d22 <main+0x1a>
      ;
    __sync_synchronize();
    80000d28:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000d2c:	00001097          	auipc	ra,0x1
    80000d30:	ad6080e7          	jalr	-1322(ra) # 80001802 <cpuid>
    80000d34:	85aa                	mv	a1,a0
    80000d36:	00006517          	auipc	a0,0x6
    80000d3a:	46a50513          	addi	a0,a0,1130 # 800071a0 <userret+0x110>
    80000d3e:	00000097          	auipc	ra,0x0
    80000d42:	854080e7          	jalr	-1964(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000d46:	00000097          	auipc	ra,0x0
    80000d4a:	1e8080e7          	jalr	488(ra) # 80000f2e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000d4e:	00001097          	auipc	ra,0x1
    80000d52:	6d2080e7          	jalr	1746(ra) # 80002420 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000d56:	00005097          	auipc	ra,0x5
    80000d5a:	3aa080e7          	jalr	938(ra) # 80006100 <plicinithart>
  }

  scheduler();        
    80000d5e:	00001097          	auipc	ra,0x1
    80000d62:	fb2080e7          	jalr	-78(ra) # 80001d10 <scheduler>
    consoleinit();
    80000d66:	fffff097          	auipc	ra,0xfffff
    80000d6a:	6f4080e7          	jalr	1780(ra) # 8000045a <consoleinit>
    printfinit();
    80000d6e:	00000097          	auipc	ra,0x0
    80000d72:	a04080e7          	jalr	-1532(ra) # 80000772 <printfinit>
    printf("\n");
    80000d76:	00007517          	auipc	a0,0x7
    80000d7a:	d7a50513          	addi	a0,a0,-646 # 80007af0 <userret+0xa60>
    80000d7e:	00000097          	auipc	ra,0x0
    80000d82:	814080e7          	jalr	-2028(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000d86:	00006517          	auipc	a0,0x6
    80000d8a:	40250513          	addi	a0,a0,1026 # 80007188 <userret+0xf8>
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	804080e7          	jalr	-2044(ra) # 80000592 <printf>
    printf("\n");
    80000d96:	00007517          	auipc	a0,0x7
    80000d9a:	d5a50513          	addi	a0,a0,-678 # 80007af0 <userret+0xa60>
    80000d9e:	fffff097          	auipc	ra,0xfffff
    80000da2:	7f4080e7          	jalr	2036(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	b6e080e7          	jalr	-1170(ra) # 80000914 <kinit>
    kvminit();       // create kernel page table
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	30a080e7          	jalr	778(ra) # 800010b8 <kvminit>
    kvminithart();   // turn on paging
    80000db6:	00000097          	auipc	ra,0x0
    80000dba:	178080e7          	jalr	376(ra) # 80000f2e <kvminithart>
    procinit();      // process table
    80000dbe:	00001097          	auipc	ra,0x1
    80000dc2:	974080e7          	jalr	-1676(ra) # 80001732 <procinit>
    trapinit();      // trap vectors
    80000dc6:	00001097          	auipc	ra,0x1
    80000dca:	632080e7          	jalr	1586(ra) # 800023f8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000dce:	00001097          	auipc	ra,0x1
    80000dd2:	652080e7          	jalr	1618(ra) # 80002420 <trapinithart>
    plicinit();      // set up interrupt controller
    80000dd6:	00005097          	auipc	ra,0x5
    80000dda:	314080e7          	jalr	788(ra) # 800060ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000dde:	00005097          	auipc	ra,0x5
    80000de2:	322080e7          	jalr	802(ra) # 80006100 <plicinithart>
    binit();         // buffer cache
    80000de6:	00002097          	auipc	ra,0x2
    80000dea:	2c0080e7          	jalr	704(ra) # 800030a6 <binit>
    iinit();         // inode cache
    80000dee:	00003097          	auipc	ra,0x3
    80000df2:	952080e7          	jalr	-1710(ra) # 80003740 <iinit>
    fileinit();      // file table
    80000df6:	00004097          	auipc	ra,0x4
    80000dfa:	8ca080e7          	jalr	-1846(ra) # 800046c0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000dfe:	00005097          	auipc	ra,0x5
    80000e02:	41c080e7          	jalr	1052(ra) # 8000621a <virtio_disk_init>
    userinit();      // first user process
    80000e06:	00001097          	auipc	ra,0x1
    80000e0a:	ca0080e7          	jalr	-864(ra) # 80001aa6 <userinit>
    __sync_synchronize();
    80000e0e:	0ff0000f          	fence
    started = 1;
    80000e12:	4785                	li	a5,1
    80000e14:	00025717          	auipc	a4,0x25
    80000e18:	1ef72823          	sw	a5,496(a4) # 80026004 <started>
    80000e1c:	b789                	j	80000d5e <main+0x56>

0000000080000e1e <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000e1e:	7139                	addi	sp,sp,-64
    80000e20:	fc06                	sd	ra,56(sp)
    80000e22:	f822                	sd	s0,48(sp)
    80000e24:	f426                	sd	s1,40(sp)
    80000e26:	f04a                	sd	s2,32(sp)
    80000e28:	ec4e                	sd	s3,24(sp)
    80000e2a:	e852                	sd	s4,16(sp)
    80000e2c:	e456                	sd	s5,8(sp)
    80000e2e:	e05a                	sd	s6,0(sp)
    80000e30:	0080                	addi	s0,sp,64
    80000e32:	84aa                	mv	s1,a0
    80000e34:	89ae                	mv	s3,a1
    80000e36:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000e38:	57fd                	li	a5,-1
    80000e3a:	83e9                	srli	a5,a5,0x1a
    80000e3c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000e3e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000e40:	04b7f263          	bgeu	a5,a1,80000e84 <walk+0x66>
    panic("walk");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	37450513          	addi	a0,a0,884 # 800071b8 <userret+0x128>
    80000e4c:	fffff097          	auipc	ra,0xfffff
    80000e50:	6fc080e7          	jalr	1788(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000e54:	060a8663          	beqz	s5,80000ec0 <walk+0xa2>
    80000e58:	00000097          	auipc	ra,0x0
    80000e5c:	af8080e7          	jalr	-1288(ra) # 80000950 <kalloc>
    80000e60:	84aa                	mv	s1,a0
    80000e62:	c529                	beqz	a0,80000eac <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000e64:	6605                	lui	a2,0x1
    80000e66:	4581                	li	a1,0
    80000e68:	00000097          	auipc	ra,0x0
    80000e6c:	cf2080e7          	jalr	-782(ra) # 80000b5a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000e70:	00c4d793          	srli	a5,s1,0xc
    80000e74:	07aa                	slli	a5,a5,0xa
    80000e76:	0017e793          	ori	a5,a5,1
    80000e7a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000e7e:	3a5d                	addiw	s4,s4,-9
    80000e80:	036a0063          	beq	s4,s6,80000ea0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000e84:	0149d933          	srl	s2,s3,s4
    80000e88:	1ff97913          	andi	s2,s2,511
    80000e8c:	090e                	slli	s2,s2,0x3
    80000e8e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000e90:	00093483          	ld	s1,0(s2)
    80000e94:	0014f793          	andi	a5,s1,1
    80000e98:	dfd5                	beqz	a5,80000e54 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000e9a:	80a9                	srli	s1,s1,0xa
    80000e9c:	04b2                	slli	s1,s1,0xc
    80000e9e:	b7c5                	j	80000e7e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000ea0:	00c9d513          	srli	a0,s3,0xc
    80000ea4:	1ff57513          	andi	a0,a0,511
    80000ea8:	050e                	slli	a0,a0,0x3
    80000eaa:	9526                	add	a0,a0,s1
}
    80000eac:	70e2                	ld	ra,56(sp)
    80000eae:	7442                	ld	s0,48(sp)
    80000eb0:	74a2                	ld	s1,40(sp)
    80000eb2:	7902                	ld	s2,32(sp)
    80000eb4:	69e2                	ld	s3,24(sp)
    80000eb6:	6a42                	ld	s4,16(sp)
    80000eb8:	6aa2                	ld	s5,8(sp)
    80000eba:	6b02                	ld	s6,0(sp)
    80000ebc:	6121                	addi	sp,sp,64
    80000ebe:	8082                	ret
        return 0;
    80000ec0:	4501                	li	a0,0
    80000ec2:	b7ed                	j	80000eac <walk+0x8e>

0000000080000ec4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80000ec4:	7179                	addi	sp,sp,-48
    80000ec6:	f406                	sd	ra,40(sp)
    80000ec8:	f022                	sd	s0,32(sp)
    80000eca:	ec26                	sd	s1,24(sp)
    80000ecc:	e84a                	sd	s2,16(sp)
    80000ece:	e44e                	sd	s3,8(sp)
    80000ed0:	e052                	sd	s4,0(sp)
    80000ed2:	1800                	addi	s0,sp,48
    80000ed4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000ed6:	84aa                	mv	s1,a0
    80000ed8:	6905                	lui	s2,0x1
    80000eda:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000edc:	4985                	li	s3,1
    80000ede:	a821                	j	80000ef6 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000ee0:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000ee2:	0532                	slli	a0,a0,0xc
    80000ee4:	00000097          	auipc	ra,0x0
    80000ee8:	fe0080e7          	jalr	-32(ra) # 80000ec4 <freewalk>
      pagetable[i] = 0;
    80000eec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000ef0:	04a1                	addi	s1,s1,8
    80000ef2:	03248163          	beq	s1,s2,80000f14 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000ef6:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000ef8:	00f57793          	andi	a5,a0,15
    80000efc:	ff3782e3          	beq	a5,s3,80000ee0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000f00:	8905                	andi	a0,a0,1
    80000f02:	d57d                	beqz	a0,80000ef0 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	2bc50513          	addi	a0,a0,700 # 800071c0 <userret+0x130>
    80000f0c:	fffff097          	auipc	ra,0xfffff
    80000f10:	63c080e7          	jalr	1596(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80000f14:	8552                	mv	a0,s4
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	93e080e7          	jalr	-1730(ra) # 80000854 <kfree>
}
    80000f1e:	70a2                	ld	ra,40(sp)
    80000f20:	7402                	ld	s0,32(sp)
    80000f22:	64e2                	ld	s1,24(sp)
    80000f24:	6942                	ld	s2,16(sp)
    80000f26:	69a2                	ld	s3,8(sp)
    80000f28:	6a02                	ld	s4,0(sp)
    80000f2a:	6145                	addi	sp,sp,48
    80000f2c:	8082                	ret

0000000080000f2e <kvminithart>:
{
    80000f2e:	1141                	addi	sp,sp,-16
    80000f30:	e422                	sd	s0,8(sp)
    80000f32:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f34:	00025797          	auipc	a5,0x25
    80000f38:	0d47b783          	ld	a5,212(a5) # 80026008 <kernel_pagetable>
    80000f3c:	83b1                	srli	a5,a5,0xc
    80000f3e:	577d                	li	a4,-1
    80000f40:	177e                	slli	a4,a4,0x3f
    80000f42:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f44:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f48:	12000073          	sfence.vma
}
    80000f4c:	6422                	ld	s0,8(sp)
    80000f4e:	0141                	addi	sp,sp,16
    80000f50:	8082                	ret

0000000080000f52 <walkaddr>:
  if(va >= MAXVA)
    80000f52:	57fd                	li	a5,-1
    80000f54:	83e9                	srli	a5,a5,0x1a
    80000f56:	00b7f463          	bgeu	a5,a1,80000f5e <walkaddr+0xc>
    return 0;
    80000f5a:	4501                	li	a0,0
}
    80000f5c:	8082                	ret
{
    80000f5e:	1141                	addi	sp,sp,-16
    80000f60:	e406                	sd	ra,8(sp)
    80000f62:	e022                	sd	s0,0(sp)
    80000f64:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f66:	4601                	li	a2,0
    80000f68:	00000097          	auipc	ra,0x0
    80000f6c:	eb6080e7          	jalr	-330(ra) # 80000e1e <walk>
  if(pte == 0)
    80000f70:	c105                	beqz	a0,80000f90 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000f72:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f74:	0117f693          	andi	a3,a5,17
    80000f78:	4745                	li	a4,17
    return 0;
    80000f7a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f7c:	00e68663          	beq	a3,a4,80000f88 <walkaddr+0x36>
}
    80000f80:	60a2                	ld	ra,8(sp)
    80000f82:	6402                	ld	s0,0(sp)
    80000f84:	0141                	addi	sp,sp,16
    80000f86:	8082                	ret
  pa = PTE2PA(*pte);
    80000f88:	00a7d513          	srli	a0,a5,0xa
    80000f8c:	0532                	slli	a0,a0,0xc
  return pa;
    80000f8e:	bfcd                	j	80000f80 <walkaddr+0x2e>
    return 0;
    80000f90:	4501                	li	a0,0
    80000f92:	b7fd                	j	80000f80 <walkaddr+0x2e>

0000000080000f94 <kvmpa>:
{
    80000f94:	1101                	addi	sp,sp,-32
    80000f96:	ec06                	sd	ra,24(sp)
    80000f98:	e822                	sd	s0,16(sp)
    80000f9a:	e426                	sd	s1,8(sp)
    80000f9c:	1000                	addi	s0,sp,32
    80000f9e:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80000fa0:	1552                	slli	a0,a0,0x34
    80000fa2:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80000fa6:	4601                	li	a2,0
    80000fa8:	00025517          	auipc	a0,0x25
    80000fac:	06053503          	ld	a0,96(a0) # 80026008 <kernel_pagetable>
    80000fb0:	00000097          	auipc	ra,0x0
    80000fb4:	e6e080e7          	jalr	-402(ra) # 80000e1e <walk>
  if(pte == 0)
    80000fb8:	cd09                	beqz	a0,80000fd2 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80000fba:	6108                	ld	a0,0(a0)
    80000fbc:	00157793          	andi	a5,a0,1
    80000fc0:	c38d                	beqz	a5,80000fe2 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80000fc2:	8129                	srli	a0,a0,0xa
    80000fc4:	0532                	slli	a0,a0,0xc
}
    80000fc6:	9526                	add	a0,a0,s1
    80000fc8:	60e2                	ld	ra,24(sp)
    80000fca:	6442                	ld	s0,16(sp)
    80000fcc:	64a2                	ld	s1,8(sp)
    80000fce:	6105                	addi	sp,sp,32
    80000fd0:	8082                	ret
    panic("kvmpa");
    80000fd2:	00006517          	auipc	a0,0x6
    80000fd6:	1fe50513          	addi	a0,a0,510 # 800071d0 <userret+0x140>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	56e080e7          	jalr	1390(ra) # 80000548 <panic>
    panic("kvmpa");
    80000fe2:	00006517          	auipc	a0,0x6
    80000fe6:	1ee50513          	addi	a0,a0,494 # 800071d0 <userret+0x140>
    80000fea:	fffff097          	auipc	ra,0xfffff
    80000fee:	55e080e7          	jalr	1374(ra) # 80000548 <panic>

0000000080000ff2 <mappages>:
{
    80000ff2:	715d                	addi	sp,sp,-80
    80000ff4:	e486                	sd	ra,72(sp)
    80000ff6:	e0a2                	sd	s0,64(sp)
    80000ff8:	fc26                	sd	s1,56(sp)
    80000ffa:	f84a                	sd	s2,48(sp)
    80000ffc:	f44e                	sd	s3,40(sp)
    80000ffe:	f052                	sd	s4,32(sp)
    80001000:	ec56                	sd	s5,24(sp)
    80001002:	e85a                	sd	s6,16(sp)
    80001004:	e45e                	sd	s7,8(sp)
    80001006:	0880                	addi	s0,sp,80
    80001008:	8aaa                	mv	s5,a0
    8000100a:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    8000100c:	777d                	lui	a4,0xfffff
    8000100e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001012:	167d                	addi	a2,a2,-1
    80001014:	00b609b3          	add	s3,a2,a1
    80001018:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000101c:	893e                	mv	s2,a5
    8000101e:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001022:	6b85                	lui	s7,0x1
    80001024:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001028:	4605                	li	a2,1
    8000102a:	85ca                	mv	a1,s2
    8000102c:	8556                	mv	a0,s5
    8000102e:	00000097          	auipc	ra,0x0
    80001032:	df0080e7          	jalr	-528(ra) # 80000e1e <walk>
    80001036:	c51d                	beqz	a0,80001064 <mappages+0x72>
    if(*pte & PTE_V)
    80001038:	611c                	ld	a5,0(a0)
    8000103a:	8b85                	andi	a5,a5,1
    8000103c:	ef81                	bnez	a5,80001054 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103e:	80b1                	srli	s1,s1,0xc
    80001040:	04aa                	slli	s1,s1,0xa
    80001042:	0164e4b3          	or	s1,s1,s6
    80001046:	0014e493          	ori	s1,s1,1
    8000104a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104c:	03390863          	beq	s2,s3,8000107c <mappages+0x8a>
    a += PGSIZE;
    80001050:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001052:	bfc9                	j	80001024 <mappages+0x32>
      panic("remap");
    80001054:	00006517          	auipc	a0,0x6
    80001058:	18450513          	addi	a0,a0,388 # 800071d8 <userret+0x148>
    8000105c:	fffff097          	auipc	ra,0xfffff
    80001060:	4ec080e7          	jalr	1260(ra) # 80000548 <panic>
      return -1;
    80001064:	557d                	li	a0,-1
}
    80001066:	60a6                	ld	ra,72(sp)
    80001068:	6406                	ld	s0,64(sp)
    8000106a:	74e2                	ld	s1,56(sp)
    8000106c:	7942                	ld	s2,48(sp)
    8000106e:	79a2                	ld	s3,40(sp)
    80001070:	7a02                	ld	s4,32(sp)
    80001072:	6ae2                	ld	s5,24(sp)
    80001074:	6b42                	ld	s6,16(sp)
    80001076:	6ba2                	ld	s7,8(sp)
    80001078:	6161                	addi	sp,sp,80
    8000107a:	8082                	ret
  return 0;
    8000107c:	4501                	li	a0,0
    8000107e:	b7e5                	j	80001066 <mappages+0x74>

0000000080001080 <kvmmap>:
{
    80001080:	1141                	addi	sp,sp,-16
    80001082:	e406                	sd	ra,8(sp)
    80001084:	e022                	sd	s0,0(sp)
    80001086:	0800                	addi	s0,sp,16
    80001088:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000108a:	86ae                	mv	a3,a1
    8000108c:	85aa                	mv	a1,a0
    8000108e:	00025517          	auipc	a0,0x25
    80001092:	f7a53503          	ld	a0,-134(a0) # 80026008 <kernel_pagetable>
    80001096:	00000097          	auipc	ra,0x0
    8000109a:	f5c080e7          	jalr	-164(ra) # 80000ff2 <mappages>
    8000109e:	e509                	bnez	a0,800010a8 <kvmmap+0x28>
}
    800010a0:	60a2                	ld	ra,8(sp)
    800010a2:	6402                	ld	s0,0(sp)
    800010a4:	0141                	addi	sp,sp,16
    800010a6:	8082                	ret
    panic("kvmmap");
    800010a8:	00006517          	auipc	a0,0x6
    800010ac:	13850513          	addi	a0,a0,312 # 800071e0 <userret+0x150>
    800010b0:	fffff097          	auipc	ra,0xfffff
    800010b4:	498080e7          	jalr	1176(ra) # 80000548 <panic>

00000000800010b8 <kvminit>:
{
    800010b8:	1101                	addi	sp,sp,-32
    800010ba:	ec06                	sd	ra,24(sp)
    800010bc:	e822                	sd	s0,16(sp)
    800010be:	e426                	sd	s1,8(sp)
    800010c0:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800010c2:	00000097          	auipc	ra,0x0
    800010c6:	88e080e7          	jalr	-1906(ra) # 80000950 <kalloc>
    800010ca:	00025797          	auipc	a5,0x25
    800010ce:	f2a7bf23          	sd	a0,-194(a5) # 80026008 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800010d2:	6605                	lui	a2,0x1
    800010d4:	4581                	li	a1,0
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	a84080e7          	jalr	-1404(ra) # 80000b5a <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010de:	4699                	li	a3,6
    800010e0:	6605                	lui	a2,0x1
    800010e2:	100005b7          	lui	a1,0x10000
    800010e6:	10000537          	lui	a0,0x10000
    800010ea:	00000097          	auipc	ra,0x0
    800010ee:	f96080e7          	jalr	-106(ra) # 80001080 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4699                	li	a3,6
    800010f4:	6605                	lui	a2,0x1
    800010f6:	100015b7          	lui	a1,0x10001
    800010fa:	10001537          	lui	a0,0x10001
    800010fe:	00000097          	auipc	ra,0x0
    80001102:	f82080e7          	jalr	-126(ra) # 80001080 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001106:	4699                	li	a3,6
    80001108:	6641                	lui	a2,0x10
    8000110a:	020005b7          	lui	a1,0x2000
    8000110e:	02000537          	lui	a0,0x2000
    80001112:	00000097          	auipc	ra,0x0
    80001116:	f6e080e7          	jalr	-146(ra) # 80001080 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000111a:	4699                	li	a3,6
    8000111c:	00400637          	lui	a2,0x400
    80001120:	0c0005b7          	lui	a1,0xc000
    80001124:	0c000537          	lui	a0,0xc000
    80001128:	00000097          	auipc	ra,0x0
    8000112c:	f58080e7          	jalr	-168(ra) # 80001080 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001130:	00007497          	auipc	s1,0x7
    80001134:	ed048493          	addi	s1,s1,-304 # 80008000 <initcode>
    80001138:	46a9                	li	a3,10
    8000113a:	80007617          	auipc	a2,0x80007
    8000113e:	ec660613          	addi	a2,a2,-314 # 8000 <_entry-0x7fff8000>
    80001142:	4585                	li	a1,1
    80001144:	05fe                	slli	a1,a1,0x1f
    80001146:	852e                	mv	a0,a1
    80001148:	00000097          	auipc	ra,0x0
    8000114c:	f38080e7          	jalr	-200(ra) # 80001080 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001150:	4699                	li	a3,6
    80001152:	4645                	li	a2,17
    80001154:	066e                	slli	a2,a2,0x1b
    80001156:	8e05                	sub	a2,a2,s1
    80001158:	85a6                	mv	a1,s1
    8000115a:	8526                	mv	a0,s1
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	f24080e7          	jalr	-220(ra) # 80001080 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001164:	46a9                	li	a3,10
    80001166:	6605                	lui	a2,0x1
    80001168:	00006597          	auipc	a1,0x6
    8000116c:	e9858593          	addi	a1,a1,-360 # 80007000 <trampoline>
    80001170:	04000537          	lui	a0,0x4000
    80001174:	157d                	addi	a0,a0,-1
    80001176:	0532                	slli	a0,a0,0xc
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	f08080e7          	jalr	-248(ra) # 80001080 <kvmmap>
}
    80001180:	60e2                	ld	ra,24(sp)
    80001182:	6442                	ld	s0,16(sp)
    80001184:	64a2                	ld	s1,8(sp)
    80001186:	6105                	addi	sp,sp,32
    80001188:	8082                	ret

000000008000118a <uvmunmap>:
{
    8000118a:	715d                	addi	sp,sp,-80
    8000118c:	e486                	sd	ra,72(sp)
    8000118e:	e0a2                	sd	s0,64(sp)
    80001190:	fc26                	sd	s1,56(sp)
    80001192:	f84a                	sd	s2,48(sp)
    80001194:	f44e                	sd	s3,40(sp)
    80001196:	f052                	sd	s4,32(sp)
    80001198:	ec56                	sd	s5,24(sp)
    8000119a:	e85a                	sd	s6,16(sp)
    8000119c:	e45e                	sd	s7,8(sp)
    8000119e:	0880                	addi	s0,sp,80
    800011a0:	8a2a                	mv	s4,a0
    800011a2:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800011a4:	77fd                	lui	a5,0xfffff
    800011a6:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800011aa:	167d                	addi	a2,a2,-1
    800011ac:	00b609b3          	add	s3,a2,a1
    800011b0:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800011b4:	4b05                	li	s6,1
    a += PGSIZE;
    800011b6:	6b85                	lui	s7,0x1
    800011b8:	a0b9                	j	80001206 <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    800011ba:	00006517          	auipc	a0,0x6
    800011be:	02e50513          	addi	a0,a0,46 # 800071e8 <userret+0x158>
    800011c2:	fffff097          	auipc	ra,0xfffff
    800011c6:	386080e7          	jalr	902(ra) # 80000548 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800011ca:	85ca                	mv	a1,s2
    800011cc:	00006517          	auipc	a0,0x6
    800011d0:	02c50513          	addi	a0,a0,44 # 800071f8 <userret+0x168>
    800011d4:	fffff097          	auipc	ra,0xfffff
    800011d8:	3be080e7          	jalr	958(ra) # 80000592 <printf>
      panic("uvmunmap: not mapped");
    800011dc:	00006517          	auipc	a0,0x6
    800011e0:	02c50513          	addi	a0,a0,44 # 80007208 <userret+0x178>
    800011e4:	fffff097          	auipc	ra,0xfffff
    800011e8:	364080e7          	jalr	868(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800011ec:	00006517          	auipc	a0,0x6
    800011f0:	03450513          	addi	a0,a0,52 # 80007220 <userret+0x190>
    800011f4:	fffff097          	auipc	ra,0xfffff
    800011f8:	354080e7          	jalr	852(ra) # 80000548 <panic>
    *pte = 0;
    800011fc:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001200:	03390e63          	beq	s2,s3,8000123c <uvmunmap+0xb2>
    a += PGSIZE;
    80001204:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001206:	4601                	li	a2,0
    80001208:	85ca                	mv	a1,s2
    8000120a:	8552                	mv	a0,s4
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	c12080e7          	jalr	-1006(ra) # 80000e1e <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d155                	beqz	a0,800011ba <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001218:	6110                	ld	a2,0(a0)
    8000121a:	00167793          	andi	a5,a2,1
    8000121e:	d7d5                	beqz	a5,800011ca <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001220:	3ff67793          	andi	a5,a2,1023
    80001224:	fd6784e3          	beq	a5,s6,800011ec <uvmunmap+0x62>
    if(do_free){
    80001228:	fc0a8ae3          	beqz	s5,800011fc <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    8000122c:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    8000122e:	00c61513          	slli	a0,a2,0xc
    80001232:	fffff097          	auipc	ra,0xfffff
    80001236:	622080e7          	jalr	1570(ra) # 80000854 <kfree>
    8000123a:	b7c9                	j	800011fc <uvmunmap+0x72>
}
    8000123c:	60a6                	ld	ra,72(sp)
    8000123e:	6406                	ld	s0,64(sp)
    80001240:	74e2                	ld	s1,56(sp)
    80001242:	7942                	ld	s2,48(sp)
    80001244:	79a2                	ld	s3,40(sp)
    80001246:	7a02                	ld	s4,32(sp)
    80001248:	6ae2                	ld	s5,24(sp)
    8000124a:	6b42                	ld	s6,16(sp)
    8000124c:	6ba2                	ld	s7,8(sp)
    8000124e:	6161                	addi	sp,sp,80
    80001250:	8082                	ret

0000000080001252 <uvmcreate>:
{
    80001252:	1101                	addi	sp,sp,-32
    80001254:	ec06                	sd	ra,24(sp)
    80001256:	e822                	sd	s0,16(sp)
    80001258:	e426                	sd	s1,8(sp)
    8000125a:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000125c:	fffff097          	auipc	ra,0xfffff
    80001260:	6f4080e7          	jalr	1780(ra) # 80000950 <kalloc>
  if(pagetable == 0)
    80001264:	cd11                	beqz	a0,80001280 <uvmcreate+0x2e>
    80001266:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001268:	6605                	lui	a2,0x1
    8000126a:	4581                	li	a1,0
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	8ee080e7          	jalr	-1810(ra) # 80000b5a <memset>
}
    80001274:	8526                	mv	a0,s1
    80001276:	60e2                	ld	ra,24(sp)
    80001278:	6442                	ld	s0,16(sp)
    8000127a:	64a2                	ld	s1,8(sp)
    8000127c:	6105                	addi	sp,sp,32
    8000127e:	8082                	ret
    panic("uvmcreate: out of memory");
    80001280:	00006517          	auipc	a0,0x6
    80001284:	fb850513          	addi	a0,a0,-72 # 80007238 <userret+0x1a8>
    80001288:	fffff097          	auipc	ra,0xfffff
    8000128c:	2c0080e7          	jalr	704(ra) # 80000548 <panic>

0000000080001290 <uvminit>:
{
    80001290:	7179                	addi	sp,sp,-48
    80001292:	f406                	sd	ra,40(sp)
    80001294:	f022                	sd	s0,32(sp)
    80001296:	ec26                	sd	s1,24(sp)
    80001298:	e84a                	sd	s2,16(sp)
    8000129a:	e44e                	sd	s3,8(sp)
    8000129c:	e052                	sd	s4,0(sp)
    8000129e:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800012a0:	6785                	lui	a5,0x1
    800012a2:	04f67863          	bgeu	a2,a5,800012f2 <uvminit+0x62>
    800012a6:	8a2a                	mv	s4,a0
    800012a8:	89ae                	mv	s3,a1
    800012aa:	84b2                	mv	s1,a2
  mem = kalloc();
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	6a4080e7          	jalr	1700(ra) # 80000950 <kalloc>
    800012b4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012b6:	6605                	lui	a2,0x1
    800012b8:	4581                	li	a1,0
    800012ba:	00000097          	auipc	ra,0x0
    800012be:	8a0080e7          	jalr	-1888(ra) # 80000b5a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c2:	4779                	li	a4,30
    800012c4:	86ca                	mv	a3,s2
    800012c6:	6605                	lui	a2,0x1
    800012c8:	4581                	li	a1,0
    800012ca:	8552                	mv	a0,s4
    800012cc:	00000097          	auipc	ra,0x0
    800012d0:	d26080e7          	jalr	-730(ra) # 80000ff2 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	00000097          	auipc	ra,0x0
    800012de:	8dc080e7          	jalr	-1828(ra) # 80000bb6 <memmove>
}
    800012e2:	70a2                	ld	ra,40(sp)
    800012e4:	7402                	ld	s0,32(sp)
    800012e6:	64e2                	ld	s1,24(sp)
    800012e8:	6942                	ld	s2,16(sp)
    800012ea:	69a2                	ld	s3,8(sp)
    800012ec:	6a02                	ld	s4,0(sp)
    800012ee:	6145                	addi	sp,sp,48
    800012f0:	8082                	ret
    panic("inituvm: more than a page");
    800012f2:	00006517          	auipc	a0,0x6
    800012f6:	f6650513          	addi	a0,a0,-154 # 80007258 <userret+0x1c8>
    800012fa:	fffff097          	auipc	ra,0xfffff
    800012fe:	24e080e7          	jalr	590(ra) # 80000548 <panic>

0000000080001302 <uvmdealloc>:
{
    80001302:	1101                	addi	sp,sp,-32
    80001304:	ec06                	sd	ra,24(sp)
    80001306:	e822                	sd	s0,16(sp)
    80001308:	e426                	sd	s1,8(sp)
    8000130a:	1000                	addi	s0,sp,32
    return oldsz;
    8000130c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000130e:	00b67d63          	bgeu	a2,a1,80001328 <uvmdealloc+0x26>
    80001312:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1
    80001318:	00f60733          	add	a4,a2,a5
    8000131c:	76fd                	lui	a3,0xfffff
    8000131e:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001320:	97ae                	add	a5,a5,a1
    80001322:	8ff5                	and	a5,a5,a3
    80001324:	00f76863          	bltu	a4,a5,80001334 <uvmdealloc+0x32>
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001334:	4685                	li	a3,1
    80001336:	40e58633          	sub	a2,a1,a4
    8000133a:	85ba                	mv	a1,a4
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	e4e080e7          	jalr	-434(ra) # 8000118a <uvmunmap>
    80001344:	b7d5                	j	80001328 <uvmdealloc+0x26>

0000000080001346 <uvmalloc>:
  if(newsz < oldsz)
    80001346:	0ab66163          	bltu	a2,a1,800013e8 <uvmalloc+0xa2>
{
    8000134a:	7139                	addi	sp,sp,-64
    8000134c:	fc06                	sd	ra,56(sp)
    8000134e:	f822                	sd	s0,48(sp)
    80001350:	f426                	sd	s1,40(sp)
    80001352:	f04a                	sd	s2,32(sp)
    80001354:	ec4e                	sd	s3,24(sp)
    80001356:	e852                	sd	s4,16(sp)
    80001358:	e456                	sd	s5,8(sp)
    8000135a:	0080                	addi	s0,sp,64
    8000135c:	8aaa                	mv	s5,a0
    8000135e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001360:	6985                	lui	s3,0x1
    80001362:	19fd                	addi	s3,s3,-1
    80001364:	95ce                	add	a1,a1,s3
    80001366:	79fd                	lui	s3,0xfffff
    80001368:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    8000136c:	08c9f063          	bgeu	s3,a2,800013ec <uvmalloc+0xa6>
  a = oldsz;
    80001370:	894e                	mv	s2,s3
    mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	5de080e7          	jalr	1502(ra) # 80000950 <kalloc>
    8000137a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000137c:	c51d                	beqz	a0,800013aa <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000137e:	6605                	lui	a2,0x1
    80001380:	4581                	li	a1,0
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	7d8080e7          	jalr	2008(ra) # 80000b5a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000138a:	4779                	li	a4,30
    8000138c:	86a6                	mv	a3,s1
    8000138e:	6605                	lui	a2,0x1
    80001390:	85ca                	mv	a1,s2
    80001392:	8556                	mv	a0,s5
    80001394:	00000097          	auipc	ra,0x0
    80001398:	c5e080e7          	jalr	-930(ra) # 80000ff2 <mappages>
    8000139c:	e905                	bnez	a0,800013cc <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    8000139e:	6785                	lui	a5,0x1
    800013a0:	993e                	add	s2,s2,a5
    800013a2:	fd4968e3          	bltu	s2,s4,80001372 <uvmalloc+0x2c>
  return newsz;
    800013a6:	8552                	mv	a0,s4
    800013a8:	a809                	j	800013ba <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800013aa:	864e                	mv	a2,s3
    800013ac:	85ca                	mv	a1,s2
    800013ae:	8556                	mv	a0,s5
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	f52080e7          	jalr	-174(ra) # 80001302 <uvmdealloc>
      return 0;
    800013b8:	4501                	li	a0,0
}
    800013ba:	70e2                	ld	ra,56(sp)
    800013bc:	7442                	ld	s0,48(sp)
    800013be:	74a2                	ld	s1,40(sp)
    800013c0:	7902                	ld	s2,32(sp)
    800013c2:	69e2                	ld	s3,24(sp)
    800013c4:	6a42                	ld	s4,16(sp)
    800013c6:	6aa2                	ld	s5,8(sp)
    800013c8:	6121                	addi	sp,sp,64
    800013ca:	8082                	ret
      kfree(mem);
    800013cc:	8526                	mv	a0,s1
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	486080e7          	jalr	1158(ra) # 80000854 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013d6:	864e                	mv	a2,s3
    800013d8:	85ca                	mv	a1,s2
    800013da:	8556                	mv	a0,s5
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	f26080e7          	jalr	-218(ra) # 80001302 <uvmdealloc>
      return 0;
    800013e4:	4501                	li	a0,0
    800013e6:	bfd1                	j	800013ba <uvmalloc+0x74>
    return oldsz;
    800013e8:	852e                	mv	a0,a1
}
    800013ea:	8082                	ret
  return newsz;
    800013ec:	8532                	mv	a0,a2
    800013ee:	b7f1                	j	800013ba <uvmalloc+0x74>

00000000800013f0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013f0:	1101                	addi	sp,sp,-32
    800013f2:	ec06                	sd	ra,24(sp)
    800013f4:	e822                	sd	s0,16(sp)
    800013f6:	e426                	sd	s1,8(sp)
    800013f8:	1000                	addi	s0,sp,32
    800013fa:	84aa                	mv	s1,a0
    800013fc:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    800013fe:	4685                	li	a3,1
    80001400:	4581                	li	a1,0
    80001402:	00000097          	auipc	ra,0x0
    80001406:	d88080e7          	jalr	-632(ra) # 8000118a <uvmunmap>
  freewalk(pagetable);
    8000140a:	8526                	mv	a0,s1
    8000140c:	00000097          	auipc	ra,0x0
    80001410:	ab8080e7          	jalr	-1352(ra) # 80000ec4 <freewalk>
}
    80001414:	60e2                	ld	ra,24(sp)
    80001416:	6442                	ld	s0,16(sp)
    80001418:	64a2                	ld	s1,8(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000141e:	c671                	beqz	a2,800014ea <uvmcopy+0xcc>
{
    80001420:	715d                	addi	sp,sp,-80
    80001422:	e486                	sd	ra,72(sp)
    80001424:	e0a2                	sd	s0,64(sp)
    80001426:	fc26                	sd	s1,56(sp)
    80001428:	f84a                	sd	s2,48(sp)
    8000142a:	f44e                	sd	s3,40(sp)
    8000142c:	f052                	sd	s4,32(sp)
    8000142e:	ec56                	sd	s5,24(sp)
    80001430:	e85a                	sd	s6,16(sp)
    80001432:	e45e                	sd	s7,8(sp)
    80001434:	0880                	addi	s0,sp,80
    80001436:	8b2a                	mv	s6,a0
    80001438:	8aae                	mv	s5,a1
    8000143a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000143c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000143e:	4601                	li	a2,0
    80001440:	85ce                	mv	a1,s3
    80001442:	855a                	mv	a0,s6
    80001444:	00000097          	auipc	ra,0x0
    80001448:	9da080e7          	jalr	-1574(ra) # 80000e1e <walk>
    8000144c:	c531                	beqz	a0,80001498 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000144e:	6118                	ld	a4,0(a0)
    80001450:	00177793          	andi	a5,a4,1
    80001454:	cbb1                	beqz	a5,800014a8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001456:	00a75593          	srli	a1,a4,0xa
    8000145a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000145e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001462:	fffff097          	auipc	ra,0xfffff
    80001466:	4ee080e7          	jalr	1262(ra) # 80000950 <kalloc>
    8000146a:	892a                	mv	s2,a0
    8000146c:	c939                	beqz	a0,800014c2 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000146e:	6605                	lui	a2,0x1
    80001470:	85de                	mv	a1,s7
    80001472:	fffff097          	auipc	ra,0xfffff
    80001476:	744080e7          	jalr	1860(ra) # 80000bb6 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000147a:	8726                	mv	a4,s1
    8000147c:	86ca                	mv	a3,s2
    8000147e:	6605                	lui	a2,0x1
    80001480:	85ce                	mv	a1,s3
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	b6e080e7          	jalr	-1170(ra) # 80000ff2 <mappages>
    8000148c:	e515                	bnez	a0,800014b8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000148e:	6785                	lui	a5,0x1
    80001490:	99be                	add	s3,s3,a5
    80001492:	fb49e6e3          	bltu	s3,s4,8000143e <uvmcopy+0x20>
    80001496:	a83d                	j	800014d4 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    80001498:	00006517          	auipc	a0,0x6
    8000149c:	de050513          	addi	a0,a0,-544 # 80007278 <userret+0x1e8>
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	0a8080e7          	jalr	168(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800014a8:	00006517          	auipc	a0,0x6
    800014ac:	df050513          	addi	a0,a0,-528 # 80007298 <userret+0x208>
    800014b0:	fffff097          	auipc	ra,0xfffff
    800014b4:	098080e7          	jalr	152(ra) # 80000548 <panic>
      kfree(mem);
    800014b8:	854a                	mv	a0,s2
    800014ba:	fffff097          	auipc	ra,0xfffff
    800014be:	39a080e7          	jalr	922(ra) # 80000854 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800014c2:	4685                	li	a3,1
    800014c4:	864e                	mv	a2,s3
    800014c6:	4581                	li	a1,0
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	cc0080e7          	jalr	-832(ra) # 8000118a <uvmunmap>
  return -1;
    800014d2:	557d                	li	a0,-1
}
    800014d4:	60a6                	ld	ra,72(sp)
    800014d6:	6406                	ld	s0,64(sp)
    800014d8:	74e2                	ld	s1,56(sp)
    800014da:	7942                	ld	s2,48(sp)
    800014dc:	79a2                	ld	s3,40(sp)
    800014de:	7a02                	ld	s4,32(sp)
    800014e0:	6ae2                	ld	s5,24(sp)
    800014e2:	6b42                	ld	s6,16(sp)
    800014e4:	6ba2                	ld	s7,8(sp)
    800014e6:	6161                	addi	sp,sp,80
    800014e8:	8082                	ret
  return 0;
    800014ea:	4501                	li	a0,0
}
    800014ec:	8082                	ret

00000000800014ee <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ee:	1141                	addi	sp,sp,-16
    800014f0:	e406                	sd	ra,8(sp)
    800014f2:	e022                	sd	s0,0(sp)
    800014f4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014f6:	4601                	li	a2,0
    800014f8:	00000097          	auipc	ra,0x0
    800014fc:	926080e7          	jalr	-1754(ra) # 80000e1e <walk>
  if(pte == 0)
    80001500:	c901                	beqz	a0,80001510 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001502:	611c                	ld	a5,0(a0)
    80001504:	9bbd                	andi	a5,a5,-17
    80001506:	e11c                	sd	a5,0(a0)
}
    80001508:	60a2                	ld	ra,8(sp)
    8000150a:	6402                	ld	s0,0(sp)
    8000150c:	0141                	addi	sp,sp,16
    8000150e:	8082                	ret
    panic("uvmclear");
    80001510:	00006517          	auipc	a0,0x6
    80001514:	da850513          	addi	a0,a0,-600 # 800072b8 <userret+0x228>
    80001518:	fffff097          	auipc	ra,0xfffff
    8000151c:	030080e7          	jalr	48(ra) # 80000548 <panic>

0000000080001520 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001520:	c6bd                	beqz	a3,8000158e <copyout+0x6e>
{
    80001522:	715d                	addi	sp,sp,-80
    80001524:	e486                	sd	ra,72(sp)
    80001526:	e0a2                	sd	s0,64(sp)
    80001528:	fc26                	sd	s1,56(sp)
    8000152a:	f84a                	sd	s2,48(sp)
    8000152c:	f44e                	sd	s3,40(sp)
    8000152e:	f052                	sd	s4,32(sp)
    80001530:	ec56                	sd	s5,24(sp)
    80001532:	e85a                	sd	s6,16(sp)
    80001534:	e45e                	sd	s7,8(sp)
    80001536:	e062                	sd	s8,0(sp)
    80001538:	0880                	addi	s0,sp,80
    8000153a:	8b2a                	mv	s6,a0
    8000153c:	8c2e                	mv	s8,a1
    8000153e:	8a32                	mv	s4,a2
    80001540:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001542:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001544:	6a85                	lui	s5,0x1
    80001546:	a015                	j	8000156a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001548:	9562                	add	a0,a0,s8
    8000154a:	0004861b          	sext.w	a2,s1
    8000154e:	85d2                	mv	a1,s4
    80001550:	41250533          	sub	a0,a0,s2
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	662080e7          	jalr	1634(ra) # 80000bb6 <memmove>

    len -= n;
    8000155c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001560:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001562:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001566:	02098263          	beqz	s3,8000158a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000156a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000156e:	85ca                	mv	a1,s2
    80001570:	855a                	mv	a0,s6
    80001572:	00000097          	auipc	ra,0x0
    80001576:	9e0080e7          	jalr	-1568(ra) # 80000f52 <walkaddr>
    if(pa0 == 0)
    8000157a:	cd01                	beqz	a0,80001592 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000157c:	418904b3          	sub	s1,s2,s8
    80001580:	94d6                	add	s1,s1,s5
    if(n > len)
    80001582:	fc99f3e3          	bgeu	s3,s1,80001548 <copyout+0x28>
    80001586:	84ce                	mv	s1,s3
    80001588:	b7c1                	j	80001548 <copyout+0x28>
  }
  return 0;
    8000158a:	4501                	li	a0,0
    8000158c:	a021                	j	80001594 <copyout+0x74>
    8000158e:	4501                	li	a0,0
}
    80001590:	8082                	ret
      return -1;
    80001592:	557d                	li	a0,-1
}
    80001594:	60a6                	ld	ra,72(sp)
    80001596:	6406                	ld	s0,64(sp)
    80001598:	74e2                	ld	s1,56(sp)
    8000159a:	7942                	ld	s2,48(sp)
    8000159c:	79a2                	ld	s3,40(sp)
    8000159e:	7a02                	ld	s4,32(sp)
    800015a0:	6ae2                	ld	s5,24(sp)
    800015a2:	6b42                	ld	s6,16(sp)
    800015a4:	6ba2                	ld	s7,8(sp)
    800015a6:	6c02                	ld	s8,0(sp)
    800015a8:	6161                	addi	sp,sp,80
    800015aa:	8082                	ret

00000000800015ac <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800015ac:	caa5                	beqz	a3,8000161c <copyin+0x70>
{
    800015ae:	715d                	addi	sp,sp,-80
    800015b0:	e486                	sd	ra,72(sp)
    800015b2:	e0a2                	sd	s0,64(sp)
    800015b4:	fc26                	sd	s1,56(sp)
    800015b6:	f84a                	sd	s2,48(sp)
    800015b8:	f44e                	sd	s3,40(sp)
    800015ba:	f052                	sd	s4,32(sp)
    800015bc:	ec56                	sd	s5,24(sp)
    800015be:	e85a                	sd	s6,16(sp)
    800015c0:	e45e                	sd	s7,8(sp)
    800015c2:	e062                	sd	s8,0(sp)
    800015c4:	0880                	addi	s0,sp,80
    800015c6:	8b2a                	mv	s6,a0
    800015c8:	8a2e                	mv	s4,a1
    800015ca:	8c32                	mv	s8,a2
    800015cc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800015ce:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015d0:	6a85                	lui	s5,0x1
    800015d2:	a01d                	j	800015f8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015d4:	018505b3          	add	a1,a0,s8
    800015d8:	0004861b          	sext.w	a2,s1
    800015dc:	412585b3          	sub	a1,a1,s2
    800015e0:	8552                	mv	a0,s4
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	5d4080e7          	jalr	1492(ra) # 80000bb6 <memmove>

    len -= n;
    800015ea:	409989b3          	sub	s3,s3,s1
    dst += n;
    800015ee:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800015f0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800015f4:	02098263          	beqz	s3,80001618 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800015f8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800015fc:	85ca                	mv	a1,s2
    800015fe:	855a                	mv	a0,s6
    80001600:	00000097          	auipc	ra,0x0
    80001604:	952080e7          	jalr	-1710(ra) # 80000f52 <walkaddr>
    if(pa0 == 0)
    80001608:	cd01                	beqz	a0,80001620 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000160a:	418904b3          	sub	s1,s2,s8
    8000160e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001610:	fc99f2e3          	bgeu	s3,s1,800015d4 <copyin+0x28>
    80001614:	84ce                	mv	s1,s3
    80001616:	bf7d                	j	800015d4 <copyin+0x28>
  }
  return 0;
    80001618:	4501                	li	a0,0
    8000161a:	a021                	j	80001622 <copyin+0x76>
    8000161c:	4501                	li	a0,0
}
    8000161e:	8082                	ret
      return -1;
    80001620:	557d                	li	a0,-1
}
    80001622:	60a6                	ld	ra,72(sp)
    80001624:	6406                	ld	s0,64(sp)
    80001626:	74e2                	ld	s1,56(sp)
    80001628:	7942                	ld	s2,48(sp)
    8000162a:	79a2                	ld	s3,40(sp)
    8000162c:	7a02                	ld	s4,32(sp)
    8000162e:	6ae2                	ld	s5,24(sp)
    80001630:	6b42                	ld	s6,16(sp)
    80001632:	6ba2                	ld	s7,8(sp)
    80001634:	6c02                	ld	s8,0(sp)
    80001636:	6161                	addi	sp,sp,80
    80001638:	8082                	ret

000000008000163a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000163a:	c6c5                	beqz	a3,800016e2 <copyinstr+0xa8>
{
    8000163c:	715d                	addi	sp,sp,-80
    8000163e:	e486                	sd	ra,72(sp)
    80001640:	e0a2                	sd	s0,64(sp)
    80001642:	fc26                	sd	s1,56(sp)
    80001644:	f84a                	sd	s2,48(sp)
    80001646:	f44e                	sd	s3,40(sp)
    80001648:	f052                	sd	s4,32(sp)
    8000164a:	ec56                	sd	s5,24(sp)
    8000164c:	e85a                	sd	s6,16(sp)
    8000164e:	e45e                	sd	s7,8(sp)
    80001650:	0880                	addi	s0,sp,80
    80001652:	8a2a                	mv	s4,a0
    80001654:	8b2e                	mv	s6,a1
    80001656:	8bb2                	mv	s7,a2
    80001658:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000165a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000165c:	6985                	lui	s3,0x1
    8000165e:	a035                	j	8000168a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001660:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001664:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001666:	0017b793          	seqz	a5,a5
    8000166a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000166e:	60a6                	ld	ra,72(sp)
    80001670:	6406                	ld	s0,64(sp)
    80001672:	74e2                	ld	s1,56(sp)
    80001674:	7942                	ld	s2,48(sp)
    80001676:	79a2                	ld	s3,40(sp)
    80001678:	7a02                	ld	s4,32(sp)
    8000167a:	6ae2                	ld	s5,24(sp)
    8000167c:	6b42                	ld	s6,16(sp)
    8000167e:	6ba2                	ld	s7,8(sp)
    80001680:	6161                	addi	sp,sp,80
    80001682:	8082                	ret
    srcva = va0 + PGSIZE;
    80001684:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001688:	c8a9                	beqz	s1,800016da <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000168a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000168e:	85ca                	mv	a1,s2
    80001690:	8552                	mv	a0,s4
    80001692:	00000097          	auipc	ra,0x0
    80001696:	8c0080e7          	jalr	-1856(ra) # 80000f52 <walkaddr>
    if(pa0 == 0)
    8000169a:	c131                	beqz	a0,800016de <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000169c:	41790833          	sub	a6,s2,s7
    800016a0:	984e                	add	a6,a6,s3
    if(n > max)
    800016a2:	0104f363          	bgeu	s1,a6,800016a8 <copyinstr+0x6e>
    800016a6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016a8:	955e                	add	a0,a0,s7
    800016aa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016ae:	fc080be3          	beqz	a6,80001684 <copyinstr+0x4a>
    800016b2:	985a                	add	a6,a6,s6
    800016b4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016b6:	41650633          	sub	a2,a0,s6
    800016ba:	14fd                	addi	s1,s1,-1
    800016bc:	9b26                	add	s6,s6,s1
    800016be:	00f60733          	add	a4,a2,a5
    800016c2:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8fe4>
    800016c6:	df49                	beqz	a4,80001660 <copyinstr+0x26>
        *dst = *p;
    800016c8:	00e78023          	sb	a4,0(a5)
      --max;
    800016cc:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016d0:	0785                	addi	a5,a5,1
    while(n > 0){
    800016d2:	ff0796e3          	bne	a5,a6,800016be <copyinstr+0x84>
      dst++;
    800016d6:	8b42                	mv	s6,a6
    800016d8:	b775                	j	80001684 <copyinstr+0x4a>
    800016da:	4781                	li	a5,0
    800016dc:	b769                	j	80001666 <copyinstr+0x2c>
      return -1;
    800016de:	557d                	li	a0,-1
    800016e0:	b779                	j	8000166e <copyinstr+0x34>
  int got_null = 0;
    800016e2:	4781                	li	a5,0
  if(got_null){
    800016e4:	0017b793          	seqz	a5,a5
    800016e8:	40f00533          	neg	a0,a5
}
    800016ec:	8082                	ret

00000000800016ee <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800016ee:	1101                	addi	sp,sp,-32
    800016f0:	ec06                	sd	ra,24(sp)
    800016f2:	e822                	sd	s0,16(sp)
    800016f4:	e426                	sd	s1,8(sp)
    800016f6:	1000                	addi	s0,sp,32
    800016f8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800016fa:	fffff097          	auipc	ra,0xfffff
    800016fe:	384080e7          	jalr	900(ra) # 80000a7e <holding>
    80001702:	c909                	beqz	a0,80001714 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001704:	749c                	ld	a5,40(s1)
    80001706:	00978f63          	beq	a5,s1,80001724 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000170a:	60e2                	ld	ra,24(sp)
    8000170c:	6442                	ld	s0,16(sp)
    8000170e:	64a2                	ld	s1,8(sp)
    80001710:	6105                	addi	sp,sp,32
    80001712:	8082                	ret
    panic("wakeup1");
    80001714:	00006517          	auipc	a0,0x6
    80001718:	bb450513          	addi	a0,a0,-1100 # 800072c8 <userret+0x238>
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	e2c080e7          	jalr	-468(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001724:	4c98                	lw	a4,24(s1)
    80001726:	4785                	li	a5,1
    80001728:	fef711e3          	bne	a4,a5,8000170a <wakeup1+0x1c>
    p->state = RUNNABLE;
    8000172c:	4789                	li	a5,2
    8000172e:	cc9c                	sw	a5,24(s1)
}
    80001730:	bfe9                	j	8000170a <wakeup1+0x1c>

0000000080001732 <procinit>:
{
    80001732:	715d                	addi	sp,sp,-80
    80001734:	e486                	sd	ra,72(sp)
    80001736:	e0a2                	sd	s0,64(sp)
    80001738:	fc26                	sd	s1,56(sp)
    8000173a:	f84a                	sd	s2,48(sp)
    8000173c:	f44e                	sd	s3,40(sp)
    8000173e:	f052                	sd	s4,32(sp)
    80001740:	ec56                	sd	s5,24(sp)
    80001742:	e85a                	sd	s6,16(sp)
    80001744:	e45e                	sd	s7,8(sp)
    80001746:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001748:	00006597          	auipc	a1,0x6
    8000174c:	b8858593          	addi	a1,a1,-1144 # 800072d0 <userret+0x240>
    80001750:	00010517          	auipc	a0,0x10
    80001754:	19850513          	addi	a0,a0,408 # 800118e8 <pid_lock>
    80001758:	fffff097          	auipc	ra,0xfffff
    8000175c:	258080e7          	jalr	600(ra) # 800009b0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001760:	00010917          	auipc	s2,0x10
    80001764:	5a090913          	addi	s2,s2,1440 # 80011d00 <proc>
      initlock(&p->lock, "proc");
    80001768:	00006b97          	auipc	s7,0x6
    8000176c:	b70b8b93          	addi	s7,s7,-1168 # 800072d8 <userret+0x248>
      uint64 va = KSTACK((int) (p - proc));
    80001770:	8b4a                	mv	s6,s2
    80001772:	00006a97          	auipc	s5,0x6
    80001776:	60ea8a93          	addi	s5,s5,1550 # 80007d80 <syscalls+0xd0>
    8000177a:	040009b7          	lui	s3,0x4000
    8000177e:	19fd                	addi	s3,s3,-1
    80001780:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001782:	00016a17          	auipc	s4,0x16
    80001786:	f7ea0a13          	addi	s4,s4,-130 # 80017700 <tickslock>
      initlock(&p->lock, "proc");
    8000178a:	85de                	mv	a1,s7
    8000178c:	854a                	mv	a0,s2
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	222080e7          	jalr	546(ra) # 800009b0 <initlock>
      char *pa = kalloc();
    80001796:	fffff097          	auipc	ra,0xfffff
    8000179a:	1ba080e7          	jalr	442(ra) # 80000950 <kalloc>
    8000179e:	85aa                	mv	a1,a0
      if(pa == 0)
    800017a0:	c929                	beqz	a0,800017f2 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800017a2:	416904b3          	sub	s1,s2,s6
    800017a6:	848d                	srai	s1,s1,0x3
    800017a8:	000ab783          	ld	a5,0(s5)
    800017ac:	02f484b3          	mul	s1,s1,a5
    800017b0:	2485                	addiw	s1,s1,1
    800017b2:	00d4949b          	slliw	s1,s1,0xd
    800017b6:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017ba:	4699                	li	a3,6
    800017bc:	6605                	lui	a2,0x1
    800017be:	8526                	mv	a0,s1
    800017c0:	00000097          	auipc	ra,0x0
    800017c4:	8c0080e7          	jalr	-1856(ra) # 80001080 <kvmmap>
      p->kstack = va;
    800017c8:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017cc:	16890913          	addi	s2,s2,360
    800017d0:	fb491de3          	bne	s2,s4,8000178a <procinit+0x58>
  kvminithart();
    800017d4:	fffff097          	auipc	ra,0xfffff
    800017d8:	75a080e7          	jalr	1882(ra) # 80000f2e <kvminithart>
}
    800017dc:	60a6                	ld	ra,72(sp)
    800017de:	6406                	ld	s0,64(sp)
    800017e0:	74e2                	ld	s1,56(sp)
    800017e2:	7942                	ld	s2,48(sp)
    800017e4:	79a2                	ld	s3,40(sp)
    800017e6:	7a02                	ld	s4,32(sp)
    800017e8:	6ae2                	ld	s5,24(sp)
    800017ea:	6b42                	ld	s6,16(sp)
    800017ec:	6ba2                	ld	s7,8(sp)
    800017ee:	6161                	addi	sp,sp,80
    800017f0:	8082                	ret
        panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	aee50513          	addi	a0,a0,-1298 # 800072e0 <userret+0x250>
    800017fa:	fffff097          	auipc	ra,0xfffff
    800017fe:	d4e080e7          	jalr	-690(ra) # 80000548 <panic>

0000000080001802 <cpuid>:
{
    80001802:	1141                	addi	sp,sp,-16
    80001804:	e422                	sd	s0,8(sp)
    80001806:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001808:	8512                	mv	a0,tp
}
    8000180a:	2501                	sext.w	a0,a0
    8000180c:	6422                	ld	s0,8(sp)
    8000180e:	0141                	addi	sp,sp,16
    80001810:	8082                	ret

0000000080001812 <mycpu>:
mycpu(void) {
    80001812:	1141                	addi	sp,sp,-16
    80001814:	e422                	sd	s0,8(sp)
    80001816:	0800                	addi	s0,sp,16
    80001818:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    8000181a:	2781                	sext.w	a5,a5
    8000181c:	079e                	slli	a5,a5,0x7
}
    8000181e:	00010517          	auipc	a0,0x10
    80001822:	0e250513          	addi	a0,a0,226 # 80011900 <cpus>
    80001826:	953e                	add	a0,a0,a5
    80001828:	6422                	ld	s0,8(sp)
    8000182a:	0141                	addi	sp,sp,16
    8000182c:	8082                	ret

000000008000182e <myproc>:
myproc(void) {
    8000182e:	1101                	addi	sp,sp,-32
    80001830:	ec06                	sd	ra,24(sp)
    80001832:	e822                	sd	s0,16(sp)
    80001834:	e426                	sd	s1,8(sp)
    80001836:	1000                	addi	s0,sp,32
  push_off();
    80001838:	fffff097          	auipc	ra,0xfffff
    8000183c:	18e080e7          	jalr	398(ra) # 800009c6 <push_off>
    80001840:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001842:	2781                	sext.w	a5,a5
    80001844:	079e                	slli	a5,a5,0x7
    80001846:	00010717          	auipc	a4,0x10
    8000184a:	0a270713          	addi	a4,a4,162 # 800118e8 <pid_lock>
    8000184e:	97ba                	add	a5,a5,a4
    80001850:	6f84                	ld	s1,24(a5)
  pop_off();
    80001852:	fffff097          	auipc	ra,0xfffff
    80001856:	1c0080e7          	jalr	448(ra) # 80000a12 <pop_off>
}
    8000185a:	8526                	mv	a0,s1
    8000185c:	60e2                	ld	ra,24(sp)
    8000185e:	6442                	ld	s0,16(sp)
    80001860:	64a2                	ld	s1,8(sp)
    80001862:	6105                	addi	sp,sp,32
    80001864:	8082                	ret

0000000080001866 <forkret>:
{
    80001866:	1141                	addi	sp,sp,-16
    80001868:	e406                	sd	ra,8(sp)
    8000186a:	e022                	sd	s0,0(sp)
    8000186c:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	fc0080e7          	jalr	-64(ra) # 8000182e <myproc>
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	29c080e7          	jalr	668(ra) # 80000b12 <release>
  if (first) {
    8000187e:	00006797          	auipc	a5,0x6
    80001882:	7b67a783          	lw	a5,1974(a5) # 80008034 <first.1>
    80001886:	eb89                	bnez	a5,80001898 <forkret+0x32>
  usertrapret();
    80001888:	00001097          	auipc	ra,0x1
    8000188c:	bb0080e7          	jalr	-1104(ra) # 80002438 <usertrapret>
}
    80001890:	60a2                	ld	ra,8(sp)
    80001892:	6402                	ld	s0,0(sp)
    80001894:	0141                	addi	sp,sp,16
    80001896:	8082                	ret
    first = 0;
    80001898:	00006797          	auipc	a5,0x6
    8000189c:	7807ae23          	sw	zero,1948(a5) # 80008034 <first.1>
    fsinit(ROOTDEV);
    800018a0:	4505                	li	a0,1
    800018a2:	00002097          	auipc	ra,0x2
    800018a6:	e1e080e7          	jalr	-482(ra) # 800036c0 <fsinit>
    800018aa:	bff9                	j	80001888 <forkret+0x22>

00000000800018ac <allocpid>:
allocpid() {
    800018ac:	1101                	addi	sp,sp,-32
    800018ae:	ec06                	sd	ra,24(sp)
    800018b0:	e822                	sd	s0,16(sp)
    800018b2:	e426                	sd	s1,8(sp)
    800018b4:	e04a                	sd	s2,0(sp)
    800018b6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018b8:	00010917          	auipc	s2,0x10
    800018bc:	03090913          	addi	s2,s2,48 # 800118e8 <pid_lock>
    800018c0:	854a                	mv	a0,s2
    800018c2:	fffff097          	auipc	ra,0xfffff
    800018c6:	1fc080e7          	jalr	508(ra) # 80000abe <acquire>
  pid = nextpid;
    800018ca:	00006797          	auipc	a5,0x6
    800018ce:	76e78793          	addi	a5,a5,1902 # 80008038 <nextpid>
    800018d2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018d4:	0014871b          	addiw	a4,s1,1
    800018d8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018da:	854a                	mv	a0,s2
    800018dc:	fffff097          	auipc	ra,0xfffff
    800018e0:	236080e7          	jalr	566(ra) # 80000b12 <release>
}
    800018e4:	8526                	mv	a0,s1
    800018e6:	60e2                	ld	ra,24(sp)
    800018e8:	6442                	ld	s0,16(sp)
    800018ea:	64a2                	ld	s1,8(sp)
    800018ec:	6902                	ld	s2,0(sp)
    800018ee:	6105                	addi	sp,sp,32
    800018f0:	8082                	ret

00000000800018f2 <proc_pagetable>:
{
    800018f2:	1101                	addi	sp,sp,-32
    800018f4:	ec06                	sd	ra,24(sp)
    800018f6:	e822                	sd	s0,16(sp)
    800018f8:	e426                	sd	s1,8(sp)
    800018fa:	e04a                	sd	s2,0(sp)
    800018fc:	1000                	addi	s0,sp,32
    800018fe:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001900:	00000097          	auipc	ra,0x0
    80001904:	952080e7          	jalr	-1710(ra) # 80001252 <uvmcreate>
    80001908:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000190a:	4729                	li	a4,10
    8000190c:	00005697          	auipc	a3,0x5
    80001910:	6f468693          	addi	a3,a3,1780 # 80007000 <trampoline>
    80001914:	6605                	lui	a2,0x1
    80001916:	040005b7          	lui	a1,0x4000
    8000191a:	15fd                	addi	a1,a1,-1
    8000191c:	05b2                	slli	a1,a1,0xc
    8000191e:	fffff097          	auipc	ra,0xfffff
    80001922:	6d4080e7          	jalr	1748(ra) # 80000ff2 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001926:	4719                	li	a4,6
    80001928:	05893683          	ld	a3,88(s2)
    8000192c:	6605                	lui	a2,0x1
    8000192e:	020005b7          	lui	a1,0x2000
    80001932:	15fd                	addi	a1,a1,-1
    80001934:	05b6                	slli	a1,a1,0xd
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	6ba080e7          	jalr	1722(ra) # 80000ff2 <mappages>
}
    80001940:	8526                	mv	a0,s1
    80001942:	60e2                	ld	ra,24(sp)
    80001944:	6442                	ld	s0,16(sp)
    80001946:	64a2                	ld	s1,8(sp)
    80001948:	6902                	ld	s2,0(sp)
    8000194a:	6105                	addi	sp,sp,32
    8000194c:	8082                	ret

000000008000194e <allocproc>:
{
    8000194e:	1101                	addi	sp,sp,-32
    80001950:	ec06                	sd	ra,24(sp)
    80001952:	e822                	sd	s0,16(sp)
    80001954:	e426                	sd	s1,8(sp)
    80001956:	e04a                	sd	s2,0(sp)
    80001958:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195a:	00010497          	auipc	s1,0x10
    8000195e:	3a648493          	addi	s1,s1,934 # 80011d00 <proc>
    80001962:	00016917          	auipc	s2,0x16
    80001966:	d9e90913          	addi	s2,s2,-610 # 80017700 <tickslock>
    acquire(&p->lock);
    8000196a:	8526                	mv	a0,s1
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	152080e7          	jalr	338(ra) # 80000abe <acquire>
    if(p->state == UNUSED) {
    80001974:	4c9c                	lw	a5,24(s1)
    80001976:	cf81                	beqz	a5,8000198e <allocproc+0x40>
      release(&p->lock);
    80001978:	8526                	mv	a0,s1
    8000197a:	fffff097          	auipc	ra,0xfffff
    8000197e:	198080e7          	jalr	408(ra) # 80000b12 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001982:	16848493          	addi	s1,s1,360
    80001986:	ff2492e3          	bne	s1,s2,8000196a <allocproc+0x1c>
  return 0;
    8000198a:	4481                	li	s1,0
    8000198c:	a0b9                	j	800019da <allocproc+0x8c>
  p->pid = allocpid();
    8000198e:	00000097          	auipc	ra,0x0
    80001992:	f1e080e7          	jalr	-226(ra) # 800018ac <allocpid>
    80001996:	dc88                	sw	a0,56(s1)
  p->tra=0;
    80001998:	0204ae23          	sw	zero,60(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	fb4080e7          	jalr	-76(ra) # 80000950 <kalloc>
    800019a4:	892a                	mv	s2,a0
    800019a6:	eca8                	sd	a0,88(s1)
    800019a8:	c121                	beqz	a0,800019e8 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    800019aa:	8526                	mv	a0,s1
    800019ac:	00000097          	auipc	ra,0x0
    800019b0:	f46080e7          	jalr	-186(ra) # 800018f2 <proc_pagetable>
    800019b4:	e8a8                	sd	a0,80(s1)
  memset(&p->context, 0, sizeof p->context);
    800019b6:	07000613          	li	a2,112
    800019ba:	4581                	li	a1,0
    800019bc:	06048513          	addi	a0,s1,96
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	19a080e7          	jalr	410(ra) # 80000b5a <memset>
  p->context.ra = (uint64)forkret;
    800019c8:	00000797          	auipc	a5,0x0
    800019cc:	e9e78793          	addi	a5,a5,-354 # 80001866 <forkret>
    800019d0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800019d2:	60bc                	ld	a5,64(s1)
    800019d4:	6705                	lui	a4,0x1
    800019d6:	97ba                	add	a5,a5,a4
    800019d8:	f4bc                	sd	a5,104(s1)
}
    800019da:	8526                	mv	a0,s1
    800019dc:	60e2                	ld	ra,24(sp)
    800019de:	6442                	ld	s0,16(sp)
    800019e0:	64a2                	ld	s1,8(sp)
    800019e2:	6902                	ld	s2,0(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret
    release(&p->lock);
    800019e8:	8526                	mv	a0,s1
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	128080e7          	jalr	296(ra) # 80000b12 <release>
    return 0;
    800019f2:	84ca                	mv	s1,s2
    800019f4:	b7dd                	j	800019da <allocproc+0x8c>

00000000800019f6 <proc_freepagetable>:
{
    800019f6:	1101                	addi	sp,sp,-32
    800019f8:	ec06                	sd	ra,24(sp)
    800019fa:	e822                	sd	s0,16(sp)
    800019fc:	e426                	sd	s1,8(sp)
    800019fe:	e04a                	sd	s2,0(sp)
    80001a00:	1000                	addi	s0,sp,32
    80001a02:	84aa                	mv	s1,a0
    80001a04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001a06:	4681                	li	a3,0
    80001a08:	6605                	lui	a2,0x1
    80001a0a:	040005b7          	lui	a1,0x4000
    80001a0e:	15fd                	addi	a1,a1,-1
    80001a10:	05b2                	slli	a1,a1,0xc
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	778080e7          	jalr	1912(ra) # 8000118a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001a1a:	4681                	li	a3,0
    80001a1c:	6605                	lui	a2,0x1
    80001a1e:	020005b7          	lui	a1,0x2000
    80001a22:	15fd                	addi	a1,a1,-1
    80001a24:	05b6                	slli	a1,a1,0xd
    80001a26:	8526                	mv	a0,s1
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	762080e7          	jalr	1890(ra) # 8000118a <uvmunmap>
  if(sz > 0)
    80001a30:	00091863          	bnez	s2,80001a40 <proc_freepagetable+0x4a>
}
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6902                	ld	s2,0(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret
    uvmfree(pagetable, sz);
    80001a40:	85ca                	mv	a1,s2
    80001a42:	8526                	mv	a0,s1
    80001a44:	00000097          	auipc	ra,0x0
    80001a48:	9ac080e7          	jalr	-1620(ra) # 800013f0 <uvmfree>
}
    80001a4c:	b7e5                	j	80001a34 <proc_freepagetable+0x3e>

0000000080001a4e <freeproc>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	1000                	addi	s0,sp,32
    80001a58:	84aa                	mv	s1,a0
  if(p->tf)
    80001a5a:	6d28                	ld	a0,88(a0)
    80001a5c:	c509                	beqz	a0,80001a66 <freeproc+0x18>
    kfree((void*)p->tf);
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	df6080e7          	jalr	-522(ra) # 80000854 <kfree>
  p->tf = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c511                	beqz	a0,80001a78 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	00000097          	auipc	ra,0x0
    80001a74:	f86080e7          	jalr	-122(ra) # 800019f6 <proc_freepagetable>
  p->pagetable = 0;
    80001a78:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a7c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a80:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001a84:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001a88:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a8c:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001a90:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001a94:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001a98:	0004ac23          	sw	zero,24(s1)
}
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6105                	addi	sp,sp,32
    80001aa4:	8082                	ret

0000000080001aa6 <userinit>:
{
    80001aa6:	1101                	addi	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ab0:	00000097          	auipc	ra,0x0
    80001ab4:	e9e080e7          	jalr	-354(ra) # 8000194e <allocproc>
    80001ab8:	84aa                	mv	s1,a0
  initproc = p;
    80001aba:	00024797          	auipc	a5,0x24
    80001abe:	54a7bb23          	sd	a0,1366(a5) # 80026010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ac2:	03300613          	li	a2,51
    80001ac6:	00006597          	auipc	a1,0x6
    80001aca:	53a58593          	addi	a1,a1,1338 # 80008000 <initcode>
    80001ace:	6928                	ld	a0,80(a0)
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	7c0080e7          	jalr	1984(ra) # 80001290 <uvminit>
  p->sz = PGSIZE;
    80001ad8:	6785                	lui	a5,0x1
    80001ada:	e4bc                	sd	a5,72(s1)
  p->tf->epc = 0;      // user program counter
    80001adc:	6cb8                	ld	a4,88(s1)
    80001ade:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001ae2:	6cb8                	ld	a4,88(s1)
    80001ae4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ae6:	4641                	li	a2,16
    80001ae8:	00006597          	auipc	a1,0x6
    80001aec:	80058593          	addi	a1,a1,-2048 # 800072e8 <userret+0x258>
    80001af0:	15848513          	addi	a0,s1,344
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	1b8080e7          	jalr	440(ra) # 80000cac <safestrcpy>
  p->cwd = namei("/");
    80001afc:	00005517          	auipc	a0,0x5
    80001b00:	7fc50513          	addi	a0,a0,2044 # 800072f8 <userret+0x268>
    80001b04:	00002097          	auipc	ra,0x2
    80001b08:	5be080e7          	jalr	1470(ra) # 800040c2 <namei>
    80001b0c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b10:	4789                	li	a5,2
    80001b12:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b14:	8526                	mv	a0,s1
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	ffc080e7          	jalr	-4(ra) # 80000b12 <release>
}
    80001b1e:	60e2                	ld	ra,24(sp)
    80001b20:	6442                	ld	s0,16(sp)
    80001b22:	64a2                	ld	s1,8(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret

0000000080001b28 <growproc>:
{
    80001b28:	1101                	addi	sp,sp,-32
    80001b2a:	ec06                	sd	ra,24(sp)
    80001b2c:	e822                	sd	s0,16(sp)
    80001b2e:	e426                	sd	s1,8(sp)
    80001b30:	e04a                	sd	s2,0(sp)
    80001b32:	1000                	addi	s0,sp,32
    80001b34:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b36:	00000097          	auipc	ra,0x0
    80001b3a:	cf8080e7          	jalr	-776(ra) # 8000182e <myproc>
    80001b3e:	892a                	mv	s2,a0
  sz = p->sz;
    80001b40:	652c                	ld	a1,72(a0)
    80001b42:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001b46:	00904f63          	bgtz	s1,80001b64 <growproc+0x3c>
  } else if(n < 0){
    80001b4a:	0204cc63          	bltz	s1,80001b82 <growproc+0x5a>
  p->sz = sz;
    80001b4e:	1602                	slli	a2,a2,0x20
    80001b50:	9201                	srli	a2,a2,0x20
    80001b52:	04c93423          	sd	a2,72(s2)
  return 0;
    80001b56:	4501                	li	a0,0
}
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6902                	ld	s2,0(sp)
    80001b60:	6105                	addi	sp,sp,32
    80001b62:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001b64:	9e25                	addw	a2,a2,s1
    80001b66:	1602                	slli	a2,a2,0x20
    80001b68:	9201                	srli	a2,a2,0x20
    80001b6a:	1582                	slli	a1,a1,0x20
    80001b6c:	9181                	srli	a1,a1,0x20
    80001b6e:	6928                	ld	a0,80(a0)
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	7d6080e7          	jalr	2006(ra) # 80001346 <uvmalloc>
    80001b78:	0005061b          	sext.w	a2,a0
    80001b7c:	fa69                	bnez	a2,80001b4e <growproc+0x26>
      return -1;
    80001b7e:	557d                	li	a0,-1
    80001b80:	bfe1                	j	80001b58 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b82:	9e25                	addw	a2,a2,s1
    80001b84:	1602                	slli	a2,a2,0x20
    80001b86:	9201                	srli	a2,a2,0x20
    80001b88:	1582                	slli	a1,a1,0x20
    80001b8a:	9181                	srli	a1,a1,0x20
    80001b8c:	6928                	ld	a0,80(a0)
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	774080e7          	jalr	1908(ra) # 80001302 <uvmdealloc>
    80001b96:	0005061b          	sext.w	a2,a0
    80001b9a:	bf55                	j	80001b4e <growproc+0x26>

0000000080001b9c <fork>:
{
    80001b9c:	7139                	addi	sp,sp,-64
    80001b9e:	fc06                	sd	ra,56(sp)
    80001ba0:	f822                	sd	s0,48(sp)
    80001ba2:	f426                	sd	s1,40(sp)
    80001ba4:	f04a                	sd	s2,32(sp)
    80001ba6:	ec4e                	sd	s3,24(sp)
    80001ba8:	e852                	sd	s4,16(sp)
    80001baa:	e456                	sd	s5,8(sp)
    80001bac:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001bae:	00000097          	auipc	ra,0x0
    80001bb2:	c80080e7          	jalr	-896(ra) # 8000182e <myproc>
    80001bb6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001bb8:	00000097          	auipc	ra,0x0
    80001bbc:	d96080e7          	jalr	-618(ra) # 8000194e <allocproc>
    80001bc0:	c17d                	beqz	a0,80001ca6 <fork+0x10a>
    80001bc2:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001bc4:	048ab603          	ld	a2,72(s5)
    80001bc8:	692c                	ld	a1,80(a0)
    80001bca:	050ab503          	ld	a0,80(s5)
    80001bce:	00000097          	auipc	ra,0x0
    80001bd2:	850080e7          	jalr	-1968(ra) # 8000141e <uvmcopy>
    80001bd6:	04054a63          	bltz	a0,80001c2a <fork+0x8e>
  np->sz = p->sz;
    80001bda:	048ab783          	ld	a5,72(s5)
    80001bde:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001be2:	035a3023          	sd	s5,32(s4)
  *(np->tf) = *(p->tf);
    80001be6:	058ab683          	ld	a3,88(s5)
    80001bea:	87b6                	mv	a5,a3
    80001bec:	058a3703          	ld	a4,88(s4)
    80001bf0:	12068693          	addi	a3,a3,288
    80001bf4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001bf8:	6788                	ld	a0,8(a5)
    80001bfa:	6b8c                	ld	a1,16(a5)
    80001bfc:	6f90                	ld	a2,24(a5)
    80001bfe:	01073023          	sd	a6,0(a4)
    80001c02:	e708                	sd	a0,8(a4)
    80001c04:	eb0c                	sd	a1,16(a4)
    80001c06:	ef10                	sd	a2,24(a4)
    80001c08:	02078793          	addi	a5,a5,32
    80001c0c:	02070713          	addi	a4,a4,32
    80001c10:	fed792e3          	bne	a5,a3,80001bf4 <fork+0x58>
  np->tf->a0 = 0;
    80001c14:	058a3783          	ld	a5,88(s4)
    80001c18:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c1c:	0d0a8493          	addi	s1,s5,208
    80001c20:	0d0a0913          	addi	s2,s4,208
    80001c24:	150a8993          	addi	s3,s5,336
    80001c28:	a00d                	j	80001c4a <fork+0xae>
    freeproc(np);
    80001c2a:	8552                	mv	a0,s4
    80001c2c:	00000097          	auipc	ra,0x0
    80001c30:	e22080e7          	jalr	-478(ra) # 80001a4e <freeproc>
    release(&np->lock);
    80001c34:	8552                	mv	a0,s4
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	edc080e7          	jalr	-292(ra) # 80000b12 <release>
    return -1;
    80001c3e:	54fd                	li	s1,-1
    80001c40:	a889                	j	80001c92 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001c42:	04a1                	addi	s1,s1,8
    80001c44:	0921                	addi	s2,s2,8
    80001c46:	01348b63          	beq	s1,s3,80001c5c <fork+0xc0>
    if(p->ofile[i])
    80001c4a:	6088                	ld	a0,0(s1)
    80001c4c:	d97d                	beqz	a0,80001c42 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c4e:	00003097          	auipc	ra,0x3
    80001c52:	b04080e7          	jalr	-1276(ra) # 80004752 <filedup>
    80001c56:	00a93023          	sd	a0,0(s2)
    80001c5a:	b7e5                	j	80001c42 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001c5c:	150ab503          	ld	a0,336(s5)
    80001c60:	00002097          	auipc	ra,0x2
    80001c64:	c9a080e7          	jalr	-870(ra) # 800038fa <idup>
    80001c68:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c6c:	4641                	li	a2,16
    80001c6e:	158a8593          	addi	a1,s5,344
    80001c72:	158a0513          	addi	a0,s4,344
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	036080e7          	jalr	54(ra) # 80000cac <safestrcpy>
  pid = np->pid;
    80001c7e:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001c82:	4789                	li	a5,2
    80001c84:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c88:	8552                	mv	a0,s4
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	e88080e7          	jalr	-376(ra) # 80000b12 <release>
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	70e2                	ld	ra,56(sp)
    80001c96:	7442                	ld	s0,48(sp)
    80001c98:	74a2                	ld	s1,40(sp)
    80001c9a:	7902                	ld	s2,32(sp)
    80001c9c:	69e2                	ld	s3,24(sp)
    80001c9e:	6a42                	ld	s4,16(sp)
    80001ca0:	6aa2                	ld	s5,8(sp)
    80001ca2:	6121                	addi	sp,sp,64
    80001ca4:	8082                	ret
    return -1;
    80001ca6:	54fd                	li	s1,-1
    80001ca8:	b7ed                	j	80001c92 <fork+0xf6>

0000000080001caa <reparent>:
{
    80001caa:	7179                	addi	sp,sp,-48
    80001cac:	f406                	sd	ra,40(sp)
    80001cae:	f022                	sd	s0,32(sp)
    80001cb0:	ec26                	sd	s1,24(sp)
    80001cb2:	e84a                	sd	s2,16(sp)
    80001cb4:	e44e                	sd	s3,8(sp)
    80001cb6:	e052                	sd	s4,0(sp)
    80001cb8:	1800                	addi	s0,sp,48
    80001cba:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001cbc:	00010497          	auipc	s1,0x10
    80001cc0:	04448493          	addi	s1,s1,68 # 80011d00 <proc>
      pp->parent = initproc;
    80001cc4:	00024a17          	auipc	s4,0x24
    80001cc8:	34ca0a13          	addi	s4,s4,844 # 80026010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ccc:	00016997          	auipc	s3,0x16
    80001cd0:	a3498993          	addi	s3,s3,-1484 # 80017700 <tickslock>
    80001cd4:	a029                	j	80001cde <reparent+0x34>
    80001cd6:	16848493          	addi	s1,s1,360
    80001cda:	03348363          	beq	s1,s3,80001d00 <reparent+0x56>
    if(pp->parent == p){
    80001cde:	709c                	ld	a5,32(s1)
    80001ce0:	ff279be3          	bne	a5,s2,80001cd6 <reparent+0x2c>
      acquire(&pp->lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	dd8080e7          	jalr	-552(ra) # 80000abe <acquire>
      pp->parent = initproc;
    80001cee:	000a3783          	ld	a5,0(s4)
    80001cf2:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	e1c080e7          	jalr	-484(ra) # 80000b12 <release>
    80001cfe:	bfe1                	j	80001cd6 <reparent+0x2c>
}
    80001d00:	70a2                	ld	ra,40(sp)
    80001d02:	7402                	ld	s0,32(sp)
    80001d04:	64e2                	ld	s1,24(sp)
    80001d06:	6942                	ld	s2,16(sp)
    80001d08:	69a2                	ld	s3,8(sp)
    80001d0a:	6a02                	ld	s4,0(sp)
    80001d0c:	6145                	addi	sp,sp,48
    80001d0e:	8082                	ret

0000000080001d10 <scheduler>:
{
    80001d10:	7139                	addi	sp,sp,-64
    80001d12:	fc06                	sd	ra,56(sp)
    80001d14:	f822                	sd	s0,48(sp)
    80001d16:	f426                	sd	s1,40(sp)
    80001d18:	f04a                	sd	s2,32(sp)
    80001d1a:	ec4e                	sd	s3,24(sp)
    80001d1c:	e852                	sd	s4,16(sp)
    80001d1e:	e456                	sd	s5,8(sp)
    80001d20:	e05a                	sd	s6,0(sp)
    80001d22:	0080                	addi	s0,sp,64
    80001d24:	8792                	mv	a5,tp
  int id = r_tp();
    80001d26:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d28:	00779a93          	slli	s5,a5,0x7
    80001d2c:	00010717          	auipc	a4,0x10
    80001d30:	bbc70713          	addi	a4,a4,-1092 # 800118e8 <pid_lock>
    80001d34:	9756                	add	a4,a4,s5
    80001d36:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001d3a:	00010717          	auipc	a4,0x10
    80001d3e:	bce70713          	addi	a4,a4,-1074 # 80011908 <cpus+0x8>
    80001d42:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001d44:	4989                	li	s3,2
        p->state = RUNNING;
    80001d46:	4b0d                	li	s6,3
        c->proc = p;
    80001d48:	079e                	slli	a5,a5,0x7
    80001d4a:	00010a17          	auipc	s4,0x10
    80001d4e:	b9ea0a13          	addi	s4,s4,-1122 # 800118e8 <pid_lock>
    80001d52:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d54:	00016917          	auipc	s2,0x16
    80001d58:	9ac90913          	addi	s2,s2,-1620 # 80017700 <tickslock>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001d5c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001d60:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001d64:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d70:	10079073          	csrw	sstatus,a5
    80001d74:	00010497          	auipc	s1,0x10
    80001d78:	f8c48493          	addi	s1,s1,-116 # 80011d00 <proc>
    80001d7c:	a811                	j	80001d90 <scheduler+0x80>
      release(&p->lock);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	d92080e7          	jalr	-622(ra) # 80000b12 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d88:	16848493          	addi	s1,s1,360
    80001d8c:	fd2488e3          	beq	s1,s2,80001d5c <scheduler+0x4c>
      acquire(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	d2c080e7          	jalr	-724(ra) # 80000abe <acquire>
      if(p->state == RUNNABLE) {
    80001d9a:	4c9c                	lw	a5,24(s1)
    80001d9c:	ff3791e3          	bne	a5,s3,80001d7e <scheduler+0x6e>
        p->state = RUNNING;
    80001da0:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001da4:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001da8:	06048593          	addi	a1,s1,96
    80001dac:	8556                	mv	a0,s5
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	5e0080e7          	jalr	1504(ra) # 8000238e <swtch>
        c->proc = 0;
    80001db6:	000a3c23          	sd	zero,24(s4)
    80001dba:	b7d1                	j	80001d7e <scheduler+0x6e>

0000000080001dbc <sched>:
{
    80001dbc:	7179                	addi	sp,sp,-48
    80001dbe:	f406                	sd	ra,40(sp)
    80001dc0:	f022                	sd	s0,32(sp)
    80001dc2:	ec26                	sd	s1,24(sp)
    80001dc4:	e84a                	sd	s2,16(sp)
    80001dc6:	e44e                	sd	s3,8(sp)
    80001dc8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dca:	00000097          	auipc	ra,0x0
    80001dce:	a64080e7          	jalr	-1436(ra) # 8000182e <myproc>
    80001dd2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	caa080e7          	jalr	-854(ra) # 80000a7e <holding>
    80001ddc:	c93d                	beqz	a0,80001e52 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dde:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de0:	2781                	sext.w	a5,a5
    80001de2:	079e                	slli	a5,a5,0x7
    80001de4:	00010717          	auipc	a4,0x10
    80001de8:	b0470713          	addi	a4,a4,-1276 # 800118e8 <pid_lock>
    80001dec:	97ba                	add	a5,a5,a4
    80001dee:	0907a703          	lw	a4,144(a5)
    80001df2:	4785                	li	a5,1
    80001df4:	06f71763          	bne	a4,a5,80001e62 <sched+0xa6>
  if(p->state == RUNNING)
    80001df8:	4c98                	lw	a4,24(s1)
    80001dfa:	478d                	li	a5,3
    80001dfc:	06f70b63          	beq	a4,a5,80001e72 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e06:	efb5                	bnez	a5,80001e82 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e08:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0a:	00010917          	auipc	s2,0x10
    80001e0e:	ade90913          	addi	s2,s2,-1314 # 800118e8 <pid_lock>
    80001e12:	2781                	sext.w	a5,a5
    80001e14:	079e                	slli	a5,a5,0x7
    80001e16:	97ca                	add	a5,a5,s2
    80001e18:	0947a983          	lw	s3,148(a5)
    80001e1c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	00010597          	auipc	a1,0x10
    80001e26:	ae658593          	addi	a1,a1,-1306 # 80011908 <cpus+0x8>
    80001e2a:	95be                	add	a1,a1,a5
    80001e2c:	06048513          	addi	a0,s1,96
    80001e30:	00000097          	auipc	ra,0x0
    80001e34:	55e080e7          	jalr	1374(ra) # 8000238e <swtch>
    80001e38:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	97ca                	add	a5,a5,s2
    80001e40:	0937aa23          	sw	s3,148(a5)
}
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    panic("sched p->lock");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	4ae50513          	addi	a0,a0,1198 # 80007300 <userret+0x270>
    80001e5a:	ffffe097          	auipc	ra,0xffffe
    80001e5e:	6ee080e7          	jalr	1774(ra) # 80000548 <panic>
    panic("sched locks");
    80001e62:	00005517          	auipc	a0,0x5
    80001e66:	4ae50513          	addi	a0,a0,1198 # 80007310 <userret+0x280>
    80001e6a:	ffffe097          	auipc	ra,0xffffe
    80001e6e:	6de080e7          	jalr	1758(ra) # 80000548 <panic>
    panic("sched running");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	4ae50513          	addi	a0,a0,1198 # 80007320 <userret+0x290>
    80001e7a:	ffffe097          	auipc	ra,0xffffe
    80001e7e:	6ce080e7          	jalr	1742(ra) # 80000548 <panic>
    panic("sched interruptible");
    80001e82:	00005517          	auipc	a0,0x5
    80001e86:	4ae50513          	addi	a0,a0,1198 # 80007330 <userret+0x2a0>
    80001e8a:	ffffe097          	auipc	ra,0xffffe
    80001e8e:	6be080e7          	jalr	1726(ra) # 80000548 <panic>

0000000080001e92 <exit>:
{
    80001e92:	7179                	addi	sp,sp,-48
    80001e94:	f406                	sd	ra,40(sp)
    80001e96:	f022                	sd	s0,32(sp)
    80001e98:	ec26                	sd	s1,24(sp)
    80001e9a:	e84a                	sd	s2,16(sp)
    80001e9c:	e44e                	sd	s3,8(sp)
    80001e9e:	e052                	sd	s4,0(sp)
    80001ea0:	1800                	addi	s0,sp,48
    80001ea2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ea4:	00000097          	auipc	ra,0x0
    80001ea8:	98a080e7          	jalr	-1654(ra) # 8000182e <myproc>
    80001eac:	89aa                	mv	s3,a0
  if(p == initproc)
    80001eae:	00024797          	auipc	a5,0x24
    80001eb2:	1627b783          	ld	a5,354(a5) # 80026010 <initproc>
    80001eb6:	0d050493          	addi	s1,a0,208
    80001eba:	15050913          	addi	s2,a0,336
    80001ebe:	02a79363          	bne	a5,a0,80001ee4 <exit+0x52>
    panic("init exiting");
    80001ec2:	00005517          	auipc	a0,0x5
    80001ec6:	48650513          	addi	a0,a0,1158 # 80007348 <userret+0x2b8>
    80001eca:	ffffe097          	auipc	ra,0xffffe
    80001ece:	67e080e7          	jalr	1662(ra) # 80000548 <panic>
      fileclose(f);
    80001ed2:	00003097          	auipc	ra,0x3
    80001ed6:	8d2080e7          	jalr	-1838(ra) # 800047a4 <fileclose>
      p->ofile[fd] = 0;
    80001eda:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ede:	04a1                	addi	s1,s1,8
    80001ee0:	01248563          	beq	s1,s2,80001eea <exit+0x58>
    if(p->ofile[fd]){
    80001ee4:	6088                	ld	a0,0(s1)
    80001ee6:	f575                	bnez	a0,80001ed2 <exit+0x40>
    80001ee8:	bfdd                	j	80001ede <exit+0x4c>
  begin_op();
    80001eea:	00002097          	auipc	ra,0x2
    80001eee:	3e8080e7          	jalr	1000(ra) # 800042d2 <begin_op>
  iput(p->cwd);
    80001ef2:	1509b503          	ld	a0,336(s3)
    80001ef6:	00002097          	auipc	ra,0x2
    80001efa:	b50080e7          	jalr	-1200(ra) # 80003a46 <iput>
  end_op();
    80001efe:	00002097          	auipc	ra,0x2
    80001f02:	454080e7          	jalr	1108(ra) # 80004352 <end_op>
  p->cwd = 0;
    80001f06:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80001f0a:	00024497          	auipc	s1,0x24
    80001f0e:	10648493          	addi	s1,s1,262 # 80026010 <initproc>
    80001f12:	6088                	ld	a0,0(s1)
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	baa080e7          	jalr	-1110(ra) # 80000abe <acquire>
  wakeup1(initproc);
    80001f1c:	6088                	ld	a0,0(s1)
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	7d0080e7          	jalr	2000(ra) # 800016ee <wakeup1>
  release(&initproc->lock);
    80001f26:	6088                	ld	a0,0(s1)
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	bea080e7          	jalr	-1046(ra) # 80000b12 <release>
  acquire(&p->lock);
    80001f30:	854e                	mv	a0,s3
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	b8c080e7          	jalr	-1140(ra) # 80000abe <acquire>
  struct proc *original_parent = p->parent;
    80001f3a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80001f3e:	854e                	mv	a0,s3
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	bd2080e7          	jalr	-1070(ra) # 80000b12 <release>
  acquire(&original_parent->lock);
    80001f48:	8526                	mv	a0,s1
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	b74080e7          	jalr	-1164(ra) # 80000abe <acquire>
  acquire(&p->lock);
    80001f52:	854e                	mv	a0,s3
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	b6a080e7          	jalr	-1174(ra) # 80000abe <acquire>
  reparent(p);
    80001f5c:	854e                	mv	a0,s3
    80001f5e:	00000097          	auipc	ra,0x0
    80001f62:	d4c080e7          	jalr	-692(ra) # 80001caa <reparent>
  wakeup1(original_parent);
    80001f66:	8526                	mv	a0,s1
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	786080e7          	jalr	1926(ra) # 800016ee <wakeup1>
  p->xstate = status;
    80001f70:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80001f74:	4791                	li	a5,4
    80001f76:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	b96080e7          	jalr	-1130(ra) # 80000b12 <release>
  sched();
    80001f84:	00000097          	auipc	ra,0x0
    80001f88:	e38080e7          	jalr	-456(ra) # 80001dbc <sched>
  panic("zombie exit");
    80001f8c:	00005517          	auipc	a0,0x5
    80001f90:	3cc50513          	addi	a0,a0,972 # 80007358 <userret+0x2c8>
    80001f94:	ffffe097          	auipc	ra,0xffffe
    80001f98:	5b4080e7          	jalr	1460(ra) # 80000548 <panic>

0000000080001f9c <yield>:
{
    80001f9c:	1101                	addi	sp,sp,-32
    80001f9e:	ec06                	sd	ra,24(sp)
    80001fa0:	e822                	sd	s0,16(sp)
    80001fa2:	e426                	sd	s1,8(sp)
    80001fa4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fa6:	00000097          	auipc	ra,0x0
    80001faa:	888080e7          	jalr	-1912(ra) # 8000182e <myproc>
    80001fae:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	b0e080e7          	jalr	-1266(ra) # 80000abe <acquire>
  p->state = RUNNABLE;
    80001fb8:	4789                	li	a5,2
    80001fba:	cc9c                	sw	a5,24(s1)
  sched();
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	e00080e7          	jalr	-512(ra) # 80001dbc <sched>
  release(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	b4c080e7          	jalr	-1204(ra) # 80000b12 <release>
}
    80001fce:	60e2                	ld	ra,24(sp)
    80001fd0:	6442                	ld	s0,16(sp)
    80001fd2:	64a2                	ld	s1,8(sp)
    80001fd4:	6105                	addi	sp,sp,32
    80001fd6:	8082                	ret

0000000080001fd8 <sleep>:
{
    80001fd8:	7179                	addi	sp,sp,-48
    80001fda:	f406                	sd	ra,40(sp)
    80001fdc:	f022                	sd	s0,32(sp)
    80001fde:	ec26                	sd	s1,24(sp)
    80001fe0:	e84a                	sd	s2,16(sp)
    80001fe2:	e44e                	sd	s3,8(sp)
    80001fe4:	1800                	addi	s0,sp,48
    80001fe6:	89aa                	mv	s3,a0
    80001fe8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fea:	00000097          	auipc	ra,0x0
    80001fee:	844080e7          	jalr	-1980(ra) # 8000182e <myproc>
    80001ff2:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80001ff4:	05250663          	beq	a0,s2,80002040 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	ac6080e7          	jalr	-1338(ra) # 80000abe <acquire>
    release(lk);
    80002000:	854a                	mv	a0,s2
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	b10080e7          	jalr	-1264(ra) # 80000b12 <release>
  p->chan = chan;
    8000200a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000200e:	4785                	li	a5,1
    80002010:	cc9c                	sw	a5,24(s1)
  sched();
    80002012:	00000097          	auipc	ra,0x0
    80002016:	daa080e7          	jalr	-598(ra) # 80001dbc <sched>
  p->chan = 0;
    8000201a:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000201e:	8526                	mv	a0,s1
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	af2080e7          	jalr	-1294(ra) # 80000b12 <release>
    acquire(lk);
    80002028:	854a                	mv	a0,s2
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	a94080e7          	jalr	-1388(ra) # 80000abe <acquire>
}
    80002032:	70a2                	ld	ra,40(sp)
    80002034:	7402                	ld	s0,32(sp)
    80002036:	64e2                	ld	s1,24(sp)
    80002038:	6942                	ld	s2,16(sp)
    8000203a:	69a2                	ld	s3,8(sp)
    8000203c:	6145                	addi	sp,sp,48
    8000203e:	8082                	ret
  p->chan = chan;
    80002040:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002044:	4785                	li	a5,1
    80002046:	cd1c                	sw	a5,24(a0)
  sched();
    80002048:	00000097          	auipc	ra,0x0
    8000204c:	d74080e7          	jalr	-652(ra) # 80001dbc <sched>
  p->chan = 0;
    80002050:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002054:	bff9                	j	80002032 <sleep+0x5a>

0000000080002056 <wait>:
{
    80002056:	715d                	addi	sp,sp,-80
    80002058:	e486                	sd	ra,72(sp)
    8000205a:	e0a2                	sd	s0,64(sp)
    8000205c:	fc26                	sd	s1,56(sp)
    8000205e:	f84a                	sd	s2,48(sp)
    80002060:	f44e                	sd	s3,40(sp)
    80002062:	f052                	sd	s4,32(sp)
    80002064:	ec56                	sd	s5,24(sp)
    80002066:	e85a                	sd	s6,16(sp)
    80002068:	e45e                	sd	s7,8(sp)
    8000206a:	0880                	addi	s0,sp,80
    8000206c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	7c0080e7          	jalr	1984(ra) # 8000182e <myproc>
    80002076:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	a46080e7          	jalr	-1466(ra) # 80000abe <acquire>
    havekids = 0;
    80002080:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002082:	4a11                	li	s4,4
        havekids = 1;
    80002084:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002086:	00015997          	auipc	s3,0x15
    8000208a:	67a98993          	addi	s3,s3,1658 # 80017700 <tickslock>
    havekids = 0;
    8000208e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002090:	00010497          	auipc	s1,0x10
    80002094:	c7048493          	addi	s1,s1,-912 # 80011d00 <proc>
    80002098:	a08d                	j	800020fa <wait+0xa4>
          pid = np->pid;
    8000209a:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000209e:	000b0e63          	beqz	s6,800020ba <wait+0x64>
    800020a2:	4691                	li	a3,4
    800020a4:	03448613          	addi	a2,s1,52
    800020a8:	85da                	mv	a1,s6
    800020aa:	05093503          	ld	a0,80(s2)
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	472080e7          	jalr	1138(ra) # 80001520 <copyout>
    800020b6:	02054263          	bltz	a0,800020da <wait+0x84>
          freeproc(np);
    800020ba:	8526                	mv	a0,s1
    800020bc:	00000097          	auipc	ra,0x0
    800020c0:	992080e7          	jalr	-1646(ra) # 80001a4e <freeproc>
          release(&np->lock);
    800020c4:	8526                	mv	a0,s1
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	a4c080e7          	jalr	-1460(ra) # 80000b12 <release>
          release(&p->lock);
    800020ce:	854a                	mv	a0,s2
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	a42080e7          	jalr	-1470(ra) # 80000b12 <release>
          return pid;
    800020d8:	a8a9                	j	80002132 <wait+0xdc>
            release(&np->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	fffff097          	auipc	ra,0xfffff
    800020e0:	a36080e7          	jalr	-1482(ra) # 80000b12 <release>
            release(&p->lock);
    800020e4:	854a                	mv	a0,s2
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	a2c080e7          	jalr	-1492(ra) # 80000b12 <release>
            return -1;
    800020ee:	59fd                	li	s3,-1
    800020f0:	a089                	j	80002132 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800020f2:	16848493          	addi	s1,s1,360
    800020f6:	03348463          	beq	s1,s3,8000211e <wait+0xc8>
      if(np->parent == p){
    800020fa:	709c                	ld	a5,32(s1)
    800020fc:	ff279be3          	bne	a5,s2,800020f2 <wait+0x9c>
        acquire(&np->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	9bc080e7          	jalr	-1604(ra) # 80000abe <acquire>
        if(np->state == ZOMBIE){
    8000210a:	4c9c                	lw	a5,24(s1)
    8000210c:	f94787e3          	beq	a5,s4,8000209a <wait+0x44>
        release(&np->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	a00080e7          	jalr	-1536(ra) # 80000b12 <release>
        havekids = 1;
    8000211a:	8756                	mv	a4,s5
    8000211c:	bfd9                	j	800020f2 <wait+0x9c>
    if(!havekids || p->killed){
    8000211e:	c701                	beqz	a4,80002126 <wait+0xd0>
    80002120:	03092783          	lw	a5,48(s2)
    80002124:	c39d                	beqz	a5,8000214a <wait+0xf4>
      release(&p->lock);
    80002126:	854a                	mv	a0,s2
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	9ea080e7          	jalr	-1558(ra) # 80000b12 <release>
      return -1;
    80002130:	59fd                	li	s3,-1
}
    80002132:	854e                	mv	a0,s3
    80002134:	60a6                	ld	ra,72(sp)
    80002136:	6406                	ld	s0,64(sp)
    80002138:	74e2                	ld	s1,56(sp)
    8000213a:	7942                	ld	s2,48(sp)
    8000213c:	79a2                	ld	s3,40(sp)
    8000213e:	7a02                	ld	s4,32(sp)
    80002140:	6ae2                	ld	s5,24(sp)
    80002142:	6b42                	ld	s6,16(sp)
    80002144:	6ba2                	ld	s7,8(sp)
    80002146:	6161                	addi	sp,sp,80
    80002148:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000214a:	85ca                	mv	a1,s2
    8000214c:	854a                	mv	a0,s2
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	e8a080e7          	jalr	-374(ra) # 80001fd8 <sleep>
    havekids = 0;
    80002156:	bf25                	j	8000208e <wait+0x38>

0000000080002158 <wakeup>:
{
    80002158:	7139                	addi	sp,sp,-64
    8000215a:	fc06                	sd	ra,56(sp)
    8000215c:	f822                	sd	s0,48(sp)
    8000215e:	f426                	sd	s1,40(sp)
    80002160:	f04a                	sd	s2,32(sp)
    80002162:	ec4e                	sd	s3,24(sp)
    80002164:	e852                	sd	s4,16(sp)
    80002166:	e456                	sd	s5,8(sp)
    80002168:	0080                	addi	s0,sp,64
    8000216a:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000216c:	00010497          	auipc	s1,0x10
    80002170:	b9448493          	addi	s1,s1,-1132 # 80011d00 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002174:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002176:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002178:	00015917          	auipc	s2,0x15
    8000217c:	58890913          	addi	s2,s2,1416 # 80017700 <tickslock>
    80002180:	a811                	j	80002194 <wakeup+0x3c>
    release(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	98e080e7          	jalr	-1650(ra) # 80000b12 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218c:	16848493          	addi	s1,s1,360
    80002190:	03248063          	beq	s1,s2,800021b0 <wakeup+0x58>
    acquire(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	928080e7          	jalr	-1752(ra) # 80000abe <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000219e:	4c9c                	lw	a5,24(s1)
    800021a0:	ff3791e3          	bne	a5,s3,80002182 <wakeup+0x2a>
    800021a4:	749c                	ld	a5,40(s1)
    800021a6:	fd479ee3          	bne	a5,s4,80002182 <wakeup+0x2a>
      p->state = RUNNABLE;
    800021aa:	0154ac23          	sw	s5,24(s1)
    800021ae:	bfd1                	j	80002182 <wakeup+0x2a>
}
    800021b0:	70e2                	ld	ra,56(sp)
    800021b2:	7442                	ld	s0,48(sp)
    800021b4:	74a2                	ld	s1,40(sp)
    800021b6:	7902                	ld	s2,32(sp)
    800021b8:	69e2                	ld	s3,24(sp)
    800021ba:	6a42                	ld	s4,16(sp)
    800021bc:	6aa2                	ld	s5,8(sp)
    800021be:	6121                	addi	sp,sp,64
    800021c0:	8082                	ret

00000000800021c2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800021c2:	7179                	addi	sp,sp,-48
    800021c4:	f406                	sd	ra,40(sp)
    800021c6:	f022                	sd	s0,32(sp)
    800021c8:	ec26                	sd	s1,24(sp)
    800021ca:	e84a                	sd	s2,16(sp)
    800021cc:	e44e                	sd	s3,8(sp)
    800021ce:	1800                	addi	s0,sp,48
    800021d0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800021d2:	00010497          	auipc	s1,0x10
    800021d6:	b2e48493          	addi	s1,s1,-1234 # 80011d00 <proc>
    800021da:	00015997          	auipc	s3,0x15
    800021de:	52698993          	addi	s3,s3,1318 # 80017700 <tickslock>
    acquire(&p->lock);
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	8da080e7          	jalr	-1830(ra) # 80000abe <acquire>
    if(p->pid == pid){
    800021ec:	5c9c                	lw	a5,56(s1)
    800021ee:	01278d63          	beq	a5,s2,80002208 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	91e080e7          	jalr	-1762(ra) # 80000b12 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800021fc:	16848493          	addi	s1,s1,360
    80002200:	ff3491e3          	bne	s1,s3,800021e2 <kill+0x20>
  }
  return -1;
    80002204:	557d                	li	a0,-1
    80002206:	a821                	j	8000221e <kill+0x5c>
      p->killed = 1;
    80002208:	4785                	li	a5,1
    8000220a:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000220c:	4c98                	lw	a4,24(s1)
    8000220e:	00f70f63          	beq	a4,a5,8000222c <kill+0x6a>
      release(&p->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	8fe080e7          	jalr	-1794(ra) # 80000b12 <release>
      return 0;
    8000221c:	4501                	li	a0,0
}
    8000221e:	70a2                	ld	ra,40(sp)
    80002220:	7402                	ld	s0,32(sp)
    80002222:	64e2                	ld	s1,24(sp)
    80002224:	6942                	ld	s2,16(sp)
    80002226:	69a2                	ld	s3,8(sp)
    80002228:	6145                	addi	sp,sp,48
    8000222a:	8082                	ret
        p->state = RUNNABLE;
    8000222c:	4789                	li	a5,2
    8000222e:	cc9c                	sw	a5,24(s1)
    80002230:	b7cd                	j	80002212 <kill+0x50>

0000000080002232 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002232:	7179                	addi	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	e052                	sd	s4,0(sp)
    80002240:	1800                	addi	s0,sp,48
    80002242:	84aa                	mv	s1,a0
    80002244:	892e                	mv	s2,a1
    80002246:	89b2                	mv	s3,a2
    80002248:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	5e4080e7          	jalr	1508(ra) # 8000182e <myproc>
  if(user_dst){
    80002252:	c08d                	beqz	s1,80002274 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002254:	86d2                	mv	a3,s4
    80002256:	864e                	mv	a2,s3
    80002258:	85ca                	mv	a1,s2
    8000225a:	6928                	ld	a0,80(a0)
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	2c4080e7          	jalr	708(ra) # 80001520 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002264:	70a2                	ld	ra,40(sp)
    80002266:	7402                	ld	s0,32(sp)
    80002268:	64e2                	ld	s1,24(sp)
    8000226a:	6942                	ld	s2,16(sp)
    8000226c:	69a2                	ld	s3,8(sp)
    8000226e:	6a02                	ld	s4,0(sp)
    80002270:	6145                	addi	sp,sp,48
    80002272:	8082                	ret
    memmove((char *)dst, src, len);
    80002274:	000a061b          	sext.w	a2,s4
    80002278:	85ce                	mv	a1,s3
    8000227a:	854a                	mv	a0,s2
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	93a080e7          	jalr	-1734(ra) # 80000bb6 <memmove>
    return 0;
    80002284:	8526                	mv	a0,s1
    80002286:	bff9                	j	80002264 <either_copyout+0x32>

0000000080002288 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	e052                	sd	s4,0(sp)
    80002296:	1800                	addi	s0,sp,48
    80002298:	892a                	mv	s2,a0
    8000229a:	84ae                	mv	s1,a1
    8000229c:	89b2                	mv	s3,a2
    8000229e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	58e080e7          	jalr	1422(ra) # 8000182e <myproc>
  if(user_src){
    800022a8:	c08d                	beqz	s1,800022ca <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800022aa:	86d2                	mv	a3,s4
    800022ac:	864e                	mv	a2,s3
    800022ae:	85ca                	mv	a1,s2
    800022b0:	6928                	ld	a0,80(a0)
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	2fa080e7          	jalr	762(ra) # 800015ac <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022ba:	70a2                	ld	ra,40(sp)
    800022bc:	7402                	ld	s0,32(sp)
    800022be:	64e2                	ld	s1,24(sp)
    800022c0:	6942                	ld	s2,16(sp)
    800022c2:	69a2                	ld	s3,8(sp)
    800022c4:	6a02                	ld	s4,0(sp)
    800022c6:	6145                	addi	sp,sp,48
    800022c8:	8082                	ret
    memmove(dst, (char*)src, len);
    800022ca:	000a061b          	sext.w	a2,s4
    800022ce:	85ce                	mv	a1,s3
    800022d0:	854a                	mv	a0,s2
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	8e4080e7          	jalr	-1820(ra) # 80000bb6 <memmove>
    return 0;
    800022da:	8526                	mv	a0,s1
    800022dc:	bff9                	j	800022ba <either_copyin+0x32>

00000000800022de <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022de:	715d                	addi	sp,sp,-80
    800022e0:	e486                	sd	ra,72(sp)
    800022e2:	e0a2                	sd	s0,64(sp)
    800022e4:	fc26                	sd	s1,56(sp)
    800022e6:	f84a                	sd	s2,48(sp)
    800022e8:	f44e                	sd	s3,40(sp)
    800022ea:	f052                	sd	s4,32(sp)
    800022ec:	ec56                	sd	s5,24(sp)
    800022ee:	e85a                	sd	s6,16(sp)
    800022f0:	e45e                	sd	s7,8(sp)
    800022f2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022f4:	00005517          	auipc	a0,0x5
    800022f8:	7fc50513          	addi	a0,a0,2044 # 80007af0 <userret+0xa60>
    800022fc:	ffffe097          	auipc	ra,0xffffe
    80002300:	296080e7          	jalr	662(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002304:	00010497          	auipc	s1,0x10
    80002308:	b5448493          	addi	s1,s1,-1196 # 80011e58 <proc+0x158>
    8000230c:	00015917          	auipc	s2,0x15
    80002310:	54c90913          	addi	s2,s2,1356 # 80017858 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002314:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002316:	00005997          	auipc	s3,0x5
    8000231a:	05298993          	addi	s3,s3,82 # 80007368 <userret+0x2d8>
    printf("%d %s %s", p->pid, state, p->name);
    8000231e:	00005a97          	auipc	s5,0x5
    80002322:	052a8a93          	addi	s5,s5,82 # 80007370 <userret+0x2e0>
    printf("\n");
    80002326:	00005a17          	auipc	s4,0x5
    8000232a:	7caa0a13          	addi	s4,s4,1994 # 80007af0 <userret+0xa60>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000232e:	00006b97          	auipc	s7,0x6
    80002332:	8dab8b93          	addi	s7,s7,-1830 # 80007c08 <states.0>
    80002336:	a00d                	j	80002358 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002338:	ee06a583          	lw	a1,-288(a3)
    8000233c:	8556                	mv	a0,s5
    8000233e:	ffffe097          	auipc	ra,0xffffe
    80002342:	254080e7          	jalr	596(ra) # 80000592 <printf>
    printf("\n");
    80002346:	8552                	mv	a0,s4
    80002348:	ffffe097          	auipc	ra,0xffffe
    8000234c:	24a080e7          	jalr	586(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002350:	16848493          	addi	s1,s1,360
    80002354:	03248263          	beq	s1,s2,80002378 <procdump+0x9a>
    if(p->state == UNUSED)
    80002358:	86a6                	mv	a3,s1
    8000235a:	ec04a783          	lw	a5,-320(s1)
    8000235e:	dbed                	beqz	a5,80002350 <procdump+0x72>
      state = "???";
    80002360:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002362:	fcfb6be3          	bltu	s6,a5,80002338 <procdump+0x5a>
    80002366:	02079713          	slli	a4,a5,0x20
    8000236a:	01d75793          	srli	a5,a4,0x1d
    8000236e:	97de                	add	a5,a5,s7
    80002370:	6390                	ld	a2,0(a5)
    80002372:	f279                	bnez	a2,80002338 <procdump+0x5a>
      state = "???";
    80002374:	864e                	mv	a2,s3
    80002376:	b7c9                	j	80002338 <procdump+0x5a>
  }
}
    80002378:	60a6                	ld	ra,72(sp)
    8000237a:	6406                	ld	s0,64(sp)
    8000237c:	74e2                	ld	s1,56(sp)
    8000237e:	7942                	ld	s2,48(sp)
    80002380:	79a2                	ld	s3,40(sp)
    80002382:	7a02                	ld	s4,32(sp)
    80002384:	6ae2                	ld	s5,24(sp)
    80002386:	6b42                	ld	s6,16(sp)
    80002388:	6ba2                	ld	s7,8(sp)
    8000238a:	6161                	addi	sp,sp,80
    8000238c:	8082                	ret

000000008000238e <swtch>:
    8000238e:	00153023          	sd	ra,0(a0)
    80002392:	00253423          	sd	sp,8(a0)
    80002396:	e900                	sd	s0,16(a0)
    80002398:	ed04                	sd	s1,24(a0)
    8000239a:	03253023          	sd	s2,32(a0)
    8000239e:	03353423          	sd	s3,40(a0)
    800023a2:	03453823          	sd	s4,48(a0)
    800023a6:	03553c23          	sd	s5,56(a0)
    800023aa:	05653023          	sd	s6,64(a0)
    800023ae:	05753423          	sd	s7,72(a0)
    800023b2:	05853823          	sd	s8,80(a0)
    800023b6:	05953c23          	sd	s9,88(a0)
    800023ba:	07a53023          	sd	s10,96(a0)
    800023be:	07b53423          	sd	s11,104(a0)
    800023c2:	0005b083          	ld	ra,0(a1)
    800023c6:	0085b103          	ld	sp,8(a1)
    800023ca:	6980                	ld	s0,16(a1)
    800023cc:	6d84                	ld	s1,24(a1)
    800023ce:	0205b903          	ld	s2,32(a1)
    800023d2:	0285b983          	ld	s3,40(a1)
    800023d6:	0305ba03          	ld	s4,48(a1)
    800023da:	0385ba83          	ld	s5,56(a1)
    800023de:	0405bb03          	ld	s6,64(a1)
    800023e2:	0485bb83          	ld	s7,72(a1)
    800023e6:	0505bc03          	ld	s8,80(a1)
    800023ea:	0585bc83          	ld	s9,88(a1)
    800023ee:	0605bd03          	ld	s10,96(a1)
    800023f2:	0685bd83          	ld	s11,104(a1)
    800023f6:	8082                	ret

00000000800023f8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023f8:	1141                	addi	sp,sp,-16
    800023fa:	e406                	sd	ra,8(sp)
    800023fc:	e022                	sd	s0,0(sp)
    800023fe:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002400:	00005597          	auipc	a1,0x5
    80002404:	fa858593          	addi	a1,a1,-88 # 800073a8 <userret+0x318>
    80002408:	00015517          	auipc	a0,0x15
    8000240c:	2f850513          	addi	a0,a0,760 # 80017700 <tickslock>
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	5a0080e7          	jalr	1440(ra) # 800009b0 <initlock>
}
    80002418:	60a2                	ld	ra,8(sp)
    8000241a:	6402                	ld	s0,0(sp)
    8000241c:	0141                	addi	sp,sp,16
    8000241e:	8082                	ret

0000000080002420 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002420:	1141                	addi	sp,sp,-16
    80002422:	e422                	sd	s0,8(sp)
    80002424:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002426:	00004797          	auipc	a5,0x4
    8000242a:	c0a78793          	addi	a5,a5,-1014 # 80006030 <kernelvec>
    8000242e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002432:	6422                	ld	s0,8(sp)
    80002434:	0141                	addi	sp,sp,16
    80002436:	8082                	ret

0000000080002438 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002438:	1141                	addi	sp,sp,-16
    8000243a:	e406                	sd	ra,8(sp)
    8000243c:	e022                	sd	s0,0(sp)
    8000243e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	3ee080e7          	jalr	1006(ra) # 8000182e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002448:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000244c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000244e:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002452:	00005617          	auipc	a2,0x5
    80002456:	bae60613          	addi	a2,a2,-1106 # 80007000 <trampoline>
    8000245a:	00005697          	auipc	a3,0x5
    8000245e:	ba668693          	addi	a3,a3,-1114 # 80007000 <trampoline>
    80002462:	8e91                	sub	a3,a3,a2
    80002464:	040007b7          	lui	a5,0x4000
    80002468:	17fd                	addi	a5,a5,-1
    8000246a:	07b2                	slli	a5,a5,0xc
    8000246c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000246e:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002472:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002474:	180026f3          	csrr	a3,satp
    80002478:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000247a:	6d38                	ld	a4,88(a0)
    8000247c:	6134                	ld	a3,64(a0)
    8000247e:	6585                	lui	a1,0x1
    80002480:	96ae                	add	a3,a3,a1
    80002482:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002484:	6d38                	ld	a4,88(a0)
    80002486:	00000697          	auipc	a3,0x0
    8000248a:	12268693          	addi	a3,a3,290 # 800025a8 <usertrap>
    8000248e:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002490:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002492:	8692                	mv	a3,tp
    80002494:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002496:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000249a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000249e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024a2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800024a6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024a8:	6f18                	ld	a4,24(a4)
    800024aa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800024ae:	692c                	ld	a1,80(a0)
    800024b0:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800024b2:	00005717          	auipc	a4,0x5
    800024b6:	bde70713          	addi	a4,a4,-1058 # 80007090 <userret>
    800024ba:	8f11                	sub	a4,a4,a2
    800024bc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800024be:	577d                	li	a4,-1
    800024c0:	177e                	slli	a4,a4,0x3f
    800024c2:	8dd9                	or	a1,a1,a4
    800024c4:	02000537          	lui	a0,0x2000
    800024c8:	157d                	addi	a0,a0,-1
    800024ca:	0536                	slli	a0,a0,0xd
    800024cc:	9782                	jalr	a5
}
    800024ce:	60a2                	ld	ra,8(sp)
    800024d0:	6402                	ld	s0,0(sp)
    800024d2:	0141                	addi	sp,sp,16
    800024d4:	8082                	ret

00000000800024d6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024d6:	1101                	addi	sp,sp,-32
    800024d8:	ec06                	sd	ra,24(sp)
    800024da:	e822                	sd	s0,16(sp)
    800024dc:	e426                	sd	s1,8(sp)
    800024de:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800024e0:	00015497          	auipc	s1,0x15
    800024e4:	22048493          	addi	s1,s1,544 # 80017700 <tickslock>
    800024e8:	8526                	mv	a0,s1
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	5d4080e7          	jalr	1492(ra) # 80000abe <acquire>
  ticks++;
    800024f2:	00024517          	auipc	a0,0x24
    800024f6:	b2650513          	addi	a0,a0,-1242 # 80026018 <ticks>
    800024fa:	411c                	lw	a5,0(a0)
    800024fc:	2785                	addiw	a5,a5,1
    800024fe:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002500:	00000097          	auipc	ra,0x0
    80002504:	c58080e7          	jalr	-936(ra) # 80002158 <wakeup>
  release(&tickslock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	608080e7          	jalr	1544(ra) # 80000b12 <release>
}
    80002512:	60e2                	ld	ra,24(sp)
    80002514:	6442                	ld	s0,16(sp)
    80002516:	64a2                	ld	s1,8(sp)
    80002518:	6105                	addi	sp,sp,32
    8000251a:	8082                	ret

000000008000251c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000251c:	1101                	addi	sp,sp,-32
    8000251e:	ec06                	sd	ra,24(sp)
    80002520:	e822                	sd	s0,16(sp)
    80002522:	e426                	sd	s1,8(sp)
    80002524:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002526:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000252a:	00074d63          	bltz	a4,80002544 <devintr+0x28>
      virtio_disk_intr();
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    8000252e:	57fd                	li	a5,-1
    80002530:	17fe                	slli	a5,a5,0x3f
    80002532:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002534:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002536:	04f70863          	beq	a4,a5,80002586 <devintr+0x6a>
  }
}
    8000253a:	60e2                	ld	ra,24(sp)
    8000253c:	6442                	ld	s0,16(sp)
    8000253e:	64a2                	ld	s1,8(sp)
    80002540:	6105                	addi	sp,sp,32
    80002542:	8082                	ret
     (scause & 0xff) == 9){
    80002544:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002548:	46a5                	li	a3,9
    8000254a:	fed792e3          	bne	a5,a3,8000252e <devintr+0x12>
    int irq = plic_claim();
    8000254e:	00004097          	auipc	ra,0x4
    80002552:	bfc080e7          	jalr	-1028(ra) # 8000614a <plic_claim>
    80002556:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002558:	47a9                	li	a5,10
    8000255a:	00f50c63          	beq	a0,a5,80002572 <devintr+0x56>
    } else if(irq == VIRTIO0_IRQ){
    8000255e:	4785                	li	a5,1
    80002560:	00f50e63          	beq	a0,a5,8000257c <devintr+0x60>
    plic_complete(irq);
    80002564:	8526                	mv	a0,s1
    80002566:	00004097          	auipc	ra,0x4
    8000256a:	c08080e7          	jalr	-1016(ra) # 8000616e <plic_complete>
    return 1;
    8000256e:	4505                	li	a0,1
    80002570:	b7e9                	j	8000253a <devintr+0x1e>
      uartintr();
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	2b6080e7          	jalr	694(ra) # 80000828 <uartintr>
    8000257a:	b7ed                	j	80002564 <devintr+0x48>
      virtio_disk_intr();
    8000257c:	00004097          	auipc	ra,0x4
    80002580:	06c080e7          	jalr	108(ra) # 800065e8 <virtio_disk_intr>
    80002584:	b7c5                	j	80002564 <devintr+0x48>
    if(cpuid() == 0){
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	27c080e7          	jalr	636(ra) # 80001802 <cpuid>
    8000258e:	c901                	beqz	a0,8000259e <devintr+0x82>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002590:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002594:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002596:	14479073          	csrw	sip,a5
    return 2;
    8000259a:	4509                	li	a0,2
    8000259c:	bf79                	j	8000253a <devintr+0x1e>
      clockintr();
    8000259e:	00000097          	auipc	ra,0x0
    800025a2:	f38080e7          	jalr	-200(ra) # 800024d6 <clockintr>
    800025a6:	b7ed                	j	80002590 <devintr+0x74>

00000000800025a8 <usertrap>:
{
    800025a8:	1101                	addi	sp,sp,-32
    800025aa:	ec06                	sd	ra,24(sp)
    800025ac:	e822                	sd	s0,16(sp)
    800025ae:	e426                	sd	s1,8(sp)
    800025b0:	e04a                	sd	s2,0(sp)
    800025b2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025b4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025b8:	1007f793          	andi	a5,a5,256
    800025bc:	e7bd                	bnez	a5,8000262a <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025be:	00004797          	auipc	a5,0x4
    800025c2:	a7278793          	addi	a5,a5,-1422 # 80006030 <kernelvec>
    800025c6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025ca:	fffff097          	auipc	ra,0xfffff
    800025ce:	264080e7          	jalr	612(ra) # 8000182e <myproc>
    800025d2:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    800025d4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025d6:	14102773          	csrr	a4,sepc
    800025da:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025dc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025e0:	47a1                	li	a5,8
    800025e2:	06f71263          	bne	a4,a5,80002646 <usertrap+0x9e>
    if(p->killed)
    800025e6:	591c                	lw	a5,48(a0)
    800025e8:	eba9                	bnez	a5,8000263a <usertrap+0x92>
    p->tf->epc += 4;
    800025ea:	6cb8                	ld	a4,88(s1)
    800025ec:	6f1c                	ld	a5,24(a4)
    800025ee:	0791                	addi	a5,a5,4
    800025f0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    800025f2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800025f6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800025fa:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002602:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002606:	10079073          	csrw	sstatus,a5
    syscall();
    8000260a:	00000097          	auipc	ra,0x0
    8000260e:	2e0080e7          	jalr	736(ra) # 800028ea <syscall>
  if(p->killed)
    80002612:	589c                	lw	a5,48(s1)
    80002614:	ebc1                	bnez	a5,800026a4 <usertrap+0xfc>
  usertrapret();
    80002616:	00000097          	auipc	ra,0x0
    8000261a:	e22080e7          	jalr	-478(ra) # 80002438 <usertrapret>
}
    8000261e:	60e2                	ld	ra,24(sp)
    80002620:	6442                	ld	s0,16(sp)
    80002622:	64a2                	ld	s1,8(sp)
    80002624:	6902                	ld	s2,0(sp)
    80002626:	6105                	addi	sp,sp,32
    80002628:	8082                	ret
    panic("usertrap: not from user mode");
    8000262a:	00005517          	auipc	a0,0x5
    8000262e:	d8650513          	addi	a0,a0,-634 # 800073b0 <userret+0x320>
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	f16080e7          	jalr	-234(ra) # 80000548 <panic>
      exit(-1);
    8000263a:	557d                	li	a0,-1
    8000263c:	00000097          	auipc	ra,0x0
    80002640:	856080e7          	jalr	-1962(ra) # 80001e92 <exit>
    80002644:	b75d                	j	800025ea <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	ed6080e7          	jalr	-298(ra) # 8000251c <devintr>
    8000264e:	892a                	mv	s2,a0
    80002650:	c501                	beqz	a0,80002658 <usertrap+0xb0>
  if(p->killed)
    80002652:	589c                	lw	a5,48(s1)
    80002654:	c3a1                	beqz	a5,80002694 <usertrap+0xec>
    80002656:	a815                	j	8000268a <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002658:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000265c:	5c90                	lw	a2,56(s1)
    8000265e:	00005517          	auipc	a0,0x5
    80002662:	d7250513          	addi	a0,a0,-654 # 800073d0 <userret+0x340>
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	f2c080e7          	jalr	-212(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000266e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002672:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002676:	00005517          	auipc	a0,0x5
    8000267a:	d8a50513          	addi	a0,a0,-630 # 80007400 <userret+0x370>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	f14080e7          	jalr	-236(ra) # 80000592 <printf>
    p->killed = 1;
    80002686:	4785                	li	a5,1
    80002688:	d89c                	sw	a5,48(s1)
    exit(-1);
    8000268a:	557d                	li	a0,-1
    8000268c:	00000097          	auipc	ra,0x0
    80002690:	806080e7          	jalr	-2042(ra) # 80001e92 <exit>
  if(which_dev == 2)
    80002694:	4789                	li	a5,2
    80002696:	f8f910e3          	bne	s2,a5,80002616 <usertrap+0x6e>
    yield();
    8000269a:	00000097          	auipc	ra,0x0
    8000269e:	902080e7          	jalr	-1790(ra) # 80001f9c <yield>
    800026a2:	bf95                	j	80002616 <usertrap+0x6e>
  int which_dev = 0;
    800026a4:	4901                	li	s2,0
    800026a6:	b7d5                	j	8000268a <usertrap+0xe2>

00000000800026a8 <kerneltrap>:
{
    800026a8:	7179                	addi	sp,sp,-48
    800026aa:	f406                	sd	ra,40(sp)
    800026ac:	f022                	sd	s0,32(sp)
    800026ae:	ec26                	sd	s1,24(sp)
    800026b0:	e84a                	sd	s2,16(sp)
    800026b2:	e44e                	sd	s3,8(sp)
    800026b4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026b6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ba:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026be:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026c2:	1004f793          	andi	a5,s1,256
    800026c6:	cb85                	beqz	a5,800026f6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026cc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026ce:	ef85                	bnez	a5,80002706 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800026d0:	00000097          	auipc	ra,0x0
    800026d4:	e4c080e7          	jalr	-436(ra) # 8000251c <devintr>
    800026d8:	cd1d                	beqz	a0,80002716 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800026da:	4789                	li	a5,2
    800026dc:	06f50a63          	beq	a0,a5,80002750 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e4:	10049073          	csrw	sstatus,s1
}
    800026e8:	70a2                	ld	ra,40(sp)
    800026ea:	7402                	ld	s0,32(sp)
    800026ec:	64e2                	ld	s1,24(sp)
    800026ee:	6942                	ld	s2,16(sp)
    800026f0:	69a2                	ld	s3,8(sp)
    800026f2:	6145                	addi	sp,sp,48
    800026f4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026f6:	00005517          	auipc	a0,0x5
    800026fa:	d2a50513          	addi	a0,a0,-726 # 80007420 <userret+0x390>
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	e4a080e7          	jalr	-438(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002706:	00005517          	auipc	a0,0x5
    8000270a:	d4250513          	addi	a0,a0,-702 # 80007448 <userret+0x3b8>
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	e3a080e7          	jalr	-454(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002716:	85ce                	mv	a1,s3
    80002718:	00005517          	auipc	a0,0x5
    8000271c:	d5050513          	addi	a0,a0,-688 # 80007468 <userret+0x3d8>
    80002720:	ffffe097          	auipc	ra,0xffffe
    80002724:	e72080e7          	jalr	-398(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002728:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000272c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002730:	00005517          	auipc	a0,0x5
    80002734:	d4850513          	addi	a0,a0,-696 # 80007478 <userret+0x3e8>
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	e5a080e7          	jalr	-422(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002740:	00005517          	auipc	a0,0x5
    80002744:	d5050513          	addi	a0,a0,-688 # 80007490 <userret+0x400>
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	e00080e7          	jalr	-512(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	0de080e7          	jalr	222(ra) # 8000182e <myproc>
    80002758:	d541                	beqz	a0,800026e0 <kerneltrap+0x38>
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	0d4080e7          	jalr	212(ra) # 8000182e <myproc>
    80002762:	4d18                	lw	a4,24(a0)
    80002764:	478d                	li	a5,3
    80002766:	f6f71de3          	bne	a4,a5,800026e0 <kerneltrap+0x38>
    yield();
    8000276a:	00000097          	auipc	ra,0x0
    8000276e:	832080e7          	jalr	-1998(ra) # 80001f9c <yield>
    80002772:	b7bd                	j	800026e0 <kerneltrap+0x38>

0000000080002774 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002774:	1101                	addi	sp,sp,-32
    80002776:	ec06                	sd	ra,24(sp)
    80002778:	e822                	sd	s0,16(sp)
    8000277a:	e426                	sd	s1,8(sp)
    8000277c:	1000                	addi	s0,sp,32
    8000277e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	0ae080e7          	jalr	174(ra) # 8000182e <myproc>
  switch (n) {
    80002788:	4795                	li	a5,5
    8000278a:	0497e163          	bltu	a5,s1,800027cc <argraw+0x58>
    8000278e:	048a                	slli	s1,s1,0x2
    80002790:	00005717          	auipc	a4,0x5
    80002794:	4a070713          	addi	a4,a4,1184 # 80007c30 <states.0+0x28>
    80002798:	94ba                	add	s1,s1,a4
    8000279a:	409c                	lw	a5,0(s1)
    8000279c:	97ba                	add	a5,a5,a4
    8000279e:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800027a0:	6d3c                	ld	a5,88(a0)
    800027a2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    800027a4:	60e2                	ld	ra,24(sp)
    800027a6:	6442                	ld	s0,16(sp)
    800027a8:	64a2                	ld	s1,8(sp)
    800027aa:	6105                	addi	sp,sp,32
    800027ac:	8082                	ret
    return p->tf->a1;
    800027ae:	6d3c                	ld	a5,88(a0)
    800027b0:	7fa8                	ld	a0,120(a5)
    800027b2:	bfcd                	j	800027a4 <argraw+0x30>
    return p->tf->a2;
    800027b4:	6d3c                	ld	a5,88(a0)
    800027b6:	63c8                	ld	a0,128(a5)
    800027b8:	b7f5                	j	800027a4 <argraw+0x30>
    return p->tf->a3;
    800027ba:	6d3c                	ld	a5,88(a0)
    800027bc:	67c8                	ld	a0,136(a5)
    800027be:	b7dd                	j	800027a4 <argraw+0x30>
    return p->tf->a4;
    800027c0:	6d3c                	ld	a5,88(a0)
    800027c2:	6bc8                	ld	a0,144(a5)
    800027c4:	b7c5                	j	800027a4 <argraw+0x30>
    return p->tf->a5;
    800027c6:	6d3c                	ld	a5,88(a0)
    800027c8:	6fc8                	ld	a0,152(a5)
    800027ca:	bfe9                	j	800027a4 <argraw+0x30>
  panic("argraw");
    800027cc:	00005517          	auipc	a0,0x5
    800027d0:	cd450513          	addi	a0,a0,-812 # 800074a0 <userret+0x410>
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	d74080e7          	jalr	-652(ra) # 80000548 <panic>

00000000800027dc <fetchaddr>:
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	e04a                	sd	s2,0(sp)
    800027e6:	1000                	addi	s0,sp,32
    800027e8:	84aa                	mv	s1,a0
    800027ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027ec:	fffff097          	auipc	ra,0xfffff
    800027f0:	042080e7          	jalr	66(ra) # 8000182e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800027f4:	653c                	ld	a5,72(a0)
    800027f6:	02f4f863          	bgeu	s1,a5,80002826 <fetchaddr+0x4a>
    800027fa:	00848713          	addi	a4,s1,8
    800027fe:	02e7e663          	bltu	a5,a4,8000282a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002802:	46a1                	li	a3,8
    80002804:	8626                	mv	a2,s1
    80002806:	85ca                	mv	a1,s2
    80002808:	6928                	ld	a0,80(a0)
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	da2080e7          	jalr	-606(ra) # 800015ac <copyin>
    80002812:	00a03533          	snez	a0,a0
    80002816:	40a00533          	neg	a0,a0
}
    8000281a:	60e2                	ld	ra,24(sp)
    8000281c:	6442                	ld	s0,16(sp)
    8000281e:	64a2                	ld	s1,8(sp)
    80002820:	6902                	ld	s2,0(sp)
    80002822:	6105                	addi	sp,sp,32
    80002824:	8082                	ret
    return -1;
    80002826:	557d                	li	a0,-1
    80002828:	bfcd                	j	8000281a <fetchaddr+0x3e>
    8000282a:	557d                	li	a0,-1
    8000282c:	b7fd                	j	8000281a <fetchaddr+0x3e>

000000008000282e <fetchstr>:
{
    8000282e:	7179                	addi	sp,sp,-48
    80002830:	f406                	sd	ra,40(sp)
    80002832:	f022                	sd	s0,32(sp)
    80002834:	ec26                	sd	s1,24(sp)
    80002836:	e84a                	sd	s2,16(sp)
    80002838:	e44e                	sd	s3,8(sp)
    8000283a:	1800                	addi	s0,sp,48
    8000283c:	892a                	mv	s2,a0
    8000283e:	84ae                	mv	s1,a1
    80002840:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002842:	fffff097          	auipc	ra,0xfffff
    80002846:	fec080e7          	jalr	-20(ra) # 8000182e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000284a:	86ce                	mv	a3,s3
    8000284c:	864a                	mv	a2,s2
    8000284e:	85a6                	mv	a1,s1
    80002850:	6928                	ld	a0,80(a0)
    80002852:	fffff097          	auipc	ra,0xfffff
    80002856:	de8080e7          	jalr	-536(ra) # 8000163a <copyinstr>
  if(err < 0)
    8000285a:	00054763          	bltz	a0,80002868 <fetchstr+0x3a>
  return strlen(buf);
    8000285e:	8526                	mv	a0,s1
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	47e080e7          	jalr	1150(ra) # 80000cde <strlen>
}
    80002868:	70a2                	ld	ra,40(sp)
    8000286a:	7402                	ld	s0,32(sp)
    8000286c:	64e2                	ld	s1,24(sp)
    8000286e:	6942                	ld	s2,16(sp)
    80002870:	69a2                	ld	s3,8(sp)
    80002872:	6145                	addi	sp,sp,48
    80002874:	8082                	ret

0000000080002876 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002876:	1101                	addi	sp,sp,-32
    80002878:	ec06                	sd	ra,24(sp)
    8000287a:	e822                	sd	s0,16(sp)
    8000287c:	e426                	sd	s1,8(sp)
    8000287e:	1000                	addi	s0,sp,32
    80002880:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002882:	00000097          	auipc	ra,0x0
    80002886:	ef2080e7          	jalr	-270(ra) # 80002774 <argraw>
    8000288a:	c088                	sw	a0,0(s1)
  return 0;
}
    8000288c:	4501                	li	a0,0
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	64a2                	ld	s1,8(sp)
    80002894:	6105                	addi	sp,sp,32
    80002896:	8082                	ret

0000000080002898 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002898:	1101                	addi	sp,sp,-32
    8000289a:	ec06                	sd	ra,24(sp)
    8000289c:	e822                	sd	s0,16(sp)
    8000289e:	e426                	sd	s1,8(sp)
    800028a0:	1000                	addi	s0,sp,32
    800028a2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028a4:	00000097          	auipc	ra,0x0
    800028a8:	ed0080e7          	jalr	-304(ra) # 80002774 <argraw>
    800028ac:	e088                	sd	a0,0(s1)
  return 0;
}
    800028ae:	4501                	li	a0,0
    800028b0:	60e2                	ld	ra,24(sp)
    800028b2:	6442                	ld	s0,16(sp)
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret

00000000800028ba <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028ba:	1101                	addi	sp,sp,-32
    800028bc:	ec06                	sd	ra,24(sp)
    800028be:	e822                	sd	s0,16(sp)
    800028c0:	e426                	sd	s1,8(sp)
    800028c2:	e04a                	sd	s2,0(sp)
    800028c4:	1000                	addi	s0,sp,32
    800028c6:	84ae                	mv	s1,a1
    800028c8:	8932                	mv	s2,a2
  *ip = argraw(n);
    800028ca:	00000097          	auipc	ra,0x0
    800028ce:	eaa080e7          	jalr	-342(ra) # 80002774 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800028d2:	864a                	mv	a2,s2
    800028d4:	85a6                	mv	a1,s1
    800028d6:	00000097          	auipc	ra,0x0
    800028da:	f58080e7          	jalr	-168(ra) # 8000282e <fetchstr>
}
    800028de:	60e2                	ld	ra,24(sp)
    800028e0:	6442                	ld	s0,16(sp)
    800028e2:	64a2                	ld	s1,8(sp)
    800028e4:	6902                	ld	s2,0(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret

00000000800028ea <syscall>:
[SYS_trace]   sys_trace,
};

void
syscall(void)
{
    800028ea:	7179                	addi	sp,sp,-48
    800028ec:	f406                	sd	ra,40(sp)
    800028ee:	f022                	sd	s0,32(sp)
    800028f0:	ec26                	sd	s1,24(sp)
    800028f2:	e84a                	sd	s2,16(sp)
    800028f4:	e44e                	sd	s3,8(sp)
    800028f6:	e052                	sd	s4,0(sp)
    800028f8:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    800028fa:	fffff097          	auipc	ra,0xfffff
    800028fe:	f34080e7          	jalr	-204(ra) # 8000182e <myproc>
    80002902:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002904:	05853903          	ld	s2,88(a0)
    80002908:	0a893783          	ld	a5,168(s2)
    8000290c:	00078a1b          	sext.w	s4,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002910:	37fd                	addiw	a5,a5,-1
    80002912:	4761                	li	a4,24
    80002914:	2af76063          	bltu	a4,a5,80002bb4 <syscall+0x2ca>
    80002918:	003a1713          	slli	a4,s4,0x3
    8000291c:	00005797          	auipc	a5,0x5
    80002920:	39478793          	addi	a5,a5,916 # 80007cb0 <syscalls>
    80002924:	97ba                	add	a5,a5,a4
    80002926:	639c                	ld	a5,0(a5)
    80002928:	28078663          	beqz	a5,80002bb4 <syscall+0x2ca>
    int h=1<<(num),i;   
    8000292c:	4985                	li	s3,1
    8000292e:	014999bb          	sllw	s3,s3,s4
    p->tf->a0 = syscalls[num]();
    80002932:	9782                	jalr	a5
    80002934:	06a93823          	sd	a0,112(s2)
    i=p->tra;
    if((h&i)==h) {
    80002938:	5cdc                	lw	a5,60(s1)
    8000293a:	00f9f7b3          	and	a5,s3,a5
    8000293e:	29379a63          	bne	a5,s3,80002bd2 <syscall+0x2e8>
	switch(num){
    80002942:	47e5                	li	a5,25
    80002944:	2947e763          	bltu	a5,s4,80002bd2 <syscall+0x2e8>
    80002948:	0a0a                	slli	s4,s4,0x2
    8000294a:	00005717          	auipc	a4,0x5
    8000294e:	2fe70713          	addi	a4,a4,766 # 80007c48 <states.0+0x40>
    80002952:	9a3a                	add	s4,s4,a4
    80002954:	000a2783          	lw	a5,0(s4)
    80002958:	97ba                	add	a5,a5,a4
    8000295a:	8782                	jr	a5
		case 1: printf("%d: syscall fork -> %d\n",p->pid,p->tf->a0);
    8000295c:	6cbc                	ld	a5,88(s1)
    8000295e:	7bb0                	ld	a2,112(a5)
    80002960:	5c8c                	lw	a1,56(s1)
    80002962:	00005517          	auipc	a0,0x5
    80002966:	b4650513          	addi	a0,a0,-1210 # 800074a8 <userret+0x418>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	c28080e7          	jalr	-984(ra) # 80000592 <printf>
		break;
    80002972:	a485                	j	80002bd2 <syscall+0x2e8>
		case 2: printf("%d: syscall exit -> %d\n",p->pid,p->tf->a0);
    80002974:	6cbc                	ld	a5,88(s1)
    80002976:	7bb0                	ld	a2,112(a5)
    80002978:	5c8c                	lw	a1,56(s1)
    8000297a:	00005517          	auipc	a0,0x5
    8000297e:	b4650513          	addi	a0,a0,-1210 # 800074c0 <userret+0x430>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	c10080e7          	jalr	-1008(ra) # 80000592 <printf>
		break;
    8000298a:	a4a1                	j	80002bd2 <syscall+0x2e8>
		case 3: printf("%d: syscall wait -> %d\n",p->pid,p->tf->a0);
    8000298c:	6cbc                	ld	a5,88(s1)
    8000298e:	7bb0                	ld	a2,112(a5)
    80002990:	5c8c                	lw	a1,56(s1)
    80002992:	00005517          	auipc	a0,0x5
    80002996:	b4650513          	addi	a0,a0,-1210 # 800074d8 <userret+0x448>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	bf8080e7          	jalr	-1032(ra) # 80000592 <printf>
		break;
    800029a2:	ac05                	j	80002bd2 <syscall+0x2e8>
		case 4: printf("%d: syscall pipe -> %d\n",p->pid,p->tf->a0);
    800029a4:	6cbc                	ld	a5,88(s1)
    800029a6:	7bb0                	ld	a2,112(a5)
    800029a8:	5c8c                	lw	a1,56(s1)
    800029aa:	00005517          	auipc	a0,0x5
    800029ae:	b4650513          	addi	a0,a0,-1210 # 800074f0 <userret+0x460>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	be0080e7          	jalr	-1056(ra) # 80000592 <printf>
		break;
    800029ba:	ac21                	j	80002bd2 <syscall+0x2e8>
		case 5: printf("%d: syscall read -> %d\n",p->pid,p->tf->a0);
    800029bc:	6cbc                	ld	a5,88(s1)
    800029be:	7bb0                	ld	a2,112(a5)
    800029c0:	5c8c                	lw	a1,56(s1)
    800029c2:	00005517          	auipc	a0,0x5
    800029c6:	b4650513          	addi	a0,a0,-1210 # 80007508 <userret+0x478>
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	bc8080e7          	jalr	-1080(ra) # 80000592 <printf>
		break;
    800029d2:	a401                	j	80002bd2 <syscall+0x2e8>
		case 6: printf("%d: syscall kill -> %d\n",p->pid,p->tf->a0);
    800029d4:	6cbc                	ld	a5,88(s1)
    800029d6:	7bb0                	ld	a2,112(a5)
    800029d8:	5c8c                	lw	a1,56(s1)
    800029da:	00005517          	auipc	a0,0x5
    800029de:	b4650513          	addi	a0,a0,-1210 # 80007520 <userret+0x490>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	bb0080e7          	jalr	-1104(ra) # 80000592 <printf>
		break;
    800029ea:	a2e5                	j	80002bd2 <syscall+0x2e8>
		case 7: printf("%d: syscall exec -> %d\n",p->pid,p->tf->a0);
    800029ec:	6cbc                	ld	a5,88(s1)
    800029ee:	7bb0                	ld	a2,112(a5)
    800029f0:	5c8c                	lw	a1,56(s1)
    800029f2:	00005517          	auipc	a0,0x5
    800029f6:	b4650513          	addi	a0,a0,-1210 # 80007538 <userret+0x4a8>
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	b98080e7          	jalr	-1128(ra) # 80000592 <printf>
		break;
    80002a02:	aac1                	j	80002bd2 <syscall+0x2e8>
		case 8: printf("%d: syscall fstat -> %d\n",p->pid,p->tf->a0);
    80002a04:	6cbc                	ld	a5,88(s1)
    80002a06:	7bb0                	ld	a2,112(a5)
    80002a08:	5c8c                	lw	a1,56(s1)
    80002a0a:	00005517          	auipc	a0,0x5
    80002a0e:	b4650513          	addi	a0,a0,-1210 # 80007550 <userret+0x4c0>
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	b80080e7          	jalr	-1152(ra) # 80000592 <printf>
		break;
    80002a1a:	aa65                	j	80002bd2 <syscall+0x2e8>
		case 9: printf("%d: syscall chdir -> %d\n",p->pid,p->tf->a0);
    80002a1c:	6cbc                	ld	a5,88(s1)
    80002a1e:	7bb0                	ld	a2,112(a5)
    80002a20:	5c8c                	lw	a1,56(s1)
    80002a22:	00005517          	auipc	a0,0x5
    80002a26:	b4e50513          	addi	a0,a0,-1202 # 80007570 <userret+0x4e0>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b68080e7          	jalr	-1176(ra) # 80000592 <printf>
		break;
    80002a32:	a245                	j	80002bd2 <syscall+0x2e8>
		case 10: printf("%d: syscall dup -> %d\n",p->pid,p->tf->a0);
    80002a34:	6cbc                	ld	a5,88(s1)
    80002a36:	7bb0                	ld	a2,112(a5)
    80002a38:	5c8c                	lw	a1,56(s1)
    80002a3a:	00005517          	auipc	a0,0x5
    80002a3e:	b5650513          	addi	a0,a0,-1194 # 80007590 <userret+0x500>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b50080e7          	jalr	-1200(ra) # 80000592 <printf>
		break;
    80002a4a:	a261                	j	80002bd2 <syscall+0x2e8>
		case 11: printf("%d: syscall getpid -> %d\n",p->pid,p->tf->a0);
    80002a4c:	6cbc                	ld	a5,88(s1)
    80002a4e:	7bb0                	ld	a2,112(a5)
    80002a50:	5c8c                	lw	a1,56(s1)
    80002a52:	00005517          	auipc	a0,0x5
    80002a56:	b5650513          	addi	a0,a0,-1194 # 800075a8 <userret+0x518>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	b38080e7          	jalr	-1224(ra) # 80000592 <printf>
		break;
    80002a62:	aa85                	j	80002bd2 <syscall+0x2e8>
		case 12: printf("%d: syscall sbrk -> %d\n",p->pid,p->tf->a0);
    80002a64:	6cbc                	ld	a5,88(s1)
    80002a66:	7bb0                	ld	a2,112(a5)
    80002a68:	5c8c                	lw	a1,56(s1)
    80002a6a:	00005517          	auipc	a0,0x5
    80002a6e:	b5e50513          	addi	a0,a0,-1186 # 800075c8 <userret+0x538>
    80002a72:	ffffe097          	auipc	ra,0xffffe
    80002a76:	b20080e7          	jalr	-1248(ra) # 80000592 <printf>
		break;
    80002a7a:	aaa1                	j	80002bd2 <syscall+0x2e8>
		case 13: printf("%d: syscall sleep -> %d\n",p->pid,p->tf->a0);
    80002a7c:	6cbc                	ld	a5,88(s1)
    80002a7e:	7bb0                	ld	a2,112(a5)
    80002a80:	5c8c                	lw	a1,56(s1)
    80002a82:	00005517          	auipc	a0,0x5
    80002a86:	b5e50513          	addi	a0,a0,-1186 # 800075e0 <userret+0x550>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	b08080e7          	jalr	-1272(ra) # 80000592 <printf>
		break;
    80002a92:	a281                	j	80002bd2 <syscall+0x2e8>
		case 14: printf("%d: syscall uptime -> %d\n",p->pid,p->tf->a0);
    80002a94:	6cbc                	ld	a5,88(s1)
    80002a96:	7bb0                	ld	a2,112(a5)
    80002a98:	5c8c                	lw	a1,56(s1)
    80002a9a:	00005517          	auipc	a0,0x5
    80002a9e:	b6650513          	addi	a0,a0,-1178 # 80007600 <userret+0x570>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	af0080e7          	jalr	-1296(ra) # 80000592 <printf>
		break;
    80002aaa:	a225                	j	80002bd2 <syscall+0x2e8>
		case 15: printf("%d: syscall open -> %d\n",p->pid,p->tf->a0);
    80002aac:	6cbc                	ld	a5,88(s1)
    80002aae:	7bb0                	ld	a2,112(a5)
    80002ab0:	5c8c                	lw	a1,56(s1)
    80002ab2:	00005517          	auipc	a0,0x5
    80002ab6:	b6e50513          	addi	a0,a0,-1170 # 80007620 <userret+0x590>
    80002aba:	ffffe097          	auipc	ra,0xffffe
    80002abe:	ad8080e7          	jalr	-1320(ra) # 80000592 <printf>
		break;
    80002ac2:	aa01                	j	80002bd2 <syscall+0x2e8>
		case 16: printf("%d: syscall write -> %d\n",p->pid,p->tf->a0);
    80002ac4:	6cbc                	ld	a5,88(s1)
    80002ac6:	7bb0                	ld	a2,112(a5)
    80002ac8:	5c8c                	lw	a1,56(s1)
    80002aca:	00005517          	auipc	a0,0x5
    80002ace:	b6e50513          	addi	a0,a0,-1170 # 80007638 <userret+0x5a8>
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	ac0080e7          	jalr	-1344(ra) # 80000592 <printf>
		break;
    80002ada:	a8e5                	j	80002bd2 <syscall+0x2e8>
		case 17: printf("%d: syscall mknod -> %d\n",p->pid,p->tf->a0);
    80002adc:	6cbc                	ld	a5,88(s1)
    80002ade:	7bb0                	ld	a2,112(a5)
    80002ae0:	5c8c                	lw	a1,56(s1)
    80002ae2:	00005517          	auipc	a0,0x5
    80002ae6:	b7650513          	addi	a0,a0,-1162 # 80007658 <userret+0x5c8>
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	aa8080e7          	jalr	-1368(ra) # 80000592 <printf>
		break;
    80002af2:	a0c5                	j	80002bd2 <syscall+0x2e8>
		case 18: printf("%d: syscall unlink -> %d\n",p->pid,p->tf->a0);
    80002af4:	6cbc                	ld	a5,88(s1)
    80002af6:	7bb0                	ld	a2,112(a5)
    80002af8:	5c8c                	lw	a1,56(s1)
    80002afa:	00005517          	auipc	a0,0x5
    80002afe:	b7e50513          	addi	a0,a0,-1154 # 80007678 <userret+0x5e8>
    80002b02:	ffffe097          	auipc	ra,0xffffe
    80002b06:	a90080e7          	jalr	-1392(ra) # 80000592 <printf>
		break;
    80002b0a:	a0e1                	j	80002bd2 <syscall+0x2e8>
		case 19: printf("%d: syscall link -> %d\n",p->pid,p->tf->a0);
    80002b0c:	6cbc                	ld	a5,88(s1)
    80002b0e:	7bb0                	ld	a2,112(a5)
    80002b10:	5c8c                	lw	a1,56(s1)
    80002b12:	00005517          	auipc	a0,0x5
    80002b16:	b8650513          	addi	a0,a0,-1146 # 80007698 <userret+0x608>
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	a78080e7          	jalr	-1416(ra) # 80000592 <printf>
		break;
    80002b22:	a845                	j	80002bd2 <syscall+0x2e8>
		case 20: printf("%d: syscall mkdir -> %d\n",p->pid,p->tf->a0);
    80002b24:	6cbc                	ld	a5,88(s1)
    80002b26:	7bb0                	ld	a2,112(a5)
    80002b28:	5c8c                	lw	a1,56(s1)
    80002b2a:	00005517          	auipc	a0,0x5
    80002b2e:	b8650513          	addi	a0,a0,-1146 # 800076b0 <userret+0x620>
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a60080e7          	jalr	-1440(ra) # 80000592 <printf>
		break;
    80002b3a:	a861                	j	80002bd2 <syscall+0x2e8>
		case 21: printf("%d: syscall close -> %d\n",p->pid,p->tf->a0);
    80002b3c:	6cbc                	ld	a5,88(s1)
    80002b3e:	7bb0                	ld	a2,112(a5)
    80002b40:	5c8c                	lw	a1,56(s1)
    80002b42:	00005517          	auipc	a0,0x5
    80002b46:	b8e50513          	addi	a0,a0,-1138 # 800076d0 <userret+0x640>
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	a48080e7          	jalr	-1464(ra) # 80000592 <printf>
		break;
    80002b52:	a041                	j	80002bd2 <syscall+0x2e8>
		case 22: printf("%d: syscall echo_simple -> %d\n",p->pid,p->tf->a0);
    80002b54:	6cbc                	ld	a5,88(s1)
    80002b56:	7bb0                	ld	a2,112(a5)
    80002b58:	5c8c                	lw	a1,56(s1)
    80002b5a:	00005517          	auipc	a0,0x5
    80002b5e:	b9650513          	addi	a0,a0,-1130 # 800076f0 <userret+0x660>
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	a30080e7          	jalr	-1488(ra) # 80000592 <printf>
		break;
    80002b6a:	a0a5                	j	80002bd2 <syscall+0x2e8>
		case 23: printf("%d: syscall echo_kernel -> %d\n",p->pid,p->tf->a0);
    80002b6c:	6cbc                	ld	a5,88(s1)
    80002b6e:	7bb0                	ld	a2,112(a5)
    80002b70:	5c8c                	lw	a1,56(s1)
    80002b72:	00005517          	auipc	a0,0x5
    80002b76:	b9e50513          	addi	a0,a0,-1122 # 80007710 <userret+0x680>
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	a18080e7          	jalr	-1512(ra) # 80000592 <printf>
		break;
    80002b82:	a881                	j	80002bd2 <syscall+0x2e8>
		case 24: printf("%d: syscall get_process_info -> %d\n",p->pid,p->tf->a0);
    80002b84:	6cbc                	ld	a5,88(s1)
    80002b86:	7bb0                	ld	a2,112(a5)
    80002b88:	5c8c                	lw	a1,56(s1)
    80002b8a:	00005517          	auipc	a0,0x5
    80002b8e:	ba650513          	addi	a0,a0,-1114 # 80007730 <userret+0x6a0>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	a00080e7          	jalr	-1536(ra) # 80000592 <printf>
		break;
    80002b9a:	a825                	j	80002bd2 <syscall+0x2e8>
		case 25: printf("%d: syscall trace -> %d\n",p->pid,p->tf->a0);
    80002b9c:	6cbc                	ld	a5,88(s1)
    80002b9e:	7bb0                	ld	a2,112(a5)
    80002ba0:	5c8c                	lw	a1,56(s1)
    80002ba2:	00005517          	auipc	a0,0x5
    80002ba6:	bb650513          	addi	a0,a0,-1098 # 80007758 <userret+0x6c8>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	9e8080e7          	jalr	-1560(ra) # 80000592 <printf>
		break;
    80002bb2:	a005                	j	80002bd2 <syscall+0x2e8>
		
	}
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bb4:	86d2                	mv	a3,s4
    80002bb6:	15848613          	addi	a2,s1,344
    80002bba:	5c8c                	lw	a1,56(s1)
    80002bbc:	00005517          	auipc	a0,0x5
    80002bc0:	bbc50513          	addi	a0,a0,-1092 # 80007778 <userret+0x6e8>
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	9ce080e7          	jalr	-1586(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002bcc:	6cbc                	ld	a5,88(s1)
    80002bce:	577d                	li	a4,-1
    80002bd0:	fbb8                	sd	a4,112(a5)
  }
  
}
    80002bd2:	70a2                	ld	ra,40(sp)
    80002bd4:	7402                	ld	s0,32(sp)
    80002bd6:	64e2                	ld	s1,24(sp)
    80002bd8:	6942                	ld	s2,16(sp)
    80002bda:	69a2                	ld	s3,8(sp)
    80002bdc:	6a02                	ld	s4,0(sp)
    80002bde:	6145                	addi	sp,sp,48
    80002be0:	8082                	ret

0000000080002be2 <sys_exit>:
#include "file.h"
#include "fcntl.h"
#include "processinfo.h"
uint64
sys_exit(void)
{
    80002be2:	1101                	addi	sp,sp,-32
    80002be4:	ec06                	sd	ra,24(sp)
    80002be6:	e822                	sd	s0,16(sp)
    80002be8:	1000                	addi	s0,sp,32
   
  int n;
  if(argint(0, &n) < 0)
    80002bea:	fec40593          	addi	a1,s0,-20
    80002bee:	4501                	li	a0,0
    80002bf0:	00000097          	auipc	ra,0x0
    80002bf4:	c86080e7          	jalr	-890(ra) # 80002876 <argint>
    return -1;
    80002bf8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bfa:	02054063          	bltz	a0,80002c1a <sys_exit+0x38>
   int h=1<<2,i; 
   struct proc *pi = myproc();
    80002bfe:	fffff097          	auipc	ra,0xfffff
    80002c02:	c30080e7          	jalr	-976(ra) # 8000182e <myproc>
	i=pi->tra;
   if((h&i)==h){
    80002c06:	5d5c                	lw	a5,60(a0)
    80002c08:	8b91                	andi	a5,a5,4
    80002c0a:	ef89                	bnez	a5,80002c24 <sys_exit+0x42>
	printf("arguments: %d\n",n);
  }
  exit(n);
    80002c0c:	fec42503          	lw	a0,-20(s0)
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	282080e7          	jalr	642(ra) # 80001e92 <exit>
  return 0;  // not reached
    80002c18:	4781                	li	a5,0
}
    80002c1a:	853e                	mv	a0,a5
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	6105                	addi	sp,sp,32
    80002c22:	8082                	ret
	printf("arguments: %d\n",n);
    80002c24:	fec42583          	lw	a1,-20(s0)
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	b7050513          	addi	a0,a0,-1168 # 80007798 <userret+0x708>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	962080e7          	jalr	-1694(ra) # 80000592 <printf>
    80002c38:	bfd1                	j	80002c0c <sys_exit+0x2a>

0000000080002c3a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c3a:	1141                	addi	sp,sp,-16
    80002c3c:	e406                	sd	ra,8(sp)
    80002c3e:	e022                	sd	s0,0(sp)
    80002c40:	0800                	addi	s0,sp,16
	
  return myproc()->pid;
    80002c42:	fffff097          	auipc	ra,0xfffff
    80002c46:	bec080e7          	jalr	-1044(ra) # 8000182e <myproc>
}
    80002c4a:	5d08                	lw	a0,56(a0)
    80002c4c:	60a2                	ld	ra,8(sp)
    80002c4e:	6402                	ld	s0,0(sp)
    80002c50:	0141                	addi	sp,sp,16
    80002c52:	8082                	ret

0000000080002c54 <sys_fork>:

uint64
sys_fork(void)
{
    80002c54:	1141                	addi	sp,sp,-16
    80002c56:	e406                	sd	ra,8(sp)
    80002c58:	e022                	sd	s0,0(sp)
    80002c5a:	0800                	addi	s0,sp,16
  return fork();
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	f40080e7          	jalr	-192(ra) # 80001b9c <fork>
}
    80002c64:	60a2                	ld	ra,8(sp)
    80002c66:	6402                	ld	s0,0(sp)
    80002c68:	0141                	addi	sp,sp,16
    80002c6a:	8082                	ret

0000000080002c6c <sys_wait>:

uint64
sys_wait(void)
{
    80002c6c:	1101                	addi	sp,sp,-32
    80002c6e:	ec06                	sd	ra,24(sp)
    80002c70:	e822                	sd	s0,16(sp)
    80002c72:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c74:	fe840593          	addi	a1,s0,-24
    80002c78:	4501                	li	a0,0
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	c1e080e7          	jalr	-994(ra) # 80002898 <argaddr>
    80002c82:	87aa                	mv	a5,a0
    return -1;
    80002c84:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c86:	0007cf63          	bltz	a5,80002ca4 <sys_wait+0x38>
   int h=1<<3,i; 
   struct proc *pi = myproc();
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	ba4080e7          	jalr	-1116(ra) # 8000182e <myproc>
	i=pi->tra;
   if((h&i)==h){
    80002c92:	5d5c                	lw	a5,60(a0)
    80002c94:	8ba1                	andi	a5,a5,8
    80002c96:	eb99                	bnez	a5,80002cac <sys_wait+0x40>
	printf("arguments: %p\n",p);
  }
  return wait(p);
    80002c98:	fe843503          	ld	a0,-24(s0)
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	3ba080e7          	jalr	954(ra) # 80002056 <wait>
}
    80002ca4:	60e2                	ld	ra,24(sp)
    80002ca6:	6442                	ld	s0,16(sp)
    80002ca8:	6105                	addi	sp,sp,32
    80002caa:	8082                	ret
	printf("arguments: %p\n",p);
    80002cac:	fe843583          	ld	a1,-24(s0)
    80002cb0:	00005517          	auipc	a0,0x5
    80002cb4:	af850513          	addi	a0,a0,-1288 # 800077a8 <userret+0x718>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	8da080e7          	jalr	-1830(ra) # 80000592 <printf>
    80002cc0:	bfe1                	j	80002c98 <sys_wait+0x2c>

0000000080002cc2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cc2:	7139                	addi	sp,sp,-64
    80002cc4:	fc06                	sd	ra,56(sp)
    80002cc6:	f822                	sd	s0,48(sp)
    80002cc8:	f426                	sd	s1,40(sp)
    80002cca:	f04a                	sd	s2,32(sp)
    80002ccc:	ec4e                	sd	s3,24(sp)
    80002cce:	0080                	addi	s0,sp,64
  int addr;
  int n;
  if(argint(0, &n) < 0)
    80002cd0:	fcc40593          	addi	a1,s0,-52
    80002cd4:	4501                	li	a0,0
    80002cd6:	00000097          	auipc	ra,0x0
    80002cda:	ba0080e7          	jalr	-1120(ra) # 80002876 <argint>
    return -1;
    80002cde:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002ce0:	02054663          	bltz	a0,80002d0c <sys_sbrk+0x4a>
  addr = myproc()->sz;
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	b4a080e7          	jalr	-1206(ra) # 8000182e <myproc>
    80002cec:	4524                	lw	s1,72(a0)
  myproc()->sz=myproc()->sz+n;
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	b40080e7          	jalr	-1216(ra) # 8000182e <myproc>
    80002cf6:	04853903          	ld	s2,72(a0)
    80002cfa:	fcc42983          	lw	s3,-52(s0)
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	b30080e7          	jalr	-1232(ra) # 8000182e <myproc>
    80002d06:	994e                	add	s2,s2,s3
    80002d08:	05253423          	sd	s2,72(a0)
  return addr;
}
    80002d0c:	8526                	mv	a0,s1
    80002d0e:	70e2                	ld	ra,56(sp)
    80002d10:	7442                	ld	s0,48(sp)
    80002d12:	74a2                	ld	s1,40(sp)
    80002d14:	7902                	ld	s2,32(sp)
    80002d16:	69e2                	ld	s3,24(sp)
    80002d18:	6121                	addi	sp,sp,64
    80002d1a:	8082                	ret

0000000080002d1c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d1c:	7139                	addi	sp,sp,-64
    80002d1e:	fc06                	sd	ra,56(sp)
    80002d20:	f822                	sd	s0,48(sp)
    80002d22:	f426                	sd	s1,40(sp)
    80002d24:	f04a                	sd	s2,32(sp)
    80002d26:	ec4e                	sd	s3,24(sp)
    80002d28:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d2a:	fcc40593          	addi	a1,s0,-52
    80002d2e:	4501                	li	a0,0
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	b46080e7          	jalr	-1210(ra) # 80002876 <argint>
    return -1;
    80002d38:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d3a:	06054d63          	bltz	a0,80002db4 <sys_sleep+0x98>
  int h=1<<13,i; 
   struct proc *pi = myproc();
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	af0080e7          	jalr	-1296(ra) # 8000182e <myproc>
	i=pi->tra;
   if((h&i)==h){
    80002d46:	5d5c                	lw	a5,60(a0)
    80002d48:	6709                	lui	a4,0x2
    80002d4a:	8ff9                	and	a5,a5,a4
    80002d4c:	efa5                	bnez	a5,80002dc4 <sys_sleep+0xa8>
	printf("arguments: %d\n",n);
  }
  acquire(&tickslock);
    80002d4e:	00015517          	auipc	a0,0x15
    80002d52:	9b250513          	addi	a0,a0,-1614 # 80017700 <tickslock>
    80002d56:	ffffe097          	auipc	ra,0xffffe
    80002d5a:	d68080e7          	jalr	-664(ra) # 80000abe <acquire>
  ticks0 = ticks;
    80002d5e:	00023917          	auipc	s2,0x23
    80002d62:	2ba92903          	lw	s2,698(s2) # 80026018 <ticks>
  while(ticks - ticks0 < n){
    80002d66:	fcc42783          	lw	a5,-52(s0)
    80002d6a:	cf85                	beqz	a5,80002da2 <sys_sleep+0x86>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d6c:	00015997          	auipc	s3,0x15
    80002d70:	99498993          	addi	s3,s3,-1644 # 80017700 <tickslock>
    80002d74:	00023497          	auipc	s1,0x23
    80002d78:	2a448493          	addi	s1,s1,676 # 80026018 <ticks>
    if(myproc()->killed){
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	ab2080e7          	jalr	-1358(ra) # 8000182e <myproc>
    80002d84:	591c                	lw	a5,48(a0)
    80002d86:	ebb1                	bnez	a5,80002dda <sys_sleep+0xbe>
    sleep(&ticks, &tickslock);
    80002d88:	85ce                	mv	a1,s3
    80002d8a:	8526                	mv	a0,s1
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	24c080e7          	jalr	588(ra) # 80001fd8 <sleep>
  while(ticks - ticks0 < n){
    80002d94:	409c                	lw	a5,0(s1)
    80002d96:	412787bb          	subw	a5,a5,s2
    80002d9a:	fcc42703          	lw	a4,-52(s0)
    80002d9e:	fce7efe3          	bltu	a5,a4,80002d7c <sys_sleep+0x60>
  }
  release(&tickslock);
    80002da2:	00015517          	auipc	a0,0x15
    80002da6:	95e50513          	addi	a0,a0,-1698 # 80017700 <tickslock>
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	d68080e7          	jalr	-664(ra) # 80000b12 <release>
  return 0;
    80002db2:	4781                	li	a5,0
}
    80002db4:	853e                	mv	a0,a5
    80002db6:	70e2                	ld	ra,56(sp)
    80002db8:	7442                	ld	s0,48(sp)
    80002dba:	74a2                	ld	s1,40(sp)
    80002dbc:	7902                	ld	s2,32(sp)
    80002dbe:	69e2                	ld	s3,24(sp)
    80002dc0:	6121                	addi	sp,sp,64
    80002dc2:	8082                	ret
	printf("arguments: %d\n",n);
    80002dc4:	fcc42583          	lw	a1,-52(s0)
    80002dc8:	00005517          	auipc	a0,0x5
    80002dcc:	9d050513          	addi	a0,a0,-1584 # 80007798 <userret+0x708>
    80002dd0:	ffffd097          	auipc	ra,0xffffd
    80002dd4:	7c2080e7          	jalr	1986(ra) # 80000592 <printf>
    80002dd8:	bf9d                	j	80002d4e <sys_sleep+0x32>
      release(&tickslock);
    80002dda:	00015517          	auipc	a0,0x15
    80002dde:	92650513          	addi	a0,a0,-1754 # 80017700 <tickslock>
    80002de2:	ffffe097          	auipc	ra,0xffffe
    80002de6:	d30080e7          	jalr	-720(ra) # 80000b12 <release>
      return -1;
    80002dea:	57fd                	li	a5,-1
    80002dec:	b7e1                	j	80002db4 <sys_sleep+0x98>

0000000080002dee <sys_kill>:

uint64
sys_kill(void)
{
    80002dee:	1101                	addi	sp,sp,-32
    80002df0:	ec06                	sd	ra,24(sp)
    80002df2:	e822                	sd	s0,16(sp)
    80002df4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002df6:	fec40593          	addi	a1,s0,-20
    80002dfa:	4501                	li	a0,0
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	a7a080e7          	jalr	-1414(ra) # 80002876 <argint>
    80002e04:	87aa                	mv	a5,a0
    return -1;
    80002e06:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e08:	0207c063          	bltz	a5,80002e28 <sys_kill+0x3a>
  int h=1<<6,i; 
   struct proc *pi = myproc();
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	a22080e7          	jalr	-1502(ra) # 8000182e <myproc>
	i=pi->tra;
   if((h&i)==h){
    80002e14:	5d5c                	lw	a5,60(a0)
    80002e16:	0407f793          	andi	a5,a5,64
    80002e1a:	eb99                	bnez	a5,80002e30 <sys_kill+0x42>
	printf("arguments: %d\n",pid);
  }
  return kill(pid);
    80002e1c:	fec42503          	lw	a0,-20(s0)
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	3a2080e7          	jalr	930(ra) # 800021c2 <kill>
}
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret
	printf("arguments: %d\n",pid);
    80002e30:	fec42583          	lw	a1,-20(s0)
    80002e34:	00005517          	auipc	a0,0x5
    80002e38:	96450513          	addi	a0,a0,-1692 # 80007798 <userret+0x708>
    80002e3c:	ffffd097          	auipc	ra,0xffffd
    80002e40:	756080e7          	jalr	1878(ra) # 80000592 <printf>
    80002e44:	bfe1                	j	80002e1c <sys_kill+0x2e>

0000000080002e46 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e46:	1101                	addi	sp,sp,-32
    80002e48:	ec06                	sd	ra,24(sp)
    80002e4a:	e822                	sd	s0,16(sp)
    80002e4c:	e426                	sd	s1,8(sp)
    80002e4e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e50:	00015517          	auipc	a0,0x15
    80002e54:	8b050513          	addi	a0,a0,-1872 # 80017700 <tickslock>
    80002e58:	ffffe097          	auipc	ra,0xffffe
    80002e5c:	c66080e7          	jalr	-922(ra) # 80000abe <acquire>
  xticks = ticks;
    80002e60:	00023497          	auipc	s1,0x23
    80002e64:	1b84a483          	lw	s1,440(s1) # 80026018 <ticks>
  release(&tickslock);
    80002e68:	00015517          	auipc	a0,0x15
    80002e6c:	89850513          	addi	a0,a0,-1896 # 80017700 <tickslock>
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	ca2080e7          	jalr	-862(ra) # 80000b12 <release>
  return xticks;
}
    80002e78:	02049513          	slli	a0,s1,0x20
    80002e7c:	9101                	srli	a0,a0,0x20
    80002e7e:	60e2                	ld	ra,24(sp)
    80002e80:	6442                	ld	s0,16(sp)
    80002e82:	64a2                	ld	s1,8(sp)
    80002e84:	6105                	addi	sp,sp,32
    80002e86:	8082                	ret

0000000080002e88 <sys_echo_simple>:
uint64
sys_echo_simple(void){
    80002e88:	7119                	addi	sp,sp,-128
    80002e8a:	fc86                	sd	ra,120(sp)
    80002e8c:	f8a2                	sd	s0,112(sp)
    80002e8e:	0100                	addi	s0,sp,128
	char buf[100];
	if(argstr(0, buf, 100)<0)return -1;
    80002e90:	06400613          	li	a2,100
    80002e94:	f8840593          	addi	a1,s0,-120
    80002e98:	4501                	li	a0,0
    80002e9a:	00000097          	auipc	ra,0x0
    80002e9e:	a20080e7          	jalr	-1504(ra) # 800028ba <argstr>
    80002ea2:	57fd                	li	a5,-1
    80002ea4:	02054663          	bltz	a0,80002ed0 <sys_echo_simple+0x48>
	int h=1<<22,i; 
	struct proc *pi = myproc();
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	986080e7          	jalr	-1658(ra) # 8000182e <myproc>
	i=pi->tra;
	if((h&i)==h){
    80002eb0:	5d5c                	lw	a5,60(a0)
    80002eb2:	00400737          	lui	a4,0x400
    80002eb6:	8ff9                	and	a5,a5,a4
    80002eb8:	e38d                	bnez	a5,80002eda <sys_echo_simple+0x52>
		printf("arguments: %s\n",buf);
	}
	printf("%s\n", buf);
    80002eba:	f8840593          	addi	a1,s0,-120
    80002ebe:	00005517          	auipc	a0,0x5
    80002ec2:	90a50513          	addi	a0,a0,-1782 # 800077c8 <userret+0x738>
    80002ec6:	ffffd097          	auipc	ra,0xffffd
    80002eca:	6cc080e7          	jalr	1740(ra) # 80000592 <printf>
	return 0;
    80002ece:	4781                	li	a5,0

}
    80002ed0:	853e                	mv	a0,a5
    80002ed2:	70e6                	ld	ra,120(sp)
    80002ed4:	7446                	ld	s0,112(sp)
    80002ed6:	6109                	addi	sp,sp,128
    80002ed8:	8082                	ret
		printf("arguments: %s\n",buf);
    80002eda:	f8840593          	addi	a1,s0,-120
    80002ede:	00005517          	auipc	a0,0x5
    80002ee2:	8da50513          	addi	a0,a0,-1830 # 800077b8 <userret+0x728>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	6ac080e7          	jalr	1708(ra) # 80000592 <printf>
    80002eee:	b7f1                	j	80002eba <sys_echo_simple+0x32>

0000000080002ef0 <sys_echo_kernel>:
uint64
sys_echo_kernel(void){
    80002ef0:	7171                	addi	sp,sp,-176
    80002ef2:	f506                	sd	ra,168(sp)
    80002ef4:	f122                	sd	s0,160(sp)
    80002ef6:	ed26                	sd	s1,152(sp)
    80002ef8:	e94a                	sd	s2,144(sp)
    80002efa:	e54e                	sd	s3,136(sp)
    80002efc:	1900                	addi	s0,sp,176
	int n;
	uint64 uargv;
	char buf[100];
	if(argaddr(1,&uargv)<0||argint(0, &n)<0)return -1;
    80002efe:	fc040593          	addi	a1,s0,-64
    80002f02:	4505                	li	a0,1
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	994080e7          	jalr	-1644(ra) # 80002898 <argaddr>
    80002f0c:	57fd                	li	a5,-1
    80002f0e:	08054263          	bltz	a0,80002f92 <sys_echo_kernel+0xa2>
    80002f12:	fcc40593          	addi	a1,s0,-52
    80002f16:	4501                	li	a0,0
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	95e080e7          	jalr	-1698(ra) # 80002876 <argint>
    80002f20:	57fd                	li	a5,-1
    80002f22:	06054863          	bltz	a0,80002f92 <sys_echo_kernel+0xa2>
	int h=1<<23,i; 
	struct proc *pi = myproc();
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	908080e7          	jalr	-1784(ra) # 8000182e <myproc>
	i=pi->tra;
	if((h&i)==h){
    80002f2e:	5d5c                	lw	a5,60(a0)
    80002f30:	00800737          	lui	a4,0x800
    80002f34:	8ff9                	and	a5,a5,a4
    80002f36:	e7b5                	bnez	a5,80002fa2 <sys_echo_kernel+0xb2>
		printf("arguments: %d %p\n",n,uargv);
	}
	for(int i=1;i<n;i++){
    80002f38:	fcc42703          	lw	a4,-52(s0)
    80002f3c:	4785                	li	a5,1
    80002f3e:	04e7d163          	bge	a5,a4,80002f80 <sys_echo_kernel+0x90>
    80002f42:	4941                	li	s2,16
    80002f44:	4485                	li	s1,1
		fetchstr(uargv-i*16,buf,100);
		printf("%s ", buf);
    80002f46:	00005997          	auipc	s3,0x5
    80002f4a:	8a298993          	addi	s3,s3,-1886 # 800077e8 <userret+0x758>
		fetchstr(uargv-i*16,buf,100);
    80002f4e:	06400613          	li	a2,100
    80002f52:	f5840593          	addi	a1,s0,-168
    80002f56:	fc043503          	ld	a0,-64(s0)
    80002f5a:	41250533          	sub	a0,a0,s2
    80002f5e:	00000097          	auipc	ra,0x0
    80002f62:	8d0080e7          	jalr	-1840(ra) # 8000282e <fetchstr>
		printf("%s ", buf);
    80002f66:	f5840593          	addi	a1,s0,-168
    80002f6a:	854e                	mv	a0,s3
    80002f6c:	ffffd097          	auipc	ra,0xffffd
    80002f70:	626080e7          	jalr	1574(ra) # 80000592 <printf>
	for(int i=1;i<n;i++){
    80002f74:	2485                	addiw	s1,s1,1
    80002f76:	0941                	addi	s2,s2,16
    80002f78:	fcc42783          	lw	a5,-52(s0)
    80002f7c:	fcf4c9e3          	blt	s1,a5,80002f4e <sys_echo_kernel+0x5e>
	}
	printf("\n");
    80002f80:	00005517          	auipc	a0,0x5
    80002f84:	b7050513          	addi	a0,a0,-1168 # 80007af0 <userret+0xa60>
    80002f88:	ffffd097          	auipc	ra,0xffffd
    80002f8c:	60a080e7          	jalr	1546(ra) # 80000592 <printf>
	return 0;
    80002f90:	4781                	li	a5,0

}
    80002f92:	853e                	mv	a0,a5
    80002f94:	70aa                	ld	ra,168(sp)
    80002f96:	740a                	ld	s0,160(sp)
    80002f98:	64ea                	ld	s1,152(sp)
    80002f9a:	694a                	ld	s2,144(sp)
    80002f9c:	69aa                	ld	s3,136(sp)
    80002f9e:	614d                	addi	sp,sp,176
    80002fa0:	8082                	ret
		printf("arguments: %d %p\n",n,uargv);
    80002fa2:	fc043603          	ld	a2,-64(s0)
    80002fa6:	fcc42583          	lw	a1,-52(s0)
    80002faa:	00005517          	auipc	a0,0x5
    80002fae:	82650513          	addi	a0,a0,-2010 # 800077d0 <userret+0x740>
    80002fb2:	ffffd097          	auipc	ra,0xffffd
    80002fb6:	5e0080e7          	jalr	1504(ra) # 80000592 <printf>
    80002fba:	bfbd                	j	80002f38 <sys_echo_kernel+0x48>

0000000080002fbc <sys_get_process_info>:
uint64
sys_get_process_info(void){
    80002fbc:	715d                	addi	sp,sp,-80
    80002fbe:	e486                	sd	ra,72(sp)
    80002fc0:	e0a2                	sd	s0,64(sp)
    80002fc2:	fc26                	sd	s1,56(sp)
    80002fc4:	0880                	addi	s0,sp,80
	uint64 uargv;
	if(argaddr(0,&uargv)<0)return -1;
    80002fc6:	fd840593          	addi	a1,s0,-40
    80002fca:	4501                	li	a0,0
    80002fcc:	00000097          	auipc	ra,0x0
    80002fd0:	8cc080e7          	jalr	-1844(ra) # 80002898 <argaddr>
    80002fd4:	87aa                	mv	a5,a0
    80002fd6:	557d                	li	a0,-1
    80002fd8:	0407cb63          	bltz	a5,8000302e <sys_get_process_info+0x72>
	int h=1<<24,i; 
	struct proc *pi = myproc();
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	852080e7          	jalr	-1966(ra) # 8000182e <myproc>
	i=pi->tra;
	if((h&i)==h){
    80002fe4:	5d5c                	lw	a5,60(a0)
    80002fe6:	01000737          	lui	a4,0x1000
    80002fea:	8ff9                	and	a5,a5,a4
    80002fec:	e7b1                	bnez	a5,80003038 <sys_get_process_info+0x7c>
		printf("arguments: %p\n",uargv);
	}
	struct processinfo pf;
	struct proc *p = myproc();
    80002fee:	fffff097          	auipc	ra,0xfffff
    80002ff2:	840080e7          	jalr	-1984(ra) # 8000182e <myproc>
    80002ff6:	84aa                	mv	s1,a0
	pf.pid=p->pid;
    80002ff8:	5d1c                	lw	a5,56(a0)
    80002ffa:	faf42c23          	sw	a5,-72(s0)
	pf.sz=p->sz;
    80002ffe:	653c                	ld	a5,72(a0)
    80003000:	fcf43823          	sd	a5,-48(s0)
	strncpy(pf.name,p->name,16);
    80003004:	4641                	li	a2,16
    80003006:	15850593          	addi	a1,a0,344
    8000300a:	fbc40513          	addi	a0,s0,-68
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	c60080e7          	jalr	-928(ra) # 80000c6e <strncpy>
	if(copyout(p->pagetable, uargv, (char *)&pf, sizeof(pf)) < 0)return -1;
    80003016:	02000693          	li	a3,32
    8000301a:	fb840613          	addi	a2,s0,-72
    8000301e:	fd843583          	ld	a1,-40(s0)
    80003022:	68a8                	ld	a0,80(s1)
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	4fc080e7          	jalr	1276(ra) # 80001520 <copyout>
    8000302c:	957d                	srai	a0,a0,0x3f
	return 0;

}
    8000302e:	60a6                	ld	ra,72(sp)
    80003030:	6406                	ld	s0,64(sp)
    80003032:	74e2                	ld	s1,56(sp)
    80003034:	6161                	addi	sp,sp,80
    80003036:	8082                	ret
		printf("arguments: %p\n",uargv);
    80003038:	fd843583          	ld	a1,-40(s0)
    8000303c:	00004517          	auipc	a0,0x4
    80003040:	76c50513          	addi	a0,a0,1900 # 800077a8 <userret+0x718>
    80003044:	ffffd097          	auipc	ra,0xffffd
    80003048:	54e080e7          	jalr	1358(ra) # 80000592 <printf>
    8000304c:	b74d                	j	80002fee <sys_get_process_info+0x32>

000000008000304e <sys_trace>:
uint64
sys_trace(void){
    8000304e:	7179                	addi	sp,sp,-48
    80003050:	f406                	sd	ra,40(sp)
    80003052:	f022                	sd	s0,32(sp)
    80003054:	ec26                	sd	s1,24(sp)
    80003056:	1800                	addi	s0,sp,48
	int n;
	struct proc*p=myproc();
    80003058:	ffffe097          	auipc	ra,0xffffe
    8000305c:	7d6080e7          	jalr	2006(ra) # 8000182e <myproc>
    80003060:	84aa                	mv	s1,a0
	if(argint(0, &n)<0)return -1;
    80003062:	fdc40593          	addi	a1,s0,-36
    80003066:	4501                	li	a0,0
    80003068:	00000097          	auipc	ra,0x0
    8000306c:	80e080e7          	jalr	-2034(ra) # 80002876 <argint>
    80003070:	02054963          	bltz	a0,800030a2 <sys_trace+0x54>
	p->tra=n;
    80003074:	fdc42583          	lw	a1,-36(s0)
    80003078:	dccc                	sw	a1,60(s1)
	int h=1<<25,i; 
	i=p->tra;
	if((h&i)==h){
    8000307a:	0195d793          	srli	a5,a1,0x19
    8000307e:	8b85                	andi	a5,a5,1
		printf("arguments: %d\n",n);
	}
	return 0;
    80003080:	4501                	li	a0,0
	if((h&i)==h){
    80003082:	e791                	bnez	a5,8000308e <sys_trace+0x40>
}
    80003084:	70a2                	ld	ra,40(sp)
    80003086:	7402                	ld	s0,32(sp)
    80003088:	64e2                	ld	s1,24(sp)
    8000308a:	6145                	addi	sp,sp,48
    8000308c:	8082                	ret
		printf("arguments: %d\n",n);
    8000308e:	00004517          	auipc	a0,0x4
    80003092:	70a50513          	addi	a0,a0,1802 # 80007798 <userret+0x708>
    80003096:	ffffd097          	auipc	ra,0xffffd
    8000309a:	4fc080e7          	jalr	1276(ra) # 80000592 <printf>
	return 0;
    8000309e:	4501                	li	a0,0
    800030a0:	b7d5                	j	80003084 <sys_trace+0x36>
	if(argint(0, &n)<0)return -1;
    800030a2:	557d                	li	a0,-1
    800030a4:	b7c5                	j	80003084 <sys_trace+0x36>

00000000800030a6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030a6:	7179                	addi	sp,sp,-48
    800030a8:	f406                	sd	ra,40(sp)
    800030aa:	f022                	sd	s0,32(sp)
    800030ac:	ec26                	sd	s1,24(sp)
    800030ae:	e84a                	sd	s2,16(sp)
    800030b0:	e44e                	sd	s3,8(sp)
    800030b2:	e052                	sd	s4,0(sp)
    800030b4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030b6:	00004597          	auipc	a1,0x4
    800030ba:	73a58593          	addi	a1,a1,1850 # 800077f0 <userret+0x760>
    800030be:	00014517          	auipc	a0,0x14
    800030c2:	65a50513          	addi	a0,a0,1626 # 80017718 <bcache>
    800030c6:	ffffe097          	auipc	ra,0xffffe
    800030ca:	8ea080e7          	jalr	-1814(ra) # 800009b0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030ce:	0001c797          	auipc	a5,0x1c
    800030d2:	64a78793          	addi	a5,a5,1610 # 8001f718 <bcache+0x8000>
    800030d6:	0001d717          	auipc	a4,0x1d
    800030da:	99a70713          	addi	a4,a4,-1638 # 8001fa70 <bcache+0x8358>
    800030de:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    800030e2:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030e6:	00014497          	auipc	s1,0x14
    800030ea:	64a48493          	addi	s1,s1,1610 # 80017730 <bcache+0x18>
    b->next = bcache.head.next;
    800030ee:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030f0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030f2:	00004a17          	auipc	s4,0x4
    800030f6:	706a0a13          	addi	s4,s4,1798 # 800077f8 <userret+0x768>
    b->next = bcache.head.next;
    800030fa:	3a893783          	ld	a5,936(s2)
    800030fe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003100:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003104:	85d2                	mv	a1,s4
    80003106:	01048513          	addi	a0,s1,16
    8000310a:	00001097          	auipc	ra,0x1
    8000310e:	48c080e7          	jalr	1164(ra) # 80004596 <initsleeplock>
    bcache.head.next->prev = b;
    80003112:	3a893783          	ld	a5,936(s2)
    80003116:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003118:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000311c:	46048493          	addi	s1,s1,1120
    80003120:	fd349de3          	bne	s1,s3,800030fa <binit+0x54>
  }
}
    80003124:	70a2                	ld	ra,40(sp)
    80003126:	7402                	ld	s0,32(sp)
    80003128:	64e2                	ld	s1,24(sp)
    8000312a:	6942                	ld	s2,16(sp)
    8000312c:	69a2                	ld	s3,8(sp)
    8000312e:	6a02                	ld	s4,0(sp)
    80003130:	6145                	addi	sp,sp,48
    80003132:	8082                	ret

0000000080003134 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003134:	7179                	addi	sp,sp,-48
    80003136:	f406                	sd	ra,40(sp)
    80003138:	f022                	sd	s0,32(sp)
    8000313a:	ec26                	sd	s1,24(sp)
    8000313c:	e84a                	sd	s2,16(sp)
    8000313e:	e44e                	sd	s3,8(sp)
    80003140:	1800                	addi	s0,sp,48
    80003142:	892a                	mv	s2,a0
    80003144:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003146:	00014517          	auipc	a0,0x14
    8000314a:	5d250513          	addi	a0,a0,1490 # 80017718 <bcache>
    8000314e:	ffffe097          	auipc	ra,0xffffe
    80003152:	970080e7          	jalr	-1680(ra) # 80000abe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003156:	0001d497          	auipc	s1,0x1d
    8000315a:	96a4b483          	ld	s1,-1686(s1) # 8001fac0 <bcache+0x83a8>
    8000315e:	0001d797          	auipc	a5,0x1d
    80003162:	91278793          	addi	a5,a5,-1774 # 8001fa70 <bcache+0x8358>
    80003166:	02f48f63          	beq	s1,a5,800031a4 <bread+0x70>
    8000316a:	873e                	mv	a4,a5
    8000316c:	a021                	j	80003174 <bread+0x40>
    8000316e:	68a4                	ld	s1,80(s1)
    80003170:	02e48a63          	beq	s1,a4,800031a4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003174:	449c                	lw	a5,8(s1)
    80003176:	ff279ce3          	bne	a5,s2,8000316e <bread+0x3a>
    8000317a:	44dc                	lw	a5,12(s1)
    8000317c:	ff3799e3          	bne	a5,s3,8000316e <bread+0x3a>
      b->refcnt++;
    80003180:	40bc                	lw	a5,64(s1)
    80003182:	2785                	addiw	a5,a5,1
    80003184:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003186:	00014517          	auipc	a0,0x14
    8000318a:	59250513          	addi	a0,a0,1426 # 80017718 <bcache>
    8000318e:	ffffe097          	auipc	ra,0xffffe
    80003192:	984080e7          	jalr	-1660(ra) # 80000b12 <release>
      acquiresleep(&b->lock);
    80003196:	01048513          	addi	a0,s1,16
    8000319a:	00001097          	auipc	ra,0x1
    8000319e:	436080e7          	jalr	1078(ra) # 800045d0 <acquiresleep>
      return b;
    800031a2:	a8b9                	j	80003200 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031a4:	0001d497          	auipc	s1,0x1d
    800031a8:	9144b483          	ld	s1,-1772(s1) # 8001fab8 <bcache+0x83a0>
    800031ac:	0001d797          	auipc	a5,0x1d
    800031b0:	8c478793          	addi	a5,a5,-1852 # 8001fa70 <bcache+0x8358>
    800031b4:	00f48863          	beq	s1,a5,800031c4 <bread+0x90>
    800031b8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031ba:	40bc                	lw	a5,64(s1)
    800031bc:	cf81                	beqz	a5,800031d4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031be:	64a4                	ld	s1,72(s1)
    800031c0:	fee49de3          	bne	s1,a4,800031ba <bread+0x86>
  panic("bget: no buffers");
    800031c4:	00004517          	auipc	a0,0x4
    800031c8:	63c50513          	addi	a0,a0,1596 # 80007800 <userret+0x770>
    800031cc:	ffffd097          	auipc	ra,0xffffd
    800031d0:	37c080e7          	jalr	892(ra) # 80000548 <panic>
      b->dev = dev;
    800031d4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031d8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031dc:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031e0:	4785                	li	a5,1
    800031e2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031e4:	00014517          	auipc	a0,0x14
    800031e8:	53450513          	addi	a0,a0,1332 # 80017718 <bcache>
    800031ec:	ffffe097          	auipc	ra,0xffffe
    800031f0:	926080e7          	jalr	-1754(ra) # 80000b12 <release>
      acquiresleep(&b->lock);
    800031f4:	01048513          	addi	a0,s1,16
    800031f8:	00001097          	auipc	ra,0x1
    800031fc:	3d8080e7          	jalr	984(ra) # 800045d0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003200:	409c                	lw	a5,0(s1)
    80003202:	cb89                	beqz	a5,80003214 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003204:	8526                	mv	a0,s1
    80003206:	70a2                	ld	ra,40(sp)
    80003208:	7402                	ld	s0,32(sp)
    8000320a:	64e2                	ld	s1,24(sp)
    8000320c:	6942                	ld	s2,16(sp)
    8000320e:	69a2                	ld	s3,8(sp)
    80003210:	6145                	addi	sp,sp,48
    80003212:	8082                	ret
    virtio_disk_rw(b, 0);
    80003214:	4581                	li	a1,0
    80003216:	8526                	mv	a0,s1
    80003218:	00003097          	auipc	ra,0x3
    8000321c:	146080e7          	jalr	326(ra) # 8000635e <virtio_disk_rw>
    b->valid = 1;
    80003220:	4785                	li	a5,1
    80003222:	c09c                	sw	a5,0(s1)
  return b;
    80003224:	b7c5                	j	80003204 <bread+0xd0>

0000000080003226 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003226:	1101                	addi	sp,sp,-32
    80003228:	ec06                	sd	ra,24(sp)
    8000322a:	e822                	sd	s0,16(sp)
    8000322c:	e426                	sd	s1,8(sp)
    8000322e:	1000                	addi	s0,sp,32
    80003230:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003232:	0541                	addi	a0,a0,16
    80003234:	00001097          	auipc	ra,0x1
    80003238:	436080e7          	jalr	1078(ra) # 8000466a <holdingsleep>
    8000323c:	cd01                	beqz	a0,80003254 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000323e:	4585                	li	a1,1
    80003240:	8526                	mv	a0,s1
    80003242:	00003097          	auipc	ra,0x3
    80003246:	11c080e7          	jalr	284(ra) # 8000635e <virtio_disk_rw>
}
    8000324a:	60e2                	ld	ra,24(sp)
    8000324c:	6442                	ld	s0,16(sp)
    8000324e:	64a2                	ld	s1,8(sp)
    80003250:	6105                	addi	sp,sp,32
    80003252:	8082                	ret
    panic("bwrite");
    80003254:	00004517          	auipc	a0,0x4
    80003258:	5c450513          	addi	a0,a0,1476 # 80007818 <userret+0x788>
    8000325c:	ffffd097          	auipc	ra,0xffffd
    80003260:	2ec080e7          	jalr	748(ra) # 80000548 <panic>

0000000080003264 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	e426                	sd	s1,8(sp)
    8000326c:	e04a                	sd	s2,0(sp)
    8000326e:	1000                	addi	s0,sp,32
    80003270:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003272:	01050913          	addi	s2,a0,16
    80003276:	854a                	mv	a0,s2
    80003278:	00001097          	auipc	ra,0x1
    8000327c:	3f2080e7          	jalr	1010(ra) # 8000466a <holdingsleep>
    80003280:	c92d                	beqz	a0,800032f2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003282:	854a                	mv	a0,s2
    80003284:	00001097          	auipc	ra,0x1
    80003288:	3a2080e7          	jalr	930(ra) # 80004626 <releasesleep>

  acquire(&bcache.lock);
    8000328c:	00014517          	auipc	a0,0x14
    80003290:	48c50513          	addi	a0,a0,1164 # 80017718 <bcache>
    80003294:	ffffe097          	auipc	ra,0xffffe
    80003298:	82a080e7          	jalr	-2006(ra) # 80000abe <acquire>
  b->refcnt--;
    8000329c:	40bc                	lw	a5,64(s1)
    8000329e:	37fd                	addiw	a5,a5,-1
    800032a0:	0007871b          	sext.w	a4,a5
    800032a4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032a6:	eb05                	bnez	a4,800032d6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032a8:	68bc                	ld	a5,80(s1)
    800032aa:	64b8                	ld	a4,72(s1)
    800032ac:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032ae:	64bc                	ld	a5,72(s1)
    800032b0:	68b8                	ld	a4,80(s1)
    800032b2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032b4:	0001c797          	auipc	a5,0x1c
    800032b8:	46478793          	addi	a5,a5,1124 # 8001f718 <bcache+0x8000>
    800032bc:	3a87b703          	ld	a4,936(a5)
    800032c0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032c2:	0001c717          	auipc	a4,0x1c
    800032c6:	7ae70713          	addi	a4,a4,1966 # 8001fa70 <bcache+0x8358>
    800032ca:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032cc:	3a87b703          	ld	a4,936(a5)
    800032d0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032d2:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    800032d6:	00014517          	auipc	a0,0x14
    800032da:	44250513          	addi	a0,a0,1090 # 80017718 <bcache>
    800032de:	ffffe097          	auipc	ra,0xffffe
    800032e2:	834080e7          	jalr	-1996(ra) # 80000b12 <release>
}
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	64a2                	ld	s1,8(sp)
    800032ec:	6902                	ld	s2,0(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret
    panic("brelse");
    800032f2:	00004517          	auipc	a0,0x4
    800032f6:	52e50513          	addi	a0,a0,1326 # 80007820 <userret+0x790>
    800032fa:	ffffd097          	auipc	ra,0xffffd
    800032fe:	24e080e7          	jalr	590(ra) # 80000548 <panic>

0000000080003302 <bpin>:

void
bpin(struct buf *b) {
    80003302:	1101                	addi	sp,sp,-32
    80003304:	ec06                	sd	ra,24(sp)
    80003306:	e822                	sd	s0,16(sp)
    80003308:	e426                	sd	s1,8(sp)
    8000330a:	1000                	addi	s0,sp,32
    8000330c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000330e:	00014517          	auipc	a0,0x14
    80003312:	40a50513          	addi	a0,a0,1034 # 80017718 <bcache>
    80003316:	ffffd097          	auipc	ra,0xffffd
    8000331a:	7a8080e7          	jalr	1960(ra) # 80000abe <acquire>
  b->refcnt++;
    8000331e:	40bc                	lw	a5,64(s1)
    80003320:	2785                	addiw	a5,a5,1
    80003322:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003324:	00014517          	auipc	a0,0x14
    80003328:	3f450513          	addi	a0,a0,1012 # 80017718 <bcache>
    8000332c:	ffffd097          	auipc	ra,0xffffd
    80003330:	7e6080e7          	jalr	2022(ra) # 80000b12 <release>
}
    80003334:	60e2                	ld	ra,24(sp)
    80003336:	6442                	ld	s0,16(sp)
    80003338:	64a2                	ld	s1,8(sp)
    8000333a:	6105                	addi	sp,sp,32
    8000333c:	8082                	ret

000000008000333e <bunpin>:

void
bunpin(struct buf *b) {
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	1000                	addi	s0,sp,32
    80003348:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000334a:	00014517          	auipc	a0,0x14
    8000334e:	3ce50513          	addi	a0,a0,974 # 80017718 <bcache>
    80003352:	ffffd097          	auipc	ra,0xffffd
    80003356:	76c080e7          	jalr	1900(ra) # 80000abe <acquire>
  b->refcnt--;
    8000335a:	40bc                	lw	a5,64(s1)
    8000335c:	37fd                	addiw	a5,a5,-1
    8000335e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003360:	00014517          	auipc	a0,0x14
    80003364:	3b850513          	addi	a0,a0,952 # 80017718 <bcache>
    80003368:	ffffd097          	auipc	ra,0xffffd
    8000336c:	7aa080e7          	jalr	1962(ra) # 80000b12 <release>
}
    80003370:	60e2                	ld	ra,24(sp)
    80003372:	6442                	ld	s0,16(sp)
    80003374:	64a2                	ld	s1,8(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret

000000008000337a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000337a:	1101                	addi	sp,sp,-32
    8000337c:	ec06                	sd	ra,24(sp)
    8000337e:	e822                	sd	s0,16(sp)
    80003380:	e426                	sd	s1,8(sp)
    80003382:	e04a                	sd	s2,0(sp)
    80003384:	1000                	addi	s0,sp,32
    80003386:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003388:	00d5d59b          	srliw	a1,a1,0xd
    8000338c:	0001d797          	auipc	a5,0x1d
    80003390:	b607a783          	lw	a5,-1184(a5) # 8001feec <sb+0x1c>
    80003394:	9dbd                	addw	a1,a1,a5
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	d9e080e7          	jalr	-610(ra) # 80003134 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000339e:	0074f713          	andi	a4,s1,7
    800033a2:	4785                	li	a5,1
    800033a4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033a8:	14ce                	slli	s1,s1,0x33
    800033aa:	90d9                	srli	s1,s1,0x36
    800033ac:	00950733          	add	a4,a0,s1
    800033b0:	06074703          	lbu	a4,96(a4)
    800033b4:	00e7f6b3          	and	a3,a5,a4
    800033b8:	c69d                	beqz	a3,800033e6 <bfree+0x6c>
    800033ba:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033bc:	94aa                	add	s1,s1,a0
    800033be:	fff7c793          	not	a5,a5
    800033c2:	8ff9                	and	a5,a5,a4
    800033c4:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800033c8:	00001097          	auipc	ra,0x1
    800033cc:	0e0080e7          	jalr	224(ra) # 800044a8 <log_write>
  brelse(bp);
    800033d0:	854a                	mv	a0,s2
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	e92080e7          	jalr	-366(ra) # 80003264 <brelse>
}
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	64a2                	ld	s1,8(sp)
    800033e0:	6902                	ld	s2,0(sp)
    800033e2:	6105                	addi	sp,sp,32
    800033e4:	8082                	ret
    panic("freeing free block");
    800033e6:	00004517          	auipc	a0,0x4
    800033ea:	44250513          	addi	a0,a0,1090 # 80007828 <userret+0x798>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	15a080e7          	jalr	346(ra) # 80000548 <panic>

00000000800033f6 <balloc>:
{
    800033f6:	711d                	addi	sp,sp,-96
    800033f8:	ec86                	sd	ra,88(sp)
    800033fa:	e8a2                	sd	s0,80(sp)
    800033fc:	e4a6                	sd	s1,72(sp)
    800033fe:	e0ca                	sd	s2,64(sp)
    80003400:	fc4e                	sd	s3,56(sp)
    80003402:	f852                	sd	s4,48(sp)
    80003404:	f456                	sd	s5,40(sp)
    80003406:	f05a                	sd	s6,32(sp)
    80003408:	ec5e                	sd	s7,24(sp)
    8000340a:	e862                	sd	s8,16(sp)
    8000340c:	e466                	sd	s9,8(sp)
    8000340e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003410:	0001d797          	auipc	a5,0x1d
    80003414:	ac47a783          	lw	a5,-1340(a5) # 8001fed4 <sb+0x4>
    80003418:	cbd1                	beqz	a5,800034ac <balloc+0xb6>
    8000341a:	8baa                	mv	s7,a0
    8000341c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000341e:	0001db17          	auipc	s6,0x1d
    80003422:	ab2b0b13          	addi	s6,s6,-1358 # 8001fed0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003426:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003428:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000342a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000342c:	6c89                	lui	s9,0x2
    8000342e:	a831                	j	8000344a <balloc+0x54>
    brelse(bp);
    80003430:	854a                	mv	a0,s2
    80003432:	00000097          	auipc	ra,0x0
    80003436:	e32080e7          	jalr	-462(ra) # 80003264 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000343a:	015c87bb          	addw	a5,s9,s5
    8000343e:	00078a9b          	sext.w	s5,a5
    80003442:	004b2703          	lw	a4,4(s6)
    80003446:	06eaf363          	bgeu	s5,a4,800034ac <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000344a:	41fad79b          	sraiw	a5,s5,0x1f
    8000344e:	0137d79b          	srliw	a5,a5,0x13
    80003452:	015787bb          	addw	a5,a5,s5
    80003456:	40d7d79b          	sraiw	a5,a5,0xd
    8000345a:	01cb2583          	lw	a1,28(s6)
    8000345e:	9dbd                	addw	a1,a1,a5
    80003460:	855e                	mv	a0,s7
    80003462:	00000097          	auipc	ra,0x0
    80003466:	cd2080e7          	jalr	-814(ra) # 80003134 <bread>
    8000346a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000346c:	004b2503          	lw	a0,4(s6)
    80003470:	000a849b          	sext.w	s1,s5
    80003474:	8662                	mv	a2,s8
    80003476:	faa4fde3          	bgeu	s1,a0,80003430 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000347a:	41f6579b          	sraiw	a5,a2,0x1f
    8000347e:	01d7d69b          	srliw	a3,a5,0x1d
    80003482:	00c6873b          	addw	a4,a3,a2
    80003486:	00777793          	andi	a5,a4,7
    8000348a:	9f95                	subw	a5,a5,a3
    8000348c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003490:	4037571b          	sraiw	a4,a4,0x3
    80003494:	00e906b3          	add	a3,s2,a4
    80003498:	0606c683          	lbu	a3,96(a3)
    8000349c:	00d7f5b3          	and	a1,a5,a3
    800034a0:	cd91                	beqz	a1,800034bc <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034a2:	2605                	addiw	a2,a2,1
    800034a4:	2485                	addiw	s1,s1,1
    800034a6:	fd4618e3          	bne	a2,s4,80003476 <balloc+0x80>
    800034aa:	b759                	j	80003430 <balloc+0x3a>
  panic("balloc: out of blocks");
    800034ac:	00004517          	auipc	a0,0x4
    800034b0:	39450513          	addi	a0,a0,916 # 80007840 <userret+0x7b0>
    800034b4:	ffffd097          	auipc	ra,0xffffd
    800034b8:	094080e7          	jalr	148(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034bc:	974a                	add	a4,a4,s2
    800034be:	8fd5                	or	a5,a5,a3
    800034c0:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800034c4:	854a                	mv	a0,s2
    800034c6:	00001097          	auipc	ra,0x1
    800034ca:	fe2080e7          	jalr	-30(ra) # 800044a8 <log_write>
        brelse(bp);
    800034ce:	854a                	mv	a0,s2
    800034d0:	00000097          	auipc	ra,0x0
    800034d4:	d94080e7          	jalr	-620(ra) # 80003264 <brelse>
  bp = bread(dev, bno);
    800034d8:	85a6                	mv	a1,s1
    800034da:	855e                	mv	a0,s7
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	c58080e7          	jalr	-936(ra) # 80003134 <bread>
    800034e4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034e6:	40000613          	li	a2,1024
    800034ea:	4581                	li	a1,0
    800034ec:	06050513          	addi	a0,a0,96
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	66a080e7          	jalr	1642(ra) # 80000b5a <memset>
  log_write(bp);
    800034f8:	854a                	mv	a0,s2
    800034fa:	00001097          	auipc	ra,0x1
    800034fe:	fae080e7          	jalr	-82(ra) # 800044a8 <log_write>
  brelse(bp);
    80003502:	854a                	mv	a0,s2
    80003504:	00000097          	auipc	ra,0x0
    80003508:	d60080e7          	jalr	-672(ra) # 80003264 <brelse>
}
    8000350c:	8526                	mv	a0,s1
    8000350e:	60e6                	ld	ra,88(sp)
    80003510:	6446                	ld	s0,80(sp)
    80003512:	64a6                	ld	s1,72(sp)
    80003514:	6906                	ld	s2,64(sp)
    80003516:	79e2                	ld	s3,56(sp)
    80003518:	7a42                	ld	s4,48(sp)
    8000351a:	7aa2                	ld	s5,40(sp)
    8000351c:	7b02                	ld	s6,32(sp)
    8000351e:	6be2                	ld	s7,24(sp)
    80003520:	6c42                	ld	s8,16(sp)
    80003522:	6ca2                	ld	s9,8(sp)
    80003524:	6125                	addi	sp,sp,96
    80003526:	8082                	ret

0000000080003528 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003528:	7179                	addi	sp,sp,-48
    8000352a:	f406                	sd	ra,40(sp)
    8000352c:	f022                	sd	s0,32(sp)
    8000352e:	ec26                	sd	s1,24(sp)
    80003530:	e84a                	sd	s2,16(sp)
    80003532:	e44e                	sd	s3,8(sp)
    80003534:	e052                	sd	s4,0(sp)
    80003536:	1800                	addi	s0,sp,48
    80003538:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000353a:	47ad                	li	a5,11
    8000353c:	04b7fe63          	bgeu	a5,a1,80003598 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003540:	ff45849b          	addiw	s1,a1,-12
    80003544:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003548:	0ff00793          	li	a5,255
    8000354c:	0ae7e463          	bltu	a5,a4,800035f4 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003550:	08052583          	lw	a1,128(a0)
    80003554:	c5b5                	beqz	a1,800035c0 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003556:	00092503          	lw	a0,0(s2)
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	bda080e7          	jalr	-1062(ra) # 80003134 <bread>
    80003562:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003564:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003568:	02049713          	slli	a4,s1,0x20
    8000356c:	01e75593          	srli	a1,a4,0x1e
    80003570:	00b784b3          	add	s1,a5,a1
    80003574:	0004a983          	lw	s3,0(s1)
    80003578:	04098e63          	beqz	s3,800035d4 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000357c:	8552                	mv	a0,s4
    8000357e:	00000097          	auipc	ra,0x0
    80003582:	ce6080e7          	jalr	-794(ra) # 80003264 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003586:	854e                	mv	a0,s3
    80003588:	70a2                	ld	ra,40(sp)
    8000358a:	7402                	ld	s0,32(sp)
    8000358c:	64e2                	ld	s1,24(sp)
    8000358e:	6942                	ld	s2,16(sp)
    80003590:	69a2                	ld	s3,8(sp)
    80003592:	6a02                	ld	s4,0(sp)
    80003594:	6145                	addi	sp,sp,48
    80003596:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003598:	02059793          	slli	a5,a1,0x20
    8000359c:	01e7d593          	srli	a1,a5,0x1e
    800035a0:	00b504b3          	add	s1,a0,a1
    800035a4:	0504a983          	lw	s3,80(s1)
    800035a8:	fc099fe3          	bnez	s3,80003586 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800035ac:	4108                	lw	a0,0(a0)
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	e48080e7          	jalr	-440(ra) # 800033f6 <balloc>
    800035b6:	0005099b          	sext.w	s3,a0
    800035ba:	0534a823          	sw	s3,80(s1)
    800035be:	b7e1                	j	80003586 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035c0:	4108                	lw	a0,0(a0)
    800035c2:	00000097          	auipc	ra,0x0
    800035c6:	e34080e7          	jalr	-460(ra) # 800033f6 <balloc>
    800035ca:	0005059b          	sext.w	a1,a0
    800035ce:	08b92023          	sw	a1,128(s2)
    800035d2:	b751                	j	80003556 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800035d4:	00092503          	lw	a0,0(s2)
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	e1e080e7          	jalr	-482(ra) # 800033f6 <balloc>
    800035e0:	0005099b          	sext.w	s3,a0
    800035e4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800035e8:	8552                	mv	a0,s4
    800035ea:	00001097          	auipc	ra,0x1
    800035ee:	ebe080e7          	jalr	-322(ra) # 800044a8 <log_write>
    800035f2:	b769                	j	8000357c <bmap+0x54>
  panic("bmap: out of range");
    800035f4:	00004517          	auipc	a0,0x4
    800035f8:	26450513          	addi	a0,a0,612 # 80007858 <userret+0x7c8>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	f4c080e7          	jalr	-180(ra) # 80000548 <panic>

0000000080003604 <iget>:
{
    80003604:	7179                	addi	sp,sp,-48
    80003606:	f406                	sd	ra,40(sp)
    80003608:	f022                	sd	s0,32(sp)
    8000360a:	ec26                	sd	s1,24(sp)
    8000360c:	e84a                	sd	s2,16(sp)
    8000360e:	e44e                	sd	s3,8(sp)
    80003610:	e052                	sd	s4,0(sp)
    80003612:	1800                	addi	s0,sp,48
    80003614:	89aa                	mv	s3,a0
    80003616:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003618:	0001d517          	auipc	a0,0x1d
    8000361c:	8d850513          	addi	a0,a0,-1832 # 8001fef0 <icache>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	49e080e7          	jalr	1182(ra) # 80000abe <acquire>
  empty = 0;
    80003628:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000362a:	0001d497          	auipc	s1,0x1d
    8000362e:	8de48493          	addi	s1,s1,-1826 # 8001ff08 <icache+0x18>
    80003632:	0001e697          	auipc	a3,0x1e
    80003636:	36668693          	addi	a3,a3,870 # 80021998 <log>
    8000363a:	a039                	j	80003648 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000363c:	02090b63          	beqz	s2,80003672 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003640:	08848493          	addi	s1,s1,136
    80003644:	02d48a63          	beq	s1,a3,80003678 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003648:	449c                	lw	a5,8(s1)
    8000364a:	fef059e3          	blez	a5,8000363c <iget+0x38>
    8000364e:	4098                	lw	a4,0(s1)
    80003650:	ff3716e3          	bne	a4,s3,8000363c <iget+0x38>
    80003654:	40d8                	lw	a4,4(s1)
    80003656:	ff4713e3          	bne	a4,s4,8000363c <iget+0x38>
      ip->ref++;
    8000365a:	2785                	addiw	a5,a5,1
    8000365c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000365e:	0001d517          	auipc	a0,0x1d
    80003662:	89250513          	addi	a0,a0,-1902 # 8001fef0 <icache>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	4ac080e7          	jalr	1196(ra) # 80000b12 <release>
      return ip;
    8000366e:	8926                	mv	s2,s1
    80003670:	a03d                	j	8000369e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003672:	f7f9                	bnez	a5,80003640 <iget+0x3c>
    80003674:	8926                	mv	s2,s1
    80003676:	b7e9                	j	80003640 <iget+0x3c>
  if(empty == 0)
    80003678:	02090c63          	beqz	s2,800036b0 <iget+0xac>
  ip->dev = dev;
    8000367c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003680:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003684:	4785                	li	a5,1
    80003686:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000368a:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000368e:	0001d517          	auipc	a0,0x1d
    80003692:	86250513          	addi	a0,a0,-1950 # 8001fef0 <icache>
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	47c080e7          	jalr	1148(ra) # 80000b12 <release>
}
    8000369e:	854a                	mv	a0,s2
    800036a0:	70a2                	ld	ra,40(sp)
    800036a2:	7402                	ld	s0,32(sp)
    800036a4:	64e2                	ld	s1,24(sp)
    800036a6:	6942                	ld	s2,16(sp)
    800036a8:	69a2                	ld	s3,8(sp)
    800036aa:	6a02                	ld	s4,0(sp)
    800036ac:	6145                	addi	sp,sp,48
    800036ae:	8082                	ret
    panic("iget: no inodes");
    800036b0:	00004517          	auipc	a0,0x4
    800036b4:	1c050513          	addi	a0,a0,448 # 80007870 <userret+0x7e0>
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	e90080e7          	jalr	-368(ra) # 80000548 <panic>

00000000800036c0 <fsinit>:
fsinit(int dev) {
    800036c0:	7179                	addi	sp,sp,-48
    800036c2:	f406                	sd	ra,40(sp)
    800036c4:	f022                	sd	s0,32(sp)
    800036c6:	ec26                	sd	s1,24(sp)
    800036c8:	e84a                	sd	s2,16(sp)
    800036ca:	e44e                	sd	s3,8(sp)
    800036cc:	1800                	addi	s0,sp,48
    800036ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036d0:	4585                	li	a1,1
    800036d2:	00000097          	auipc	ra,0x0
    800036d6:	a62080e7          	jalr	-1438(ra) # 80003134 <bread>
    800036da:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036dc:	0001c997          	auipc	s3,0x1c
    800036e0:	7f498993          	addi	s3,s3,2036 # 8001fed0 <sb>
    800036e4:	02000613          	li	a2,32
    800036e8:	06050593          	addi	a1,a0,96
    800036ec:	854e                	mv	a0,s3
    800036ee:	ffffd097          	auipc	ra,0xffffd
    800036f2:	4c8080e7          	jalr	1224(ra) # 80000bb6 <memmove>
  brelse(bp);
    800036f6:	8526                	mv	a0,s1
    800036f8:	00000097          	auipc	ra,0x0
    800036fc:	b6c080e7          	jalr	-1172(ra) # 80003264 <brelse>
  if(sb.magic != FSMAGIC)
    80003700:	0009a703          	lw	a4,0(s3)
    80003704:	102037b7          	lui	a5,0x10203
    80003708:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000370c:	02f71263          	bne	a4,a5,80003730 <fsinit+0x70>
  initlog(dev, &sb);
    80003710:	0001c597          	auipc	a1,0x1c
    80003714:	7c058593          	addi	a1,a1,1984 # 8001fed0 <sb>
    80003718:	854a                	mv	a0,s2
    8000371a:	00001097          	auipc	ra,0x1
    8000371e:	b14080e7          	jalr	-1260(ra) # 8000422e <initlog>
}
    80003722:	70a2                	ld	ra,40(sp)
    80003724:	7402                	ld	s0,32(sp)
    80003726:	64e2                	ld	s1,24(sp)
    80003728:	6942                	ld	s2,16(sp)
    8000372a:	69a2                	ld	s3,8(sp)
    8000372c:	6145                	addi	sp,sp,48
    8000372e:	8082                	ret
    panic("invalid file system");
    80003730:	00004517          	auipc	a0,0x4
    80003734:	15050513          	addi	a0,a0,336 # 80007880 <userret+0x7f0>
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	e10080e7          	jalr	-496(ra) # 80000548 <panic>

0000000080003740 <iinit>:
{
    80003740:	7179                	addi	sp,sp,-48
    80003742:	f406                	sd	ra,40(sp)
    80003744:	f022                	sd	s0,32(sp)
    80003746:	ec26                	sd	s1,24(sp)
    80003748:	e84a                	sd	s2,16(sp)
    8000374a:	e44e                	sd	s3,8(sp)
    8000374c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000374e:	00004597          	auipc	a1,0x4
    80003752:	14a58593          	addi	a1,a1,330 # 80007898 <userret+0x808>
    80003756:	0001c517          	auipc	a0,0x1c
    8000375a:	79a50513          	addi	a0,a0,1946 # 8001fef0 <icache>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	252080e7          	jalr	594(ra) # 800009b0 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003766:	0001c497          	auipc	s1,0x1c
    8000376a:	7b248493          	addi	s1,s1,1970 # 8001ff18 <icache+0x28>
    8000376e:	0001e997          	auipc	s3,0x1e
    80003772:	23a98993          	addi	s3,s3,570 # 800219a8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003776:	00004917          	auipc	s2,0x4
    8000377a:	12a90913          	addi	s2,s2,298 # 800078a0 <userret+0x810>
    8000377e:	85ca                	mv	a1,s2
    80003780:	8526                	mv	a0,s1
    80003782:	00001097          	auipc	ra,0x1
    80003786:	e14080e7          	jalr	-492(ra) # 80004596 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000378a:	08848493          	addi	s1,s1,136
    8000378e:	ff3498e3          	bne	s1,s3,8000377e <iinit+0x3e>
}
    80003792:	70a2                	ld	ra,40(sp)
    80003794:	7402                	ld	s0,32(sp)
    80003796:	64e2                	ld	s1,24(sp)
    80003798:	6942                	ld	s2,16(sp)
    8000379a:	69a2                	ld	s3,8(sp)
    8000379c:	6145                	addi	sp,sp,48
    8000379e:	8082                	ret

00000000800037a0 <ialloc>:
{
    800037a0:	715d                	addi	sp,sp,-80
    800037a2:	e486                	sd	ra,72(sp)
    800037a4:	e0a2                	sd	s0,64(sp)
    800037a6:	fc26                	sd	s1,56(sp)
    800037a8:	f84a                	sd	s2,48(sp)
    800037aa:	f44e                	sd	s3,40(sp)
    800037ac:	f052                	sd	s4,32(sp)
    800037ae:	ec56                	sd	s5,24(sp)
    800037b0:	e85a                	sd	s6,16(sp)
    800037b2:	e45e                	sd	s7,8(sp)
    800037b4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037b6:	0001c717          	auipc	a4,0x1c
    800037ba:	72672703          	lw	a4,1830(a4) # 8001fedc <sb+0xc>
    800037be:	4785                	li	a5,1
    800037c0:	04e7fa63          	bgeu	a5,a4,80003814 <ialloc+0x74>
    800037c4:	8aaa                	mv	s5,a0
    800037c6:	8bae                	mv	s7,a1
    800037c8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037ca:	0001ca17          	auipc	s4,0x1c
    800037ce:	706a0a13          	addi	s4,s4,1798 # 8001fed0 <sb>
    800037d2:	00048b1b          	sext.w	s6,s1
    800037d6:	0044d793          	srli	a5,s1,0x4
    800037da:	018a2583          	lw	a1,24(s4)
    800037de:	9dbd                	addw	a1,a1,a5
    800037e0:	8556                	mv	a0,s5
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	952080e7          	jalr	-1710(ra) # 80003134 <bread>
    800037ea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037ec:	06050993          	addi	s3,a0,96
    800037f0:	00f4f793          	andi	a5,s1,15
    800037f4:	079a                	slli	a5,a5,0x6
    800037f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037f8:	00099783          	lh	a5,0(s3)
    800037fc:	c785                	beqz	a5,80003824 <ialloc+0x84>
    brelse(bp);
    800037fe:	00000097          	auipc	ra,0x0
    80003802:	a66080e7          	jalr	-1434(ra) # 80003264 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003806:	0485                	addi	s1,s1,1
    80003808:	00ca2703          	lw	a4,12(s4)
    8000380c:	0004879b          	sext.w	a5,s1
    80003810:	fce7e1e3          	bltu	a5,a4,800037d2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003814:	00004517          	auipc	a0,0x4
    80003818:	09450513          	addi	a0,a0,148 # 800078a8 <userret+0x818>
    8000381c:	ffffd097          	auipc	ra,0xffffd
    80003820:	d2c080e7          	jalr	-724(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003824:	04000613          	li	a2,64
    80003828:	4581                	li	a1,0
    8000382a:	854e                	mv	a0,s3
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	32e080e7          	jalr	814(ra) # 80000b5a <memset>
      dip->type = type;
    80003834:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003838:	854a                	mv	a0,s2
    8000383a:	00001097          	auipc	ra,0x1
    8000383e:	c6e080e7          	jalr	-914(ra) # 800044a8 <log_write>
      brelse(bp);
    80003842:	854a                	mv	a0,s2
    80003844:	00000097          	auipc	ra,0x0
    80003848:	a20080e7          	jalr	-1504(ra) # 80003264 <brelse>
      return iget(dev, inum);
    8000384c:	85da                	mv	a1,s6
    8000384e:	8556                	mv	a0,s5
    80003850:	00000097          	auipc	ra,0x0
    80003854:	db4080e7          	jalr	-588(ra) # 80003604 <iget>
}
    80003858:	60a6                	ld	ra,72(sp)
    8000385a:	6406                	ld	s0,64(sp)
    8000385c:	74e2                	ld	s1,56(sp)
    8000385e:	7942                	ld	s2,48(sp)
    80003860:	79a2                	ld	s3,40(sp)
    80003862:	7a02                	ld	s4,32(sp)
    80003864:	6ae2                	ld	s5,24(sp)
    80003866:	6b42                	ld	s6,16(sp)
    80003868:	6ba2                	ld	s7,8(sp)
    8000386a:	6161                	addi	sp,sp,80
    8000386c:	8082                	ret

000000008000386e <iupdate>:
{
    8000386e:	1101                	addi	sp,sp,-32
    80003870:	ec06                	sd	ra,24(sp)
    80003872:	e822                	sd	s0,16(sp)
    80003874:	e426                	sd	s1,8(sp)
    80003876:	e04a                	sd	s2,0(sp)
    80003878:	1000                	addi	s0,sp,32
    8000387a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000387c:	415c                	lw	a5,4(a0)
    8000387e:	0047d79b          	srliw	a5,a5,0x4
    80003882:	0001c597          	auipc	a1,0x1c
    80003886:	6665a583          	lw	a1,1638(a1) # 8001fee8 <sb+0x18>
    8000388a:	9dbd                	addw	a1,a1,a5
    8000388c:	4108                	lw	a0,0(a0)
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	8a6080e7          	jalr	-1882(ra) # 80003134 <bread>
    80003896:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003898:	06050793          	addi	a5,a0,96
    8000389c:	40c8                	lw	a0,4(s1)
    8000389e:	893d                	andi	a0,a0,15
    800038a0:	051a                	slli	a0,a0,0x6
    800038a2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038a4:	04449703          	lh	a4,68(s1)
    800038a8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038ac:	04649703          	lh	a4,70(s1)
    800038b0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038b4:	04849703          	lh	a4,72(s1)
    800038b8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038bc:	04a49703          	lh	a4,74(s1)
    800038c0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038c4:	44f8                	lw	a4,76(s1)
    800038c6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038c8:	03400613          	li	a2,52
    800038cc:	05048593          	addi	a1,s1,80
    800038d0:	0531                	addi	a0,a0,12
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	2e4080e7          	jalr	740(ra) # 80000bb6 <memmove>
  log_write(bp);
    800038da:	854a                	mv	a0,s2
    800038dc:	00001097          	auipc	ra,0x1
    800038e0:	bcc080e7          	jalr	-1076(ra) # 800044a8 <log_write>
  brelse(bp);
    800038e4:	854a                	mv	a0,s2
    800038e6:	00000097          	auipc	ra,0x0
    800038ea:	97e080e7          	jalr	-1666(ra) # 80003264 <brelse>
}
    800038ee:	60e2                	ld	ra,24(sp)
    800038f0:	6442                	ld	s0,16(sp)
    800038f2:	64a2                	ld	s1,8(sp)
    800038f4:	6902                	ld	s2,0(sp)
    800038f6:	6105                	addi	sp,sp,32
    800038f8:	8082                	ret

00000000800038fa <idup>:
{
    800038fa:	1101                	addi	sp,sp,-32
    800038fc:	ec06                	sd	ra,24(sp)
    800038fe:	e822                	sd	s0,16(sp)
    80003900:	e426                	sd	s1,8(sp)
    80003902:	1000                	addi	s0,sp,32
    80003904:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003906:	0001c517          	auipc	a0,0x1c
    8000390a:	5ea50513          	addi	a0,a0,1514 # 8001fef0 <icache>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	1b0080e7          	jalr	432(ra) # 80000abe <acquire>
  ip->ref++;
    80003916:	449c                	lw	a5,8(s1)
    80003918:	2785                	addiw	a5,a5,1
    8000391a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000391c:	0001c517          	auipc	a0,0x1c
    80003920:	5d450513          	addi	a0,a0,1492 # 8001fef0 <icache>
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	1ee080e7          	jalr	494(ra) # 80000b12 <release>
}
    8000392c:	8526                	mv	a0,s1
    8000392e:	60e2                	ld	ra,24(sp)
    80003930:	6442                	ld	s0,16(sp)
    80003932:	64a2                	ld	s1,8(sp)
    80003934:	6105                	addi	sp,sp,32
    80003936:	8082                	ret

0000000080003938 <ilock>:
{
    80003938:	1101                	addi	sp,sp,-32
    8000393a:	ec06                	sd	ra,24(sp)
    8000393c:	e822                	sd	s0,16(sp)
    8000393e:	e426                	sd	s1,8(sp)
    80003940:	e04a                	sd	s2,0(sp)
    80003942:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003944:	c115                	beqz	a0,80003968 <ilock+0x30>
    80003946:	84aa                	mv	s1,a0
    80003948:	451c                	lw	a5,8(a0)
    8000394a:	00f05f63          	blez	a5,80003968 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000394e:	0541                	addi	a0,a0,16
    80003950:	00001097          	auipc	ra,0x1
    80003954:	c80080e7          	jalr	-896(ra) # 800045d0 <acquiresleep>
  if(ip->valid == 0){
    80003958:	40bc                	lw	a5,64(s1)
    8000395a:	cf99                	beqz	a5,80003978 <ilock+0x40>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
    panic("ilock");
    80003968:	00004517          	auipc	a0,0x4
    8000396c:	f5850513          	addi	a0,a0,-168 # 800078c0 <userret+0x830>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	bd8080e7          	jalr	-1064(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003978:	40dc                	lw	a5,4(s1)
    8000397a:	0047d79b          	srliw	a5,a5,0x4
    8000397e:	0001c597          	auipc	a1,0x1c
    80003982:	56a5a583          	lw	a1,1386(a1) # 8001fee8 <sb+0x18>
    80003986:	9dbd                	addw	a1,a1,a5
    80003988:	4088                	lw	a0,0(s1)
    8000398a:	fffff097          	auipc	ra,0xfffff
    8000398e:	7aa080e7          	jalr	1962(ra) # 80003134 <bread>
    80003992:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003994:	06050593          	addi	a1,a0,96
    80003998:	40dc                	lw	a5,4(s1)
    8000399a:	8bbd                	andi	a5,a5,15
    8000399c:	079a                	slli	a5,a5,0x6
    8000399e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039a0:	00059783          	lh	a5,0(a1)
    800039a4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039a8:	00259783          	lh	a5,2(a1)
    800039ac:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039b0:	00459783          	lh	a5,4(a1)
    800039b4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039b8:	00659783          	lh	a5,6(a1)
    800039bc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039c0:	459c                	lw	a5,8(a1)
    800039c2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039c4:	03400613          	li	a2,52
    800039c8:	05b1                	addi	a1,a1,12
    800039ca:	05048513          	addi	a0,s1,80
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	1e8080e7          	jalr	488(ra) # 80000bb6 <memmove>
    brelse(bp);
    800039d6:	854a                	mv	a0,s2
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	88c080e7          	jalr	-1908(ra) # 80003264 <brelse>
    ip->valid = 1;
    800039e0:	4785                	li	a5,1
    800039e2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039e4:	04449783          	lh	a5,68(s1)
    800039e8:	fbb5                	bnez	a5,8000395c <ilock+0x24>
      panic("ilock: no type");
    800039ea:	00004517          	auipc	a0,0x4
    800039ee:	ede50513          	addi	a0,a0,-290 # 800078c8 <userret+0x838>
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	b56080e7          	jalr	-1194(ra) # 80000548 <panic>

00000000800039fa <iunlock>:
{
    800039fa:	1101                	addi	sp,sp,-32
    800039fc:	ec06                	sd	ra,24(sp)
    800039fe:	e822                	sd	s0,16(sp)
    80003a00:	e426                	sd	s1,8(sp)
    80003a02:	e04a                	sd	s2,0(sp)
    80003a04:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a06:	c905                	beqz	a0,80003a36 <iunlock+0x3c>
    80003a08:	84aa                	mv	s1,a0
    80003a0a:	01050913          	addi	s2,a0,16
    80003a0e:	854a                	mv	a0,s2
    80003a10:	00001097          	auipc	ra,0x1
    80003a14:	c5a080e7          	jalr	-934(ra) # 8000466a <holdingsleep>
    80003a18:	cd19                	beqz	a0,80003a36 <iunlock+0x3c>
    80003a1a:	449c                	lw	a5,8(s1)
    80003a1c:	00f05d63          	blez	a5,80003a36 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a20:	854a                	mv	a0,s2
    80003a22:	00001097          	auipc	ra,0x1
    80003a26:	c04080e7          	jalr	-1020(ra) # 80004626 <releasesleep>
}
    80003a2a:	60e2                	ld	ra,24(sp)
    80003a2c:	6442                	ld	s0,16(sp)
    80003a2e:	64a2                	ld	s1,8(sp)
    80003a30:	6902                	ld	s2,0(sp)
    80003a32:	6105                	addi	sp,sp,32
    80003a34:	8082                	ret
    panic("iunlock");
    80003a36:	00004517          	auipc	a0,0x4
    80003a3a:	ea250513          	addi	a0,a0,-350 # 800078d8 <userret+0x848>
    80003a3e:	ffffd097          	auipc	ra,0xffffd
    80003a42:	b0a080e7          	jalr	-1270(ra) # 80000548 <panic>

0000000080003a46 <iput>:
{
    80003a46:	7139                	addi	sp,sp,-64
    80003a48:	fc06                	sd	ra,56(sp)
    80003a4a:	f822                	sd	s0,48(sp)
    80003a4c:	f426                	sd	s1,40(sp)
    80003a4e:	f04a                	sd	s2,32(sp)
    80003a50:	ec4e                	sd	s3,24(sp)
    80003a52:	e852                	sd	s4,16(sp)
    80003a54:	e456                	sd	s5,8(sp)
    80003a56:	0080                	addi	s0,sp,64
    80003a58:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a5a:	0001c517          	auipc	a0,0x1c
    80003a5e:	49650513          	addi	a0,a0,1174 # 8001fef0 <icache>
    80003a62:	ffffd097          	auipc	ra,0xffffd
    80003a66:	05c080e7          	jalr	92(ra) # 80000abe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a6a:	4498                	lw	a4,8(s1)
    80003a6c:	4785                	li	a5,1
    80003a6e:	02f70663          	beq	a4,a5,80003a9a <iput+0x54>
  ip->ref--;
    80003a72:	449c                	lw	a5,8(s1)
    80003a74:	37fd                	addiw	a5,a5,-1
    80003a76:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a78:	0001c517          	auipc	a0,0x1c
    80003a7c:	47850513          	addi	a0,a0,1144 # 8001fef0 <icache>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	092080e7          	jalr	146(ra) # 80000b12 <release>
}
    80003a88:	70e2                	ld	ra,56(sp)
    80003a8a:	7442                	ld	s0,48(sp)
    80003a8c:	74a2                	ld	s1,40(sp)
    80003a8e:	7902                	ld	s2,32(sp)
    80003a90:	69e2                	ld	s3,24(sp)
    80003a92:	6a42                	ld	s4,16(sp)
    80003a94:	6aa2                	ld	s5,8(sp)
    80003a96:	6121                	addi	sp,sp,64
    80003a98:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a9a:	40bc                	lw	a5,64(s1)
    80003a9c:	dbf9                	beqz	a5,80003a72 <iput+0x2c>
    80003a9e:	04a49783          	lh	a5,74(s1)
    80003aa2:	fbe1                	bnez	a5,80003a72 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003aa4:	01048a13          	addi	s4,s1,16
    80003aa8:	8552                	mv	a0,s4
    80003aaa:	00001097          	auipc	ra,0x1
    80003aae:	b26080e7          	jalr	-1242(ra) # 800045d0 <acquiresleep>
    release(&icache.lock);
    80003ab2:	0001c517          	auipc	a0,0x1c
    80003ab6:	43e50513          	addi	a0,a0,1086 # 8001fef0 <icache>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	058080e7          	jalr	88(ra) # 80000b12 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ac2:	05048913          	addi	s2,s1,80
    80003ac6:	08048993          	addi	s3,s1,128
    80003aca:	a021                	j	80003ad2 <iput+0x8c>
    80003acc:	0911                	addi	s2,s2,4
    80003ace:	01390d63          	beq	s2,s3,80003ae8 <iput+0xa2>
    if(ip->addrs[i]){
    80003ad2:	00092583          	lw	a1,0(s2)
    80003ad6:	d9fd                	beqz	a1,80003acc <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003ad8:	4088                	lw	a0,0(s1)
    80003ada:	00000097          	auipc	ra,0x0
    80003ade:	8a0080e7          	jalr	-1888(ra) # 8000337a <bfree>
      ip->addrs[i] = 0;
    80003ae2:	00092023          	sw	zero,0(s2)
    80003ae6:	b7dd                	j	80003acc <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ae8:	0804a583          	lw	a1,128(s1)
    80003aec:	ed9d                	bnez	a1,80003b2a <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003aee:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    80003af2:	8526                	mv	a0,s1
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	d7a080e7          	jalr	-646(ra) # 8000386e <iupdate>
    ip->type = 0;
    80003afc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b00:	8526                	mv	a0,s1
    80003b02:	00000097          	auipc	ra,0x0
    80003b06:	d6c080e7          	jalr	-660(ra) # 8000386e <iupdate>
    ip->valid = 0;
    80003b0a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b0e:	8552                	mv	a0,s4
    80003b10:	00001097          	auipc	ra,0x1
    80003b14:	b16080e7          	jalr	-1258(ra) # 80004626 <releasesleep>
    acquire(&icache.lock);
    80003b18:	0001c517          	auipc	a0,0x1c
    80003b1c:	3d850513          	addi	a0,a0,984 # 8001fef0 <icache>
    80003b20:	ffffd097          	auipc	ra,0xffffd
    80003b24:	f9e080e7          	jalr	-98(ra) # 80000abe <acquire>
    80003b28:	b7a9                	j	80003a72 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b2a:	4088                	lw	a0,0(s1)
    80003b2c:	fffff097          	auipc	ra,0xfffff
    80003b30:	608080e7          	jalr	1544(ra) # 80003134 <bread>
    80003b34:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b36:	06050913          	addi	s2,a0,96
    80003b3a:	46050993          	addi	s3,a0,1120
    80003b3e:	a021                	j	80003b46 <iput+0x100>
    80003b40:	0911                	addi	s2,s2,4
    80003b42:	01390b63          	beq	s2,s3,80003b58 <iput+0x112>
      if(a[j])
    80003b46:	00092583          	lw	a1,0(s2)
    80003b4a:	d9fd                	beqz	a1,80003b40 <iput+0xfa>
        bfree(ip->dev, a[j]);
    80003b4c:	4088                	lw	a0,0(s1)
    80003b4e:	00000097          	auipc	ra,0x0
    80003b52:	82c080e7          	jalr	-2004(ra) # 8000337a <bfree>
    80003b56:	b7ed                	j	80003b40 <iput+0xfa>
    brelse(bp);
    80003b58:	8556                	mv	a0,s5
    80003b5a:	fffff097          	auipc	ra,0xfffff
    80003b5e:	70a080e7          	jalr	1802(ra) # 80003264 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b62:	0804a583          	lw	a1,128(s1)
    80003b66:	4088                	lw	a0,0(s1)
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	812080e7          	jalr	-2030(ra) # 8000337a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b70:	0804a023          	sw	zero,128(s1)
    80003b74:	bfad                	j	80003aee <iput+0xa8>

0000000080003b76 <iunlockput>:
{
    80003b76:	1101                	addi	sp,sp,-32
    80003b78:	ec06                	sd	ra,24(sp)
    80003b7a:	e822                	sd	s0,16(sp)
    80003b7c:	e426                	sd	s1,8(sp)
    80003b7e:	1000                	addi	s0,sp,32
    80003b80:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b82:	00000097          	auipc	ra,0x0
    80003b86:	e78080e7          	jalr	-392(ra) # 800039fa <iunlock>
  iput(ip);
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	eba080e7          	jalr	-326(ra) # 80003a46 <iput>
}
    80003b94:	60e2                	ld	ra,24(sp)
    80003b96:	6442                	ld	s0,16(sp)
    80003b98:	64a2                	ld	s1,8(sp)
    80003b9a:	6105                	addi	sp,sp,32
    80003b9c:	8082                	ret

0000000080003b9e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b9e:	1141                	addi	sp,sp,-16
    80003ba0:	e422                	sd	s0,8(sp)
    80003ba2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ba4:	411c                	lw	a5,0(a0)
    80003ba6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ba8:	415c                	lw	a5,4(a0)
    80003baa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bac:	04451783          	lh	a5,68(a0)
    80003bb0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bb4:	04a51783          	lh	a5,74(a0)
    80003bb8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bbc:	04c56783          	lwu	a5,76(a0)
    80003bc0:	e99c                	sd	a5,16(a1)
}
    80003bc2:	6422                	ld	s0,8(sp)
    80003bc4:	0141                	addi	sp,sp,16
    80003bc6:	8082                	ret

0000000080003bc8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bc8:	457c                	lw	a5,76(a0)
    80003bca:	0ed7e563          	bltu	a5,a3,80003cb4 <readi+0xec>
{
    80003bce:	7159                	addi	sp,sp,-112
    80003bd0:	f486                	sd	ra,104(sp)
    80003bd2:	f0a2                	sd	s0,96(sp)
    80003bd4:	eca6                	sd	s1,88(sp)
    80003bd6:	e8ca                	sd	s2,80(sp)
    80003bd8:	e4ce                	sd	s3,72(sp)
    80003bda:	e0d2                	sd	s4,64(sp)
    80003bdc:	fc56                	sd	s5,56(sp)
    80003bde:	f85a                	sd	s6,48(sp)
    80003be0:	f45e                	sd	s7,40(sp)
    80003be2:	f062                	sd	s8,32(sp)
    80003be4:	ec66                	sd	s9,24(sp)
    80003be6:	e86a                	sd	s10,16(sp)
    80003be8:	e46e                	sd	s11,8(sp)
    80003bea:	1880                	addi	s0,sp,112
    80003bec:	8baa                	mv	s7,a0
    80003bee:	8c2e                	mv	s8,a1
    80003bf0:	8ab2                	mv	s5,a2
    80003bf2:	8936                	mv	s2,a3
    80003bf4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bf6:	9f35                	addw	a4,a4,a3
    80003bf8:	0cd76063          	bltu	a4,a3,80003cb8 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003bfc:	00e7f463          	bgeu	a5,a4,80003c04 <readi+0x3c>
    n = ip->size - off;
    80003c00:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c04:	080b0763          	beqz	s6,80003c92 <readi+0xca>
    80003c08:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c0a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c0e:	5cfd                	li	s9,-1
    80003c10:	a82d                	j	80003c4a <readi+0x82>
    80003c12:	02099d93          	slli	s11,s3,0x20
    80003c16:	020ddd93          	srli	s11,s11,0x20
    80003c1a:	06048793          	addi	a5,s1,96
    80003c1e:	86ee                	mv	a3,s11
    80003c20:	963e                	add	a2,a2,a5
    80003c22:	85d6                	mv	a1,s5
    80003c24:	8562                	mv	a0,s8
    80003c26:	ffffe097          	auipc	ra,0xffffe
    80003c2a:	60c080e7          	jalr	1548(ra) # 80002232 <either_copyout>
    80003c2e:	05950d63          	beq	a0,s9,80003c88 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003c32:	8526                	mv	a0,s1
    80003c34:	fffff097          	auipc	ra,0xfffff
    80003c38:	630080e7          	jalr	1584(ra) # 80003264 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c3c:	01498a3b          	addw	s4,s3,s4
    80003c40:	0129893b          	addw	s2,s3,s2
    80003c44:	9aee                	add	s5,s5,s11
    80003c46:	056a7663          	bgeu	s4,s6,80003c92 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c4a:	000ba483          	lw	s1,0(s7)
    80003c4e:	00a9559b          	srliw	a1,s2,0xa
    80003c52:	855e                	mv	a0,s7
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	8d4080e7          	jalr	-1836(ra) # 80003528 <bmap>
    80003c5c:	0005059b          	sext.w	a1,a0
    80003c60:	8526                	mv	a0,s1
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	4d2080e7          	jalr	1234(ra) # 80003134 <bread>
    80003c6a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c6c:	3ff97613          	andi	a2,s2,1023
    80003c70:	40cd07bb          	subw	a5,s10,a2
    80003c74:	414b073b          	subw	a4,s6,s4
    80003c78:	89be                	mv	s3,a5
    80003c7a:	2781                	sext.w	a5,a5
    80003c7c:	0007069b          	sext.w	a3,a4
    80003c80:	f8f6f9e3          	bgeu	a3,a5,80003c12 <readi+0x4a>
    80003c84:	89ba                	mv	s3,a4
    80003c86:	b771                	j	80003c12 <readi+0x4a>
      brelse(bp);
    80003c88:	8526                	mv	a0,s1
    80003c8a:	fffff097          	auipc	ra,0xfffff
    80003c8e:	5da080e7          	jalr	1498(ra) # 80003264 <brelse>
  }
  return n;
    80003c92:	000b051b          	sext.w	a0,s6
}
    80003c96:	70a6                	ld	ra,104(sp)
    80003c98:	7406                	ld	s0,96(sp)
    80003c9a:	64e6                	ld	s1,88(sp)
    80003c9c:	6946                	ld	s2,80(sp)
    80003c9e:	69a6                	ld	s3,72(sp)
    80003ca0:	6a06                	ld	s4,64(sp)
    80003ca2:	7ae2                	ld	s5,56(sp)
    80003ca4:	7b42                	ld	s6,48(sp)
    80003ca6:	7ba2                	ld	s7,40(sp)
    80003ca8:	7c02                	ld	s8,32(sp)
    80003caa:	6ce2                	ld	s9,24(sp)
    80003cac:	6d42                	ld	s10,16(sp)
    80003cae:	6da2                	ld	s11,8(sp)
    80003cb0:	6165                	addi	sp,sp,112
    80003cb2:	8082                	ret
    return -1;
    80003cb4:	557d                	li	a0,-1
}
    80003cb6:	8082                	ret
    return -1;
    80003cb8:	557d                	li	a0,-1
    80003cba:	bff1                	j	80003c96 <readi+0xce>

0000000080003cbc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cbc:	457c                	lw	a5,76(a0)
    80003cbe:	10d7e663          	bltu	a5,a3,80003dca <writei+0x10e>
{
    80003cc2:	7159                	addi	sp,sp,-112
    80003cc4:	f486                	sd	ra,104(sp)
    80003cc6:	f0a2                	sd	s0,96(sp)
    80003cc8:	eca6                	sd	s1,88(sp)
    80003cca:	e8ca                	sd	s2,80(sp)
    80003ccc:	e4ce                	sd	s3,72(sp)
    80003cce:	e0d2                	sd	s4,64(sp)
    80003cd0:	fc56                	sd	s5,56(sp)
    80003cd2:	f85a                	sd	s6,48(sp)
    80003cd4:	f45e                	sd	s7,40(sp)
    80003cd6:	f062                	sd	s8,32(sp)
    80003cd8:	ec66                	sd	s9,24(sp)
    80003cda:	e86a                	sd	s10,16(sp)
    80003cdc:	e46e                	sd	s11,8(sp)
    80003cde:	1880                	addi	s0,sp,112
    80003ce0:	8baa                	mv	s7,a0
    80003ce2:	8c2e                	mv	s8,a1
    80003ce4:	8ab2                	mv	s5,a2
    80003ce6:	8936                	mv	s2,a3
    80003ce8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cea:	00e687bb          	addw	a5,a3,a4
    80003cee:	0ed7e063          	bltu	a5,a3,80003dce <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cf2:	00043737          	lui	a4,0x43
    80003cf6:	0cf76e63          	bltu	a4,a5,80003dd2 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cfa:	0a0b0763          	beqz	s6,80003da8 <writei+0xec>
    80003cfe:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d00:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d04:	5cfd                	li	s9,-1
    80003d06:	a091                	j	80003d4a <writei+0x8e>
    80003d08:	02099d93          	slli	s11,s3,0x20
    80003d0c:	020ddd93          	srli	s11,s11,0x20
    80003d10:	06048793          	addi	a5,s1,96
    80003d14:	86ee                	mv	a3,s11
    80003d16:	8656                	mv	a2,s5
    80003d18:	85e2                	mv	a1,s8
    80003d1a:	953e                	add	a0,a0,a5
    80003d1c:	ffffe097          	auipc	ra,0xffffe
    80003d20:	56c080e7          	jalr	1388(ra) # 80002288 <either_copyin>
    80003d24:	07950263          	beq	a0,s9,80003d88 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d28:	8526                	mv	a0,s1
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	77e080e7          	jalr	1918(ra) # 800044a8 <log_write>
    brelse(bp);
    80003d32:	8526                	mv	a0,s1
    80003d34:	fffff097          	auipc	ra,0xfffff
    80003d38:	530080e7          	jalr	1328(ra) # 80003264 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d3c:	01498a3b          	addw	s4,s3,s4
    80003d40:	0129893b          	addw	s2,s3,s2
    80003d44:	9aee                	add	s5,s5,s11
    80003d46:	056a7663          	bgeu	s4,s6,80003d92 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d4a:	000ba483          	lw	s1,0(s7)
    80003d4e:	00a9559b          	srliw	a1,s2,0xa
    80003d52:	855e                	mv	a0,s7
    80003d54:	fffff097          	auipc	ra,0xfffff
    80003d58:	7d4080e7          	jalr	2004(ra) # 80003528 <bmap>
    80003d5c:	0005059b          	sext.w	a1,a0
    80003d60:	8526                	mv	a0,s1
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	3d2080e7          	jalr	978(ra) # 80003134 <bread>
    80003d6a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d6c:	3ff97513          	andi	a0,s2,1023
    80003d70:	40ad07bb          	subw	a5,s10,a0
    80003d74:	414b073b          	subw	a4,s6,s4
    80003d78:	89be                	mv	s3,a5
    80003d7a:	2781                	sext.w	a5,a5
    80003d7c:	0007069b          	sext.w	a3,a4
    80003d80:	f8f6f4e3          	bgeu	a3,a5,80003d08 <writei+0x4c>
    80003d84:	89ba                	mv	s3,a4
    80003d86:	b749                	j	80003d08 <writei+0x4c>
      brelse(bp);
    80003d88:	8526                	mv	a0,s1
    80003d8a:	fffff097          	auipc	ra,0xfffff
    80003d8e:	4da080e7          	jalr	1242(ra) # 80003264 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003d92:	04cba783          	lw	a5,76(s7)
    80003d96:	0127f463          	bgeu	a5,s2,80003d9e <writei+0xe2>
      ip->size = off;
    80003d9a:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d9e:	855e                	mv	a0,s7
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	ace080e7          	jalr	-1330(ra) # 8000386e <iupdate>
  }

  return n;
    80003da8:	000b051b          	sext.w	a0,s6
}
    80003dac:	70a6                	ld	ra,104(sp)
    80003dae:	7406                	ld	s0,96(sp)
    80003db0:	64e6                	ld	s1,88(sp)
    80003db2:	6946                	ld	s2,80(sp)
    80003db4:	69a6                	ld	s3,72(sp)
    80003db6:	6a06                	ld	s4,64(sp)
    80003db8:	7ae2                	ld	s5,56(sp)
    80003dba:	7b42                	ld	s6,48(sp)
    80003dbc:	7ba2                	ld	s7,40(sp)
    80003dbe:	7c02                	ld	s8,32(sp)
    80003dc0:	6ce2                	ld	s9,24(sp)
    80003dc2:	6d42                	ld	s10,16(sp)
    80003dc4:	6da2                	ld	s11,8(sp)
    80003dc6:	6165                	addi	sp,sp,112
    80003dc8:	8082                	ret
    return -1;
    80003dca:	557d                	li	a0,-1
}
    80003dcc:	8082                	ret
    return -1;
    80003dce:	557d                	li	a0,-1
    80003dd0:	bff1                	j	80003dac <writei+0xf0>
    return -1;
    80003dd2:	557d                	li	a0,-1
    80003dd4:	bfe1                	j	80003dac <writei+0xf0>

0000000080003dd6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dd6:	1141                	addi	sp,sp,-16
    80003dd8:	e406                	sd	ra,8(sp)
    80003dda:	e022                	sd	s0,0(sp)
    80003ddc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dde:	4639                	li	a2,14
    80003de0:	ffffd097          	auipc	ra,0xffffd
    80003de4:	e52080e7          	jalr	-430(ra) # 80000c32 <strncmp>
}
    80003de8:	60a2                	ld	ra,8(sp)
    80003dea:	6402                	ld	s0,0(sp)
    80003dec:	0141                	addi	sp,sp,16
    80003dee:	8082                	ret

0000000080003df0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003df0:	7139                	addi	sp,sp,-64
    80003df2:	fc06                	sd	ra,56(sp)
    80003df4:	f822                	sd	s0,48(sp)
    80003df6:	f426                	sd	s1,40(sp)
    80003df8:	f04a                	sd	s2,32(sp)
    80003dfa:	ec4e                	sd	s3,24(sp)
    80003dfc:	e852                	sd	s4,16(sp)
    80003dfe:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e00:	04451703          	lh	a4,68(a0)
    80003e04:	4785                	li	a5,1
    80003e06:	00f71a63          	bne	a4,a5,80003e1a <dirlookup+0x2a>
    80003e0a:	892a                	mv	s2,a0
    80003e0c:	89ae                	mv	s3,a1
    80003e0e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e10:	457c                	lw	a5,76(a0)
    80003e12:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e14:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e16:	e79d                	bnez	a5,80003e44 <dirlookup+0x54>
    80003e18:	a8a5                	j	80003e90 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e1a:	00004517          	auipc	a0,0x4
    80003e1e:	ac650513          	addi	a0,a0,-1338 # 800078e0 <userret+0x850>
    80003e22:	ffffc097          	auipc	ra,0xffffc
    80003e26:	726080e7          	jalr	1830(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003e2a:	00004517          	auipc	a0,0x4
    80003e2e:	ace50513          	addi	a0,a0,-1330 # 800078f8 <userret+0x868>
    80003e32:	ffffc097          	auipc	ra,0xffffc
    80003e36:	716080e7          	jalr	1814(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e3a:	24c1                	addiw	s1,s1,16
    80003e3c:	04c92783          	lw	a5,76(s2)
    80003e40:	04f4f763          	bgeu	s1,a5,80003e8e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e44:	4741                	li	a4,16
    80003e46:	86a6                	mv	a3,s1
    80003e48:	fc040613          	addi	a2,s0,-64
    80003e4c:	4581                	li	a1,0
    80003e4e:	854a                	mv	a0,s2
    80003e50:	00000097          	auipc	ra,0x0
    80003e54:	d78080e7          	jalr	-648(ra) # 80003bc8 <readi>
    80003e58:	47c1                	li	a5,16
    80003e5a:	fcf518e3          	bne	a0,a5,80003e2a <dirlookup+0x3a>
    if(de.inum == 0)
    80003e5e:	fc045783          	lhu	a5,-64(s0)
    80003e62:	dfe1                	beqz	a5,80003e3a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e64:	fc240593          	addi	a1,s0,-62
    80003e68:	854e                	mv	a0,s3
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	f6c080e7          	jalr	-148(ra) # 80003dd6 <namecmp>
    80003e72:	f561                	bnez	a0,80003e3a <dirlookup+0x4a>
      if(poff)
    80003e74:	000a0463          	beqz	s4,80003e7c <dirlookup+0x8c>
        *poff = off;
    80003e78:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e7c:	fc045583          	lhu	a1,-64(s0)
    80003e80:	00092503          	lw	a0,0(s2)
    80003e84:	fffff097          	auipc	ra,0xfffff
    80003e88:	780080e7          	jalr	1920(ra) # 80003604 <iget>
    80003e8c:	a011                	j	80003e90 <dirlookup+0xa0>
  return 0;
    80003e8e:	4501                	li	a0,0
}
    80003e90:	70e2                	ld	ra,56(sp)
    80003e92:	7442                	ld	s0,48(sp)
    80003e94:	74a2                	ld	s1,40(sp)
    80003e96:	7902                	ld	s2,32(sp)
    80003e98:	69e2                	ld	s3,24(sp)
    80003e9a:	6a42                	ld	s4,16(sp)
    80003e9c:	6121                	addi	sp,sp,64
    80003e9e:	8082                	ret

0000000080003ea0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ea0:	711d                	addi	sp,sp,-96
    80003ea2:	ec86                	sd	ra,88(sp)
    80003ea4:	e8a2                	sd	s0,80(sp)
    80003ea6:	e4a6                	sd	s1,72(sp)
    80003ea8:	e0ca                	sd	s2,64(sp)
    80003eaa:	fc4e                	sd	s3,56(sp)
    80003eac:	f852                	sd	s4,48(sp)
    80003eae:	f456                	sd	s5,40(sp)
    80003eb0:	f05a                	sd	s6,32(sp)
    80003eb2:	ec5e                	sd	s7,24(sp)
    80003eb4:	e862                	sd	s8,16(sp)
    80003eb6:	e466                	sd	s9,8(sp)
    80003eb8:	1080                	addi	s0,sp,96
    80003eba:	84aa                	mv	s1,a0
    80003ebc:	8aae                	mv	s5,a1
    80003ebe:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ec0:	00054703          	lbu	a4,0(a0)
    80003ec4:	02f00793          	li	a5,47
    80003ec8:	02f70363          	beq	a4,a5,80003eee <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ecc:	ffffe097          	auipc	ra,0xffffe
    80003ed0:	962080e7          	jalr	-1694(ra) # 8000182e <myproc>
    80003ed4:	15053503          	ld	a0,336(a0)
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	a22080e7          	jalr	-1502(ra) # 800038fa <idup>
    80003ee0:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ee2:	02f00913          	li	s2,47
  len = path - s;
    80003ee6:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003ee8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003eea:	4b85                	li	s7,1
    80003eec:	a865                	j	80003fa4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003eee:	4585                	li	a1,1
    80003ef0:	4505                	li	a0,1
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	712080e7          	jalr	1810(ra) # 80003604 <iget>
    80003efa:	89aa                	mv	s3,a0
    80003efc:	b7dd                	j	80003ee2 <namex+0x42>
      iunlockput(ip);
    80003efe:	854e                	mv	a0,s3
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	c76080e7          	jalr	-906(ra) # 80003b76 <iunlockput>
      return 0;
    80003f08:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f0a:	854e                	mv	a0,s3
    80003f0c:	60e6                	ld	ra,88(sp)
    80003f0e:	6446                	ld	s0,80(sp)
    80003f10:	64a6                	ld	s1,72(sp)
    80003f12:	6906                	ld	s2,64(sp)
    80003f14:	79e2                	ld	s3,56(sp)
    80003f16:	7a42                	ld	s4,48(sp)
    80003f18:	7aa2                	ld	s5,40(sp)
    80003f1a:	7b02                	ld	s6,32(sp)
    80003f1c:	6be2                	ld	s7,24(sp)
    80003f1e:	6c42                	ld	s8,16(sp)
    80003f20:	6ca2                	ld	s9,8(sp)
    80003f22:	6125                	addi	sp,sp,96
    80003f24:	8082                	ret
      iunlock(ip);
    80003f26:	854e                	mv	a0,s3
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	ad2080e7          	jalr	-1326(ra) # 800039fa <iunlock>
      return ip;
    80003f30:	bfe9                	j	80003f0a <namex+0x6a>
      iunlockput(ip);
    80003f32:	854e                	mv	a0,s3
    80003f34:	00000097          	auipc	ra,0x0
    80003f38:	c42080e7          	jalr	-958(ra) # 80003b76 <iunlockput>
      return 0;
    80003f3c:	89e6                	mv	s3,s9
    80003f3e:	b7f1                	j	80003f0a <namex+0x6a>
  len = path - s;
    80003f40:	40b48633          	sub	a2,s1,a1
    80003f44:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f48:	099c5463          	bge	s8,s9,80003fd0 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f4c:	4639                	li	a2,14
    80003f4e:	8552                	mv	a0,s4
    80003f50:	ffffd097          	auipc	ra,0xffffd
    80003f54:	c66080e7          	jalr	-922(ra) # 80000bb6 <memmove>
  while(*path == '/')
    80003f58:	0004c783          	lbu	a5,0(s1)
    80003f5c:	01279763          	bne	a5,s2,80003f6a <namex+0xca>
    path++;
    80003f60:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f62:	0004c783          	lbu	a5,0(s1)
    80003f66:	ff278de3          	beq	a5,s2,80003f60 <namex+0xc0>
    ilock(ip);
    80003f6a:	854e                	mv	a0,s3
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	9cc080e7          	jalr	-1588(ra) # 80003938 <ilock>
    if(ip->type != T_DIR){
    80003f74:	04499783          	lh	a5,68(s3)
    80003f78:	f97793e3          	bne	a5,s7,80003efe <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f7c:	000a8563          	beqz	s5,80003f86 <namex+0xe6>
    80003f80:	0004c783          	lbu	a5,0(s1)
    80003f84:	d3cd                	beqz	a5,80003f26 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f86:	865a                	mv	a2,s6
    80003f88:	85d2                	mv	a1,s4
    80003f8a:	854e                	mv	a0,s3
    80003f8c:	00000097          	auipc	ra,0x0
    80003f90:	e64080e7          	jalr	-412(ra) # 80003df0 <dirlookup>
    80003f94:	8caa                	mv	s9,a0
    80003f96:	dd51                	beqz	a0,80003f32 <namex+0x92>
    iunlockput(ip);
    80003f98:	854e                	mv	a0,s3
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	bdc080e7          	jalr	-1060(ra) # 80003b76 <iunlockput>
    ip = next;
    80003fa2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fa4:	0004c783          	lbu	a5,0(s1)
    80003fa8:	05279763          	bne	a5,s2,80003ff6 <namex+0x156>
    path++;
    80003fac:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fae:	0004c783          	lbu	a5,0(s1)
    80003fb2:	ff278de3          	beq	a5,s2,80003fac <namex+0x10c>
  if(*path == 0)
    80003fb6:	c79d                	beqz	a5,80003fe4 <namex+0x144>
    path++;
    80003fb8:	85a6                	mv	a1,s1
  len = path - s;
    80003fba:	8cda                	mv	s9,s6
    80003fbc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003fbe:	01278963          	beq	a5,s2,80003fd0 <namex+0x130>
    80003fc2:	dfbd                	beqz	a5,80003f40 <namex+0xa0>
    path++;
    80003fc4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fc6:	0004c783          	lbu	a5,0(s1)
    80003fca:	ff279ce3          	bne	a5,s2,80003fc2 <namex+0x122>
    80003fce:	bf8d                	j	80003f40 <namex+0xa0>
    memmove(name, s, len);
    80003fd0:	2601                	sext.w	a2,a2
    80003fd2:	8552                	mv	a0,s4
    80003fd4:	ffffd097          	auipc	ra,0xffffd
    80003fd8:	be2080e7          	jalr	-1054(ra) # 80000bb6 <memmove>
    name[len] = 0;
    80003fdc:	9cd2                	add	s9,s9,s4
    80003fde:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003fe2:	bf9d                	j	80003f58 <namex+0xb8>
  if(nameiparent){
    80003fe4:	f20a83e3          	beqz	s5,80003f0a <namex+0x6a>
    iput(ip);
    80003fe8:	854e                	mv	a0,s3
    80003fea:	00000097          	auipc	ra,0x0
    80003fee:	a5c080e7          	jalr	-1444(ra) # 80003a46 <iput>
    return 0;
    80003ff2:	4981                	li	s3,0
    80003ff4:	bf19                	j	80003f0a <namex+0x6a>
  if(*path == 0)
    80003ff6:	d7fd                	beqz	a5,80003fe4 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003ff8:	0004c783          	lbu	a5,0(s1)
    80003ffc:	85a6                	mv	a1,s1
    80003ffe:	b7d1                	j	80003fc2 <namex+0x122>

0000000080004000 <dirlink>:
{
    80004000:	7139                	addi	sp,sp,-64
    80004002:	fc06                	sd	ra,56(sp)
    80004004:	f822                	sd	s0,48(sp)
    80004006:	f426                	sd	s1,40(sp)
    80004008:	f04a                	sd	s2,32(sp)
    8000400a:	ec4e                	sd	s3,24(sp)
    8000400c:	e852                	sd	s4,16(sp)
    8000400e:	0080                	addi	s0,sp,64
    80004010:	892a                	mv	s2,a0
    80004012:	8a2e                	mv	s4,a1
    80004014:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004016:	4601                	li	a2,0
    80004018:	00000097          	auipc	ra,0x0
    8000401c:	dd8080e7          	jalr	-552(ra) # 80003df0 <dirlookup>
    80004020:	e93d                	bnez	a0,80004096 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004022:	04c92483          	lw	s1,76(s2)
    80004026:	c49d                	beqz	s1,80004054 <dirlink+0x54>
    80004028:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000402a:	4741                	li	a4,16
    8000402c:	86a6                	mv	a3,s1
    8000402e:	fc040613          	addi	a2,s0,-64
    80004032:	4581                	li	a1,0
    80004034:	854a                	mv	a0,s2
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	b92080e7          	jalr	-1134(ra) # 80003bc8 <readi>
    8000403e:	47c1                	li	a5,16
    80004040:	06f51163          	bne	a0,a5,800040a2 <dirlink+0xa2>
    if(de.inum == 0)
    80004044:	fc045783          	lhu	a5,-64(s0)
    80004048:	c791                	beqz	a5,80004054 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000404a:	24c1                	addiw	s1,s1,16
    8000404c:	04c92783          	lw	a5,76(s2)
    80004050:	fcf4ede3          	bltu	s1,a5,8000402a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004054:	4639                	li	a2,14
    80004056:	85d2                	mv	a1,s4
    80004058:	fc240513          	addi	a0,s0,-62
    8000405c:	ffffd097          	auipc	ra,0xffffd
    80004060:	c12080e7          	jalr	-1006(ra) # 80000c6e <strncpy>
  de.inum = inum;
    80004064:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004068:	4741                	li	a4,16
    8000406a:	86a6                	mv	a3,s1
    8000406c:	fc040613          	addi	a2,s0,-64
    80004070:	4581                	li	a1,0
    80004072:	854a                	mv	a0,s2
    80004074:	00000097          	auipc	ra,0x0
    80004078:	c48080e7          	jalr	-952(ra) # 80003cbc <writei>
    8000407c:	872a                	mv	a4,a0
    8000407e:	47c1                	li	a5,16
  return 0;
    80004080:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004082:	02f71863          	bne	a4,a5,800040b2 <dirlink+0xb2>
}
    80004086:	70e2                	ld	ra,56(sp)
    80004088:	7442                	ld	s0,48(sp)
    8000408a:	74a2                	ld	s1,40(sp)
    8000408c:	7902                	ld	s2,32(sp)
    8000408e:	69e2                	ld	s3,24(sp)
    80004090:	6a42                	ld	s4,16(sp)
    80004092:	6121                	addi	sp,sp,64
    80004094:	8082                	ret
    iput(ip);
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	9b0080e7          	jalr	-1616(ra) # 80003a46 <iput>
    return -1;
    8000409e:	557d                	li	a0,-1
    800040a0:	b7dd                	j	80004086 <dirlink+0x86>
      panic("dirlink read");
    800040a2:	00004517          	auipc	a0,0x4
    800040a6:	86650513          	addi	a0,a0,-1946 # 80007908 <userret+0x878>
    800040aa:	ffffc097          	auipc	ra,0xffffc
    800040ae:	49e080e7          	jalr	1182(ra) # 80000548 <panic>
    panic("dirlink");
    800040b2:	00004517          	auipc	a0,0x4
    800040b6:	97650513          	addi	a0,a0,-1674 # 80007a28 <userret+0x998>
    800040ba:	ffffc097          	auipc	ra,0xffffc
    800040be:	48e080e7          	jalr	1166(ra) # 80000548 <panic>

00000000800040c2 <namei>:

struct inode*
namei(char *path)
{
    800040c2:	1101                	addi	sp,sp,-32
    800040c4:	ec06                	sd	ra,24(sp)
    800040c6:	e822                	sd	s0,16(sp)
    800040c8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040ca:	fe040613          	addi	a2,s0,-32
    800040ce:	4581                	li	a1,0
    800040d0:	00000097          	auipc	ra,0x0
    800040d4:	dd0080e7          	jalr	-560(ra) # 80003ea0 <namex>
}
    800040d8:	60e2                	ld	ra,24(sp)
    800040da:	6442                	ld	s0,16(sp)
    800040dc:	6105                	addi	sp,sp,32
    800040de:	8082                	ret

00000000800040e0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040e0:	1141                	addi	sp,sp,-16
    800040e2:	e406                	sd	ra,8(sp)
    800040e4:	e022                	sd	s0,0(sp)
    800040e6:	0800                	addi	s0,sp,16
    800040e8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040ea:	4585                	li	a1,1
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	db4080e7          	jalr	-588(ra) # 80003ea0 <namex>
}
    800040f4:	60a2                	ld	ra,8(sp)
    800040f6:	6402                	ld	s0,0(sp)
    800040f8:	0141                	addi	sp,sp,16
    800040fa:	8082                	ret

00000000800040fc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040fc:	1101                	addi	sp,sp,-32
    800040fe:	ec06                	sd	ra,24(sp)
    80004100:	e822                	sd	s0,16(sp)
    80004102:	e426                	sd	s1,8(sp)
    80004104:	e04a                	sd	s2,0(sp)
    80004106:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004108:	0001e917          	auipc	s2,0x1e
    8000410c:	89090913          	addi	s2,s2,-1904 # 80021998 <log>
    80004110:	01892583          	lw	a1,24(s2)
    80004114:	02892503          	lw	a0,40(s2)
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	01c080e7          	jalr	28(ra) # 80003134 <bread>
    80004120:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004122:	02c92683          	lw	a3,44(s2)
    80004126:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004128:	02d05863          	blez	a3,80004158 <write_head+0x5c>
    8000412c:	0001e797          	auipc	a5,0x1e
    80004130:	89c78793          	addi	a5,a5,-1892 # 800219c8 <log+0x30>
    80004134:	06450713          	addi	a4,a0,100
    80004138:	36fd                	addiw	a3,a3,-1
    8000413a:	02069613          	slli	a2,a3,0x20
    8000413e:	01e65693          	srli	a3,a2,0x1e
    80004142:	0001e617          	auipc	a2,0x1e
    80004146:	88a60613          	addi	a2,a2,-1910 # 800219cc <log+0x34>
    8000414a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000414c:	4390                	lw	a2,0(a5)
    8000414e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004150:	0791                	addi	a5,a5,4
    80004152:	0711                	addi	a4,a4,4
    80004154:	fed79ce3          	bne	a5,a3,8000414c <write_head+0x50>
  }
  bwrite(buf);
    80004158:	8526                	mv	a0,s1
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	0cc080e7          	jalr	204(ra) # 80003226 <bwrite>
  brelse(buf);
    80004162:	8526                	mv	a0,s1
    80004164:	fffff097          	auipc	ra,0xfffff
    80004168:	100080e7          	jalr	256(ra) # 80003264 <brelse>
}
    8000416c:	60e2                	ld	ra,24(sp)
    8000416e:	6442                	ld	s0,16(sp)
    80004170:	64a2                	ld	s1,8(sp)
    80004172:	6902                	ld	s2,0(sp)
    80004174:	6105                	addi	sp,sp,32
    80004176:	8082                	ret

0000000080004178 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004178:	0001e797          	auipc	a5,0x1e
    8000417c:	84c7a783          	lw	a5,-1972(a5) # 800219c4 <log+0x2c>
    80004180:	0af05663          	blez	a5,8000422c <install_trans+0xb4>
{
    80004184:	7139                	addi	sp,sp,-64
    80004186:	fc06                	sd	ra,56(sp)
    80004188:	f822                	sd	s0,48(sp)
    8000418a:	f426                	sd	s1,40(sp)
    8000418c:	f04a                	sd	s2,32(sp)
    8000418e:	ec4e                	sd	s3,24(sp)
    80004190:	e852                	sd	s4,16(sp)
    80004192:	e456                	sd	s5,8(sp)
    80004194:	0080                	addi	s0,sp,64
    80004196:	0001ea97          	auipc	s5,0x1e
    8000419a:	832a8a93          	addi	s5,s5,-1998 # 800219c8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000419e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041a0:	0001d997          	auipc	s3,0x1d
    800041a4:	7f898993          	addi	s3,s3,2040 # 80021998 <log>
    800041a8:	0189a583          	lw	a1,24(s3)
    800041ac:	014585bb          	addw	a1,a1,s4
    800041b0:	2585                	addiw	a1,a1,1
    800041b2:	0289a503          	lw	a0,40(s3)
    800041b6:	fffff097          	auipc	ra,0xfffff
    800041ba:	f7e080e7          	jalr	-130(ra) # 80003134 <bread>
    800041be:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041c0:	000aa583          	lw	a1,0(s5)
    800041c4:	0289a503          	lw	a0,40(s3)
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	f6c080e7          	jalr	-148(ra) # 80003134 <bread>
    800041d0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041d2:	40000613          	li	a2,1024
    800041d6:	06090593          	addi	a1,s2,96
    800041da:	06050513          	addi	a0,a0,96
    800041de:	ffffd097          	auipc	ra,0xffffd
    800041e2:	9d8080e7          	jalr	-1576(ra) # 80000bb6 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041e6:	8526                	mv	a0,s1
    800041e8:	fffff097          	auipc	ra,0xfffff
    800041ec:	03e080e7          	jalr	62(ra) # 80003226 <bwrite>
    bunpin(dbuf);
    800041f0:	8526                	mv	a0,s1
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	14c080e7          	jalr	332(ra) # 8000333e <bunpin>
    brelse(lbuf);
    800041fa:	854a                	mv	a0,s2
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	068080e7          	jalr	104(ra) # 80003264 <brelse>
    brelse(dbuf);
    80004204:	8526                	mv	a0,s1
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	05e080e7          	jalr	94(ra) # 80003264 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000420e:	2a05                	addiw	s4,s4,1
    80004210:	0a91                	addi	s5,s5,4
    80004212:	02c9a783          	lw	a5,44(s3)
    80004216:	f8fa49e3          	blt	s4,a5,800041a8 <install_trans+0x30>
}
    8000421a:	70e2                	ld	ra,56(sp)
    8000421c:	7442                	ld	s0,48(sp)
    8000421e:	74a2                	ld	s1,40(sp)
    80004220:	7902                	ld	s2,32(sp)
    80004222:	69e2                	ld	s3,24(sp)
    80004224:	6a42                	ld	s4,16(sp)
    80004226:	6aa2                	ld	s5,8(sp)
    80004228:	6121                	addi	sp,sp,64
    8000422a:	8082                	ret
    8000422c:	8082                	ret

000000008000422e <initlog>:
{
    8000422e:	7179                	addi	sp,sp,-48
    80004230:	f406                	sd	ra,40(sp)
    80004232:	f022                	sd	s0,32(sp)
    80004234:	ec26                	sd	s1,24(sp)
    80004236:	e84a                	sd	s2,16(sp)
    80004238:	e44e                	sd	s3,8(sp)
    8000423a:	1800                	addi	s0,sp,48
    8000423c:	892a                	mv	s2,a0
    8000423e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004240:	0001d497          	auipc	s1,0x1d
    80004244:	75848493          	addi	s1,s1,1880 # 80021998 <log>
    80004248:	00003597          	auipc	a1,0x3
    8000424c:	6d058593          	addi	a1,a1,1744 # 80007918 <userret+0x888>
    80004250:	8526                	mv	a0,s1
    80004252:	ffffc097          	auipc	ra,0xffffc
    80004256:	75e080e7          	jalr	1886(ra) # 800009b0 <initlock>
  log.start = sb->logstart;
    8000425a:	0149a583          	lw	a1,20(s3)
    8000425e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004260:	0109a783          	lw	a5,16(s3)
    80004264:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004266:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000426a:	854a                	mv	a0,s2
    8000426c:	fffff097          	auipc	ra,0xfffff
    80004270:	ec8080e7          	jalr	-312(ra) # 80003134 <bread>
  log.lh.n = lh->n;
    80004274:	5134                	lw	a3,96(a0)
    80004276:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004278:	02d05663          	blez	a3,800042a4 <initlog+0x76>
    8000427c:	06450793          	addi	a5,a0,100
    80004280:	0001d717          	auipc	a4,0x1d
    80004284:	74870713          	addi	a4,a4,1864 # 800219c8 <log+0x30>
    80004288:	36fd                	addiw	a3,a3,-1
    8000428a:	02069613          	slli	a2,a3,0x20
    8000428e:	01e65693          	srli	a3,a2,0x1e
    80004292:	06850613          	addi	a2,a0,104
    80004296:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004298:	4390                	lw	a2,0(a5)
    8000429a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000429c:	0791                	addi	a5,a5,4
    8000429e:	0711                	addi	a4,a4,4
    800042a0:	fed79ce3          	bne	a5,a3,80004298 <initlog+0x6a>
  brelse(buf);
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	fc0080e7          	jalr	-64(ra) # 80003264 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	ecc080e7          	jalr	-308(ra) # 80004178 <install_trans>
  log.lh.n = 0;
    800042b4:	0001d797          	auipc	a5,0x1d
    800042b8:	7007a823          	sw	zero,1808(a5) # 800219c4 <log+0x2c>
  write_head(); // clear the log
    800042bc:	00000097          	auipc	ra,0x0
    800042c0:	e40080e7          	jalr	-448(ra) # 800040fc <write_head>
}
    800042c4:	70a2                	ld	ra,40(sp)
    800042c6:	7402                	ld	s0,32(sp)
    800042c8:	64e2                	ld	s1,24(sp)
    800042ca:	6942                	ld	s2,16(sp)
    800042cc:	69a2                	ld	s3,8(sp)
    800042ce:	6145                	addi	sp,sp,48
    800042d0:	8082                	ret

00000000800042d2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042d2:	1101                	addi	sp,sp,-32
    800042d4:	ec06                	sd	ra,24(sp)
    800042d6:	e822                	sd	s0,16(sp)
    800042d8:	e426                	sd	s1,8(sp)
    800042da:	e04a                	sd	s2,0(sp)
    800042dc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042de:	0001d517          	auipc	a0,0x1d
    800042e2:	6ba50513          	addi	a0,a0,1722 # 80021998 <log>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	7d8080e7          	jalr	2008(ra) # 80000abe <acquire>
  while(1){
    if(log.committing){
    800042ee:	0001d497          	auipc	s1,0x1d
    800042f2:	6aa48493          	addi	s1,s1,1706 # 80021998 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042f6:	4979                	li	s2,30
    800042f8:	a039                	j	80004306 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042fa:	85a6                	mv	a1,s1
    800042fc:	8526                	mv	a0,s1
    800042fe:	ffffe097          	auipc	ra,0xffffe
    80004302:	cda080e7          	jalr	-806(ra) # 80001fd8 <sleep>
    if(log.committing){
    80004306:	50dc                	lw	a5,36(s1)
    80004308:	fbed                	bnez	a5,800042fa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000430a:	509c                	lw	a5,32(s1)
    8000430c:	0017871b          	addiw	a4,a5,1
    80004310:	0007069b          	sext.w	a3,a4
    80004314:	0027179b          	slliw	a5,a4,0x2
    80004318:	9fb9                	addw	a5,a5,a4
    8000431a:	0017979b          	slliw	a5,a5,0x1
    8000431e:	54d8                	lw	a4,44(s1)
    80004320:	9fb9                	addw	a5,a5,a4
    80004322:	00f95963          	bge	s2,a5,80004334 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004326:	85a6                	mv	a1,s1
    80004328:	8526                	mv	a0,s1
    8000432a:	ffffe097          	auipc	ra,0xffffe
    8000432e:	cae080e7          	jalr	-850(ra) # 80001fd8 <sleep>
    80004332:	bfd1                	j	80004306 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004334:	0001d517          	auipc	a0,0x1d
    80004338:	66450513          	addi	a0,a0,1636 # 80021998 <log>
    8000433c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000433e:	ffffc097          	auipc	ra,0xffffc
    80004342:	7d4080e7          	jalr	2004(ra) # 80000b12 <release>
      break;
    }
  }
}
    80004346:	60e2                	ld	ra,24(sp)
    80004348:	6442                	ld	s0,16(sp)
    8000434a:	64a2                	ld	s1,8(sp)
    8000434c:	6902                	ld	s2,0(sp)
    8000434e:	6105                	addi	sp,sp,32
    80004350:	8082                	ret

0000000080004352 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004352:	7139                	addi	sp,sp,-64
    80004354:	fc06                	sd	ra,56(sp)
    80004356:	f822                	sd	s0,48(sp)
    80004358:	f426                	sd	s1,40(sp)
    8000435a:	f04a                	sd	s2,32(sp)
    8000435c:	ec4e                	sd	s3,24(sp)
    8000435e:	e852                	sd	s4,16(sp)
    80004360:	e456                	sd	s5,8(sp)
    80004362:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004364:	0001d497          	auipc	s1,0x1d
    80004368:	63448493          	addi	s1,s1,1588 # 80021998 <log>
    8000436c:	8526                	mv	a0,s1
    8000436e:	ffffc097          	auipc	ra,0xffffc
    80004372:	750080e7          	jalr	1872(ra) # 80000abe <acquire>
  log.outstanding -= 1;
    80004376:	509c                	lw	a5,32(s1)
    80004378:	37fd                	addiw	a5,a5,-1
    8000437a:	0007891b          	sext.w	s2,a5
    8000437e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004380:	50dc                	lw	a5,36(s1)
    80004382:	e7b9                	bnez	a5,800043d0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004384:	04091e63          	bnez	s2,800043e0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004388:	0001d497          	auipc	s1,0x1d
    8000438c:	61048493          	addi	s1,s1,1552 # 80021998 <log>
    80004390:	4785                	li	a5,1
    80004392:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004394:	8526                	mv	a0,s1
    80004396:	ffffc097          	auipc	ra,0xffffc
    8000439a:	77c080e7          	jalr	1916(ra) # 80000b12 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000439e:	54dc                	lw	a5,44(s1)
    800043a0:	06f04763          	bgtz	a5,8000440e <end_op+0xbc>
    acquire(&log.lock);
    800043a4:	0001d497          	auipc	s1,0x1d
    800043a8:	5f448493          	addi	s1,s1,1524 # 80021998 <log>
    800043ac:	8526                	mv	a0,s1
    800043ae:	ffffc097          	auipc	ra,0xffffc
    800043b2:	710080e7          	jalr	1808(ra) # 80000abe <acquire>
    log.committing = 0;
    800043b6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043ba:	8526                	mv	a0,s1
    800043bc:	ffffe097          	auipc	ra,0xffffe
    800043c0:	d9c080e7          	jalr	-612(ra) # 80002158 <wakeup>
    release(&log.lock);
    800043c4:	8526                	mv	a0,s1
    800043c6:	ffffc097          	auipc	ra,0xffffc
    800043ca:	74c080e7          	jalr	1868(ra) # 80000b12 <release>
}
    800043ce:	a03d                	j	800043fc <end_op+0xaa>
    panic("log.committing");
    800043d0:	00003517          	auipc	a0,0x3
    800043d4:	55050513          	addi	a0,a0,1360 # 80007920 <userret+0x890>
    800043d8:	ffffc097          	auipc	ra,0xffffc
    800043dc:	170080e7          	jalr	368(ra) # 80000548 <panic>
    wakeup(&log);
    800043e0:	0001d497          	auipc	s1,0x1d
    800043e4:	5b848493          	addi	s1,s1,1464 # 80021998 <log>
    800043e8:	8526                	mv	a0,s1
    800043ea:	ffffe097          	auipc	ra,0xffffe
    800043ee:	d6e080e7          	jalr	-658(ra) # 80002158 <wakeup>
  release(&log.lock);
    800043f2:	8526                	mv	a0,s1
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	71e080e7          	jalr	1822(ra) # 80000b12 <release>
}
    800043fc:	70e2                	ld	ra,56(sp)
    800043fe:	7442                	ld	s0,48(sp)
    80004400:	74a2                	ld	s1,40(sp)
    80004402:	7902                	ld	s2,32(sp)
    80004404:	69e2                	ld	s3,24(sp)
    80004406:	6a42                	ld	s4,16(sp)
    80004408:	6aa2                	ld	s5,8(sp)
    8000440a:	6121                	addi	sp,sp,64
    8000440c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000440e:	0001da97          	auipc	s5,0x1d
    80004412:	5baa8a93          	addi	s5,s5,1466 # 800219c8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004416:	0001da17          	auipc	s4,0x1d
    8000441a:	582a0a13          	addi	s4,s4,1410 # 80021998 <log>
    8000441e:	018a2583          	lw	a1,24(s4)
    80004422:	012585bb          	addw	a1,a1,s2
    80004426:	2585                	addiw	a1,a1,1
    80004428:	028a2503          	lw	a0,40(s4)
    8000442c:	fffff097          	auipc	ra,0xfffff
    80004430:	d08080e7          	jalr	-760(ra) # 80003134 <bread>
    80004434:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004436:	000aa583          	lw	a1,0(s5)
    8000443a:	028a2503          	lw	a0,40(s4)
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	cf6080e7          	jalr	-778(ra) # 80003134 <bread>
    80004446:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004448:	40000613          	li	a2,1024
    8000444c:	06050593          	addi	a1,a0,96
    80004450:	06048513          	addi	a0,s1,96
    80004454:	ffffc097          	auipc	ra,0xffffc
    80004458:	762080e7          	jalr	1890(ra) # 80000bb6 <memmove>
    bwrite(to);  // write the log
    8000445c:	8526                	mv	a0,s1
    8000445e:	fffff097          	auipc	ra,0xfffff
    80004462:	dc8080e7          	jalr	-568(ra) # 80003226 <bwrite>
    brelse(from);
    80004466:	854e                	mv	a0,s3
    80004468:	fffff097          	auipc	ra,0xfffff
    8000446c:	dfc080e7          	jalr	-516(ra) # 80003264 <brelse>
    brelse(to);
    80004470:	8526                	mv	a0,s1
    80004472:	fffff097          	auipc	ra,0xfffff
    80004476:	df2080e7          	jalr	-526(ra) # 80003264 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000447a:	2905                	addiw	s2,s2,1
    8000447c:	0a91                	addi	s5,s5,4
    8000447e:	02ca2783          	lw	a5,44(s4)
    80004482:	f8f94ee3          	blt	s2,a5,8000441e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004486:	00000097          	auipc	ra,0x0
    8000448a:	c76080e7          	jalr	-906(ra) # 800040fc <write_head>
    install_trans(); // Now install writes to home locations
    8000448e:	00000097          	auipc	ra,0x0
    80004492:	cea080e7          	jalr	-790(ra) # 80004178 <install_trans>
    log.lh.n = 0;
    80004496:	0001d797          	auipc	a5,0x1d
    8000449a:	5207a723          	sw	zero,1326(a5) # 800219c4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	c5e080e7          	jalr	-930(ra) # 800040fc <write_head>
    800044a6:	bdfd                	j	800043a4 <end_op+0x52>

00000000800044a8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044a8:	1101                	addi	sp,sp,-32
    800044aa:	ec06                	sd	ra,24(sp)
    800044ac:	e822                	sd	s0,16(sp)
    800044ae:	e426                	sd	s1,8(sp)
    800044b0:	e04a                	sd	s2,0(sp)
    800044b2:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044b4:	0001d717          	auipc	a4,0x1d
    800044b8:	51072703          	lw	a4,1296(a4) # 800219c4 <log+0x2c>
    800044bc:	47f5                	li	a5,29
    800044be:	08e7c063          	blt	a5,a4,8000453e <log_write+0x96>
    800044c2:	84aa                	mv	s1,a0
    800044c4:	0001d797          	auipc	a5,0x1d
    800044c8:	4f07a783          	lw	a5,1264(a5) # 800219b4 <log+0x1c>
    800044cc:	37fd                	addiw	a5,a5,-1
    800044ce:	06f75863          	bge	a4,a5,8000453e <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044d2:	0001d797          	auipc	a5,0x1d
    800044d6:	4e67a783          	lw	a5,1254(a5) # 800219b8 <log+0x20>
    800044da:	06f05a63          	blez	a5,8000454e <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800044de:	0001d917          	auipc	s2,0x1d
    800044e2:	4ba90913          	addi	s2,s2,1210 # 80021998 <log>
    800044e6:	854a                	mv	a0,s2
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	5d6080e7          	jalr	1494(ra) # 80000abe <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044f0:	02c92603          	lw	a2,44(s2)
    800044f4:	06c05563          	blez	a2,8000455e <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044f8:	44cc                	lw	a1,12(s1)
    800044fa:	0001d717          	auipc	a4,0x1d
    800044fe:	4ce70713          	addi	a4,a4,1230 # 800219c8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004502:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004504:	4314                	lw	a3,0(a4)
    80004506:	04b68d63          	beq	a3,a1,80004560 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    8000450a:	2785                	addiw	a5,a5,1
    8000450c:	0711                	addi	a4,a4,4
    8000450e:	fec79be3          	bne	a5,a2,80004504 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004512:	0621                	addi	a2,a2,8
    80004514:	060a                	slli	a2,a2,0x2
    80004516:	0001d797          	auipc	a5,0x1d
    8000451a:	48278793          	addi	a5,a5,1154 # 80021998 <log>
    8000451e:	963e                	add	a2,a2,a5
    80004520:	44dc                	lw	a5,12(s1)
    80004522:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004524:	8526                	mv	a0,s1
    80004526:	fffff097          	auipc	ra,0xfffff
    8000452a:	ddc080e7          	jalr	-548(ra) # 80003302 <bpin>
    log.lh.n++;
    8000452e:	0001d717          	auipc	a4,0x1d
    80004532:	46a70713          	addi	a4,a4,1130 # 80021998 <log>
    80004536:	575c                	lw	a5,44(a4)
    80004538:	2785                	addiw	a5,a5,1
    8000453a:	d75c                	sw	a5,44(a4)
    8000453c:	a83d                	j	8000457a <log_write+0xd2>
    panic("too big a transaction");
    8000453e:	00003517          	auipc	a0,0x3
    80004542:	3f250513          	addi	a0,a0,1010 # 80007930 <userret+0x8a0>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	002080e7          	jalr	2(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    8000454e:	00003517          	auipc	a0,0x3
    80004552:	3fa50513          	addi	a0,a0,1018 # 80007948 <userret+0x8b8>
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	ff2080e7          	jalr	-14(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000455e:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004560:	00878713          	addi	a4,a5,8
    80004564:	00271693          	slli	a3,a4,0x2
    80004568:	0001d717          	auipc	a4,0x1d
    8000456c:	43070713          	addi	a4,a4,1072 # 80021998 <log>
    80004570:	9736                	add	a4,a4,a3
    80004572:	44d4                	lw	a3,12(s1)
    80004574:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004576:	faf607e3          	beq	a2,a5,80004524 <log_write+0x7c>
  }
  release(&log.lock);
    8000457a:	0001d517          	auipc	a0,0x1d
    8000457e:	41e50513          	addi	a0,a0,1054 # 80021998 <log>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	590080e7          	jalr	1424(ra) # 80000b12 <release>
}
    8000458a:	60e2                	ld	ra,24(sp)
    8000458c:	6442                	ld	s0,16(sp)
    8000458e:	64a2                	ld	s1,8(sp)
    80004590:	6902                	ld	s2,0(sp)
    80004592:	6105                	addi	sp,sp,32
    80004594:	8082                	ret

0000000080004596 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004596:	1101                	addi	sp,sp,-32
    80004598:	ec06                	sd	ra,24(sp)
    8000459a:	e822                	sd	s0,16(sp)
    8000459c:	e426                	sd	s1,8(sp)
    8000459e:	e04a                	sd	s2,0(sp)
    800045a0:	1000                	addi	s0,sp,32
    800045a2:	84aa                	mv	s1,a0
    800045a4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045a6:	00003597          	auipc	a1,0x3
    800045aa:	3c258593          	addi	a1,a1,962 # 80007968 <userret+0x8d8>
    800045ae:	0521                	addi	a0,a0,8
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	400080e7          	jalr	1024(ra) # 800009b0 <initlock>
  lk->name = name;
    800045b8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045c0:	0204a423          	sw	zero,40(s1)
}
    800045c4:	60e2                	ld	ra,24(sp)
    800045c6:	6442                	ld	s0,16(sp)
    800045c8:	64a2                	ld	s1,8(sp)
    800045ca:	6902                	ld	s2,0(sp)
    800045cc:	6105                	addi	sp,sp,32
    800045ce:	8082                	ret

00000000800045d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045d0:	1101                	addi	sp,sp,-32
    800045d2:	ec06                	sd	ra,24(sp)
    800045d4:	e822                	sd	s0,16(sp)
    800045d6:	e426                	sd	s1,8(sp)
    800045d8:	e04a                	sd	s2,0(sp)
    800045da:	1000                	addi	s0,sp,32
    800045dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045de:	00850913          	addi	s2,a0,8
    800045e2:	854a                	mv	a0,s2
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	4da080e7          	jalr	1242(ra) # 80000abe <acquire>
  while (lk->locked) {
    800045ec:	409c                	lw	a5,0(s1)
    800045ee:	cb89                	beqz	a5,80004600 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045f0:	85ca                	mv	a1,s2
    800045f2:	8526                	mv	a0,s1
    800045f4:	ffffe097          	auipc	ra,0xffffe
    800045f8:	9e4080e7          	jalr	-1564(ra) # 80001fd8 <sleep>
  while (lk->locked) {
    800045fc:	409c                	lw	a5,0(s1)
    800045fe:	fbed                	bnez	a5,800045f0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004600:	4785                	li	a5,1
    80004602:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004604:	ffffd097          	auipc	ra,0xffffd
    80004608:	22a080e7          	jalr	554(ra) # 8000182e <myproc>
    8000460c:	5d1c                	lw	a5,56(a0)
    8000460e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004610:	854a                	mv	a0,s2
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	500080e7          	jalr	1280(ra) # 80000b12 <release>
}
    8000461a:	60e2                	ld	ra,24(sp)
    8000461c:	6442                	ld	s0,16(sp)
    8000461e:	64a2                	ld	s1,8(sp)
    80004620:	6902                	ld	s2,0(sp)
    80004622:	6105                	addi	sp,sp,32
    80004624:	8082                	ret

0000000080004626 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004626:	1101                	addi	sp,sp,-32
    80004628:	ec06                	sd	ra,24(sp)
    8000462a:	e822                	sd	s0,16(sp)
    8000462c:	e426                	sd	s1,8(sp)
    8000462e:	e04a                	sd	s2,0(sp)
    80004630:	1000                	addi	s0,sp,32
    80004632:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004634:	00850913          	addi	s2,a0,8
    80004638:	854a                	mv	a0,s2
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	484080e7          	jalr	1156(ra) # 80000abe <acquire>
  lk->locked = 0;
    80004642:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004646:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000464a:	8526                	mv	a0,s1
    8000464c:	ffffe097          	auipc	ra,0xffffe
    80004650:	b0c080e7          	jalr	-1268(ra) # 80002158 <wakeup>
  release(&lk->lk);
    80004654:	854a                	mv	a0,s2
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	4bc080e7          	jalr	1212(ra) # 80000b12 <release>
}
    8000465e:	60e2                	ld	ra,24(sp)
    80004660:	6442                	ld	s0,16(sp)
    80004662:	64a2                	ld	s1,8(sp)
    80004664:	6902                	ld	s2,0(sp)
    80004666:	6105                	addi	sp,sp,32
    80004668:	8082                	ret

000000008000466a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000466a:	7179                	addi	sp,sp,-48
    8000466c:	f406                	sd	ra,40(sp)
    8000466e:	f022                	sd	s0,32(sp)
    80004670:	ec26                	sd	s1,24(sp)
    80004672:	e84a                	sd	s2,16(sp)
    80004674:	e44e                	sd	s3,8(sp)
    80004676:	1800                	addi	s0,sp,48
    80004678:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000467a:	00850913          	addi	s2,a0,8
    8000467e:	854a                	mv	a0,s2
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	43e080e7          	jalr	1086(ra) # 80000abe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004688:	409c                	lw	a5,0(s1)
    8000468a:	ef99                	bnez	a5,800046a8 <holdingsleep+0x3e>
    8000468c:	4481                	li	s1,0
  release(&lk->lk);
    8000468e:	854a                	mv	a0,s2
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	482080e7          	jalr	1154(ra) # 80000b12 <release>
  return r;
}
    80004698:	8526                	mv	a0,s1
    8000469a:	70a2                	ld	ra,40(sp)
    8000469c:	7402                	ld	s0,32(sp)
    8000469e:	64e2                	ld	s1,24(sp)
    800046a0:	6942                	ld	s2,16(sp)
    800046a2:	69a2                	ld	s3,8(sp)
    800046a4:	6145                	addi	sp,sp,48
    800046a6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a8:	0284a983          	lw	s3,40(s1)
    800046ac:	ffffd097          	auipc	ra,0xffffd
    800046b0:	182080e7          	jalr	386(ra) # 8000182e <myproc>
    800046b4:	5d04                	lw	s1,56(a0)
    800046b6:	413484b3          	sub	s1,s1,s3
    800046ba:	0014b493          	seqz	s1,s1
    800046be:	bfc1                	j	8000468e <holdingsleep+0x24>

00000000800046c0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046c0:	1141                	addi	sp,sp,-16
    800046c2:	e406                	sd	ra,8(sp)
    800046c4:	e022                	sd	s0,0(sp)
    800046c6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046c8:	00003597          	auipc	a1,0x3
    800046cc:	2b058593          	addi	a1,a1,688 # 80007978 <userret+0x8e8>
    800046d0:	0001d517          	auipc	a0,0x1d
    800046d4:	41050513          	addi	a0,a0,1040 # 80021ae0 <ftable>
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	2d8080e7          	jalr	728(ra) # 800009b0 <initlock>
}
    800046e0:	60a2                	ld	ra,8(sp)
    800046e2:	6402                	ld	s0,0(sp)
    800046e4:	0141                	addi	sp,sp,16
    800046e6:	8082                	ret

00000000800046e8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046e8:	1101                	addi	sp,sp,-32
    800046ea:	ec06                	sd	ra,24(sp)
    800046ec:	e822                	sd	s0,16(sp)
    800046ee:	e426                	sd	s1,8(sp)
    800046f0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046f2:	0001d517          	auipc	a0,0x1d
    800046f6:	3ee50513          	addi	a0,a0,1006 # 80021ae0 <ftable>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	3c4080e7          	jalr	964(ra) # 80000abe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004702:	0001d497          	auipc	s1,0x1d
    80004706:	3f648493          	addi	s1,s1,1014 # 80021af8 <ftable+0x18>
    8000470a:	0001e717          	auipc	a4,0x1e
    8000470e:	38e70713          	addi	a4,a4,910 # 80022a98 <ftable+0xfb8>
    if(f->ref == 0){
    80004712:	40dc                	lw	a5,4(s1)
    80004714:	cf99                	beqz	a5,80004732 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004716:	02848493          	addi	s1,s1,40
    8000471a:	fee49ce3          	bne	s1,a4,80004712 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000471e:	0001d517          	auipc	a0,0x1d
    80004722:	3c250513          	addi	a0,a0,962 # 80021ae0 <ftable>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	3ec080e7          	jalr	1004(ra) # 80000b12 <release>
  return 0;
    8000472e:	4481                	li	s1,0
    80004730:	a819                	j	80004746 <filealloc+0x5e>
      f->ref = 1;
    80004732:	4785                	li	a5,1
    80004734:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004736:	0001d517          	auipc	a0,0x1d
    8000473a:	3aa50513          	addi	a0,a0,938 # 80021ae0 <ftable>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	3d4080e7          	jalr	980(ra) # 80000b12 <release>
}
    80004746:	8526                	mv	a0,s1
    80004748:	60e2                	ld	ra,24(sp)
    8000474a:	6442                	ld	s0,16(sp)
    8000474c:	64a2                	ld	s1,8(sp)
    8000474e:	6105                	addi	sp,sp,32
    80004750:	8082                	ret

0000000080004752 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004752:	1101                	addi	sp,sp,-32
    80004754:	ec06                	sd	ra,24(sp)
    80004756:	e822                	sd	s0,16(sp)
    80004758:	e426                	sd	s1,8(sp)
    8000475a:	1000                	addi	s0,sp,32
    8000475c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000475e:	0001d517          	auipc	a0,0x1d
    80004762:	38250513          	addi	a0,a0,898 # 80021ae0 <ftable>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	358080e7          	jalr	856(ra) # 80000abe <acquire>
  if(f->ref < 1)
    8000476e:	40dc                	lw	a5,4(s1)
    80004770:	02f05263          	blez	a5,80004794 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004774:	2785                	addiw	a5,a5,1
    80004776:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004778:	0001d517          	auipc	a0,0x1d
    8000477c:	36850513          	addi	a0,a0,872 # 80021ae0 <ftable>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	392080e7          	jalr	914(ra) # 80000b12 <release>
  return f;
}
    80004788:	8526                	mv	a0,s1
    8000478a:	60e2                	ld	ra,24(sp)
    8000478c:	6442                	ld	s0,16(sp)
    8000478e:	64a2                	ld	s1,8(sp)
    80004790:	6105                	addi	sp,sp,32
    80004792:	8082                	ret
    panic("filedup");
    80004794:	00003517          	auipc	a0,0x3
    80004798:	1ec50513          	addi	a0,a0,492 # 80007980 <userret+0x8f0>
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	dac080e7          	jalr	-596(ra) # 80000548 <panic>

00000000800047a4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047a4:	7139                	addi	sp,sp,-64
    800047a6:	fc06                	sd	ra,56(sp)
    800047a8:	f822                	sd	s0,48(sp)
    800047aa:	f426                	sd	s1,40(sp)
    800047ac:	f04a                	sd	s2,32(sp)
    800047ae:	ec4e                	sd	s3,24(sp)
    800047b0:	e852                	sd	s4,16(sp)
    800047b2:	e456                	sd	s5,8(sp)
    800047b4:	0080                	addi	s0,sp,64
    800047b6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047b8:	0001d517          	auipc	a0,0x1d
    800047bc:	32850513          	addi	a0,a0,808 # 80021ae0 <ftable>
    800047c0:	ffffc097          	auipc	ra,0xffffc
    800047c4:	2fe080e7          	jalr	766(ra) # 80000abe <acquire>
  if(f->ref < 1)
    800047c8:	40dc                	lw	a5,4(s1)
    800047ca:	06f05163          	blez	a5,8000482c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047ce:	37fd                	addiw	a5,a5,-1
    800047d0:	0007871b          	sext.w	a4,a5
    800047d4:	c0dc                	sw	a5,4(s1)
    800047d6:	06e04363          	bgtz	a4,8000483c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047da:	0004a903          	lw	s2,0(s1)
    800047de:	0094ca83          	lbu	s5,9(s1)
    800047e2:	0104ba03          	ld	s4,16(s1)
    800047e6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047ea:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047ee:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047f2:	0001d517          	auipc	a0,0x1d
    800047f6:	2ee50513          	addi	a0,a0,750 # 80021ae0 <ftable>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	318080e7          	jalr	792(ra) # 80000b12 <release>

  if(ff.type == FD_PIPE){
    80004802:	4785                	li	a5,1
    80004804:	04f90d63          	beq	s2,a5,8000485e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004808:	3979                	addiw	s2,s2,-2
    8000480a:	4785                	li	a5,1
    8000480c:	0527e063          	bltu	a5,s2,8000484c <fileclose+0xa8>
    begin_op();
    80004810:	00000097          	auipc	ra,0x0
    80004814:	ac2080e7          	jalr	-1342(ra) # 800042d2 <begin_op>
    iput(ff.ip);
    80004818:	854e                	mv	a0,s3
    8000481a:	fffff097          	auipc	ra,0xfffff
    8000481e:	22c080e7          	jalr	556(ra) # 80003a46 <iput>
    end_op();
    80004822:	00000097          	auipc	ra,0x0
    80004826:	b30080e7          	jalr	-1232(ra) # 80004352 <end_op>
    8000482a:	a00d                	j	8000484c <fileclose+0xa8>
    panic("fileclose");
    8000482c:	00003517          	auipc	a0,0x3
    80004830:	15c50513          	addi	a0,a0,348 # 80007988 <userret+0x8f8>
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	d14080e7          	jalr	-748(ra) # 80000548 <panic>
    release(&ftable.lock);
    8000483c:	0001d517          	auipc	a0,0x1d
    80004840:	2a450513          	addi	a0,a0,676 # 80021ae0 <ftable>
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	2ce080e7          	jalr	718(ra) # 80000b12 <release>
  }
}
    8000484c:	70e2                	ld	ra,56(sp)
    8000484e:	7442                	ld	s0,48(sp)
    80004850:	74a2                	ld	s1,40(sp)
    80004852:	7902                	ld	s2,32(sp)
    80004854:	69e2                	ld	s3,24(sp)
    80004856:	6a42                	ld	s4,16(sp)
    80004858:	6aa2                	ld	s5,8(sp)
    8000485a:	6121                	addi	sp,sp,64
    8000485c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000485e:	85d6                	mv	a1,s5
    80004860:	8552                	mv	a0,s4
    80004862:	00000097          	auipc	ra,0x0
    80004866:	372080e7          	jalr	882(ra) # 80004bd4 <pipeclose>
    8000486a:	b7cd                	j	8000484c <fileclose+0xa8>

000000008000486c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000486c:	715d                	addi	sp,sp,-80
    8000486e:	e486                	sd	ra,72(sp)
    80004870:	e0a2                	sd	s0,64(sp)
    80004872:	fc26                	sd	s1,56(sp)
    80004874:	f84a                	sd	s2,48(sp)
    80004876:	f44e                	sd	s3,40(sp)
    80004878:	0880                	addi	s0,sp,80
    8000487a:	84aa                	mv	s1,a0
    8000487c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000487e:	ffffd097          	auipc	ra,0xffffd
    80004882:	fb0080e7          	jalr	-80(ra) # 8000182e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004886:	409c                	lw	a5,0(s1)
    80004888:	37f9                	addiw	a5,a5,-2
    8000488a:	4705                	li	a4,1
    8000488c:	04f76763          	bltu	a4,a5,800048da <filestat+0x6e>
    80004890:	892a                	mv	s2,a0
    ilock(f->ip);
    80004892:	6c88                	ld	a0,24(s1)
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	0a4080e7          	jalr	164(ra) # 80003938 <ilock>
    stati(f->ip, &st);
    8000489c:	fb840593          	addi	a1,s0,-72
    800048a0:	6c88                	ld	a0,24(s1)
    800048a2:	fffff097          	auipc	ra,0xfffff
    800048a6:	2fc080e7          	jalr	764(ra) # 80003b9e <stati>
    iunlock(f->ip);
    800048aa:	6c88                	ld	a0,24(s1)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	14e080e7          	jalr	334(ra) # 800039fa <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048b4:	46e1                	li	a3,24
    800048b6:	fb840613          	addi	a2,s0,-72
    800048ba:	85ce                	mv	a1,s3
    800048bc:	05093503          	ld	a0,80(s2)
    800048c0:	ffffd097          	auipc	ra,0xffffd
    800048c4:	c60080e7          	jalr	-928(ra) # 80001520 <copyout>
    800048c8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048cc:	60a6                	ld	ra,72(sp)
    800048ce:	6406                	ld	s0,64(sp)
    800048d0:	74e2                	ld	s1,56(sp)
    800048d2:	7942                	ld	s2,48(sp)
    800048d4:	79a2                	ld	s3,40(sp)
    800048d6:	6161                	addi	sp,sp,80
    800048d8:	8082                	ret
  return -1;
    800048da:	557d                	li	a0,-1
    800048dc:	bfc5                	j	800048cc <filestat+0x60>

00000000800048de <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048de:	7179                	addi	sp,sp,-48
    800048e0:	f406                	sd	ra,40(sp)
    800048e2:	f022                	sd	s0,32(sp)
    800048e4:	ec26                	sd	s1,24(sp)
    800048e6:	e84a                	sd	s2,16(sp)
    800048e8:	e44e                	sd	s3,8(sp)
    800048ea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048ec:	00854783          	lbu	a5,8(a0)
    800048f0:	c3d5                	beqz	a5,80004994 <fileread+0xb6>
    800048f2:	84aa                	mv	s1,a0
    800048f4:	89ae                	mv	s3,a1
    800048f6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048f8:	411c                	lw	a5,0(a0)
    800048fa:	4705                	li	a4,1
    800048fc:	04e78963          	beq	a5,a4,8000494e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004900:	470d                	li	a4,3
    80004902:	04e78d63          	beq	a5,a4,8000495c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004906:	4709                	li	a4,2
    80004908:	06e79e63          	bne	a5,a4,80004984 <fileread+0xa6>
    ilock(f->ip);
    8000490c:	6d08                	ld	a0,24(a0)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	02a080e7          	jalr	42(ra) # 80003938 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004916:	874a                	mv	a4,s2
    80004918:	5094                	lw	a3,32(s1)
    8000491a:	864e                	mv	a2,s3
    8000491c:	4585                	li	a1,1
    8000491e:	6c88                	ld	a0,24(s1)
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	2a8080e7          	jalr	680(ra) # 80003bc8 <readi>
    80004928:	892a                	mv	s2,a0
    8000492a:	00a05563          	blez	a0,80004934 <fileread+0x56>
      f->off += r;
    8000492e:	509c                	lw	a5,32(s1)
    80004930:	9fa9                	addw	a5,a5,a0
    80004932:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004934:	6c88                	ld	a0,24(s1)
    80004936:	fffff097          	auipc	ra,0xfffff
    8000493a:	0c4080e7          	jalr	196(ra) # 800039fa <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000493e:	854a                	mv	a0,s2
    80004940:	70a2                	ld	ra,40(sp)
    80004942:	7402                	ld	s0,32(sp)
    80004944:	64e2                	ld	s1,24(sp)
    80004946:	6942                	ld	s2,16(sp)
    80004948:	69a2                	ld	s3,8(sp)
    8000494a:	6145                	addi	sp,sp,48
    8000494c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000494e:	6908                	ld	a0,16(a0)
    80004950:	00000097          	auipc	ra,0x0
    80004954:	402080e7          	jalr	1026(ra) # 80004d52 <piperead>
    80004958:	892a                	mv	s2,a0
    8000495a:	b7d5                	j	8000493e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000495c:	02451783          	lh	a5,36(a0)
    80004960:	03079693          	slli	a3,a5,0x30
    80004964:	92c1                	srli	a3,a3,0x30
    80004966:	4725                	li	a4,9
    80004968:	02d76863          	bltu	a4,a3,80004998 <fileread+0xba>
    8000496c:	0792                	slli	a5,a5,0x4
    8000496e:	0001d717          	auipc	a4,0x1d
    80004972:	0d270713          	addi	a4,a4,210 # 80021a40 <devsw>
    80004976:	97ba                	add	a5,a5,a4
    80004978:	639c                	ld	a5,0(a5)
    8000497a:	c38d                	beqz	a5,8000499c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000497c:	4505                	li	a0,1
    8000497e:	9782                	jalr	a5
    80004980:	892a                	mv	s2,a0
    80004982:	bf75                	j	8000493e <fileread+0x60>
    panic("fileread");
    80004984:	00003517          	auipc	a0,0x3
    80004988:	01450513          	addi	a0,a0,20 # 80007998 <userret+0x908>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	bbc080e7          	jalr	-1092(ra) # 80000548 <panic>
    return -1;
    80004994:	597d                	li	s2,-1
    80004996:	b765                	j	8000493e <fileread+0x60>
      return -1;
    80004998:	597d                	li	s2,-1
    8000499a:	b755                	j	8000493e <fileread+0x60>
    8000499c:	597d                	li	s2,-1
    8000499e:	b745                	j	8000493e <fileread+0x60>

00000000800049a0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049a0:	00954783          	lbu	a5,9(a0)
    800049a4:	14078563          	beqz	a5,80004aee <filewrite+0x14e>
{
    800049a8:	715d                	addi	sp,sp,-80
    800049aa:	e486                	sd	ra,72(sp)
    800049ac:	e0a2                	sd	s0,64(sp)
    800049ae:	fc26                	sd	s1,56(sp)
    800049b0:	f84a                	sd	s2,48(sp)
    800049b2:	f44e                	sd	s3,40(sp)
    800049b4:	f052                	sd	s4,32(sp)
    800049b6:	ec56                	sd	s5,24(sp)
    800049b8:	e85a                	sd	s6,16(sp)
    800049ba:	e45e                	sd	s7,8(sp)
    800049bc:	e062                	sd	s8,0(sp)
    800049be:	0880                	addi	s0,sp,80
    800049c0:	892a                	mv	s2,a0
    800049c2:	8aae                	mv	s5,a1
    800049c4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049c6:	411c                	lw	a5,0(a0)
    800049c8:	4705                	li	a4,1
    800049ca:	02e78263          	beq	a5,a4,800049ee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ce:	470d                	li	a4,3
    800049d0:	02e78563          	beq	a5,a4,800049fa <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049d4:	4709                	li	a4,2
    800049d6:	10e79463          	bne	a5,a4,80004ade <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049da:	0ec05e63          	blez	a2,80004ad6 <filewrite+0x136>
    int i = 0;
    800049de:	4981                	li	s3,0
    800049e0:	6b05                	lui	s6,0x1
    800049e2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049e6:	6b85                	lui	s7,0x1
    800049e8:	c00b8b9b          	addiw	s7,s7,-1024
    800049ec:	a851                	j	80004a80 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049ee:	6908                	ld	a0,16(a0)
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	254080e7          	jalr	596(ra) # 80004c44 <pipewrite>
    800049f8:	a85d                	j	80004aae <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049fa:	02451783          	lh	a5,36(a0)
    800049fe:	03079693          	slli	a3,a5,0x30
    80004a02:	92c1                	srli	a3,a3,0x30
    80004a04:	4725                	li	a4,9
    80004a06:	0ed76663          	bltu	a4,a3,80004af2 <filewrite+0x152>
    80004a0a:	0792                	slli	a5,a5,0x4
    80004a0c:	0001d717          	auipc	a4,0x1d
    80004a10:	03470713          	addi	a4,a4,52 # 80021a40 <devsw>
    80004a14:	97ba                	add	a5,a5,a4
    80004a16:	679c                	ld	a5,8(a5)
    80004a18:	cff9                	beqz	a5,80004af6 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004a1a:	4505                	li	a0,1
    80004a1c:	9782                	jalr	a5
    80004a1e:	a841                	j	80004aae <filewrite+0x10e>
    80004a20:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a24:	00000097          	auipc	ra,0x0
    80004a28:	8ae080e7          	jalr	-1874(ra) # 800042d2 <begin_op>
      ilock(f->ip);
    80004a2c:	01893503          	ld	a0,24(s2)
    80004a30:	fffff097          	auipc	ra,0xfffff
    80004a34:	f08080e7          	jalr	-248(ra) # 80003938 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a38:	8762                	mv	a4,s8
    80004a3a:	02092683          	lw	a3,32(s2)
    80004a3e:	01598633          	add	a2,s3,s5
    80004a42:	4585                	li	a1,1
    80004a44:	01893503          	ld	a0,24(s2)
    80004a48:	fffff097          	auipc	ra,0xfffff
    80004a4c:	274080e7          	jalr	628(ra) # 80003cbc <writei>
    80004a50:	84aa                	mv	s1,a0
    80004a52:	02a05f63          	blez	a0,80004a90 <filewrite+0xf0>
        f->off += r;
    80004a56:	02092783          	lw	a5,32(s2)
    80004a5a:	9fa9                	addw	a5,a5,a0
    80004a5c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a60:	01893503          	ld	a0,24(s2)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	f96080e7          	jalr	-106(ra) # 800039fa <iunlock>
      end_op();
    80004a6c:	00000097          	auipc	ra,0x0
    80004a70:	8e6080e7          	jalr	-1818(ra) # 80004352 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a74:	049c1963          	bne	s8,s1,80004ac6 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004a78:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a7c:	0349d663          	bge	s3,s4,80004aa8 <filewrite+0x108>
      int n1 = n - i;
    80004a80:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a84:	84be                	mv	s1,a5
    80004a86:	2781                	sext.w	a5,a5
    80004a88:	f8fb5ce3          	bge	s6,a5,80004a20 <filewrite+0x80>
    80004a8c:	84de                	mv	s1,s7
    80004a8e:	bf49                	j	80004a20 <filewrite+0x80>
      iunlock(f->ip);
    80004a90:	01893503          	ld	a0,24(s2)
    80004a94:	fffff097          	auipc	ra,0xfffff
    80004a98:	f66080e7          	jalr	-154(ra) # 800039fa <iunlock>
      end_op();
    80004a9c:	00000097          	auipc	ra,0x0
    80004aa0:	8b6080e7          	jalr	-1866(ra) # 80004352 <end_op>
      if(r < 0)
    80004aa4:	fc04d8e3          	bgez	s1,80004a74 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004aa8:	8552                	mv	a0,s4
    80004aaa:	033a1863          	bne	s4,s3,80004ada <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004aae:	60a6                	ld	ra,72(sp)
    80004ab0:	6406                	ld	s0,64(sp)
    80004ab2:	74e2                	ld	s1,56(sp)
    80004ab4:	7942                	ld	s2,48(sp)
    80004ab6:	79a2                	ld	s3,40(sp)
    80004ab8:	7a02                	ld	s4,32(sp)
    80004aba:	6ae2                	ld	s5,24(sp)
    80004abc:	6b42                	ld	s6,16(sp)
    80004abe:	6ba2                	ld	s7,8(sp)
    80004ac0:	6c02                	ld	s8,0(sp)
    80004ac2:	6161                	addi	sp,sp,80
    80004ac4:	8082                	ret
        panic("short filewrite");
    80004ac6:	00003517          	auipc	a0,0x3
    80004aca:	ee250513          	addi	a0,a0,-286 # 800079a8 <userret+0x918>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	a7a080e7          	jalr	-1414(ra) # 80000548 <panic>
    int i = 0;
    80004ad6:	4981                	li	s3,0
    80004ad8:	bfc1                	j	80004aa8 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004ada:	557d                	li	a0,-1
    80004adc:	bfc9                	j	80004aae <filewrite+0x10e>
    panic("filewrite");
    80004ade:	00003517          	auipc	a0,0x3
    80004ae2:	eda50513          	addi	a0,a0,-294 # 800079b8 <userret+0x928>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	a62080e7          	jalr	-1438(ra) # 80000548 <panic>
    return -1;
    80004aee:	557d                	li	a0,-1
}
    80004af0:	8082                	ret
      return -1;
    80004af2:	557d                	li	a0,-1
    80004af4:	bf6d                	j	80004aae <filewrite+0x10e>
    80004af6:	557d                	li	a0,-1
    80004af8:	bf5d                	j	80004aae <filewrite+0x10e>

0000000080004afa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004afa:	7179                	addi	sp,sp,-48
    80004afc:	f406                	sd	ra,40(sp)
    80004afe:	f022                	sd	s0,32(sp)
    80004b00:	ec26                	sd	s1,24(sp)
    80004b02:	e84a                	sd	s2,16(sp)
    80004b04:	e44e                	sd	s3,8(sp)
    80004b06:	e052                	sd	s4,0(sp)
    80004b08:	1800                	addi	s0,sp,48
    80004b0a:	84aa                	mv	s1,a0
    80004b0c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b0e:	0005b023          	sd	zero,0(a1)
    80004b12:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b16:	00000097          	auipc	ra,0x0
    80004b1a:	bd2080e7          	jalr	-1070(ra) # 800046e8 <filealloc>
    80004b1e:	e088                	sd	a0,0(s1)
    80004b20:	c551                	beqz	a0,80004bac <pipealloc+0xb2>
    80004b22:	00000097          	auipc	ra,0x0
    80004b26:	bc6080e7          	jalr	-1082(ra) # 800046e8 <filealloc>
    80004b2a:	00aa3023          	sd	a0,0(s4)
    80004b2e:	c92d                	beqz	a0,80004ba0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	e20080e7          	jalr	-480(ra) # 80000950 <kalloc>
    80004b38:	892a                	mv	s2,a0
    80004b3a:	c125                	beqz	a0,80004b9a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b3c:	4985                	li	s3,1
    80004b3e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b42:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b46:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b4a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b4e:	00003597          	auipc	a1,0x3
    80004b52:	e7a58593          	addi	a1,a1,-390 # 800079c8 <userret+0x938>
    80004b56:	ffffc097          	auipc	ra,0xffffc
    80004b5a:	e5a080e7          	jalr	-422(ra) # 800009b0 <initlock>
  (*f0)->type = FD_PIPE;
    80004b5e:	609c                	ld	a5,0(s1)
    80004b60:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b64:	609c                	ld	a5,0(s1)
    80004b66:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b6a:	609c                	ld	a5,0(s1)
    80004b6c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b70:	609c                	ld	a5,0(s1)
    80004b72:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b7e:	000a3783          	ld	a5,0(s4)
    80004b82:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b86:	000a3783          	ld	a5,0(s4)
    80004b8a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b8e:	000a3783          	ld	a5,0(s4)
    80004b92:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b96:	4501                	li	a0,0
    80004b98:	a025                	j	80004bc0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b9a:	6088                	ld	a0,0(s1)
    80004b9c:	e501                	bnez	a0,80004ba4 <pipealloc+0xaa>
    80004b9e:	a039                	j	80004bac <pipealloc+0xb2>
    80004ba0:	6088                	ld	a0,0(s1)
    80004ba2:	c51d                	beqz	a0,80004bd0 <pipealloc+0xd6>
    fileclose(*f0);
    80004ba4:	00000097          	auipc	ra,0x0
    80004ba8:	c00080e7          	jalr	-1024(ra) # 800047a4 <fileclose>
  if(*f1)
    80004bac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bb0:	557d                	li	a0,-1
  if(*f1)
    80004bb2:	c799                	beqz	a5,80004bc0 <pipealloc+0xc6>
    fileclose(*f1);
    80004bb4:	853e                	mv	a0,a5
    80004bb6:	00000097          	auipc	ra,0x0
    80004bba:	bee080e7          	jalr	-1042(ra) # 800047a4 <fileclose>
  return -1;
    80004bbe:	557d                	li	a0,-1
}
    80004bc0:	70a2                	ld	ra,40(sp)
    80004bc2:	7402                	ld	s0,32(sp)
    80004bc4:	64e2                	ld	s1,24(sp)
    80004bc6:	6942                	ld	s2,16(sp)
    80004bc8:	69a2                	ld	s3,8(sp)
    80004bca:	6a02                	ld	s4,0(sp)
    80004bcc:	6145                	addi	sp,sp,48
    80004bce:	8082                	ret
  return -1;
    80004bd0:	557d                	li	a0,-1
    80004bd2:	b7fd                	j	80004bc0 <pipealloc+0xc6>

0000000080004bd4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bd4:	1101                	addi	sp,sp,-32
    80004bd6:	ec06                	sd	ra,24(sp)
    80004bd8:	e822                	sd	s0,16(sp)
    80004bda:	e426                	sd	s1,8(sp)
    80004bdc:	e04a                	sd	s2,0(sp)
    80004bde:	1000                	addi	s0,sp,32
    80004be0:	84aa                	mv	s1,a0
    80004be2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	eda080e7          	jalr	-294(ra) # 80000abe <acquire>
  if(writable){
    80004bec:	02090d63          	beqz	s2,80004c26 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bf0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bf4:	21848513          	addi	a0,s1,536
    80004bf8:	ffffd097          	auipc	ra,0xffffd
    80004bfc:	560080e7          	jalr	1376(ra) # 80002158 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c00:	2204b783          	ld	a5,544(s1)
    80004c04:	eb95                	bnez	a5,80004c38 <pipeclose+0x64>
    release(&pi->lock);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	f0a080e7          	jalr	-246(ra) # 80000b12 <release>
    kfree((char*)pi);
    80004c10:	8526                	mv	a0,s1
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	c42080e7          	jalr	-958(ra) # 80000854 <kfree>
  } else
    release(&pi->lock);
}
    80004c1a:	60e2                	ld	ra,24(sp)
    80004c1c:	6442                	ld	s0,16(sp)
    80004c1e:	64a2                	ld	s1,8(sp)
    80004c20:	6902                	ld	s2,0(sp)
    80004c22:	6105                	addi	sp,sp,32
    80004c24:	8082                	ret
    pi->readopen = 0;
    80004c26:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c2a:	21c48513          	addi	a0,s1,540
    80004c2e:	ffffd097          	auipc	ra,0xffffd
    80004c32:	52a080e7          	jalr	1322(ra) # 80002158 <wakeup>
    80004c36:	b7e9                	j	80004c00 <pipeclose+0x2c>
    release(&pi->lock);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	ed8080e7          	jalr	-296(ra) # 80000b12 <release>
}
    80004c42:	bfe1                	j	80004c1a <pipeclose+0x46>

0000000080004c44 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c44:	711d                	addi	sp,sp,-96
    80004c46:	ec86                	sd	ra,88(sp)
    80004c48:	e8a2                	sd	s0,80(sp)
    80004c4a:	e4a6                	sd	s1,72(sp)
    80004c4c:	e0ca                	sd	s2,64(sp)
    80004c4e:	fc4e                	sd	s3,56(sp)
    80004c50:	f852                	sd	s4,48(sp)
    80004c52:	f456                	sd	s5,40(sp)
    80004c54:	f05a                	sd	s6,32(sp)
    80004c56:	ec5e                	sd	s7,24(sp)
    80004c58:	e862                	sd	s8,16(sp)
    80004c5a:	1080                	addi	s0,sp,96
    80004c5c:	84aa                	mv	s1,a0
    80004c5e:	8aae                	mv	s5,a1
    80004c60:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c62:	ffffd097          	auipc	ra,0xffffd
    80004c66:	bcc080e7          	jalr	-1076(ra) # 8000182e <myproc>
    80004c6a:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	ffffc097          	auipc	ra,0xffffc
    80004c72:	e50080e7          	jalr	-432(ra) # 80000abe <acquire>
  for(i = 0; i < n; i++){
    80004c76:	09405f63          	blez	s4,80004d14 <pipewrite+0xd0>
    80004c7a:	fffa0b1b          	addiw	s6,s4,-1
    80004c7e:	1b02                	slli	s6,s6,0x20
    80004c80:	020b5b13          	srli	s6,s6,0x20
    80004c84:	001a8793          	addi	a5,s5,1
    80004c88:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c8a:	21848993          	addi	s3,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c8e:	21c48913          	addi	s2,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c92:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c94:	2184a783          	lw	a5,536(s1)
    80004c98:	21c4a703          	lw	a4,540(s1)
    80004c9c:	2007879b          	addiw	a5,a5,512
    80004ca0:	02f71e63          	bne	a4,a5,80004cdc <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004ca4:	2204a783          	lw	a5,544(s1)
    80004ca8:	c3d9                	beqz	a5,80004d2e <pipewrite+0xea>
    80004caa:	ffffd097          	auipc	ra,0xffffd
    80004cae:	b84080e7          	jalr	-1148(ra) # 8000182e <myproc>
    80004cb2:	591c                	lw	a5,48(a0)
    80004cb4:	efad                	bnez	a5,80004d2e <pipewrite+0xea>
      wakeup(&pi->nread);
    80004cb6:	854e                	mv	a0,s3
    80004cb8:	ffffd097          	auipc	ra,0xffffd
    80004cbc:	4a0080e7          	jalr	1184(ra) # 80002158 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cc0:	85a6                	mv	a1,s1
    80004cc2:	854a                	mv	a0,s2
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	314080e7          	jalr	788(ra) # 80001fd8 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ccc:	2184a783          	lw	a5,536(s1)
    80004cd0:	21c4a703          	lw	a4,540(s1)
    80004cd4:	2007879b          	addiw	a5,a5,512
    80004cd8:	fcf706e3          	beq	a4,a5,80004ca4 <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cdc:	4685                	li	a3,1
    80004cde:	8656                	mv	a2,s5
    80004ce0:	faf40593          	addi	a1,s0,-81
    80004ce4:	050bb503          	ld	a0,80(s7) # 1050 <_entry-0x7fffefb0>
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	8c4080e7          	jalr	-1852(ra) # 800015ac <copyin>
    80004cf0:	03850263          	beq	a0,s8,80004d14 <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cf4:	21c4a783          	lw	a5,540(s1)
    80004cf8:	0017871b          	addiw	a4,a5,1
    80004cfc:	20e4ae23          	sw	a4,540(s1)
    80004d00:	1ff7f793          	andi	a5,a5,511
    80004d04:	97a6                	add	a5,a5,s1
    80004d06:	faf44703          	lbu	a4,-81(s0)
    80004d0a:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004d0e:	0a85                	addi	s5,s5,1
    80004d10:	f96a92e3          	bne	s5,s6,80004c94 <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004d14:	21848513          	addi	a0,s1,536
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	440080e7          	jalr	1088(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004d20:	8526                	mv	a0,s1
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	df0080e7          	jalr	-528(ra) # 80000b12 <release>
  return n;
    80004d2a:	8552                	mv	a0,s4
    80004d2c:	a039                	j	80004d3a <pipewrite+0xf6>
        release(&pi->lock);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	de2080e7          	jalr	-542(ra) # 80000b12 <release>
        return -1;
    80004d38:	557d                	li	a0,-1
}
    80004d3a:	60e6                	ld	ra,88(sp)
    80004d3c:	6446                	ld	s0,80(sp)
    80004d3e:	64a6                	ld	s1,72(sp)
    80004d40:	6906                	ld	s2,64(sp)
    80004d42:	79e2                	ld	s3,56(sp)
    80004d44:	7a42                	ld	s4,48(sp)
    80004d46:	7aa2                	ld	s5,40(sp)
    80004d48:	7b02                	ld	s6,32(sp)
    80004d4a:	6be2                	ld	s7,24(sp)
    80004d4c:	6c42                	ld	s8,16(sp)
    80004d4e:	6125                	addi	sp,sp,96
    80004d50:	8082                	ret

0000000080004d52 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d52:	715d                	addi	sp,sp,-80
    80004d54:	e486                	sd	ra,72(sp)
    80004d56:	e0a2                	sd	s0,64(sp)
    80004d58:	fc26                	sd	s1,56(sp)
    80004d5a:	f84a                	sd	s2,48(sp)
    80004d5c:	f44e                	sd	s3,40(sp)
    80004d5e:	f052                	sd	s4,32(sp)
    80004d60:	ec56                	sd	s5,24(sp)
    80004d62:	e85a                	sd	s6,16(sp)
    80004d64:	0880                	addi	s0,sp,80
    80004d66:	84aa                	mv	s1,a0
    80004d68:	892e                	mv	s2,a1
    80004d6a:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	ac2080e7          	jalr	-1342(ra) # 8000182e <myproc>
    80004d74:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	d46080e7          	jalr	-698(ra) # 80000abe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d80:	2184a703          	lw	a4,536(s1)
    80004d84:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d88:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d8c:	02f71763          	bne	a4,a5,80004dba <piperead+0x68>
    80004d90:	2244a783          	lw	a5,548(s1)
    80004d94:	c39d                	beqz	a5,80004dba <piperead+0x68>
    if(myproc()->killed){
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	a98080e7          	jalr	-1384(ra) # 8000182e <myproc>
    80004d9e:	591c                	lw	a5,48(a0)
    80004da0:	ebc1                	bnez	a5,80004e30 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004da2:	85a6                	mv	a1,s1
    80004da4:	854e                	mv	a0,s3
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	232080e7          	jalr	562(ra) # 80001fd8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dae:	2184a703          	lw	a4,536(s1)
    80004db2:	21c4a783          	lw	a5,540(s1)
    80004db6:	fcf70de3          	beq	a4,a5,80004d90 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dba:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dbc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dbe:	05405363          	blez	s4,80004e04 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004dc2:	2184a783          	lw	a5,536(s1)
    80004dc6:	21c4a703          	lw	a4,540(s1)
    80004dca:	02f70d63          	beq	a4,a5,80004e04 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dce:	0017871b          	addiw	a4,a5,1
    80004dd2:	20e4ac23          	sw	a4,536(s1)
    80004dd6:	1ff7f793          	andi	a5,a5,511
    80004dda:	97a6                	add	a5,a5,s1
    80004ddc:	0187c783          	lbu	a5,24(a5)
    80004de0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004de4:	4685                	li	a3,1
    80004de6:	fbf40613          	addi	a2,s0,-65
    80004dea:	85ca                	mv	a1,s2
    80004dec:	050ab503          	ld	a0,80(s5)
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	730080e7          	jalr	1840(ra) # 80001520 <copyout>
    80004df8:	01650663          	beq	a0,s6,80004e04 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dfc:	2985                	addiw	s3,s3,1
    80004dfe:	0905                	addi	s2,s2,1
    80004e00:	fd3a11e3          	bne	s4,s3,80004dc2 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e04:	21c48513          	addi	a0,s1,540
    80004e08:	ffffd097          	auipc	ra,0xffffd
    80004e0c:	350080e7          	jalr	848(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004e10:	8526                	mv	a0,s1
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	d00080e7          	jalr	-768(ra) # 80000b12 <release>
  return i;
}
    80004e1a:	854e                	mv	a0,s3
    80004e1c:	60a6                	ld	ra,72(sp)
    80004e1e:	6406                	ld	s0,64(sp)
    80004e20:	74e2                	ld	s1,56(sp)
    80004e22:	7942                	ld	s2,48(sp)
    80004e24:	79a2                	ld	s3,40(sp)
    80004e26:	7a02                	ld	s4,32(sp)
    80004e28:	6ae2                	ld	s5,24(sp)
    80004e2a:	6b42                	ld	s6,16(sp)
    80004e2c:	6161                	addi	sp,sp,80
    80004e2e:	8082                	ret
      release(&pi->lock);
    80004e30:	8526                	mv	a0,s1
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	ce0080e7          	jalr	-800(ra) # 80000b12 <release>
      return -1;
    80004e3a:	59fd                	li	s3,-1
    80004e3c:	bff9                	j	80004e1a <piperead+0xc8>

0000000080004e3e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e3e:	de010113          	addi	sp,sp,-544
    80004e42:	20113c23          	sd	ra,536(sp)
    80004e46:	20813823          	sd	s0,528(sp)
    80004e4a:	20913423          	sd	s1,520(sp)
    80004e4e:	21213023          	sd	s2,512(sp)
    80004e52:	ffce                	sd	s3,504(sp)
    80004e54:	fbd2                	sd	s4,496(sp)
    80004e56:	f7d6                	sd	s5,488(sp)
    80004e58:	f3da                	sd	s6,480(sp)
    80004e5a:	efde                	sd	s7,472(sp)
    80004e5c:	ebe2                	sd	s8,464(sp)
    80004e5e:	e7e6                	sd	s9,456(sp)
    80004e60:	e3ea                	sd	s10,448(sp)
    80004e62:	ff6e                	sd	s11,440(sp)
    80004e64:	1400                	addi	s0,sp,544
    80004e66:	892a                	mv	s2,a0
    80004e68:	dea43423          	sd	a0,-536(s0)
    80004e6c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e70:	ffffd097          	auipc	ra,0xffffd
    80004e74:	9be080e7          	jalr	-1602(ra) # 8000182e <myproc>
    80004e78:	84aa                	mv	s1,a0

  begin_op();
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	458080e7          	jalr	1112(ra) # 800042d2 <begin_op>

  if((ip = namei(path)) == 0){
    80004e82:	854a                	mv	a0,s2
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	23e080e7          	jalr	574(ra) # 800040c2 <namei>
    80004e8c:	c93d                	beqz	a0,80004f02 <exec+0xc4>
    80004e8e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e90:	fffff097          	auipc	ra,0xfffff
    80004e94:	aa8080e7          	jalr	-1368(ra) # 80003938 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e98:	04000713          	li	a4,64
    80004e9c:	4681                	li	a3,0
    80004e9e:	e4840613          	addi	a2,s0,-440
    80004ea2:	4581                	li	a1,0
    80004ea4:	8556                	mv	a0,s5
    80004ea6:	fffff097          	auipc	ra,0xfffff
    80004eaa:	d22080e7          	jalr	-734(ra) # 80003bc8 <readi>
    80004eae:	04000793          	li	a5,64
    80004eb2:	00f51a63          	bne	a0,a5,80004ec6 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004eb6:	e4842703          	lw	a4,-440(s0)
    80004eba:	464c47b7          	lui	a5,0x464c4
    80004ebe:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ec2:	04f70663          	beq	a4,a5,80004f0e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ec6:	8556                	mv	a0,s5
    80004ec8:	fffff097          	auipc	ra,0xfffff
    80004ecc:	cae080e7          	jalr	-850(ra) # 80003b76 <iunlockput>
    end_op();
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	482080e7          	jalr	1154(ra) # 80004352 <end_op>
  }
  return -1;
    80004ed8:	557d                	li	a0,-1
}
    80004eda:	21813083          	ld	ra,536(sp)
    80004ede:	21013403          	ld	s0,528(sp)
    80004ee2:	20813483          	ld	s1,520(sp)
    80004ee6:	20013903          	ld	s2,512(sp)
    80004eea:	79fe                	ld	s3,504(sp)
    80004eec:	7a5e                	ld	s4,496(sp)
    80004eee:	7abe                	ld	s5,488(sp)
    80004ef0:	7b1e                	ld	s6,480(sp)
    80004ef2:	6bfe                	ld	s7,472(sp)
    80004ef4:	6c5e                	ld	s8,464(sp)
    80004ef6:	6cbe                	ld	s9,456(sp)
    80004ef8:	6d1e                	ld	s10,448(sp)
    80004efa:	7dfa                	ld	s11,440(sp)
    80004efc:	22010113          	addi	sp,sp,544
    80004f00:	8082                	ret
    end_op();
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	450080e7          	jalr	1104(ra) # 80004352 <end_op>
    return -1;
    80004f0a:	557d                	li	a0,-1
    80004f0c:	b7f9                	j	80004eda <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f0e:	8526                	mv	a0,s1
    80004f10:	ffffd097          	auipc	ra,0xffffd
    80004f14:	9e2080e7          	jalr	-1566(ra) # 800018f2 <proc_pagetable>
    80004f18:	8b2a                	mv	s6,a0
    80004f1a:	d555                	beqz	a0,80004ec6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f1c:	e6842783          	lw	a5,-408(s0)
    80004f20:	e8045703          	lhu	a4,-384(s0)
    80004f24:	10070263          	beqz	a4,80005028 <exec+0x1ea>
  sz = 0;
    80004f28:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f2c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f30:	6a05                	lui	s4,0x1
    80004f32:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f36:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004f3a:	6d85                	lui	s11,0x1
    80004f3c:	7d7d                	lui	s10,0xfffff
    80004f3e:	a88d                	j	80004fb0 <exec+0x172>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f40:	00003517          	auipc	a0,0x3
    80004f44:	a9050513          	addi	a0,a0,-1392 # 800079d0 <userret+0x940>
    80004f48:	ffffb097          	auipc	ra,0xffffb
    80004f4c:	600080e7          	jalr	1536(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f50:	874a                	mv	a4,s2
    80004f52:	009c86bb          	addw	a3,s9,s1
    80004f56:	4581                	li	a1,0
    80004f58:	8556                	mv	a0,s5
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	c6e080e7          	jalr	-914(ra) # 80003bc8 <readi>
    80004f62:	2501                	sext.w	a0,a0
    80004f64:	10a91763          	bne	s2,a0,80005072 <exec+0x234>
  for(i = 0; i < sz; i += PGSIZE){
    80004f68:	009d84bb          	addw	s1,s11,s1
    80004f6c:	013d09bb          	addw	s3,s10,s3
    80004f70:	0374f263          	bgeu	s1,s7,80004f94 <exec+0x156>
    pa = walkaddr(pagetable, va + i);
    80004f74:	02049593          	slli	a1,s1,0x20
    80004f78:	9181                	srli	a1,a1,0x20
    80004f7a:	95e2                	add	a1,a1,s8
    80004f7c:	855a                	mv	a0,s6
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	fd4080e7          	jalr	-44(ra) # 80000f52 <walkaddr>
    80004f86:	862a                	mv	a2,a0
    if(pa == 0)
    80004f88:	dd45                	beqz	a0,80004f40 <exec+0x102>
      n = PGSIZE;
    80004f8a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f8c:	fd49f2e3          	bgeu	s3,s4,80004f50 <exec+0x112>
      n = sz - i;
    80004f90:	894e                	mv	s2,s3
    80004f92:	bf7d                	j	80004f50 <exec+0x112>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f94:	e0843783          	ld	a5,-504(s0)
    80004f98:	0017869b          	addiw	a3,a5,1
    80004f9c:	e0d43423          	sd	a3,-504(s0)
    80004fa0:	e0043783          	ld	a5,-512(s0)
    80004fa4:	0387879b          	addiw	a5,a5,56
    80004fa8:	e8045703          	lhu	a4,-384(s0)
    80004fac:	08e6d063          	bge	a3,a4,8000502c <exec+0x1ee>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fb0:	2781                	sext.w	a5,a5
    80004fb2:	e0f43023          	sd	a5,-512(s0)
    80004fb6:	03800713          	li	a4,56
    80004fba:	86be                	mv	a3,a5
    80004fbc:	e1040613          	addi	a2,s0,-496
    80004fc0:	4581                	li	a1,0
    80004fc2:	8556                	mv	a0,s5
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	c04080e7          	jalr	-1020(ra) # 80003bc8 <readi>
    80004fcc:	03800793          	li	a5,56
    80004fd0:	0af51163          	bne	a0,a5,80005072 <exec+0x234>
    if(ph.type != ELF_PROG_LOAD)
    80004fd4:	e1042783          	lw	a5,-496(s0)
    80004fd8:	4705                	li	a4,1
    80004fda:	fae79de3          	bne	a5,a4,80004f94 <exec+0x156>
    if(ph.memsz < ph.filesz)
    80004fde:	e3843603          	ld	a2,-456(s0)
    80004fe2:	e3043783          	ld	a5,-464(s0)
    80004fe6:	08f66663          	bltu	a2,a5,80005072 <exec+0x234>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fea:	e2043783          	ld	a5,-480(s0)
    80004fee:	963e                	add	a2,a2,a5
    80004ff0:	08f66163          	bltu	a2,a5,80005072 <exec+0x234>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ff4:	df843583          	ld	a1,-520(s0)
    80004ff8:	855a                	mv	a0,s6
    80004ffa:	ffffc097          	auipc	ra,0xffffc
    80004ffe:	34c080e7          	jalr	844(ra) # 80001346 <uvmalloc>
    80005002:	dea43c23          	sd	a0,-520(s0)
    80005006:	c535                	beqz	a0,80005072 <exec+0x234>
    if(ph.vaddr % PGSIZE != 0)
    80005008:	e2043c03          	ld	s8,-480(s0)
    8000500c:	de043783          	ld	a5,-544(s0)
    80005010:	00fc77b3          	and	a5,s8,a5
    80005014:	efb9                	bnez	a5,80005072 <exec+0x234>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005016:	e1842c83          	lw	s9,-488(s0)
    8000501a:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000501e:	f60b8be3          	beqz	s7,80004f94 <exec+0x156>
    80005022:	89de                	mv	s3,s7
    80005024:	4481                	li	s1,0
    80005026:	b7b9                	j	80004f74 <exec+0x136>
  sz = 0;
    80005028:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    8000502c:	8556                	mv	a0,s5
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	b48080e7          	jalr	-1208(ra) # 80003b76 <iunlockput>
  end_op();
    80005036:	fffff097          	auipc	ra,0xfffff
    8000503a:	31c080e7          	jalr	796(ra) # 80004352 <end_op>
  p = myproc();
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	7f0080e7          	jalr	2032(ra) # 8000182e <myproc>
    80005046:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005048:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000504c:	6585                	lui	a1,0x1
    8000504e:	15fd                	addi	a1,a1,-1
    80005050:	df843783          	ld	a5,-520(s0)
    80005054:	95be                	add	a1,a1,a5
    80005056:	77fd                	lui	a5,0xfffff
    80005058:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000505a:	6609                	lui	a2,0x2
    8000505c:	962e                	add	a2,a2,a1
    8000505e:	855a                	mv	a0,s6
    80005060:	ffffc097          	auipc	ra,0xffffc
    80005064:	2e6080e7          	jalr	742(ra) # 80001346 <uvmalloc>
    80005068:	892a                	mv	s2,a0
    8000506a:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    8000506e:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005070:	ed01                	bnez	a0,80005088 <exec+0x24a>
    proc_freepagetable(pagetable, sz);
    80005072:	df843583          	ld	a1,-520(s0)
    80005076:	855a                	mv	a0,s6
    80005078:	ffffd097          	auipc	ra,0xffffd
    8000507c:	97e080e7          	jalr	-1666(ra) # 800019f6 <proc_freepagetable>
  if(ip){
    80005080:	e40a93e3          	bnez	s5,80004ec6 <exec+0x88>
  return -1;
    80005084:	557d                	li	a0,-1
    80005086:	bd91                	j	80004eda <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005088:	75f9                	lui	a1,0xffffe
    8000508a:	95aa                	add	a1,a1,a0
    8000508c:	855a                	mv	a0,s6
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	460080e7          	jalr	1120(ra) # 800014ee <uvmclear>
  stackbase = sp - PGSIZE;
    80005096:	7c7d                	lui	s8,0xfffff
    80005098:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    8000509a:	df043783          	ld	a5,-528(s0)
    8000509e:	6388                	ld	a0,0(a5)
    800050a0:	c52d                	beqz	a0,8000510a <exec+0x2cc>
    800050a2:	e8840993          	addi	s3,s0,-376
    800050a6:	f8840a93          	addi	s5,s0,-120
    800050aa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	c32080e7          	jalr	-974(ra) # 80000cde <strlen>
    800050b4:	0015079b          	addiw	a5,a0,1
    800050b8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050bc:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050c0:	0f896b63          	bltu	s2,s8,800051b6 <exec+0x378>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050c4:	df043d03          	ld	s10,-528(s0)
    800050c8:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffd8fe4>
    800050cc:	8552                	mv	a0,s4
    800050ce:	ffffc097          	auipc	ra,0xffffc
    800050d2:	c10080e7          	jalr	-1008(ra) # 80000cde <strlen>
    800050d6:	0015069b          	addiw	a3,a0,1
    800050da:	8652                	mv	a2,s4
    800050dc:	85ca                	mv	a1,s2
    800050de:	855a                	mv	a0,s6
    800050e0:	ffffc097          	auipc	ra,0xffffc
    800050e4:	440080e7          	jalr	1088(ra) # 80001520 <copyout>
    800050e8:	0c054963          	bltz	a0,800051ba <exec+0x37c>
    ustack[argc] = sp;
    800050ec:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050f0:	0485                	addi	s1,s1,1
    800050f2:	008d0793          	addi	a5,s10,8
    800050f6:	def43823          	sd	a5,-528(s0)
    800050fa:	008d3503          	ld	a0,8(s10)
    800050fe:	c909                	beqz	a0,80005110 <exec+0x2d2>
    if(argc >= MAXARG)
    80005100:	09a1                	addi	s3,s3,8
    80005102:	fb3a95e3          	bne	s5,s3,800050ac <exec+0x26e>
  ip = 0;
    80005106:	4a81                	li	s5,0
    80005108:	b7ad                	j	80005072 <exec+0x234>
  sp = sz;
    8000510a:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000510e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005110:	00349793          	slli	a5,s1,0x3
    80005114:	f9040713          	addi	a4,s0,-112
    80005118:	97ba                	add	a5,a5,a4
    8000511a:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8edc>
  sp -= (argc+1) * sizeof(uint64);
    8000511e:	00148693          	addi	a3,s1,1
    80005122:	068e                	slli	a3,a3,0x3
    80005124:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005128:	ff097913          	andi	s2,s2,-16
  ip = 0;
    8000512c:	4a81                	li	s5,0
  if(sp < stackbase)
    8000512e:	f58962e3          	bltu	s2,s8,80005072 <exec+0x234>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005132:	e8840613          	addi	a2,s0,-376
    80005136:	85ca                	mv	a1,s2
    80005138:	855a                	mv	a0,s6
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	3e6080e7          	jalr	998(ra) # 80001520 <copyout>
    80005142:	06054e63          	bltz	a0,800051be <exec+0x380>
  p->tf->a1 = sp;
    80005146:	058bb783          	ld	a5,88(s7)
    8000514a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000514e:	de843783          	ld	a5,-536(s0)
    80005152:	0007c703          	lbu	a4,0(a5)
    80005156:	cf11                	beqz	a4,80005172 <exec+0x334>
    80005158:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000515a:	02f00693          	li	a3,47
    8000515e:	a039                	j	8000516c <exec+0x32e>
      last = s+1;
    80005160:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005164:	0785                	addi	a5,a5,1
    80005166:	fff7c703          	lbu	a4,-1(a5)
    8000516a:	c701                	beqz	a4,80005172 <exec+0x334>
    if(*s == '/')
    8000516c:	fed71ce3          	bne	a4,a3,80005164 <exec+0x326>
    80005170:	bfc5                	j	80005160 <exec+0x322>
  safestrcpy(p->name, last, sizeof(p->name));
    80005172:	4641                	li	a2,16
    80005174:	de843583          	ld	a1,-536(s0)
    80005178:	158b8513          	addi	a0,s7,344
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	b30080e7          	jalr	-1232(ra) # 80000cac <safestrcpy>
  oldpagetable = p->pagetable;
    80005184:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005188:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000518c:	df843783          	ld	a5,-520(s0)
    80005190:	04fbb423          	sd	a5,72(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005194:	058bb783          	ld	a5,88(s7)
    80005198:	e6043703          	ld	a4,-416(s0)
    8000519c:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000519e:	058bb783          	ld	a5,88(s7)
    800051a2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051a6:	85e6                	mv	a1,s9
    800051a8:	ffffd097          	auipc	ra,0xffffd
    800051ac:	84e080e7          	jalr	-1970(ra) # 800019f6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051b0:	0004851b          	sext.w	a0,s1
    800051b4:	b31d                	j	80004eda <exec+0x9c>
  ip = 0;
    800051b6:	4a81                	li	s5,0
    800051b8:	bd6d                	j	80005072 <exec+0x234>
    800051ba:	4a81                	li	s5,0
    800051bc:	bd5d                	j	80005072 <exec+0x234>
    800051be:	4a81                	li	s5,0
    800051c0:	bd4d                	j	80005072 <exec+0x234>

00000000800051c2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051c2:	1101                	addi	sp,sp,-32
    800051c4:	ec06                	sd	ra,24(sp)
    800051c6:	e822                	sd	s0,16(sp)
    800051c8:	e426                	sd	s1,8(sp)
    800051ca:	1000                	addi	s0,sp,32
    800051cc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	660080e7          	jalr	1632(ra) # 8000182e <myproc>
    800051d6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051d8:	0d050793          	addi	a5,a0,208
    800051dc:	4501                	li	a0,0
    800051de:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051e0:	6398                	ld	a4,0(a5)
    800051e2:	cb19                	beqz	a4,800051f8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051e4:	2505                	addiw	a0,a0,1
    800051e6:	07a1                	addi	a5,a5,8
    800051e8:	fed51ce3          	bne	a0,a3,800051e0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051ec:	557d                	li	a0,-1
}
    800051ee:	60e2                	ld	ra,24(sp)
    800051f0:	6442                	ld	s0,16(sp)
    800051f2:	64a2                	ld	s1,8(sp)
    800051f4:	6105                	addi	sp,sp,32
    800051f6:	8082                	ret
      p->ofile[fd] = f;
    800051f8:	01a50793          	addi	a5,a0,26
    800051fc:	078e                	slli	a5,a5,0x3
    800051fe:	963e                	add	a2,a2,a5
    80005200:	e204                	sd	s1,0(a2)
      return fd;
    80005202:	b7f5                	j	800051ee <fdalloc+0x2c>

0000000080005204 <argfd>:
{
    80005204:	7179                	addi	sp,sp,-48
    80005206:	f406                	sd	ra,40(sp)
    80005208:	f022                	sd	s0,32(sp)
    8000520a:	ec26                	sd	s1,24(sp)
    8000520c:	e84a                	sd	s2,16(sp)
    8000520e:	1800                	addi	s0,sp,48
    80005210:	892e                	mv	s2,a1
    80005212:	84b2                	mv	s1,a2
  if(argint(n, &fd) < 0)
    80005214:	fdc40593          	addi	a1,s0,-36
    80005218:	ffffd097          	auipc	ra,0xffffd
    8000521c:	65e080e7          	jalr	1630(ra) # 80002876 <argint>
    80005220:	04054063          	bltz	a0,80005260 <argfd+0x5c>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005224:	fdc42703          	lw	a4,-36(s0)
    80005228:	47bd                	li	a5,15
    8000522a:	02e7ed63          	bltu	a5,a4,80005264 <argfd+0x60>
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	600080e7          	jalr	1536(ra) # 8000182e <myproc>
    80005236:	fdc42703          	lw	a4,-36(s0)
    8000523a:	01a70793          	addi	a5,a4,26
    8000523e:	078e                	slli	a5,a5,0x3
    80005240:	953e                	add	a0,a0,a5
    80005242:	611c                	ld	a5,0(a0)
    80005244:	c395                	beqz	a5,80005268 <argfd+0x64>
  if(pfd)
    80005246:	00090463          	beqz	s2,8000524e <argfd+0x4a>
    *pfd = fd;
    8000524a:	00e92023          	sw	a4,0(s2)
  return 0;
    8000524e:	4501                	li	a0,0
  if(pf)
    80005250:	c091                	beqz	s1,80005254 <argfd+0x50>
    *pf = f;
    80005252:	e09c                	sd	a5,0(s1)
}
    80005254:	70a2                	ld	ra,40(sp)
    80005256:	7402                	ld	s0,32(sp)
    80005258:	64e2                	ld	s1,24(sp)
    8000525a:	6942                	ld	s2,16(sp)
    8000525c:	6145                	addi	sp,sp,48
    8000525e:	8082                	ret
    return -1;
    80005260:	557d                	li	a0,-1
    80005262:	bfcd                	j	80005254 <argfd+0x50>
    return -1;
    80005264:	557d                	li	a0,-1
    80005266:	b7fd                	j	80005254 <argfd+0x50>
    80005268:	557d                	li	a0,-1
    8000526a:	b7ed                	j	80005254 <argfd+0x50>

000000008000526c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000526c:	715d                	addi	sp,sp,-80
    8000526e:	e486                	sd	ra,72(sp)
    80005270:	e0a2                	sd	s0,64(sp)
    80005272:	fc26                	sd	s1,56(sp)
    80005274:	f84a                	sd	s2,48(sp)
    80005276:	f44e                	sd	s3,40(sp)
    80005278:	f052                	sd	s4,32(sp)
    8000527a:	ec56                	sd	s5,24(sp)
    8000527c:	0880                	addi	s0,sp,80
    8000527e:	89ae                	mv	s3,a1
    80005280:	8ab2                	mv	s5,a2
    80005282:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005284:	fb040593          	addi	a1,s0,-80
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	e58080e7          	jalr	-424(ra) # 800040e0 <nameiparent>
    80005290:	892a                	mv	s2,a0
    80005292:	12050e63          	beqz	a0,800053ce <create+0x162>
    return 0;

  ilock(dp);
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	6a2080e7          	jalr	1698(ra) # 80003938 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000529e:	4601                	li	a2,0
    800052a0:	fb040593          	addi	a1,s0,-80
    800052a4:	854a                	mv	a0,s2
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	b4a080e7          	jalr	-1206(ra) # 80003df0 <dirlookup>
    800052ae:	84aa                	mv	s1,a0
    800052b0:	c921                	beqz	a0,80005300 <create+0x94>
    iunlockput(dp);
    800052b2:	854a                	mv	a0,s2
    800052b4:	fffff097          	auipc	ra,0xfffff
    800052b8:	8c2080e7          	jalr	-1854(ra) # 80003b76 <iunlockput>
    ilock(ip);
    800052bc:	8526                	mv	a0,s1
    800052be:	ffffe097          	auipc	ra,0xffffe
    800052c2:	67a080e7          	jalr	1658(ra) # 80003938 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052c6:	2981                	sext.w	s3,s3
    800052c8:	4789                	li	a5,2
    800052ca:	02f99463          	bne	s3,a5,800052f2 <create+0x86>
    800052ce:	0444d783          	lhu	a5,68(s1)
    800052d2:	37f9                	addiw	a5,a5,-2
    800052d4:	17c2                	slli	a5,a5,0x30
    800052d6:	93c1                	srli	a5,a5,0x30
    800052d8:	4705                	li	a4,1
    800052da:	00f76c63          	bltu	a4,a5,800052f2 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052de:	8526                	mv	a0,s1
    800052e0:	60a6                	ld	ra,72(sp)
    800052e2:	6406                	ld	s0,64(sp)
    800052e4:	74e2                	ld	s1,56(sp)
    800052e6:	7942                	ld	s2,48(sp)
    800052e8:	79a2                	ld	s3,40(sp)
    800052ea:	7a02                	ld	s4,32(sp)
    800052ec:	6ae2                	ld	s5,24(sp)
    800052ee:	6161                	addi	sp,sp,80
    800052f0:	8082                	ret
    iunlockput(ip);
    800052f2:	8526                	mv	a0,s1
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	882080e7          	jalr	-1918(ra) # 80003b76 <iunlockput>
    return 0;
    800052fc:	4481                	li	s1,0
    800052fe:	b7c5                	j	800052de <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005300:	85ce                	mv	a1,s3
    80005302:	00092503          	lw	a0,0(s2)
    80005306:	ffffe097          	auipc	ra,0xffffe
    8000530a:	49a080e7          	jalr	1178(ra) # 800037a0 <ialloc>
    8000530e:	84aa                	mv	s1,a0
    80005310:	c521                	beqz	a0,80005358 <create+0xec>
  ilock(ip);
    80005312:	ffffe097          	auipc	ra,0xffffe
    80005316:	626080e7          	jalr	1574(ra) # 80003938 <ilock>
  ip->major = major;
    8000531a:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000531e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005322:	4a05                	li	s4,1
    80005324:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005328:	8526                	mv	a0,s1
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	544080e7          	jalr	1348(ra) # 8000386e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005332:	2981                	sext.w	s3,s3
    80005334:	03498a63          	beq	s3,s4,80005368 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005338:	40d0                	lw	a2,4(s1)
    8000533a:	fb040593          	addi	a1,s0,-80
    8000533e:	854a                	mv	a0,s2
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	cc0080e7          	jalr	-832(ra) # 80004000 <dirlink>
    80005348:	06054b63          	bltz	a0,800053be <create+0x152>
  iunlockput(dp);
    8000534c:	854a                	mv	a0,s2
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	828080e7          	jalr	-2008(ra) # 80003b76 <iunlockput>
  return ip;
    80005356:	b761                	j	800052de <create+0x72>
    panic("create: ialloc");
    80005358:	00002517          	auipc	a0,0x2
    8000535c:	69850513          	addi	a0,a0,1688 # 800079f0 <userret+0x960>
    80005360:	ffffb097          	auipc	ra,0xffffb
    80005364:	1e8080e7          	jalr	488(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005368:	04a95783          	lhu	a5,74(s2)
    8000536c:	2785                	addiw	a5,a5,1
    8000536e:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005372:	854a                	mv	a0,s2
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	4fa080e7          	jalr	1274(ra) # 8000386e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000537c:	40d0                	lw	a2,4(s1)
    8000537e:	00002597          	auipc	a1,0x2
    80005382:	68258593          	addi	a1,a1,1666 # 80007a00 <userret+0x970>
    80005386:	8526                	mv	a0,s1
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	c78080e7          	jalr	-904(ra) # 80004000 <dirlink>
    80005390:	00054f63          	bltz	a0,800053ae <create+0x142>
    80005394:	00492603          	lw	a2,4(s2)
    80005398:	00002597          	auipc	a1,0x2
    8000539c:	67058593          	addi	a1,a1,1648 # 80007a08 <userret+0x978>
    800053a0:	8526                	mv	a0,s1
    800053a2:	fffff097          	auipc	ra,0xfffff
    800053a6:	c5e080e7          	jalr	-930(ra) # 80004000 <dirlink>
    800053aa:	f80557e3          	bgez	a0,80005338 <create+0xcc>
      panic("create dots");
    800053ae:	00002517          	auipc	a0,0x2
    800053b2:	66250513          	addi	a0,a0,1634 # 80007a10 <userret+0x980>
    800053b6:	ffffb097          	auipc	ra,0xffffb
    800053ba:	192080e7          	jalr	402(ra) # 80000548 <panic>
    panic("create: dirlink");
    800053be:	00002517          	auipc	a0,0x2
    800053c2:	66250513          	addi	a0,a0,1634 # 80007a20 <userret+0x990>
    800053c6:	ffffb097          	auipc	ra,0xffffb
    800053ca:	182080e7          	jalr	386(ra) # 80000548 <panic>
    return 0;
    800053ce:	84aa                	mv	s1,a0
    800053d0:	b739                	j	800052de <create+0x72>

00000000800053d2 <sys_dup>:
{
    800053d2:	7179                	addi	sp,sp,-48
    800053d4:	f406                	sd	ra,40(sp)
    800053d6:	f022                	sd	s0,32(sp)
    800053d8:	ec26                	sd	s1,24(sp)
    800053da:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053dc:	fd840613          	addi	a2,s0,-40
    800053e0:	4581                	li	a1,0
    800053e2:	4501                	li	a0,0
    800053e4:	00000097          	auipc	ra,0x0
    800053e8:	e20080e7          	jalr	-480(ra) # 80005204 <argfd>
    return -1;
    800053ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053ee:	02054b63          	bltz	a0,80005424 <sys_dup+0x52>
  if((fd=fdalloc(f)) < 0)
    800053f2:	fd843503          	ld	a0,-40(s0)
    800053f6:	00000097          	auipc	ra,0x0
    800053fa:	dcc080e7          	jalr	-564(ra) # 800051c2 <fdalloc>
    800053fe:	84aa                	mv	s1,a0
    return -1;
    80005400:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005402:	02054163          	bltz	a0,80005424 <sys_dup+0x52>
struct proc *pi = myproc();
    80005406:	ffffc097          	auipc	ra,0xffffc
    8000540a:	428080e7          	jalr	1064(ra) # 8000182e <myproc>
	if((h&i)==h){
    8000540e:	5d5c                	lw	a5,60(a0)
    80005410:	4007f793          	andi	a5,a5,1024
    80005414:	ef91                	bnez	a5,80005430 <sys_dup+0x5e>
  filedup(f);
    80005416:	fd843503          	ld	a0,-40(s0)
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	338080e7          	jalr	824(ra) # 80004752 <filedup>
  return fd;
    80005422:	87a6                	mv	a5,s1
}
    80005424:	853e                	mv	a0,a5
    80005426:	70a2                	ld	ra,40(sp)
    80005428:	7402                	ld	s0,32(sp)
    8000542a:	64e2                	ld	s1,24(sp)
    8000542c:	6145                	addi	sp,sp,48
    8000542e:	8082                	ret
		printf("arguments: %p\n",f);
    80005430:	fd843583          	ld	a1,-40(s0)
    80005434:	00002517          	auipc	a0,0x2
    80005438:	37450513          	addi	a0,a0,884 # 800077a8 <userret+0x718>
    8000543c:	ffffb097          	auipc	ra,0xffffb
    80005440:	156080e7          	jalr	342(ra) # 80000592 <printf>
    80005444:	bfc9                	j	80005416 <sys_dup+0x44>

0000000080005446 <sys_read>:
{
    80005446:	7179                	addi	sp,sp,-48
    80005448:	f406                	sd	ra,40(sp)
    8000544a:	f022                	sd	s0,32(sp)
    8000544c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000544e:	fe840613          	addi	a2,s0,-24
    80005452:	4581                	li	a1,0
    80005454:	4501                	li	a0,0
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	dae080e7          	jalr	-594(ra) # 80005204 <argfd>
    return -1;
    8000545e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005460:	04054963          	bltz	a0,800054b2 <sys_read+0x6c>
    80005464:	fe440593          	addi	a1,s0,-28
    80005468:	4509                	li	a0,2
    8000546a:	ffffd097          	auipc	ra,0xffffd
    8000546e:	40c080e7          	jalr	1036(ra) # 80002876 <argint>
    return -1;
    80005472:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005474:	02054f63          	bltz	a0,800054b2 <sys_read+0x6c>
    80005478:	fd840593          	addi	a1,s0,-40
    8000547c:	4505                	li	a0,1
    8000547e:	ffffd097          	auipc	ra,0xffffd
    80005482:	41a080e7          	jalr	1050(ra) # 80002898 <argaddr>
    return -1;
    80005486:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005488:	02054563          	bltz	a0,800054b2 <sys_read+0x6c>
struct proc *pi = myproc();
    8000548c:	ffffc097          	auipc	ra,0xffffc
    80005490:	3a2080e7          	jalr	930(ra) # 8000182e <myproc>
	if((h&i)==h){
    80005494:	5d5c                	lw	a5,60(a0)
    80005496:	0207f793          	andi	a5,a5,32
    8000549a:	e38d                	bnez	a5,800054bc <sys_read+0x76>
  return fileread(f, p, n);
    8000549c:	fe442603          	lw	a2,-28(s0)
    800054a0:	fd843583          	ld	a1,-40(s0)
    800054a4:	fe843503          	ld	a0,-24(s0)
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	436080e7          	jalr	1078(ra) # 800048de <fileread>
    800054b0:	87aa                	mv	a5,a0
}
    800054b2:	853e                	mv	a0,a5
    800054b4:	70a2                	ld	ra,40(sp)
    800054b6:	7402                	ld	s0,32(sp)
    800054b8:	6145                	addi	sp,sp,48
    800054ba:	8082                	ret
		printf("arguments: %p %p %d\n",f,p,n);
    800054bc:	fe442683          	lw	a3,-28(s0)
    800054c0:	fd843603          	ld	a2,-40(s0)
    800054c4:	fe843583          	ld	a1,-24(s0)
    800054c8:	00002517          	auipc	a0,0x2
    800054cc:	56850513          	addi	a0,a0,1384 # 80007a30 <userret+0x9a0>
    800054d0:	ffffb097          	auipc	ra,0xffffb
    800054d4:	0c2080e7          	jalr	194(ra) # 80000592 <printf>
    800054d8:	b7d1                	j	8000549c <sys_read+0x56>

00000000800054da <sys_write>:
{
    800054da:	7179                	addi	sp,sp,-48
    800054dc:	f406                	sd	ra,40(sp)
    800054de:	f022                	sd	s0,32(sp)
    800054e0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054e2:	fe840613          	addi	a2,s0,-24
    800054e6:	4581                	li	a1,0
    800054e8:	4501                	li	a0,0
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	d1a080e7          	jalr	-742(ra) # 80005204 <argfd>
    return -1;
    800054f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054f4:	04054963          	bltz	a0,80005546 <sys_write+0x6c>
    800054f8:	fe440593          	addi	a1,s0,-28
    800054fc:	4509                	li	a0,2
    800054fe:	ffffd097          	auipc	ra,0xffffd
    80005502:	378080e7          	jalr	888(ra) # 80002876 <argint>
    return -1;
    80005506:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005508:	02054f63          	bltz	a0,80005546 <sys_write+0x6c>
    8000550c:	fd840593          	addi	a1,s0,-40
    80005510:	4505                	li	a0,1
    80005512:	ffffd097          	auipc	ra,0xffffd
    80005516:	386080e7          	jalr	902(ra) # 80002898 <argaddr>
    return -1;
    8000551a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000551c:	02054563          	bltz	a0,80005546 <sys_write+0x6c>
struct proc *pi = myproc();
    80005520:	ffffc097          	auipc	ra,0xffffc
    80005524:	30e080e7          	jalr	782(ra) # 8000182e <myproc>
	if((h&i)==h){
    80005528:	5d5c                	lw	a5,60(a0)
    8000552a:	6741                	lui	a4,0x10
    8000552c:	8ff9                	and	a5,a5,a4
    8000552e:	e38d                	bnez	a5,80005550 <sys_write+0x76>
  return filewrite(f, p, n);
    80005530:	fe442603          	lw	a2,-28(s0)
    80005534:	fd843583          	ld	a1,-40(s0)
    80005538:	fe843503          	ld	a0,-24(s0)
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	464080e7          	jalr	1124(ra) # 800049a0 <filewrite>
    80005544:	87aa                	mv	a5,a0
}
    80005546:	853e                	mv	a0,a5
    80005548:	70a2                	ld	ra,40(sp)
    8000554a:	7402                	ld	s0,32(sp)
    8000554c:	6145                	addi	sp,sp,48
    8000554e:	8082                	ret
		printf("arguments: %p %p %d\n",f,p,n);
    80005550:	fe442683          	lw	a3,-28(s0)
    80005554:	fd843603          	ld	a2,-40(s0)
    80005558:	fe843583          	ld	a1,-24(s0)
    8000555c:	00002517          	auipc	a0,0x2
    80005560:	4d450513          	addi	a0,a0,1236 # 80007a30 <userret+0x9a0>
    80005564:	ffffb097          	auipc	ra,0xffffb
    80005568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
    8000556c:	b7d1                	j	80005530 <sys_write+0x56>

000000008000556e <sys_close>:
{
    8000556e:	1101                	addi	sp,sp,-32
    80005570:	ec06                	sd	ra,24(sp)
    80005572:	e822                	sd	s0,16(sp)
    80005574:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005576:	fe040613          	addi	a2,s0,-32
    8000557a:	fec40593          	addi	a1,s0,-20
    8000557e:	4501                	li	a0,0
    80005580:	00000097          	auipc	ra,0x0
    80005584:	c84080e7          	jalr	-892(ra) # 80005204 <argfd>
    return -1;
    80005588:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000558a:	02054d63          	bltz	a0,800055c4 <sys_close+0x56>
struct proc *pi = myproc();
    8000558e:	ffffc097          	auipc	ra,0xffffc
    80005592:	2a0080e7          	jalr	672(ra) # 8000182e <myproc>
	if((h&i)==h){
    80005596:	5d5c                	lw	a5,60(a0)
    80005598:	00200737          	lui	a4,0x200
    8000559c:	8ff9                	and	a5,a5,a4
    8000559e:	eb85                	bnez	a5,800055ce <sys_close+0x60>
  myproc()->ofile[fd] = 0;
    800055a0:	ffffc097          	auipc	ra,0xffffc
    800055a4:	28e080e7          	jalr	654(ra) # 8000182e <myproc>
    800055a8:	fec42783          	lw	a5,-20(s0)
    800055ac:	07e9                	addi	a5,a5,26
    800055ae:	078e                	slli	a5,a5,0x3
    800055b0:	97aa                	add	a5,a5,a0
    800055b2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800055b6:	fe043503          	ld	a0,-32(s0)
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	1ea080e7          	jalr	490(ra) # 800047a4 <fileclose>
  return 0;
    800055c2:	4781                	li	a5,0
}
    800055c4:	853e                	mv	a0,a5
    800055c6:	60e2                	ld	ra,24(sp)
    800055c8:	6442                	ld	s0,16(sp)
    800055ca:	6105                	addi	sp,sp,32
    800055cc:	8082                	ret
		printf("arguments: %p\n",f);
    800055ce:	fe043583          	ld	a1,-32(s0)
    800055d2:	00002517          	auipc	a0,0x2
    800055d6:	1d650513          	addi	a0,a0,470 # 800077a8 <userret+0x718>
    800055da:	ffffb097          	auipc	ra,0xffffb
    800055de:	fb8080e7          	jalr	-72(ra) # 80000592 <printf>
    800055e2:	bf7d                	j	800055a0 <sys_close+0x32>

00000000800055e4 <sys_fstat>:
{
    800055e4:	1101                	addi	sp,sp,-32
    800055e6:	ec06                	sd	ra,24(sp)
    800055e8:	e822                	sd	s0,16(sp)
    800055ea:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055ec:	fe840613          	addi	a2,s0,-24
    800055f0:	4581                	li	a1,0
    800055f2:	4501                	li	a0,0
    800055f4:	00000097          	auipc	ra,0x0
    800055f8:	c10080e7          	jalr	-1008(ra) # 80005204 <argfd>
    return -1;
    800055fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055fe:	02054d63          	bltz	a0,80005638 <sys_fstat+0x54>
    80005602:	fe040593          	addi	a1,s0,-32
    80005606:	4505                	li	a0,1
    80005608:	ffffd097          	auipc	ra,0xffffd
    8000560c:	290080e7          	jalr	656(ra) # 80002898 <argaddr>
    return -1;
    80005610:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005612:	02054363          	bltz	a0,80005638 <sys_fstat+0x54>
struct proc *pi = myproc();
    80005616:	ffffc097          	auipc	ra,0xffffc
    8000561a:	218080e7          	jalr	536(ra) # 8000182e <myproc>
	if((h&i)==h){
    8000561e:	5d5c                	lw	a5,60(a0)
    80005620:	1007f793          	andi	a5,a5,256
    80005624:	ef99                	bnez	a5,80005642 <sys_fstat+0x5e>
  return filestat(f, st);
    80005626:	fe043583          	ld	a1,-32(s0)
    8000562a:	fe843503          	ld	a0,-24(s0)
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	23e080e7          	jalr	574(ra) # 8000486c <filestat>
    80005636:	87aa                	mv	a5,a0
}
    80005638:	853e                	mv	a0,a5
    8000563a:	60e2                	ld	ra,24(sp)
    8000563c:	6442                	ld	s0,16(sp)
    8000563e:	6105                	addi	sp,sp,32
    80005640:	8082                	ret
		printf("arguments: %p %p\n",f,st);
    80005642:	fe043603          	ld	a2,-32(s0)
    80005646:	fe843583          	ld	a1,-24(s0)
    8000564a:	00002517          	auipc	a0,0x2
    8000564e:	3fe50513          	addi	a0,a0,1022 # 80007a48 <userret+0x9b8>
    80005652:	ffffb097          	auipc	ra,0xffffb
    80005656:	f40080e7          	jalr	-192(ra) # 80000592 <printf>
    8000565a:	b7f1                	j	80005626 <sys_fstat+0x42>

000000008000565c <sys_link>:
{
    8000565c:	7169                	addi	sp,sp,-304
    8000565e:	f606                	sd	ra,296(sp)
    80005660:	f222                	sd	s0,288(sp)
    80005662:	ee26                	sd	s1,280(sp)
    80005664:	ea4a                	sd	s2,272(sp)
    80005666:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005668:	08000613          	li	a2,128
    8000566c:	ed040593          	addi	a1,s0,-304
    80005670:	4501                	li	a0,0
    80005672:	ffffd097          	auipc	ra,0xffffd
    80005676:	248080e7          	jalr	584(ra) # 800028ba <argstr>
    return -1;
    8000567a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000567c:	14054463          	bltz	a0,800057c4 <sys_link+0x168>
    80005680:	08000613          	li	a2,128
    80005684:	f5040593          	addi	a1,s0,-176
    80005688:	4505                	li	a0,1
    8000568a:	ffffd097          	auipc	ra,0xffffd
    8000568e:	230080e7          	jalr	560(ra) # 800028ba <argstr>
    return -1;
    80005692:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005694:	12054863          	bltz	a0,800057c4 <sys_link+0x168>
	struct proc *pi = myproc();
    80005698:	ffffc097          	auipc	ra,0xffffc
    8000569c:	196080e7          	jalr	406(ra) # 8000182e <myproc>
	if((h&i)==h){
    800056a0:	5d5c                	lw	a5,60(a0)
    800056a2:	00080737          	lui	a4,0x80
    800056a6:	8ff9                	and	a5,a5,a4
    800056a8:	e3d5                	bnez	a5,8000574c <sys_link+0xf0>
  begin_op();
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	c28080e7          	jalr	-984(ra) # 800042d2 <begin_op>
  if((ip = namei(old)) == 0){
    800056b2:	ed040513          	addi	a0,s0,-304
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	a0c080e7          	jalr	-1524(ra) # 800040c2 <namei>
    800056be:	84aa                	mv	s1,a0
    800056c0:	c15d                	beqz	a0,80005766 <sys_link+0x10a>
  ilock(ip);
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	276080e7          	jalr	630(ra) # 80003938 <ilock>
  if(ip->type == T_DIR){
    800056ca:	04449703          	lh	a4,68(s1)
    800056ce:	4785                	li	a5,1
    800056d0:	0af70163          	beq	a4,a5,80005772 <sys_link+0x116>
  ip->nlink++;
    800056d4:	04a4d783          	lhu	a5,74(s1)
    800056d8:	2785                	addiw	a5,a5,1
    800056da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056de:	8526                	mv	a0,s1
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	18e080e7          	jalr	398(ra) # 8000386e <iupdate>
  iunlock(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	310080e7          	jalr	784(ra) # 800039fa <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056f2:	fd040593          	addi	a1,s0,-48
    800056f6:	f5040513          	addi	a0,s0,-176
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	9e6080e7          	jalr	-1562(ra) # 800040e0 <nameiparent>
    80005702:	892a                	mv	s2,a0
    80005704:	c559                	beqz	a0,80005792 <sys_link+0x136>
  ilock(dp);
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	232080e7          	jalr	562(ra) # 80003938 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000570e:	00092703          	lw	a4,0(s2)
    80005712:	409c                	lw	a5,0(s1)
    80005714:	06f71a63          	bne	a4,a5,80005788 <sys_link+0x12c>
    80005718:	40d0                	lw	a2,4(s1)
    8000571a:	fd040593          	addi	a1,s0,-48
    8000571e:	854a                	mv	a0,s2
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	8e0080e7          	jalr	-1824(ra) # 80004000 <dirlink>
    80005728:	06054063          	bltz	a0,80005788 <sys_link+0x12c>
  iunlockput(dp);
    8000572c:	854a                	mv	a0,s2
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	448080e7          	jalr	1096(ra) # 80003b76 <iunlockput>
  iput(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	30e080e7          	jalr	782(ra) # 80003a46 <iput>
  end_op();
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	c12080e7          	jalr	-1006(ra) # 80004352 <end_op>
  return 0;
    80005748:	4781                	li	a5,0
    8000574a:	a8ad                	j	800057c4 <sys_link+0x168>
		printf("arguments: %s %s\n",old,new);
    8000574c:	f5040613          	addi	a2,s0,-176
    80005750:	ed040593          	addi	a1,s0,-304
    80005754:	00002517          	auipc	a0,0x2
    80005758:	30c50513          	addi	a0,a0,780 # 80007a60 <userret+0x9d0>
    8000575c:	ffffb097          	auipc	ra,0xffffb
    80005760:	e36080e7          	jalr	-458(ra) # 80000592 <printf>
    80005764:	b799                	j	800056aa <sys_link+0x4e>
    end_op();
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	bec080e7          	jalr	-1044(ra) # 80004352 <end_op>
    return -1;
    8000576e:	57fd                	li	a5,-1
    80005770:	a891                	j	800057c4 <sys_link+0x168>
    iunlockput(ip);
    80005772:	8526                	mv	a0,s1
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	402080e7          	jalr	1026(ra) # 80003b76 <iunlockput>
    end_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	bd6080e7          	jalr	-1066(ra) # 80004352 <end_op>
    return -1;
    80005784:	57fd                	li	a5,-1
    80005786:	a83d                	j	800057c4 <sys_link+0x168>
    iunlockput(dp);
    80005788:	854a                	mv	a0,s2
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	3ec080e7          	jalr	1004(ra) # 80003b76 <iunlockput>
  ilock(ip);
    80005792:	8526                	mv	a0,s1
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	1a4080e7          	jalr	420(ra) # 80003938 <ilock>
  ip->nlink--;
    8000579c:	04a4d783          	lhu	a5,74(s1)
    800057a0:	37fd                	addiw	a5,a5,-1
    800057a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	0c6080e7          	jalr	198(ra) # 8000386e <iupdate>
  iunlockput(ip);
    800057b0:	8526                	mv	a0,s1
    800057b2:	ffffe097          	auipc	ra,0xffffe
    800057b6:	3c4080e7          	jalr	964(ra) # 80003b76 <iunlockput>
  end_op();
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	b98080e7          	jalr	-1128(ra) # 80004352 <end_op>
  return -1;
    800057c2:	57fd                	li	a5,-1
}
    800057c4:	853e                	mv	a0,a5
    800057c6:	70b2                	ld	ra,296(sp)
    800057c8:	7412                	ld	s0,288(sp)
    800057ca:	64f2                	ld	s1,280(sp)
    800057cc:	6952                	ld	s2,272(sp)
    800057ce:	6155                	addi	sp,sp,304
    800057d0:	8082                	ret

00000000800057d2 <sys_unlink>:
{
    800057d2:	7151                	addi	sp,sp,-240
    800057d4:	f586                	sd	ra,232(sp)
    800057d6:	f1a2                	sd	s0,224(sp)
    800057d8:	eda6                	sd	s1,216(sp)
    800057da:	e9ca                	sd	s2,208(sp)
    800057dc:	e5ce                	sd	s3,200(sp)
    800057de:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057e0:	08000613          	li	a2,128
    800057e4:	f3040593          	addi	a1,s0,-208
    800057e8:	4501                	li	a0,0
    800057ea:	ffffd097          	auipc	ra,0xffffd
    800057ee:	0d0080e7          	jalr	208(ra) # 800028ba <argstr>
    800057f2:	1a054563          	bltz	a0,8000599c <sys_unlink+0x1ca>
	struct proc *pi = myproc();
    800057f6:	ffffc097          	auipc	ra,0xffffc
    800057fa:	038080e7          	jalr	56(ra) # 8000182e <myproc>
	if((h&i)==h){
    800057fe:	5d5c                	lw	a5,60(a0)
    80005800:	00040737          	lui	a4,0x40
    80005804:	8ff9                	and	a5,a5,a4
    80005806:	ebed                	bnez	a5,800058f8 <sys_unlink+0x126>
  begin_op();
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	aca080e7          	jalr	-1334(ra) # 800042d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005810:	fb040593          	addi	a1,s0,-80
    80005814:	f3040513          	addi	a0,s0,-208
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	8c8080e7          	jalr	-1848(ra) # 800040e0 <nameiparent>
    80005820:	84aa                	mv	s1,a0
    80005822:	c575                	beqz	a0,8000590e <sys_unlink+0x13c>
  ilock(dp);
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	114080e7          	jalr	276(ra) # 80003938 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000582c:	00002597          	auipc	a1,0x2
    80005830:	1d458593          	addi	a1,a1,468 # 80007a00 <userret+0x970>
    80005834:	fb040513          	addi	a0,s0,-80
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	59e080e7          	jalr	1438(ra) # 80003dd6 <namecmp>
    80005840:	16050563          	beqz	a0,800059aa <sys_unlink+0x1d8>
    80005844:	00002597          	auipc	a1,0x2
    80005848:	1c458593          	addi	a1,a1,452 # 80007a08 <userret+0x978>
    8000584c:	fb040513          	addi	a0,s0,-80
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	586080e7          	jalr	1414(ra) # 80003dd6 <namecmp>
    80005858:	14050963          	beqz	a0,800059aa <sys_unlink+0x1d8>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000585c:	f2c40613          	addi	a2,s0,-212
    80005860:	fb040593          	addi	a1,s0,-80
    80005864:	8526                	mv	a0,s1
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	58a080e7          	jalr	1418(ra) # 80003df0 <dirlookup>
    8000586e:	892a                	mv	s2,a0
    80005870:	12050d63          	beqz	a0,800059aa <sys_unlink+0x1d8>
  ilock(ip);
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	0c4080e7          	jalr	196(ra) # 80003938 <ilock>
  if(ip->nlink < 1)
    8000587c:	04a91783          	lh	a5,74(s2)
    80005880:	08f05d63          	blez	a5,8000591a <sys_unlink+0x148>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005884:	04491703          	lh	a4,68(s2)
    80005888:	4785                	li	a5,1
    8000588a:	0af70063          	beq	a4,a5,8000592a <sys_unlink+0x158>
  memset(&de, 0, sizeof(de));
    8000588e:	4641                	li	a2,16
    80005890:	4581                	li	a1,0
    80005892:	fc040513          	addi	a0,s0,-64
    80005896:	ffffb097          	auipc	ra,0xffffb
    8000589a:	2c4080e7          	jalr	708(ra) # 80000b5a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000589e:	4741                	li	a4,16
    800058a0:	f2c42683          	lw	a3,-212(s0)
    800058a4:	fc040613          	addi	a2,s0,-64
    800058a8:	4581                	li	a1,0
    800058aa:	8526                	mv	a0,s1
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	410080e7          	jalr	1040(ra) # 80003cbc <writei>
    800058b4:	47c1                	li	a5,16
    800058b6:	0cf51063          	bne	a0,a5,80005976 <sys_unlink+0x1a4>
  if(ip->type == T_DIR){
    800058ba:	04491703          	lh	a4,68(s2)
    800058be:	4785                	li	a5,1
    800058c0:	0cf70363          	beq	a4,a5,80005986 <sys_unlink+0x1b4>
  iunlockput(dp);
    800058c4:	8526                	mv	a0,s1
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	2b0080e7          	jalr	688(ra) # 80003b76 <iunlockput>
  ip->nlink--;
    800058ce:	04a95783          	lhu	a5,74(s2)
    800058d2:	37fd                	addiw	a5,a5,-1
    800058d4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058d8:	854a                	mv	a0,s2
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	f94080e7          	jalr	-108(ra) # 8000386e <iupdate>
  iunlockput(ip);
    800058e2:	854a                	mv	a0,s2
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	292080e7          	jalr	658(ra) # 80003b76 <iunlockput>
  end_op();
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	a66080e7          	jalr	-1434(ra) # 80004352 <end_op>
  return 0;
    800058f4:	4501                	li	a0,0
    800058f6:	a0e1                	j	800059be <sys_unlink+0x1ec>
		printf("arguments: %s\n",path);
    800058f8:	f3040593          	addi	a1,s0,-208
    800058fc:	00002517          	auipc	a0,0x2
    80005900:	ebc50513          	addi	a0,a0,-324 # 800077b8 <userret+0x728>
    80005904:	ffffb097          	auipc	ra,0xffffb
    80005908:	c8e080e7          	jalr	-882(ra) # 80000592 <printf>
    8000590c:	bdf5                	j	80005808 <sys_unlink+0x36>
    end_op();
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	a44080e7          	jalr	-1468(ra) # 80004352 <end_op>
    return -1;
    80005916:	557d                	li	a0,-1
    80005918:	a05d                	j	800059be <sys_unlink+0x1ec>
    panic("unlink: nlink < 1");
    8000591a:	00002517          	auipc	a0,0x2
    8000591e:	15e50513          	addi	a0,a0,350 # 80007a78 <userret+0x9e8>
    80005922:	ffffb097          	auipc	ra,0xffffb
    80005926:	c26080e7          	jalr	-986(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000592a:	04c92703          	lw	a4,76(s2)
    8000592e:	02000793          	li	a5,32
    80005932:	f4e7fee3          	bgeu	a5,a4,8000588e <sys_unlink+0xbc>
    80005936:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000593a:	4741                	li	a4,16
    8000593c:	86ce                	mv	a3,s3
    8000593e:	f1840613          	addi	a2,s0,-232
    80005942:	4581                	li	a1,0
    80005944:	854a                	mv	a0,s2
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	282080e7          	jalr	642(ra) # 80003bc8 <readi>
    8000594e:	47c1                	li	a5,16
    80005950:	00f51b63          	bne	a0,a5,80005966 <sys_unlink+0x194>
    if(de.inum != 0)
    80005954:	f1845783          	lhu	a5,-232(s0)
    80005958:	e7a1                	bnez	a5,800059a0 <sys_unlink+0x1ce>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000595a:	29c1                	addiw	s3,s3,16
    8000595c:	04c92783          	lw	a5,76(s2)
    80005960:	fcf9ede3          	bltu	s3,a5,8000593a <sys_unlink+0x168>
    80005964:	b72d                	j	8000588e <sys_unlink+0xbc>
      panic("isdirempty: readi");
    80005966:	00002517          	auipc	a0,0x2
    8000596a:	12a50513          	addi	a0,a0,298 # 80007a90 <userret+0xa00>
    8000596e:	ffffb097          	auipc	ra,0xffffb
    80005972:	bda080e7          	jalr	-1062(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005976:	00002517          	auipc	a0,0x2
    8000597a:	13250513          	addi	a0,a0,306 # 80007aa8 <userret+0xa18>
    8000597e:	ffffb097          	auipc	ra,0xffffb
    80005982:	bca080e7          	jalr	-1078(ra) # 80000548 <panic>
    dp->nlink--;
    80005986:	04a4d783          	lhu	a5,74(s1)
    8000598a:	37fd                	addiw	a5,a5,-1
    8000598c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005990:	8526                	mv	a0,s1
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	edc080e7          	jalr	-292(ra) # 8000386e <iupdate>
    8000599a:	b72d                	j	800058c4 <sys_unlink+0xf2>
    return -1;
    8000599c:	557d                	li	a0,-1
    8000599e:	a005                	j	800059be <sys_unlink+0x1ec>
    iunlockput(ip);
    800059a0:	854a                	mv	a0,s2
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	1d4080e7          	jalr	468(ra) # 80003b76 <iunlockput>
  iunlockput(dp);
    800059aa:	8526                	mv	a0,s1
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	1ca080e7          	jalr	458(ra) # 80003b76 <iunlockput>
  end_op();
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	99e080e7          	jalr	-1634(ra) # 80004352 <end_op>
  return -1;
    800059bc:	557d                	li	a0,-1
}
    800059be:	70ae                	ld	ra,232(sp)
    800059c0:	740e                	ld	s0,224(sp)
    800059c2:	64ee                	ld	s1,216(sp)
    800059c4:	694e                	ld	s2,208(sp)
    800059c6:	69ae                	ld	s3,200(sp)
    800059c8:	616d                	addi	sp,sp,240
    800059ca:	8082                	ret

00000000800059cc <sys_open>:

uint64
sys_open(void)
{
    800059cc:	7131                	addi	sp,sp,-192
    800059ce:	fd06                	sd	ra,184(sp)
    800059d0:	f922                	sd	s0,176(sp)
    800059d2:	f526                	sd	s1,168(sp)
    800059d4:	f14a                	sd	s2,160(sp)
    800059d6:	ed4e                	sd	s3,152(sp)
    800059d8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059da:	08000613          	li	a2,128
    800059de:	f5040593          	addi	a1,s0,-176
    800059e2:	4501                	li	a0,0
    800059e4:	ffffd097          	auipc	ra,0xffffd
    800059e8:	ed6080e7          	jalr	-298(ra) # 800028ba <argstr>
    return -1;
    800059ec:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059ee:	0c054063          	bltz	a0,80005aae <sys_open+0xe2>
    800059f2:	f4c40593          	addi	a1,s0,-180
    800059f6:	4505                	li	a0,1
    800059f8:	ffffd097          	auipc	ra,0xffffd
    800059fc:	e7e080e7          	jalr	-386(ra) # 80002876 <argint>
    80005a00:	0a054763          	bltz	a0,80005aae <sys_open+0xe2>
	int h=1<<15,i; 
	struct proc *pi = myproc();
    80005a04:	ffffc097          	auipc	ra,0xffffc
    80005a08:	e2a080e7          	jalr	-470(ra) # 8000182e <myproc>
	i=pi->tra;
	if((h&i)==h){
    80005a0c:	5d5c                	lw	a5,60(a0)
    80005a0e:	6721                	lui	a4,0x8
    80005a10:	8ff9                	and	a5,a5,a4
    80005a12:	e7d5                	bnez	a5,80005abe <sys_open+0xf2>
		printf("arguments: %s %d\n",path,omode);
	}
  begin_op();
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	8be080e7          	jalr	-1858(ra) # 800042d2 <begin_op>

  if(omode & O_CREATE){
    80005a1c:	f4c42783          	lw	a5,-180(s0)
    80005a20:	2007f793          	andi	a5,a5,512
    80005a24:	c3e1                	beqz	a5,80005ae4 <sys_open+0x118>
    ip = create(path, T_FILE, 0, 0);
    80005a26:	4681                	li	a3,0
    80005a28:	4601                	li	a2,0
    80005a2a:	4589                	li	a1,2
    80005a2c:	f5040513          	addi	a0,s0,-176
    80005a30:	00000097          	auipc	ra,0x0
    80005a34:	83c080e7          	jalr	-1988(ra) # 8000526c <create>
    80005a38:	892a                	mv	s2,a0
    if(ip == 0){
    80005a3a:	cd59                	beqz	a0,80005ad8 <sys_open+0x10c>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a3c:	04491703          	lh	a4,68(s2)
    80005a40:	478d                	li	a5,3
    80005a42:	00f71763          	bne	a4,a5,80005a50 <sys_open+0x84>
    80005a46:	04695703          	lhu	a4,70(s2)
    80005a4a:	47a5                	li	a5,9
    80005a4c:	0ee7e163          	bltu	a5,a4,80005b2e <sys_open+0x162>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	c98080e7          	jalr	-872(ra) # 800046e8 <filealloc>
    80005a58:	89aa                	mv	s3,a0
    80005a5a:	10050163          	beqz	a0,80005b5c <sys_open+0x190>
    80005a5e:	fffff097          	auipc	ra,0xfffff
    80005a62:	764080e7          	jalr	1892(ra) # 800051c2 <fdalloc>
    80005a66:	84aa                	mv	s1,a0
    80005a68:	0e054563          	bltz	a0,80005b52 <sys_open+0x186>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a6c:	04491703          	lh	a4,68(s2)
    80005a70:	478d                	li	a5,3
    80005a72:	0cf70963          	beq	a4,a5,80005b44 <sys_open+0x178>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a76:	4789                	li	a5,2
    80005a78:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a7c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a80:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a84:	f4c42783          	lw	a5,-180(s0)
    80005a88:	0017c713          	xori	a4,a5,1
    80005a8c:	8b05                	andi	a4,a4,1
    80005a8e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a92:	8b8d                	andi	a5,a5,3
    80005a94:	00f037b3          	snez	a5,a5
    80005a98:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005a9c:	854a                	mv	a0,s2
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	f5c080e7          	jalr	-164(ra) # 800039fa <iunlock>
  end_op();
    80005aa6:	fffff097          	auipc	ra,0xfffff
    80005aaa:	8ac080e7          	jalr	-1876(ra) # 80004352 <end_op>

  return fd;
}
    80005aae:	8526                	mv	a0,s1
    80005ab0:	70ea                	ld	ra,184(sp)
    80005ab2:	744a                	ld	s0,176(sp)
    80005ab4:	74aa                	ld	s1,168(sp)
    80005ab6:	790a                	ld	s2,160(sp)
    80005ab8:	69ea                	ld	s3,152(sp)
    80005aba:	6129                	addi	sp,sp,192
    80005abc:	8082                	ret
		printf("arguments: %s %d\n",path,omode);
    80005abe:	f4c42603          	lw	a2,-180(s0)
    80005ac2:	f5040593          	addi	a1,s0,-176
    80005ac6:	00002517          	auipc	a0,0x2
    80005aca:	ff250513          	addi	a0,a0,-14 # 80007ab8 <userret+0xa28>
    80005ace:	ffffb097          	auipc	ra,0xffffb
    80005ad2:	ac4080e7          	jalr	-1340(ra) # 80000592 <printf>
    80005ad6:	bf3d                	j	80005a14 <sys_open+0x48>
      end_op();
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	87a080e7          	jalr	-1926(ra) # 80004352 <end_op>
      return -1;
    80005ae0:	54fd                	li	s1,-1
    80005ae2:	b7f1                	j	80005aae <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005ae4:	f5040513          	addi	a0,s0,-176
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	5da080e7          	jalr	1498(ra) # 800040c2 <namei>
    80005af0:	892a                	mv	s2,a0
    80005af2:	c905                	beqz	a0,80005b22 <sys_open+0x156>
    ilock(ip);
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	e44080e7          	jalr	-444(ra) # 80003938 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005afc:	04491703          	lh	a4,68(s2)
    80005b00:	4785                	li	a5,1
    80005b02:	f2f71de3          	bne	a4,a5,80005a3c <sys_open+0x70>
    80005b06:	f4c42783          	lw	a5,-180(s0)
    80005b0a:	d3b9                	beqz	a5,80005a50 <sys_open+0x84>
      iunlockput(ip);
    80005b0c:	854a                	mv	a0,s2
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	068080e7          	jalr	104(ra) # 80003b76 <iunlockput>
      end_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	83c080e7          	jalr	-1988(ra) # 80004352 <end_op>
      return -1;
    80005b1e:	54fd                	li	s1,-1
    80005b20:	b779                	j	80005aae <sys_open+0xe2>
      end_op();
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	830080e7          	jalr	-2000(ra) # 80004352 <end_op>
      return -1;
    80005b2a:	54fd                	li	s1,-1
    80005b2c:	b749                	j	80005aae <sys_open+0xe2>
    iunlockput(ip);
    80005b2e:	854a                	mv	a0,s2
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	046080e7          	jalr	70(ra) # 80003b76 <iunlockput>
    end_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	81a080e7          	jalr	-2022(ra) # 80004352 <end_op>
    return -1;
    80005b40:	54fd                	li	s1,-1
    80005b42:	b7b5                	j	80005aae <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005b44:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b48:	04691783          	lh	a5,70(s2)
    80005b4c:	02f99223          	sh	a5,36(s3)
    80005b50:	bf05                	j	80005a80 <sys_open+0xb4>
      fileclose(f);
    80005b52:	854e                	mv	a0,s3
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	c50080e7          	jalr	-944(ra) # 800047a4 <fileclose>
    iunlockput(ip);
    80005b5c:	854a                	mv	a0,s2
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	018080e7          	jalr	24(ra) # 80003b76 <iunlockput>
    end_op();
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	7ec080e7          	jalr	2028(ra) # 80004352 <end_op>
    return -1;
    80005b6e:	54fd                	li	s1,-1
    80005b70:	bf3d                	j	80005aae <sys_open+0xe2>

0000000080005b72 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b72:	7135                	addi	sp,sp,-160
    80005b74:	ed06                	sd	ra,152(sp)
    80005b76:	e922                	sd	s0,144(sp)
    80005b78:	e526                	sd	s1,136(sp)
    80005b7a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  printf("Rishika Varma K\n");
    80005b7c:	00002517          	auipc	a0,0x2
    80005b80:	f5450513          	addi	a0,a0,-172 # 80007ad0 <userret+0xa40>
    80005b84:	ffffb097          	auipc	ra,0xffffb
    80005b88:	a0e080e7          	jalr	-1522(ra) # 80000592 <printf>
  begin_op();
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	746080e7          	jalr	1862(ra) # 800042d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b94:	08000613          	li	a2,128
    80005b98:	f6040593          	addi	a1,s0,-160
    80005b9c:	4501                	li	a0,0
    80005b9e:	ffffd097          	auipc	ra,0xffffd
    80005ba2:	d1c080e7          	jalr	-740(ra) # 800028ba <argstr>
    80005ba6:	04054d63          	bltz	a0,80005c00 <sys_mkdir+0x8e>
    80005baa:	4681                	li	a3,0
    80005bac:	4601                	li	a2,0
    80005bae:	4585                	li	a1,1
    80005bb0:	f6040513          	addi	a0,s0,-160
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	6b8080e7          	jalr	1720(ra) # 8000526c <create>
    80005bbc:	84aa                	mv	s1,a0
    80005bbe:	c129                	beqz	a0,80005c00 <sys_mkdir+0x8e>
    end_op();
    return -1;
  }
	int h=1<<20,i; 
	struct proc *pi = myproc();
    80005bc0:	ffffc097          	auipc	ra,0xffffc
    80005bc4:	c6e080e7          	jalr	-914(ra) # 8000182e <myproc>
	i=pi->tra;
	if((h&i)==h){
    80005bc8:	5d5c                	lw	a5,60(a0)
    80005bca:	00100737          	lui	a4,0x100
    80005bce:	8ff9                	and	a5,a5,a4
    80005bd0:	ef95                	bnez	a5,80005c0c <sys_mkdir+0x9a>
		printf("arguments: %s\n",path);
	}
  iunlockput(ip);
    80005bd2:	8526                	mv	a0,s1
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	fa2080e7          	jalr	-94(ra) # 80003b76 <iunlockput>
  end_op();
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	776080e7          	jalr	1910(ra) # 80004352 <end_op>
  printf("CS18B045\n");
    80005be4:	00002517          	auipc	a0,0x2
    80005be8:	f0450513          	addi	a0,a0,-252 # 80007ae8 <userret+0xa58>
    80005bec:	ffffb097          	auipc	ra,0xffffb
    80005bf0:	9a6080e7          	jalr	-1626(ra) # 80000592 <printf>
  return 0;
    80005bf4:	4501                	li	a0,0
}
    80005bf6:	60ea                	ld	ra,152(sp)
    80005bf8:	644a                	ld	s0,144(sp)
    80005bfa:	64aa                	ld	s1,136(sp)
    80005bfc:	610d                	addi	sp,sp,160
    80005bfe:	8082                	ret
    end_op();
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	752080e7          	jalr	1874(ra) # 80004352 <end_op>
    return -1;
    80005c08:	557d                	li	a0,-1
    80005c0a:	b7f5                	j	80005bf6 <sys_mkdir+0x84>
		printf("arguments: %s\n",path);
    80005c0c:	f6040593          	addi	a1,s0,-160
    80005c10:	00002517          	auipc	a0,0x2
    80005c14:	ba850513          	addi	a0,a0,-1112 # 800077b8 <userret+0x728>
    80005c18:	ffffb097          	auipc	ra,0xffffb
    80005c1c:	97a080e7          	jalr	-1670(ra) # 80000592 <printf>
    80005c20:	bf4d                	j	80005bd2 <sys_mkdir+0x60>

0000000080005c22 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c22:	7171                	addi	sp,sp,-176
    80005c24:	f506                	sd	ra,168(sp)
    80005c26:	f122                	sd	s0,160(sp)
    80005c28:	ed26                	sd	s1,152(sp)
    80005c2a:	1900                	addi	s0,sp,176
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	6a6080e7          	jalr	1702(ra) # 800042d2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c34:	08000613          	li	a2,128
    80005c38:	f6040593          	addi	a1,s0,-160
    80005c3c:	4501                	li	a0,0
    80005c3e:	ffffd097          	auipc	ra,0xffffd
    80005c42:	c7c080e7          	jalr	-900(ra) # 800028ba <argstr>
    80005c46:	06054563          	bltz	a0,80005cb0 <sys_mknod+0x8e>
     argint(1, &major) < 0 ||
    80005c4a:	f5c40593          	addi	a1,s0,-164
    80005c4e:	4505                	li	a0,1
    80005c50:	ffffd097          	auipc	ra,0xffffd
    80005c54:	c26080e7          	jalr	-986(ra) # 80002876 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c58:	04054c63          	bltz	a0,80005cb0 <sys_mknod+0x8e>
     argint(2, &minor) < 0 ||
    80005c5c:	f5840593          	addi	a1,s0,-168
    80005c60:	4509                	li	a0,2
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	c14080e7          	jalr	-1004(ra) # 80002876 <argint>
     argint(1, &major) < 0 ||
    80005c6a:	04054363          	bltz	a0,80005cb0 <sys_mknod+0x8e>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c6e:	f5841683          	lh	a3,-168(s0)
    80005c72:	f5c41603          	lh	a2,-164(s0)
    80005c76:	458d                	li	a1,3
    80005c78:	f6040513          	addi	a0,s0,-160
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	5f0080e7          	jalr	1520(ra) # 8000526c <create>
    80005c84:	84aa                	mv	s1,a0
     argint(2, &minor) < 0 ||
    80005c86:	c50d                	beqz	a0,80005cb0 <sys_mknod+0x8e>
    end_op();
    return -1;
  }
	int h=1<<17,i; 
	struct proc *pi = myproc();
    80005c88:	ffffc097          	auipc	ra,0xffffc
    80005c8c:	ba6080e7          	jalr	-1114(ra) # 8000182e <myproc>
	i=pi->tra;
	if((h&i)==h){
    80005c90:	5d5c                	lw	a5,60(a0)
    80005c92:	00020737          	lui	a4,0x20
    80005c96:	8ff9                	and	a5,a5,a4
    80005c98:	e795                	bnez	a5,80005cc4 <sys_mknod+0xa2>
		printf("arguments: %s %d %d\n",path,major,minor);
	}
  iunlockput(ip);
    80005c9a:	8526                	mv	a0,s1
    80005c9c:	ffffe097          	auipc	ra,0xffffe
    80005ca0:	eda080e7          	jalr	-294(ra) # 80003b76 <iunlockput>
  end_op();
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	6ae080e7          	jalr	1710(ra) # 80004352 <end_op>
  return 0;
    80005cac:	4501                	li	a0,0
    80005cae:	a031                	j	80005cba <sys_mknod+0x98>
    end_op();
    80005cb0:	ffffe097          	auipc	ra,0xffffe
    80005cb4:	6a2080e7          	jalr	1698(ra) # 80004352 <end_op>
    return -1;
    80005cb8:	557d                	li	a0,-1
}
    80005cba:	70aa                	ld	ra,168(sp)
    80005cbc:	740a                	ld	s0,160(sp)
    80005cbe:	64ea                	ld	s1,152(sp)
    80005cc0:	614d                	addi	sp,sp,176
    80005cc2:	8082                	ret
		printf("arguments: %s %d %d\n",path,major,minor);
    80005cc4:	f5842683          	lw	a3,-168(s0)
    80005cc8:	f5c42603          	lw	a2,-164(s0)
    80005ccc:	f6040593          	addi	a1,s0,-160
    80005cd0:	00002517          	auipc	a0,0x2
    80005cd4:	e2850513          	addi	a0,a0,-472 # 80007af8 <userret+0xa68>
    80005cd8:	ffffb097          	auipc	ra,0xffffb
    80005cdc:	8ba080e7          	jalr	-1862(ra) # 80000592 <printf>
    80005ce0:	bf6d                	j	80005c9a <sys_mknod+0x78>

0000000080005ce2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ce2:	7135                	addi	sp,sp,-160
    80005ce4:	ed06                	sd	ra,152(sp)
    80005ce6:	e922                	sd	s0,144(sp)
    80005ce8:	e526                	sd	s1,136(sp)
    80005cea:	e14a                	sd	s2,128(sp)
    80005cec:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cee:	ffffc097          	auipc	ra,0xffffc
    80005cf2:	b40080e7          	jalr	-1216(ra) # 8000182e <myproc>
    80005cf6:	892a                	mv	s2,a0
  
  begin_op();
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	5da080e7          	jalr	1498(ra) # 800042d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d00:	08000613          	li	a2,128
    80005d04:	f6040593          	addi	a1,s0,-160
    80005d08:	4501                	li	a0,0
    80005d0a:	ffffd097          	auipc	ra,0xffffd
    80005d0e:	bb0080e7          	jalr	-1104(ra) # 800028ba <argstr>
    80005d12:	06054163          	bltz	a0,80005d74 <sys_chdir+0x92>
    80005d16:	f6040513          	addi	a0,s0,-160
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	3a8080e7          	jalr	936(ra) # 800040c2 <namei>
    80005d22:	84aa                	mv	s1,a0
    80005d24:	c921                	beqz	a0,80005d74 <sys_chdir+0x92>
    end_op();
    return -1;
  }
	int h=1<<9,i; 
	i=p->tra;
	if((h&i)==h){
    80005d26:	03c92783          	lw	a5,60(s2)
    80005d2a:	2007f793          	andi	a5,a5,512
    80005d2e:	eba9                	bnez	a5,80005d80 <sys_chdir+0x9e>
		printf("arguments: %s\n",path);
	}
  ilock(ip);
    80005d30:	8526                	mv	a0,s1
    80005d32:	ffffe097          	auipc	ra,0xffffe
    80005d36:	c06080e7          	jalr	-1018(ra) # 80003938 <ilock>
  if(ip->type != T_DIR){
    80005d3a:	04449703          	lh	a4,68(s1)
    80005d3e:	4785                	li	a5,1
    80005d40:	04f71b63          	bne	a4,a5,80005d96 <sys_chdir+0xb4>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d44:	8526                	mv	a0,s1
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	cb4080e7          	jalr	-844(ra) # 800039fa <iunlock>
  iput(p->cwd);
    80005d4e:	15093503          	ld	a0,336(s2)
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	cf4080e7          	jalr	-780(ra) # 80003a46 <iput>
  end_op();
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	5f8080e7          	jalr	1528(ra) # 80004352 <end_op>
  p->cwd = ip;
    80005d62:	14993823          	sd	s1,336(s2)
  return 0;
    80005d66:	4501                	li	a0,0
}
    80005d68:	60ea                	ld	ra,152(sp)
    80005d6a:	644a                	ld	s0,144(sp)
    80005d6c:	64aa                	ld	s1,136(sp)
    80005d6e:	690a                	ld	s2,128(sp)
    80005d70:	610d                	addi	sp,sp,160
    80005d72:	8082                	ret
    end_op();
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	5de080e7          	jalr	1502(ra) # 80004352 <end_op>
    return -1;
    80005d7c:	557d                	li	a0,-1
    80005d7e:	b7ed                	j	80005d68 <sys_chdir+0x86>
		printf("arguments: %s\n",path);
    80005d80:	f6040593          	addi	a1,s0,-160
    80005d84:	00002517          	auipc	a0,0x2
    80005d88:	a3450513          	addi	a0,a0,-1484 # 800077b8 <userret+0x728>
    80005d8c:	ffffb097          	auipc	ra,0xffffb
    80005d90:	806080e7          	jalr	-2042(ra) # 80000592 <printf>
    80005d94:	bf71                	j	80005d30 <sys_chdir+0x4e>
    iunlockput(ip);
    80005d96:	8526                	mv	a0,s1
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	dde080e7          	jalr	-546(ra) # 80003b76 <iunlockput>
    end_op();
    80005da0:	ffffe097          	auipc	ra,0xffffe
    80005da4:	5b2080e7          	jalr	1458(ra) # 80004352 <end_op>
    return -1;
    80005da8:	557d                	li	a0,-1
    80005daa:	bf7d                	j	80005d68 <sys_chdir+0x86>

0000000080005dac <sys_exec>:

uint64
sys_exec(void)
{
    80005dac:	7145                	addi	sp,sp,-464
    80005dae:	e786                	sd	ra,456(sp)
    80005db0:	e3a2                	sd	s0,448(sp)
    80005db2:	ff26                	sd	s1,440(sp)
    80005db4:	fb4a                	sd	s2,432(sp)
    80005db6:	f74e                	sd	s3,424(sp)
    80005db8:	f352                	sd	s4,416(sp)
    80005dba:	ef56                	sd	s5,408(sp)
    80005dbc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005dbe:	08000613          	li	a2,128
    80005dc2:	f4040593          	addi	a1,s0,-192
    80005dc6:	4501                	li	a0,0
    80005dc8:	ffffd097          	auipc	ra,0xffffd
    80005dcc:	af2080e7          	jalr	-1294(ra) # 800028ba <argstr>
    80005dd0:	10054b63          	bltz	a0,80005ee6 <sys_exec+0x13a>
    80005dd4:	e3840593          	addi	a1,s0,-456
    80005dd8:	4505                	li	a0,1
    80005dda:	ffffd097          	auipc	ra,0xffffd
    80005dde:	abe080e7          	jalr	-1346(ra) # 80002898 <argaddr>
    80005de2:	10054c63          	bltz	a0,80005efa <sys_exec+0x14e>
    return -1;
  }
	int h=1<<7,li; 
	struct proc *pi = myproc();
    80005de6:	ffffc097          	auipc	ra,0xffffc
    80005dea:	a48080e7          	jalr	-1464(ra) # 8000182e <myproc>
	li=pi->tra;
	if((h&li)==h){
    80005dee:	5d5c                	lw	a5,60(a0)
    80005df0:	0807f793          	andi	a5,a5,128
    80005df4:	e7c9                	bnez	a5,80005e7e <sys_exec+0xd2>
		printf("arguments: %s %p\n",path,uargv);
	}
  memset(argv, 0, sizeof(argv));
    80005df6:	10000613          	li	a2,256
    80005dfa:	4581                	li	a1,0
    80005dfc:	e4040513          	addi	a0,s0,-448
    80005e00:	ffffb097          	auipc	ra,0xffffb
    80005e04:	d5a080e7          	jalr	-678(ra) # 80000b5a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e08:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e0c:	89ca                	mv	s3,s2
    80005e0e:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005e10:	02000a13          	li	s4,32
    80005e14:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e18:	00349793          	slli	a5,s1,0x3
    80005e1c:	e3040593          	addi	a1,s0,-464
    80005e20:	e3843503          	ld	a0,-456(s0)
    80005e24:	953e                	add	a0,a0,a5
    80005e26:	ffffd097          	auipc	ra,0xffffd
    80005e2a:	9b6080e7          	jalr	-1610(ra) # 800027dc <fetchaddr>
    80005e2e:	02054a63          	bltz	a0,80005e62 <sys_exec+0xb6>
      goto bad;
    }
    if(uarg == 0){
    80005e32:	e3043783          	ld	a5,-464(s0)
    80005e36:	c3ad                	beqz	a5,80005e98 <sys_exec+0xec>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e38:	ffffb097          	auipc	ra,0xffffb
    80005e3c:	b18080e7          	jalr	-1256(ra) # 80000950 <kalloc>
    80005e40:	85aa                	mv	a1,a0
    80005e42:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e46:	c551                	beqz	a0,80005ed2 <sys_exec+0x126>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005e48:	6605                	lui	a2,0x1
    80005e4a:	e3043503          	ld	a0,-464(s0)
    80005e4e:	ffffd097          	auipc	ra,0xffffd
    80005e52:	9e0080e7          	jalr	-1568(ra) # 8000282e <fetchstr>
    80005e56:	00054663          	bltz	a0,80005e62 <sys_exec+0xb6>
    if(i >= NELEM(argv)){
    80005e5a:	0485                	addi	s1,s1,1
    80005e5c:	09a1                	addi	s3,s3,8
    80005e5e:	fb449be3          	bne	s1,s4,80005e14 <sys_exec+0x68>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e62:	10090493          	addi	s1,s2,256
    80005e66:	00093503          	ld	a0,0(s2)
    80005e6a:	cd25                	beqz	a0,80005ee2 <sys_exec+0x136>
    kfree(argv[i]);
    80005e6c:	ffffb097          	auipc	ra,0xffffb
    80005e70:	9e8080e7          	jalr	-1560(ra) # 80000854 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e74:	0921                	addi	s2,s2,8
    80005e76:	fe9918e3          	bne	s2,s1,80005e66 <sys_exec+0xba>
  return -1;
    80005e7a:	557d                	li	a0,-1
    80005e7c:	a0b5                	j	80005ee8 <sys_exec+0x13c>
		printf("arguments: %s %p\n",path,uargv);
    80005e7e:	e3843603          	ld	a2,-456(s0)
    80005e82:	f4040593          	addi	a1,s0,-192
    80005e86:	00002517          	auipc	a0,0x2
    80005e8a:	c8a50513          	addi	a0,a0,-886 # 80007b10 <userret+0xa80>
    80005e8e:	ffffa097          	auipc	ra,0xffffa
    80005e92:	704080e7          	jalr	1796(ra) # 80000592 <printf>
    80005e96:	b785                	j	80005df6 <sys_exec+0x4a>
      argv[i] = 0;
    80005e98:	0a8e                	slli	s5,s5,0x3
    80005e9a:	fc040793          	addi	a5,s0,-64
    80005e9e:	9abe                	add	s5,s5,a5
    80005ea0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ea4:	e4040593          	addi	a1,s0,-448
    80005ea8:	f4040513          	addi	a0,s0,-192
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	f92080e7          	jalr	-110(ra) # 80004e3e <exec>
    80005eb4:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb6:	10090993          	addi	s3,s2,256
    80005eba:	00093503          	ld	a0,0(s2)
    80005ebe:	c901                	beqz	a0,80005ece <sys_exec+0x122>
    kfree(argv[i]);
    80005ec0:	ffffb097          	auipc	ra,0xffffb
    80005ec4:	994080e7          	jalr	-1644(ra) # 80000854 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ec8:	0921                	addi	s2,s2,8
    80005eca:	ff3918e3          	bne	s2,s3,80005eba <sys_exec+0x10e>
  return ret;
    80005ece:	8526                	mv	a0,s1
    80005ed0:	a821                	j	80005ee8 <sys_exec+0x13c>
      panic("sys_exec kalloc");
    80005ed2:	00002517          	auipc	a0,0x2
    80005ed6:	c5650513          	addi	a0,a0,-938 # 80007b28 <userret+0xa98>
    80005eda:	ffffa097          	auipc	ra,0xffffa
    80005ede:	66e080e7          	jalr	1646(ra) # 80000548 <panic>
  return -1;
    80005ee2:	557d                	li	a0,-1
    80005ee4:	a011                	j	80005ee8 <sys_exec+0x13c>
    return -1;
    80005ee6:	557d                	li	a0,-1
}
    80005ee8:	60be                	ld	ra,456(sp)
    80005eea:	641e                	ld	s0,448(sp)
    80005eec:	74fa                	ld	s1,440(sp)
    80005eee:	795a                	ld	s2,432(sp)
    80005ef0:	79ba                	ld	s3,424(sp)
    80005ef2:	7a1a                	ld	s4,416(sp)
    80005ef4:	6afa                	ld	s5,408(sp)
    80005ef6:	6179                	addi	sp,sp,464
    80005ef8:	8082                	ret
    return -1;
    80005efa:	557d                	li	a0,-1
    80005efc:	b7f5                	j	80005ee8 <sys_exec+0x13c>

0000000080005efe <sys_pipe>:

uint64
sys_pipe(void)
{
    80005efe:	7139                	addi	sp,sp,-64
    80005f00:	fc06                	sd	ra,56(sp)
    80005f02:	f822                	sd	s0,48(sp)
    80005f04:	f426                	sd	s1,40(sp)
    80005f06:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f08:	ffffc097          	auipc	ra,0xffffc
    80005f0c:	926080e7          	jalr	-1754(ra) # 8000182e <myproc>
    80005f10:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005f12:	fd840593          	addi	a1,s0,-40
    80005f16:	4501                	li	a0,0
    80005f18:	ffffd097          	auipc	ra,0xffffd
    80005f1c:	980080e7          	jalr	-1664(ra) # 80002898 <argaddr>
    80005f20:	10054363          	bltz	a0,80006026 <sys_pipe+0x128>
    return -1;
	int h=1<<4,i; 
	i=p->tra;
	if((h&i)==h){
    80005f24:	5cdc                	lw	a5,60(s1)
    80005f26:	8bc1                	andi	a5,a5,16
    80005f28:	ebc5                	bnez	a5,80005fd8 <sys_pipe+0xda>
		printf("arguments: %p\n",fdarray);
	}
  if(pipealloc(&rf, &wf) < 0)
    80005f2a:	fc840593          	addi	a1,s0,-56
    80005f2e:	fd040513          	addi	a0,s0,-48
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	bc8080e7          	jalr	-1080(ra) # 80004afa <pipealloc>
    return -1;
    80005f3a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f3c:	0c054f63          	bltz	a0,8000601a <sys_pipe+0x11c>
	
  fd0 = -1;
    80005f40:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f44:	fd043503          	ld	a0,-48(s0)
    80005f48:	fffff097          	auipc	ra,0xfffff
    80005f4c:	27a080e7          	jalr	634(ra) # 800051c2 <fdalloc>
    80005f50:	fca42223          	sw	a0,-60(s0)
    80005f54:	0a054663          	bltz	a0,80006000 <sys_pipe+0x102>
    80005f58:	fc843503          	ld	a0,-56(s0)
    80005f5c:	fffff097          	auipc	ra,0xfffff
    80005f60:	266080e7          	jalr	614(ra) # 800051c2 <fdalloc>
    80005f64:	fca42023          	sw	a0,-64(s0)
    80005f68:	08054363          	bltz	a0,80005fee <sys_pipe+0xf0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f6c:	4691                	li	a3,4
    80005f6e:	fc440613          	addi	a2,s0,-60
    80005f72:	fd843583          	ld	a1,-40(s0)
    80005f76:	68a8                	ld	a0,80(s1)
    80005f78:	ffffb097          	auipc	ra,0xffffb
    80005f7c:	5a8080e7          	jalr	1448(ra) # 80001520 <copyout>
    80005f80:	02054063          	bltz	a0,80005fa0 <sys_pipe+0xa2>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f84:	4691                	li	a3,4
    80005f86:	fc040613          	addi	a2,s0,-64
    80005f8a:	fd843583          	ld	a1,-40(s0)
    80005f8e:	0591                	addi	a1,a1,4
    80005f90:	68a8                	ld	a0,80(s1)
    80005f92:	ffffb097          	auipc	ra,0xffffb
    80005f96:	58e080e7          	jalr	1422(ra) # 80001520 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f9a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f9c:	06055f63          	bgez	a0,8000601a <sys_pipe+0x11c>
    p->ofile[fd0] = 0;
    80005fa0:	fc442783          	lw	a5,-60(s0)
    80005fa4:	07e9                	addi	a5,a5,26
    80005fa6:	078e                	slli	a5,a5,0x3
    80005fa8:	97a6                	add	a5,a5,s1
    80005faa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fae:	fc042503          	lw	a0,-64(s0)
    80005fb2:	0569                	addi	a0,a0,26
    80005fb4:	050e                	slli	a0,a0,0x3
    80005fb6:	94aa                	add	s1,s1,a0
    80005fb8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fbc:	fd043503          	ld	a0,-48(s0)
    80005fc0:	ffffe097          	auipc	ra,0xffffe
    80005fc4:	7e4080e7          	jalr	2020(ra) # 800047a4 <fileclose>
    fileclose(wf);
    80005fc8:	fc843503          	ld	a0,-56(s0)
    80005fcc:	ffffe097          	auipc	ra,0xffffe
    80005fd0:	7d8080e7          	jalr	2008(ra) # 800047a4 <fileclose>
    return -1;
    80005fd4:	57fd                	li	a5,-1
    80005fd6:	a091                	j	8000601a <sys_pipe+0x11c>
		printf("arguments: %p\n",fdarray);
    80005fd8:	fd843583          	ld	a1,-40(s0)
    80005fdc:	00001517          	auipc	a0,0x1
    80005fe0:	7cc50513          	addi	a0,a0,1996 # 800077a8 <userret+0x718>
    80005fe4:	ffffa097          	auipc	ra,0xffffa
    80005fe8:	5ae080e7          	jalr	1454(ra) # 80000592 <printf>
    80005fec:	bf3d                	j	80005f2a <sys_pipe+0x2c>
    if(fd0 >= 0)
    80005fee:	fc442783          	lw	a5,-60(s0)
    80005ff2:	0007c763          	bltz	a5,80006000 <sys_pipe+0x102>
      p->ofile[fd0] = 0;
    80005ff6:	07e9                	addi	a5,a5,26
    80005ff8:	078e                	slli	a5,a5,0x3
    80005ffa:	94be                	add	s1,s1,a5
    80005ffc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006000:	fd043503          	ld	a0,-48(s0)
    80006004:	ffffe097          	auipc	ra,0xffffe
    80006008:	7a0080e7          	jalr	1952(ra) # 800047a4 <fileclose>
    fileclose(wf);
    8000600c:	fc843503          	ld	a0,-56(s0)
    80006010:	ffffe097          	auipc	ra,0xffffe
    80006014:	794080e7          	jalr	1940(ra) # 800047a4 <fileclose>
    return -1;
    80006018:	57fd                	li	a5,-1
}
    8000601a:	853e                	mv	a0,a5
    8000601c:	70e2                	ld	ra,56(sp)
    8000601e:	7442                	ld	s0,48(sp)
    80006020:	74a2                	ld	s1,40(sp)
    80006022:	6121                	addi	sp,sp,64
    80006024:	8082                	ret
    return -1;
    80006026:	57fd                	li	a5,-1
    80006028:	bfcd                	j	8000601a <sys_pipe+0x11c>
    8000602a:	0000                	unimp
    8000602c:	0000                	unimp
	...

0000000080006030 <kernelvec>:
    80006030:	7111                	addi	sp,sp,-256
    80006032:	e006                	sd	ra,0(sp)
    80006034:	e40a                	sd	sp,8(sp)
    80006036:	e80e                	sd	gp,16(sp)
    80006038:	ec12                	sd	tp,24(sp)
    8000603a:	f016                	sd	t0,32(sp)
    8000603c:	f41a                	sd	t1,40(sp)
    8000603e:	f81e                	sd	t2,48(sp)
    80006040:	fc22                	sd	s0,56(sp)
    80006042:	e0a6                	sd	s1,64(sp)
    80006044:	e4aa                	sd	a0,72(sp)
    80006046:	e8ae                	sd	a1,80(sp)
    80006048:	ecb2                	sd	a2,88(sp)
    8000604a:	f0b6                	sd	a3,96(sp)
    8000604c:	f4ba                	sd	a4,104(sp)
    8000604e:	f8be                	sd	a5,112(sp)
    80006050:	fcc2                	sd	a6,120(sp)
    80006052:	e146                	sd	a7,128(sp)
    80006054:	e54a                	sd	s2,136(sp)
    80006056:	e94e                	sd	s3,144(sp)
    80006058:	ed52                	sd	s4,152(sp)
    8000605a:	f156                	sd	s5,160(sp)
    8000605c:	f55a                	sd	s6,168(sp)
    8000605e:	f95e                	sd	s7,176(sp)
    80006060:	fd62                	sd	s8,184(sp)
    80006062:	e1e6                	sd	s9,192(sp)
    80006064:	e5ea                	sd	s10,200(sp)
    80006066:	e9ee                	sd	s11,208(sp)
    80006068:	edf2                	sd	t3,216(sp)
    8000606a:	f1f6                	sd	t4,224(sp)
    8000606c:	f5fa                	sd	t5,232(sp)
    8000606e:	f9fe                	sd	t6,240(sp)
    80006070:	e38fc0ef          	jal	ra,800026a8 <kerneltrap>
    80006074:	6082                	ld	ra,0(sp)
    80006076:	6122                	ld	sp,8(sp)
    80006078:	61c2                	ld	gp,16(sp)
    8000607a:	7282                	ld	t0,32(sp)
    8000607c:	7322                	ld	t1,40(sp)
    8000607e:	73c2                	ld	t2,48(sp)
    80006080:	7462                	ld	s0,56(sp)
    80006082:	6486                	ld	s1,64(sp)
    80006084:	6526                	ld	a0,72(sp)
    80006086:	65c6                	ld	a1,80(sp)
    80006088:	6666                	ld	a2,88(sp)
    8000608a:	7686                	ld	a3,96(sp)
    8000608c:	7726                	ld	a4,104(sp)
    8000608e:	77c6                	ld	a5,112(sp)
    80006090:	7866                	ld	a6,120(sp)
    80006092:	688a                	ld	a7,128(sp)
    80006094:	692a                	ld	s2,136(sp)
    80006096:	69ca                	ld	s3,144(sp)
    80006098:	6a6a                	ld	s4,152(sp)
    8000609a:	7a8a                	ld	s5,160(sp)
    8000609c:	7b2a                	ld	s6,168(sp)
    8000609e:	7bca                	ld	s7,176(sp)
    800060a0:	7c6a                	ld	s8,184(sp)
    800060a2:	6c8e                	ld	s9,192(sp)
    800060a4:	6d2e                	ld	s10,200(sp)
    800060a6:	6dce                	ld	s11,208(sp)
    800060a8:	6e6e                	ld	t3,216(sp)
    800060aa:	7e8e                	ld	t4,224(sp)
    800060ac:	7f2e                	ld	t5,232(sp)
    800060ae:	7fce                	ld	t6,240(sp)
    800060b0:	6111                	addi	sp,sp,256
    800060b2:	10200073          	sret
    800060b6:	00000013          	nop
    800060ba:	00000013          	nop
    800060be:	0001                	nop

00000000800060c0 <timervec>:
    800060c0:	34051573          	csrrw	a0,mscratch,a0
    800060c4:	e10c                	sd	a1,0(a0)
    800060c6:	e510                	sd	a2,8(a0)
    800060c8:	e914                	sd	a3,16(a0)
    800060ca:	710c                	ld	a1,32(a0)
    800060cc:	7510                	ld	a2,40(a0)
    800060ce:	6194                	ld	a3,0(a1)
    800060d0:	96b2                	add	a3,a3,a2
    800060d2:	e194                	sd	a3,0(a1)
    800060d4:	4589                	li	a1,2
    800060d6:	14459073          	csrw	sip,a1
    800060da:	6914                	ld	a3,16(a0)
    800060dc:	6510                	ld	a2,8(a0)
    800060de:	610c                	ld	a1,0(a0)
    800060e0:	34051573          	csrrw	a0,mscratch,a0
    800060e4:	30200073          	mret
	...

00000000800060ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060ea:	1141                	addi	sp,sp,-16
    800060ec:	e422                	sd	s0,8(sp)
    800060ee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060f0:	0c0007b7          	lui	a5,0xc000
    800060f4:	4705                	li	a4,1
    800060f6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060f8:	c3d8                	sw	a4,4(a5)
}
    800060fa:	6422                	ld	s0,8(sp)
    800060fc:	0141                	addi	sp,sp,16
    800060fe:	8082                	ret

0000000080006100 <plicinithart>:

void
plicinithart(void)
{
    80006100:	1141                	addi	sp,sp,-16
    80006102:	e406                	sd	ra,8(sp)
    80006104:	e022                	sd	s0,0(sp)
    80006106:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006108:	ffffb097          	auipc	ra,0xffffb
    8000610c:	6fa080e7          	jalr	1786(ra) # 80001802 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006110:	0085171b          	slliw	a4,a0,0x8
    80006114:	0c0027b7          	lui	a5,0xc002
    80006118:	97ba                	add	a5,a5,a4
    8000611a:	40200713          	li	a4,1026
    8000611e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006122:	00d5151b          	slliw	a0,a0,0xd
    80006126:	0c2017b7          	lui	a5,0xc201
    8000612a:	953e                	add	a0,a0,a5
    8000612c:	00052023          	sw	zero,0(a0)
}
    80006130:	60a2                	ld	ra,8(sp)
    80006132:	6402                	ld	s0,0(sp)
    80006134:	0141                	addi	sp,sp,16
    80006136:	8082                	ret

0000000080006138 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80006138:	1141                	addi	sp,sp,-16
    8000613a:	e422                	sd	s0,8(sp)
    8000613c:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    8000613e:	0c0017b7          	lui	a5,0xc001
    80006142:	6388                	ld	a0,0(a5)
    80006144:	6422                	ld	s0,8(sp)
    80006146:	0141                	addi	sp,sp,16
    80006148:	8082                	ret

000000008000614a <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000614a:	1141                	addi	sp,sp,-16
    8000614c:	e406                	sd	ra,8(sp)
    8000614e:	e022                	sd	s0,0(sp)
    80006150:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006152:	ffffb097          	auipc	ra,0xffffb
    80006156:	6b0080e7          	jalr	1712(ra) # 80001802 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000615a:	00d5179b          	slliw	a5,a0,0xd
    8000615e:	0c201537          	lui	a0,0xc201
    80006162:	953e                	add	a0,a0,a5
  return irq;
}
    80006164:	4148                	lw	a0,4(a0)
    80006166:	60a2                	ld	ra,8(sp)
    80006168:	6402                	ld	s0,0(sp)
    8000616a:	0141                	addi	sp,sp,16
    8000616c:	8082                	ret

000000008000616e <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000616e:	1101                	addi	sp,sp,-32
    80006170:	ec06                	sd	ra,24(sp)
    80006172:	e822                	sd	s0,16(sp)
    80006174:	e426                	sd	s1,8(sp)
    80006176:	1000                	addi	s0,sp,32
    80006178:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000617a:	ffffb097          	auipc	ra,0xffffb
    8000617e:	688080e7          	jalr	1672(ra) # 80001802 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006182:	00d5151b          	slliw	a0,a0,0xd
    80006186:	0c2017b7          	lui	a5,0xc201
    8000618a:	97aa                	add	a5,a5,a0
    8000618c:	c3c4                	sw	s1,4(a5)
}
    8000618e:	60e2                	ld	ra,24(sp)
    80006190:	6442                	ld	s0,16(sp)
    80006192:	64a2                	ld	s1,8(sp)
    80006194:	6105                	addi	sp,sp,32
    80006196:	8082                	ret

0000000080006198 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006198:	1141                	addi	sp,sp,-16
    8000619a:	e406                	sd	ra,8(sp)
    8000619c:	e022                	sd	s0,0(sp)
    8000619e:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061a0:	479d                	li	a5,7
    800061a2:	04a7cc63          	blt	a5,a0,800061fa <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    800061a6:	0001d797          	auipc	a5,0x1d
    800061aa:	e5a78793          	addi	a5,a5,-422 # 80023000 <disk>
    800061ae:	00a78733          	add	a4,a5,a0
    800061b2:	6789                	lui	a5,0x2
    800061b4:	97ba                	add	a5,a5,a4
    800061b6:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800061ba:	eba1                	bnez	a5,8000620a <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    800061bc:	00451713          	slli	a4,a0,0x4
    800061c0:	0001f797          	auipc	a5,0x1f
    800061c4:	e407b783          	ld	a5,-448(a5) # 80025000 <disk+0x2000>
    800061c8:	97ba                	add	a5,a5,a4
    800061ca:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    800061ce:	0001d797          	auipc	a5,0x1d
    800061d2:	e3278793          	addi	a5,a5,-462 # 80023000 <disk>
    800061d6:	97aa                	add	a5,a5,a0
    800061d8:	6509                	lui	a0,0x2
    800061da:	953e                	add	a0,a0,a5
    800061dc:	4785                	li	a5,1
    800061de:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800061e2:	0001f517          	auipc	a0,0x1f
    800061e6:	e3650513          	addi	a0,a0,-458 # 80025018 <disk+0x2018>
    800061ea:	ffffc097          	auipc	ra,0xffffc
    800061ee:	f6e080e7          	jalr	-146(ra) # 80002158 <wakeup>
}
    800061f2:	60a2                	ld	ra,8(sp)
    800061f4:	6402                	ld	s0,0(sp)
    800061f6:	0141                	addi	sp,sp,16
    800061f8:	8082                	ret
    panic("virtio_disk_intr 1");
    800061fa:	00002517          	auipc	a0,0x2
    800061fe:	93e50513          	addi	a0,a0,-1730 # 80007b38 <userret+0xaa8>
    80006202:	ffffa097          	auipc	ra,0xffffa
    80006206:	346080e7          	jalr	838(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    8000620a:	00002517          	auipc	a0,0x2
    8000620e:	94650513          	addi	a0,a0,-1722 # 80007b50 <userret+0xac0>
    80006212:	ffffa097          	auipc	ra,0xffffa
    80006216:	336080e7          	jalr	822(ra) # 80000548 <panic>

000000008000621a <virtio_disk_init>:
{
    8000621a:	1101                	addi	sp,sp,-32
    8000621c:	ec06                	sd	ra,24(sp)
    8000621e:	e822                	sd	s0,16(sp)
    80006220:	e426                	sd	s1,8(sp)
    80006222:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006224:	00002597          	auipc	a1,0x2
    80006228:	94458593          	addi	a1,a1,-1724 # 80007b68 <userret+0xad8>
    8000622c:	0001f517          	auipc	a0,0x1f
    80006230:	e7c50513          	addi	a0,a0,-388 # 800250a8 <disk+0x20a8>
    80006234:	ffffa097          	auipc	ra,0xffffa
    80006238:	77c080e7          	jalr	1916(ra) # 800009b0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000623c:	100017b7          	lui	a5,0x10001
    80006240:	4398                	lw	a4,0(a5)
    80006242:	2701                	sext.w	a4,a4
    80006244:	747277b7          	lui	a5,0x74727
    80006248:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000624c:	0ef71163          	bne	a4,a5,8000632e <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006250:	100017b7          	lui	a5,0x10001
    80006254:	43dc                	lw	a5,4(a5)
    80006256:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006258:	4705                	li	a4,1
    8000625a:	0ce79a63          	bne	a5,a4,8000632e <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000625e:	100017b7          	lui	a5,0x10001
    80006262:	479c                	lw	a5,8(a5)
    80006264:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006266:	4709                	li	a4,2
    80006268:	0ce79363          	bne	a5,a4,8000632e <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000626c:	100017b7          	lui	a5,0x10001
    80006270:	47d8                	lw	a4,12(a5)
    80006272:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006274:	554d47b7          	lui	a5,0x554d4
    80006278:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000627c:	0af71963          	bne	a4,a5,8000632e <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006280:	100017b7          	lui	a5,0x10001
    80006284:	4705                	li	a4,1
    80006286:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006288:	470d                	li	a4,3
    8000628a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000628c:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000628e:	c7ffe737          	lui	a4,0xc7ffe
    80006292:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd8743>
    80006296:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006298:	2701                	sext.w	a4,a4
    8000629a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000629c:	472d                	li	a4,11
    8000629e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062a0:	473d                	li	a4,15
    800062a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800062a4:	6705                	lui	a4,0x1
    800062a6:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062ac:	5bdc                	lw	a5,52(a5)
    800062ae:	2781                	sext.w	a5,a5
  if(max == 0)
    800062b0:	c7d9                	beqz	a5,8000633e <virtio_disk_init+0x124>
  if(max < NUM)
    800062b2:	471d                	li	a4,7
    800062b4:	08f77d63          	bgeu	a4,a5,8000634e <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062b8:	100014b7          	lui	s1,0x10001
    800062bc:	47a1                	li	a5,8
    800062be:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800062c0:	6609                	lui	a2,0x2
    800062c2:	4581                	li	a1,0
    800062c4:	0001d517          	auipc	a0,0x1d
    800062c8:	d3c50513          	addi	a0,a0,-708 # 80023000 <disk>
    800062cc:	ffffb097          	auipc	ra,0xffffb
    800062d0:	88e080e7          	jalr	-1906(ra) # 80000b5a <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800062d4:	0001d717          	auipc	a4,0x1d
    800062d8:	d2c70713          	addi	a4,a4,-724 # 80023000 <disk>
    800062dc:	00c75793          	srli	a5,a4,0xc
    800062e0:	2781                	sext.w	a5,a5
    800062e2:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    800062e4:	0001f797          	auipc	a5,0x1f
    800062e8:	d1c78793          	addi	a5,a5,-740 # 80025000 <disk+0x2000>
    800062ec:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    800062ee:	0001d717          	auipc	a4,0x1d
    800062f2:	d9270713          	addi	a4,a4,-622 # 80023080 <disk+0x80>
    800062f6:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800062f8:	0001e717          	auipc	a4,0x1e
    800062fc:	d0870713          	addi	a4,a4,-760 # 80024000 <disk+0x1000>
    80006300:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006302:	4705                	li	a4,1
    80006304:	00e78c23          	sb	a4,24(a5)
    80006308:	00e78ca3          	sb	a4,25(a5)
    8000630c:	00e78d23          	sb	a4,26(a5)
    80006310:	00e78da3          	sb	a4,27(a5)
    80006314:	00e78e23          	sb	a4,28(a5)
    80006318:	00e78ea3          	sb	a4,29(a5)
    8000631c:	00e78f23          	sb	a4,30(a5)
    80006320:	00e78fa3          	sb	a4,31(a5)
}
    80006324:	60e2                	ld	ra,24(sp)
    80006326:	6442                	ld	s0,16(sp)
    80006328:	64a2                	ld	s1,8(sp)
    8000632a:	6105                	addi	sp,sp,32
    8000632c:	8082                	ret
    panic("could not find virtio disk");
    8000632e:	00002517          	auipc	a0,0x2
    80006332:	84a50513          	addi	a0,a0,-1974 # 80007b78 <userret+0xae8>
    80006336:	ffffa097          	auipc	ra,0xffffa
    8000633a:	212080e7          	jalr	530(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000633e:	00002517          	auipc	a0,0x2
    80006342:	85a50513          	addi	a0,a0,-1958 # 80007b98 <userret+0xb08>
    80006346:	ffffa097          	auipc	ra,0xffffa
    8000634a:	202080e7          	jalr	514(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000634e:	00002517          	auipc	a0,0x2
    80006352:	86a50513          	addi	a0,a0,-1942 # 80007bb8 <userret+0xb28>
    80006356:	ffffa097          	auipc	ra,0xffffa
    8000635a:	1f2080e7          	jalr	498(ra) # 80000548 <panic>

000000008000635e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000635e:	7175                	addi	sp,sp,-144
    80006360:	e506                	sd	ra,136(sp)
    80006362:	e122                	sd	s0,128(sp)
    80006364:	fca6                	sd	s1,120(sp)
    80006366:	f8ca                	sd	s2,112(sp)
    80006368:	f4ce                	sd	s3,104(sp)
    8000636a:	f0d2                	sd	s4,96(sp)
    8000636c:	ecd6                	sd	s5,88(sp)
    8000636e:	e8da                	sd	s6,80(sp)
    80006370:	e4de                	sd	s7,72(sp)
    80006372:	e0e2                	sd	s8,64(sp)
    80006374:	fc66                	sd	s9,56(sp)
    80006376:	f86a                	sd	s10,48(sp)
    80006378:	f46e                	sd	s11,40(sp)
    8000637a:	0900                	addi	s0,sp,144
    8000637c:	8aaa                	mv	s5,a0
    8000637e:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006380:	00c52c83          	lw	s9,12(a0)
    80006384:	001c9c9b          	slliw	s9,s9,0x1
    80006388:	1c82                	slli	s9,s9,0x20
    8000638a:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000638e:	0001f517          	auipc	a0,0x1f
    80006392:	d1a50513          	addi	a0,a0,-742 # 800250a8 <disk+0x20a8>
    80006396:	ffffa097          	auipc	ra,0xffffa
    8000639a:	728080e7          	jalr	1832(ra) # 80000abe <acquire>
  for(int i = 0; i < 3; i++){
    8000639e:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063a0:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063a2:	0001dc17          	auipc	s8,0x1d
    800063a6:	c5ec0c13          	addi	s8,s8,-930 # 80023000 <disk>
    800063aa:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800063ac:	4b0d                	li	s6,3
    800063ae:	a0ad                	j	80006418 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800063b0:	00fc0733          	add	a4,s8,a5
    800063b4:	975e                	add	a4,a4,s7
    800063b6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800063ba:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800063bc:	0207c563          	bltz	a5,800063e6 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800063c0:	2905                	addiw	s2,s2,1
    800063c2:	0611                	addi	a2,a2,4
    800063c4:	19690d63          	beq	s2,s6,8000655e <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800063c8:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800063ca:	0001f717          	auipc	a4,0x1f
    800063ce:	c4e70713          	addi	a4,a4,-946 # 80025018 <disk+0x2018>
    800063d2:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800063d4:	00074683          	lbu	a3,0(a4)
    800063d8:	fee1                	bnez	a3,800063b0 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800063da:	2785                	addiw	a5,a5,1
    800063dc:	0705                	addi	a4,a4,1
    800063de:	fe979be3          	bne	a5,s1,800063d4 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800063e2:	57fd                	li	a5,-1
    800063e4:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800063e6:	01205d63          	blez	s2,80006400 <virtio_disk_rw+0xa2>
    800063ea:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800063ec:	000a2503          	lw	a0,0(s4)
    800063f0:	00000097          	auipc	ra,0x0
    800063f4:	da8080e7          	jalr	-600(ra) # 80006198 <free_desc>
      for(int j = 0; j < i; j++)
    800063f8:	2d85                	addiw	s11,s11,1
    800063fa:	0a11                	addi	s4,s4,4
    800063fc:	ffb918e3          	bne	s2,s11,800063ec <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006400:	0001f597          	auipc	a1,0x1f
    80006404:	ca858593          	addi	a1,a1,-856 # 800250a8 <disk+0x20a8>
    80006408:	0001f517          	auipc	a0,0x1f
    8000640c:	c1050513          	addi	a0,a0,-1008 # 80025018 <disk+0x2018>
    80006410:	ffffc097          	auipc	ra,0xffffc
    80006414:	bc8080e7          	jalr	-1080(ra) # 80001fd8 <sleep>
  for(int i = 0; i < 3; i++){
    80006418:	f8040a13          	addi	s4,s0,-128
{
    8000641c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000641e:	894e                	mv	s2,s3
    80006420:	b765                	j	800063c8 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006422:	0001f717          	auipc	a4,0x1f
    80006426:	bde73703          	ld	a4,-1058(a4) # 80025000 <disk+0x2000>
    8000642a:	973e                	add	a4,a4,a5
    8000642c:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006430:	0001d517          	auipc	a0,0x1d
    80006434:	bd050513          	addi	a0,a0,-1072 # 80023000 <disk>
    80006438:	0001f717          	auipc	a4,0x1f
    8000643c:	bc870713          	addi	a4,a4,-1080 # 80025000 <disk+0x2000>
    80006440:	6314                	ld	a3,0(a4)
    80006442:	96be                	add	a3,a3,a5
    80006444:	00c6d603          	lhu	a2,12(a3)
    80006448:	00166613          	ori	a2,a2,1
    8000644c:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006450:	f8842683          	lw	a3,-120(s0)
    80006454:	6310                	ld	a2,0(a4)
    80006456:	97b2                	add	a5,a5,a2
    80006458:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000645c:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    80006460:	0612                	slli	a2,a2,0x4
    80006462:	962a                	add	a2,a2,a0
    80006464:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006468:	00469793          	slli	a5,a3,0x4
    8000646c:	630c                	ld	a1,0(a4)
    8000646e:	95be                	add	a1,a1,a5
    80006470:	6689                	lui	a3,0x2
    80006472:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006476:	96ca                	add	a3,a3,s2
    80006478:	96aa                	add	a3,a3,a0
    8000647a:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    8000647c:	6314                	ld	a3,0(a4)
    8000647e:	96be                	add	a3,a3,a5
    80006480:	4585                	li	a1,1
    80006482:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006484:	6314                	ld	a3,0(a4)
    80006486:	96be                	add	a3,a3,a5
    80006488:	4509                	li	a0,2
    8000648a:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000648e:	6314                	ld	a3,0(a4)
    80006490:	97b6                	add	a5,a5,a3
    80006492:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006496:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000649a:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000649e:	6714                	ld	a3,8(a4)
    800064a0:	0026d783          	lhu	a5,2(a3)
    800064a4:	8b9d                	andi	a5,a5,7
    800064a6:	0789                	addi	a5,a5,2
    800064a8:	0786                	slli	a5,a5,0x1
    800064aa:	97b6                	add	a5,a5,a3
    800064ac:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800064b0:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800064b4:	6718                	ld	a4,8(a4)
    800064b6:	00275783          	lhu	a5,2(a4)
    800064ba:	2785                	addiw	a5,a5,1
    800064bc:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064c0:	100017b7          	lui	a5,0x10001
    800064c4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800064c8:	004aa783          	lw	a5,4(s5)
    800064cc:	02b79163          	bne	a5,a1,800064ee <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800064d0:	0001f917          	auipc	s2,0x1f
    800064d4:	bd890913          	addi	s2,s2,-1064 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800064d8:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800064da:	85ca                	mv	a1,s2
    800064dc:	8556                	mv	a0,s5
    800064de:	ffffc097          	auipc	ra,0xffffc
    800064e2:	afa080e7          	jalr	-1286(ra) # 80001fd8 <sleep>
  while(b->disk == 1) {
    800064e6:	004aa783          	lw	a5,4(s5)
    800064ea:	fe9788e3          	beq	a5,s1,800064da <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800064ee:	f8042483          	lw	s1,-128(s0)
    800064f2:	20048793          	addi	a5,s1,512
    800064f6:	00479713          	slli	a4,a5,0x4
    800064fa:	0001d797          	auipc	a5,0x1d
    800064fe:	b0678793          	addi	a5,a5,-1274 # 80023000 <disk>
    80006502:	97ba                	add	a5,a5,a4
    80006504:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006508:	0001f917          	auipc	s2,0x1f
    8000650c:	af890913          	addi	s2,s2,-1288 # 80025000 <disk+0x2000>
    80006510:	a019                	j	80006516 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80006512:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006516:	8526                	mv	a0,s1
    80006518:	00000097          	auipc	ra,0x0
    8000651c:	c80080e7          	jalr	-896(ra) # 80006198 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006520:	0492                	slli	s1,s1,0x4
    80006522:	00093783          	ld	a5,0(s2)
    80006526:	94be                	add	s1,s1,a5
    80006528:	00c4d783          	lhu	a5,12(s1)
    8000652c:	8b85                	andi	a5,a5,1
    8000652e:	f3f5                	bnez	a5,80006512 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006530:	0001f517          	auipc	a0,0x1f
    80006534:	b7850513          	addi	a0,a0,-1160 # 800250a8 <disk+0x20a8>
    80006538:	ffffa097          	auipc	ra,0xffffa
    8000653c:	5da080e7          	jalr	1498(ra) # 80000b12 <release>
}
    80006540:	60aa                	ld	ra,136(sp)
    80006542:	640a                	ld	s0,128(sp)
    80006544:	74e6                	ld	s1,120(sp)
    80006546:	7946                	ld	s2,112(sp)
    80006548:	79a6                	ld	s3,104(sp)
    8000654a:	7a06                	ld	s4,96(sp)
    8000654c:	6ae6                	ld	s5,88(sp)
    8000654e:	6b46                	ld	s6,80(sp)
    80006550:	6ba6                	ld	s7,72(sp)
    80006552:	6c06                	ld	s8,64(sp)
    80006554:	7ce2                	ld	s9,56(sp)
    80006556:	7d42                	ld	s10,48(sp)
    80006558:	7da2                	ld	s11,40(sp)
    8000655a:	6149                	addi	sp,sp,144
    8000655c:	8082                	ret
  if(write)
    8000655e:	01a037b3          	snez	a5,s10
    80006562:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006566:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    8000656a:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000656e:	f8042483          	lw	s1,-128(s0)
    80006572:	00449913          	slli	s2,s1,0x4
    80006576:	0001f997          	auipc	s3,0x1f
    8000657a:	a8a98993          	addi	s3,s3,-1398 # 80025000 <disk+0x2000>
    8000657e:	0009ba03          	ld	s4,0(s3)
    80006582:	9a4a                	add	s4,s4,s2
    80006584:	f7040513          	addi	a0,s0,-144
    80006588:	ffffb097          	auipc	ra,0xffffb
    8000658c:	a0c080e7          	jalr	-1524(ra) # 80000f94 <kvmpa>
    80006590:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    80006594:	0009b783          	ld	a5,0(s3)
    80006598:	97ca                	add	a5,a5,s2
    8000659a:	4741                	li	a4,16
    8000659c:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000659e:	0009b783          	ld	a5,0(s3)
    800065a2:	97ca                	add	a5,a5,s2
    800065a4:	4705                	li	a4,1
    800065a6:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800065aa:	f8442783          	lw	a5,-124(s0)
    800065ae:	0009b703          	ld	a4,0(s3)
    800065b2:	974a                	add	a4,a4,s2
    800065b4:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800065b8:	0792                	slli	a5,a5,0x4
    800065ba:	0009b703          	ld	a4,0(s3)
    800065be:	973e                	add	a4,a4,a5
    800065c0:	060a8693          	addi	a3,s5,96
    800065c4:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800065c6:	0009b703          	ld	a4,0(s3)
    800065ca:	973e                	add	a4,a4,a5
    800065cc:	40000693          	li	a3,1024
    800065d0:	c714                	sw	a3,8(a4)
  if(write)
    800065d2:	e40d18e3          	bnez	s10,80006422 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800065d6:	0001f717          	auipc	a4,0x1f
    800065da:	a2a73703          	ld	a4,-1494(a4) # 80025000 <disk+0x2000>
    800065de:	973e                	add	a4,a4,a5
    800065e0:	4689                	li	a3,2
    800065e2:	00d71623          	sh	a3,12(a4)
    800065e6:	b5a9                	j	80006430 <virtio_disk_rw+0xd2>

00000000800065e8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065e8:	1101                	addi	sp,sp,-32
    800065ea:	ec06                	sd	ra,24(sp)
    800065ec:	e822                	sd	s0,16(sp)
    800065ee:	e426                	sd	s1,8(sp)
    800065f0:	e04a                	sd	s2,0(sp)
    800065f2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065f4:	0001f517          	auipc	a0,0x1f
    800065f8:	ab450513          	addi	a0,a0,-1356 # 800250a8 <disk+0x20a8>
    800065fc:	ffffa097          	auipc	ra,0xffffa
    80006600:	4c2080e7          	jalr	1218(ra) # 80000abe <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006604:	0001f717          	auipc	a4,0x1f
    80006608:	9fc70713          	addi	a4,a4,-1540 # 80025000 <disk+0x2000>
    8000660c:	02075783          	lhu	a5,32(a4)
    80006610:	6b18                	ld	a4,16(a4)
    80006612:	00275683          	lhu	a3,2(a4)
    80006616:	8ebd                	xor	a3,a3,a5
    80006618:	8a9d                	andi	a3,a3,7
    8000661a:	cab9                	beqz	a3,80006670 <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000661c:	0001d917          	auipc	s2,0x1d
    80006620:	9e490913          	addi	s2,s2,-1564 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006624:	0001f497          	auipc	s1,0x1f
    80006628:	9dc48493          	addi	s1,s1,-1572 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000662c:	078e                	slli	a5,a5,0x3
    8000662e:	97ba                	add	a5,a5,a4
    80006630:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006632:	20078713          	addi	a4,a5,512
    80006636:	0712                	slli	a4,a4,0x4
    80006638:	974a                	add	a4,a4,s2
    8000663a:	03074703          	lbu	a4,48(a4)
    8000663e:	e739                	bnez	a4,8000668c <virtio_disk_intr+0xa4>
    disk.info[id].b->disk = 0;   // disk is done with buf
    80006640:	20078793          	addi	a5,a5,512
    80006644:	0792                	slli	a5,a5,0x4
    80006646:	97ca                	add	a5,a5,s2
    80006648:	7798                	ld	a4,40(a5)
    8000664a:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000664e:	7788                	ld	a0,40(a5)
    80006650:	ffffc097          	auipc	ra,0xffffc
    80006654:	b08080e7          	jalr	-1272(ra) # 80002158 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006658:	0204d783          	lhu	a5,32(s1)
    8000665c:	2785                	addiw	a5,a5,1
    8000665e:	8b9d                	andi	a5,a5,7
    80006660:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006664:	6898                	ld	a4,16(s1)
    80006666:	00275683          	lhu	a3,2(a4)
    8000666a:	8a9d                	andi	a3,a3,7
    8000666c:	fcf690e3          	bne	a3,a5,8000662c <virtio_disk_intr+0x44>
  }

  release(&disk.vdisk_lock);
    80006670:	0001f517          	auipc	a0,0x1f
    80006674:	a3850513          	addi	a0,a0,-1480 # 800250a8 <disk+0x20a8>
    80006678:	ffffa097          	auipc	ra,0xffffa
    8000667c:	49a080e7          	jalr	1178(ra) # 80000b12 <release>
}
    80006680:	60e2                	ld	ra,24(sp)
    80006682:	6442                	ld	s0,16(sp)
    80006684:	64a2                	ld	s1,8(sp)
    80006686:	6902                	ld	s2,0(sp)
    80006688:	6105                	addi	sp,sp,32
    8000668a:	8082                	ret
      panic("virtio_disk_intr status");
    8000668c:	00001517          	auipc	a0,0x1
    80006690:	54c50513          	addi	a0,a0,1356 # 80007bd8 <userret+0xb48>
    80006694:	ffffa097          	auipc	ra,0xffffa
    80006698:	eb4080e7          	jalr	-332(ra) # 80000548 <panic>
	...

0000000080007000 <trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
