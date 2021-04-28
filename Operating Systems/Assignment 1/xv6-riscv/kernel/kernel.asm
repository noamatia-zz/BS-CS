
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	14c78793          	addi	a5,a5,332 # 800061b0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	57c080e7          	jalr	1404(ra) # 8000269a <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7cc080e7          	jalr	1996(ra) # 8000197e <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	0be080e7          	jalr	190(ra) # 80002280 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	446080e7          	jalr	1094(ra) # 80002644 <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	412080e7          	jalr	1042(ra) # 800026f0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	fda080e7          	jalr	-38(ra) # 8000240c <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00022797          	auipc	a5,0x22
    80000468:	8b478793          	addi	a5,a5,-1868 # 80021d18 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800080c8 <digits+0x88>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	b8e080e7          	jalr	-1138(ra) # 8000240c <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	976080e7          	jalr	-1674(ra) # 80002280 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00025797          	auipc	a5,0x25
    800009ee:	61678793          	addi	a5,a5,1558 # 80026000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00025517          	auipc	a0,0x25
    80000abe:	54650513          	addi	a0,a0,1350 # 80026000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	e06080e7          	jalr	-506(ra) # 80001962 <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	dd4080e7          	jalr	-556(ra) # 80001962 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	dc8080e7          	jalr	-568(ra) # 80001962 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	db0080e7          	jalr	-592(ra) # 80001962 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	d70080e7          	jalr	-656(ra) # 80001962 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	d44080e7          	jalr	-700(ra) # 80001962 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	ade080e7          	jalr	-1314(ra) # 80001952 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	ac2080e7          	jalr	-1342(ra) # 80001952 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	c24080e7          	jalr	-988(ra) # 80002ad6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	336080e7          	jalr	822(ra) # 800061f0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	222080e7          	jalr	546(ra) # 800020e4 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1ee50513          	addi	a0,a0,494 # 800080c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1ce50513          	addi	a0,a0,462 # 800080c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	980080e7          	jalr	-1664(ra) # 800018a2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	b84080e7          	jalr	-1148(ra) # 80002aae <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	ba4080e7          	jalr	-1116(ra) # 80002ad6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	2a0080e7          	jalr	672(ra) # 800061da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	2ae080e7          	jalr	686(ra) # 800061f0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	47c080e7          	jalr	1148(ra) # 800033c6 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	b0e080e7          	jalr	-1266(ra) # 80003a60 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	abc080e7          	jalr	-1348(ra) # 80004a16 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	3b0080e7          	jalr	944(ra) # 80006312 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	cf8080e7          	jalr	-776(ra) # 80001c62 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	600080e7          	jalr	1536(ra) # 8000180c <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001258:	03459793          	slli	a5,a1,0x34
    8000125c:	e795                	bnez	a5,80001288 <uvmunmap+0x46>
    8000125e:	8a2a                	mv	s4,a0
    80001260:	892e                	mv	s2,a1
    80001262:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	0632                	slli	a2,a2,0xc
    80001266:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	6b05                	lui	s6,0x1
    8000126e:	0735e263          	bltu	a1,s3,800012d2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001272:	60a6                	ld	ra,72(sp)
    80001274:	6406                	ld	s0,64(sp)
    80001276:	74e2                	ld	s1,56(sp)
    80001278:	7942                	ld	s2,48(sp)
    8000127a:	79a2                	ld	s3,40(sp)
    8000127c:	7a02                	ld	s4,32(sp)
    8000127e:	6ae2                	ld	s5,24(sp)
    80001280:	6b42                	ld	s6,16(sp)
    80001282:	6ba2                	ld	s7,8(sp)
    80001284:	6161                	addi	sp,sp,80
    80001286:	8082                	ret
    panic("uvmunmap: not aligned");
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	e6050513          	addi	a0,a0,-416 # 800080e8 <digits+0xa8>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e6850513          	addi	a0,a0,-408 # 80008100 <digits+0xc0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e6850513          	addi	a0,a0,-408 # 80008110 <digits+0xd0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e7050513          	addi	a0,a0,-400 # 80008128 <digits+0xe8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	26a080e7          	jalr	618(ra) # 8000052a <panic>
    *pte = 0;
    800012c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	995a                	add	s2,s2,s6
    800012ce:	fb3972e3          	bgeu	s2,s3,80001272 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012d2:	4601                	li	a2,0
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	cce080e7          	jalr	-818(ra) # 80000fa6 <walk>
    800012e0:	84aa                	mv	s1,a0
    800012e2:	d95d                	beqz	a0,80001298 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012e4:	6108                	ld	a0,0(a0)
    800012e6:	00157793          	andi	a5,a0,1
    800012ea:	dfdd                	beqz	a5,800012a8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	3ff57793          	andi	a5,a0,1023
    800012f0:	fd7784e3          	beq	a5,s7,800012b8 <uvmunmap+0x76>
    if(do_free){
    800012f4:	fc0a8ae3          	beqz	s5,800012c8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800012f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	6da080e7          	jalr	1754(ra) # 800009d6 <kfree>
    80001304:	b7d1                	j	800012c8 <uvmunmap+0x86>

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	7c2080e7          	jalr	1986(ra) # 80000ad2 <kalloc>
    80001318:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000131a:	c519                	beqz	a0,80001328 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	00000097          	auipc	ra,0x0
    80001324:	99e080e7          	jalr	-1634(ra) # 80000cbe <memset>
  return pagetable;
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	e052                	sd	s4,0(sp)
    80001342:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001344:	6785                	lui	a5,0x1
    80001346:	04f67863          	bgeu	a2,a5,80001396 <uvminit+0x62>
    8000134a:	8a2a                	mv	s4,a0
    8000134c:	89ae                	mv	s3,a1
    8000134e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	782080e7          	jalr	1922(ra) # 80000ad2 <kalloc>
    80001358:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	960080e7          	jalr	-1696(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001366:	4779                	li	a4,30
    80001368:	86ca                	mv	a3,s2
    8000136a:	6605                	lui	a2,0x1
    8000136c:	4581                	li	a1,0
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d1e080e7          	jalr	-738(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    80001378:	8626                	mv	a2,s1
    8000137a:	85ce                	mv	a1,s3
    8000137c:	854a                	mv	a0,s2
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	99c080e7          	jalr	-1636(ra) # 80000d1a <memmove>
}
    80001386:	70a2                	ld	ra,40(sp)
    80001388:	7402                	ld	s0,32(sp)
    8000138a:	64e2                	ld	s1,24(sp)
    8000138c:	6942                	ld	s2,16(sp)
    8000138e:	69a2                	ld	s3,8(sp)
    80001390:	6a02                	ld	s4,0(sp)
    80001392:	6145                	addi	sp,sp,48
    80001394:	8082                	ret
    panic("inituvm: more than a page");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	daa50513          	addi	a0,a0,-598 # 80008140 <digits+0x100>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	18c080e7          	jalr	396(ra) # 8000052a <panic>

00000000800013a6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013b2:	00b67d63          	bgeu	a2,a1,800013cc <uvmdealloc+0x26>
    800013b6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013b8:	6785                	lui	a5,0x1
    800013ba:	17fd                	addi	a5,a5,-1
    800013bc:	00f60733          	add	a4,a2,a5
    800013c0:	767d                	lui	a2,0xfffff
    800013c2:	8f71                	and	a4,a4,a2
    800013c4:	97ae                	add	a5,a5,a1
    800013c6:	8ff1                	and	a5,a5,a2
    800013c8:	00f76863          	bltu	a4,a5,800013d8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013d8:	8f99                	sub	a5,a5,a4
    800013da:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013dc:	4685                	li	a3,1
    800013de:	0007861b          	sext.w	a2,a5
    800013e2:	85ba                	mv	a1,a4
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	e5e080e7          	jalr	-418(ra) # 80001242 <uvmunmap>
    800013ec:	b7c5                	j	800013cc <uvmdealloc+0x26>

00000000800013ee <uvmalloc>:
  if(newsz < oldsz)
    800013ee:	0ab66163          	bltu	a2,a1,80001490 <uvmalloc+0xa2>
{
    800013f2:	7139                	addi	sp,sp,-64
    800013f4:	fc06                	sd	ra,56(sp)
    800013f6:	f822                	sd	s0,48(sp)
    800013f8:	f426                	sd	s1,40(sp)
    800013fa:	f04a                	sd	s2,32(sp)
    800013fc:	ec4e                	sd	s3,24(sp)
    800013fe:	e852                	sd	s4,16(sp)
    80001400:	e456                	sd	s5,8(sp)
    80001402:	0080                	addi	s0,sp,64
    80001404:	8aaa                	mv	s5,a0
    80001406:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001408:	6985                	lui	s3,0x1
    8000140a:	19fd                	addi	s3,s3,-1
    8000140c:	95ce                	add	a1,a1,s3
    8000140e:	79fd                	lui	s3,0xfffff
    80001410:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001414:	08c9f063          	bgeu	s3,a2,80001494 <uvmalloc+0xa6>
    80001418:	894e                	mv	s2,s3
    mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6b8080e7          	jalr	1720(ra) # 80000ad2 <kalloc>
    80001422:	84aa                	mv	s1,a0
    if(mem == 0){
    80001424:	c51d                	beqz	a0,80001452 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	894080e7          	jalr	-1900(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001432:	4779                	li	a4,30
    80001434:	86a6                	mv	a3,s1
    80001436:	6605                	lui	a2,0x1
    80001438:	85ca                	mv	a1,s2
    8000143a:	8556                	mv	a0,s5
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c52080e7          	jalr	-942(ra) # 8000108e <mappages>
    80001444:	e905                	bnez	a0,80001474 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	6785                	lui	a5,0x1
    80001448:	993e                	add	s2,s2,a5
    8000144a:	fd4968e3          	bltu	s2,s4,8000141a <uvmalloc+0x2c>
  return newsz;
    8000144e:	8552                	mv	a0,s4
    80001450:	a809                	j	80001462 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001452:	864e                	mv	a2,s3
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f4e080e7          	jalr	-178(ra) # 800013a6 <uvmdealloc>
      return 0;
    80001460:	4501                	li	a0,0
}
    80001462:	70e2                	ld	ra,56(sp)
    80001464:	7442                	ld	s0,48(sp)
    80001466:	74a2                	ld	s1,40(sp)
    80001468:	7902                	ld	s2,32(sp)
    8000146a:	69e2                	ld	s3,24(sp)
    8000146c:	6a42                	ld	s4,16(sp)
    8000146e:	6aa2                	ld	s5,8(sp)
    80001470:	6121                	addi	sp,sp,64
    80001472:	8082                	ret
      kfree(mem);
    80001474:	8526                	mv	a0,s1
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	560080e7          	jalr	1376(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000147e:	864e                	mv	a2,s3
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f22080e7          	jalr	-222(ra) # 800013a6 <uvmdealloc>
      return 0;
    8000148c:	4501                	li	a0,0
    8000148e:	bfd1                	j	80001462 <uvmalloc+0x74>
    return oldsz;
    80001490:	852e                	mv	a0,a1
}
    80001492:	8082                	ret
  return newsz;
    80001494:	8532                	mv	a0,a2
    80001496:	b7f1                	j	80001462 <uvmalloc+0x74>

0000000080001498 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014aa:	84aa                	mv	s1,a0
    800014ac:	6905                	lui	s2,0x1
    800014ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b0:	4985                	li	s3,1
    800014b2:	a821                	j	800014ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014b6:	0532                	slli	a0,a0,0xc
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	fe0080e7          	jalr	-32(ra) # 80001498 <freewalk>
      pagetable[i] = 0;
    800014c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014c4:	04a1                	addi	s1,s1,8
    800014c6:	03248163          	beq	s1,s2,800014e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014cc:	00f57793          	andi	a5,a0,15
    800014d0:	ff3782e3          	beq	a5,s3,800014b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014d4:	8905                	andi	a0,a0,1
    800014d6:	d57d                	beqz	a0,800014c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	c8850513          	addi	a0,a0,-888 # 80008160 <digits+0x120>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014e8:	8552                	mv	a0,s4
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	4ec080e7          	jalr	1260(ra) # 800009d6 <kfree>
}
    800014f2:	70a2                	ld	ra,40(sp)
    800014f4:	7402                	ld	s0,32(sp)
    800014f6:	64e2                	ld	s1,24(sp)
    800014f8:	6942                	ld	s2,16(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	6a02                	ld	s4,0(sp)
    800014fe:	6145                	addi	sp,sp,48
    80001500:	8082                	ret

0000000080001502 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000150e:	e999                	bnez	a1,80001524 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001510:	8526                	mv	a0,s1
    80001512:	00000097          	auipc	ra,0x0
    80001516:	f86080e7          	jalr	-122(ra) # 80001498 <freewalk>
}
    8000151a:	60e2                	ld	ra,24(sp)
    8000151c:	6442                	ld	s0,16(sp)
    8000151e:	64a2                	ld	s1,8(sp)
    80001520:	6105                	addi	sp,sp,32
    80001522:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001524:	6605                	lui	a2,0x1
    80001526:	167d                	addi	a2,a2,-1
    80001528:	962e                	add	a2,a2,a1
    8000152a:	4685                	li	a3,1
    8000152c:	8231                	srli	a2,a2,0xc
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	d12080e7          	jalr	-750(ra) # 80001242 <uvmunmap>
    80001538:	bfe1                	j	80001510 <uvmfree+0xe>

000000008000153a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000153a:	c679                	beqz	a2,80001608 <uvmcopy+0xce>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8aae                	mv	s5,a1
    80001556:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001558:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000155a:	4601                	li	a2,0
    8000155c:	85ce                	mv	a1,s3
    8000155e:	855a                	mv	a0,s6
    80001560:	00000097          	auipc	ra,0x0
    80001564:	a46080e7          	jalr	-1466(ra) # 80000fa6 <walk>
    80001568:	c531                	beqz	a0,800015b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000156a:	6118                	ld	a4,0(a0)
    8000156c:	00177793          	andi	a5,a4,1
    80001570:	cbb1                	beqz	a5,800015c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001572:	00a75593          	srli	a1,a4,0xa
    80001576:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000157a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	554080e7          	jalr	1364(ra) # 80000ad2 <kalloc>
    80001586:	892a                	mv	s2,a0
    80001588:	c939                	beqz	a0,800015de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000158a:	6605                	lui	a2,0x1
    8000158c:	85de                	mv	a1,s7
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001596:	8726                	mv	a4,s1
    80001598:	86ca                	mv	a3,s2
    8000159a:	6605                	lui	a2,0x1
    8000159c:	85ce                	mv	a1,s3
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	aee080e7          	jalr	-1298(ra) # 8000108e <mappages>
    800015a8:	e515                	bnez	a0,800015d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015aa:	6785                	lui	a5,0x1
    800015ac:	99be                	add	s3,s3,a5
    800015ae:	fb49e6e3          	bltu	s3,s4,8000155a <uvmcopy+0x20>
    800015b2:	a081                	j	800015f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015c4:	00007517          	auipc	a0,0x7
    800015c8:	bcc50513          	addi	a0,a0,-1076 # 80008190 <digits+0x150>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
      kfree(mem);
    800015d4:	854a                	mv	a0,s2
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	400080e7          	jalr	1024(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015de:	4685                	li	a3,1
    800015e0:	00c9d613          	srli	a2,s3,0xc
    800015e4:	4581                	li	a1,0
    800015e6:	8556                	mv	a0,s5
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	c5a080e7          	jalr	-934(ra) # 80001242 <uvmunmap>
  return -1;
    800015f0:	557d                	li	a0,-1
}
    800015f2:	60a6                	ld	ra,72(sp)
    800015f4:	6406                	ld	s0,64(sp)
    800015f6:	74e2                	ld	s1,56(sp)
    800015f8:	7942                	ld	s2,48(sp)
    800015fa:	79a2                	ld	s3,40(sp)
    800015fc:	7a02                	ld	s4,32(sp)
    800015fe:	6ae2                	ld	s5,24(sp)
    80001600:	6b42                	ld	s6,16(sp)
    80001602:	6ba2                	ld	s7,8(sp)
    80001604:	6161                	addi	sp,sp,80
    80001606:	8082                	ret
  return 0;
    80001608:	4501                	li	a0,0
}
    8000160a:	8082                	ret

000000008000160c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160c:	1141                	addi	sp,sp,-16
    8000160e:	e406                	sd	ra,8(sp)
    80001610:	e022                	sd	s0,0(sp)
    80001612:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001614:	4601                	li	a2,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	990080e7          	jalr	-1648(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000161e:	c901                	beqz	a0,8000162e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001620:	611c                	ld	a5,0(a0)
    80001622:	9bbd                	andi	a5,a5,-17
    80001624:	e11c                	sd	a5,0(a0)
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret
    panic("uvmclear");
    8000162e:	00007517          	auipc	a0,0x7
    80001632:	b8250513          	addi	a0,a0,-1150 # 800081b0 <digits+0x170>
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000163e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163e:	c6bd                	beqz	a3,800016ac <copyout+0x6e>
{
    80001640:	715d                	addi	sp,sp,-80
    80001642:	e486                	sd	ra,72(sp)
    80001644:	e0a2                	sd	s0,64(sp)
    80001646:	fc26                	sd	s1,56(sp)
    80001648:	f84a                	sd	s2,48(sp)
    8000164a:	f44e                	sd	s3,40(sp)
    8000164c:	f052                	sd	s4,32(sp)
    8000164e:	ec56                	sd	s5,24(sp)
    80001650:	e85a                	sd	s6,16(sp)
    80001652:	e45e                	sd	s7,8(sp)
    80001654:	e062                	sd	s8,0(sp)
    80001656:	0880                	addi	s0,sp,80
    80001658:	8b2a                	mv	s6,a0
    8000165a:	8c2e                	mv	s8,a1
    8000165c:	8a32                	mv	s4,a2
    8000165e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001660:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001662:	6a85                	lui	s5,0x1
    80001664:	a015                	j	80001688 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001666:	9562                	add	a0,a0,s8
    80001668:	0004861b          	sext.w	a2,s1
    8000166c:	85d2                	mv	a1,s4
    8000166e:	41250533          	sub	a0,a0,s2
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	6a8080e7          	jalr	1704(ra) # 80000d1a <memmove>

    len -= n;
    8000167a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000167e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001680:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001684:	02098263          	beqz	s3,800016a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001688:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000168c:	85ca                	mv	a1,s2
    8000168e:	855a                	mv	a0,s6
    80001690:	00000097          	auipc	ra,0x0
    80001694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001698:	cd01                	beqz	a0,800016b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000169a:	418904b3          	sub	s1,s2,s8
    8000169e:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a0:	fc99f3e3          	bgeu	s3,s1,80001666 <copyout+0x28>
    800016a4:	84ce                	mv	s1,s3
    800016a6:	b7c1                	j	80001666 <copyout+0x28>
  }
  return 0;
    800016a8:	4501                	li	a0,0
    800016aa:	a021                	j	800016b2 <copyout+0x74>
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret
      return -1;
    800016b0:	557d                	li	a0,-1
}
    800016b2:	60a6                	ld	ra,72(sp)
    800016b4:	6406                	ld	s0,64(sp)
    800016b6:	74e2                	ld	s1,56(sp)
    800016b8:	7942                	ld	s2,48(sp)
    800016ba:	79a2                	ld	s3,40(sp)
    800016bc:	7a02                	ld	s4,32(sp)
    800016be:	6ae2                	ld	s5,24(sp)
    800016c0:	6b42                	ld	s6,16(sp)
    800016c2:	6ba2                	ld	s7,8(sp)
    800016c4:	6c02                	ld	s8,0(sp)
    800016c6:	6161                	addi	sp,sp,80
    800016c8:	8082                	ret

00000000800016ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	caa5                	beqz	a3,8000173a <copyin+0x70>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8a2e                	mv	s4,a1
    800016e8:	8c32                	mv	s8,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a01d                	j	80001716 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f2:	018505b3          	add	a1,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	412585b3          	sub	a1,a1,s2
    800016fe:	8552                	mv	a0,s4
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	61a080e7          	jalr	1562(ra) # 80000d1a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000170c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	92e080e7          	jalr	-1746(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f2e3          	bgeu	s3,s1,800016f2 <copyin+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	bf7d                	j	800016f2 <copyin+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyin+0x76>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001758:	c6c5                	beqz	a3,80001800 <copyinstr+0xa8>
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8a2a                	mv	s4,a0
    80001772:	8b2e                	mv	s6,a1
    80001774:	8bb2                	mv	s7,a2
    80001776:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6985                	lui	s3,0x1
    8000177c:	a035                	j	800017a8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000177e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001782:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001784:	0017b793          	seqz	a5,a5
    80001788:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017a6:	c8a9                	beqz	s1,800017f8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	89c080e7          	jalr	-1892(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017b8:	c131                	beqz	a0,800017fc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ba:	41790833          	sub	a6,s2,s7
    800017be:	984e                	add	a6,a6,s3
    if(n > max)
    800017c0:	0104f363          	bgeu	s1,a6,800017c6 <copyinstr+0x6e>
    800017c4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017c6:	955e                	add	a0,a0,s7
    800017c8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017cc:	fc080be3          	beqz	a6,800017a2 <copyinstr+0x4a>
    800017d0:	985a                	add	a6,a6,s6
    800017d2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017d4:	41650633          	sub	a2,a0,s6
    800017d8:	14fd                	addi	s1,s1,-1
    800017da:	9b26                	add	s6,s6,s1
    800017dc:	00f60733          	add	a4,a2,a5
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017e4:	df49                	beqz	a4,8000177e <copyinstr+0x26>
        *dst = *p;
    800017e6:	00e78023          	sb	a4,0(a5)
      --max;
    800017ea:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017ee:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f0:	ff0796e3          	bne	a5,a6,800017dc <copyinstr+0x84>
      dst++;
    800017f4:	8b42                	mv	s6,a6
    800017f6:	b775                	j	800017a2 <copyinstr+0x4a>
    800017f8:	4781                	li	a5,0
    800017fa:	b769                	j	80001784 <copyinstr+0x2c>
      return -1;
    800017fc:	557d                	li	a0,-1
    800017fe:	b779                	j	8000178c <copyinstr+0x34>
  int got_null = 0;
    80001800:	4781                	li	a5,0
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
}
    8000180a:	8082                	ret

000000008000180c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000180c:	7139                	addi	sp,sp,-64
    8000180e:	fc06                	sd	ra,56(sp)
    80001810:	f822                	sd	s0,48(sp)
    80001812:	f426                	sd	s1,40(sp)
    80001814:	f04a                	sd	s2,32(sp)
    80001816:	ec4e                	sd	s3,24(sp)
    80001818:	e852                	sd	s4,16(sp)
    8000181a:	e456                	sd	s5,8(sp)
    8000181c:	e05a                	sd	s6,0(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001822:	00010497          	auipc	s1,0x10
    80001826:	eae48493          	addi	s1,s1,-338 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182a:	8b26                	mv	s6,s1
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	7d4a8a93          	addi	s5,s5,2004 # 80008000 <etext>
    80001834:	04000937          	lui	s2,0x4000
    80001838:	197d                	addi	s2,s2,-1
    8000183a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	00016a17          	auipc	s4,0x16
    80001840:	294a0a13          	addi	s4,s4,660 # 80017ad0 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	8591                	srai	a1,a1,0x4
    80001856:	000ab783          	ld	a5,0(s5)
    8000185a:	02f585b3          	mul	a1,a1,a5
    8000185e:	2585                	addiw	a1,a1,1
    80001860:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4719                	li	a4,6
    80001866:	6685                	lui	a3,0x1
    80001868:	40b905b3          	sub	a1,s2,a1
    8000186c:	854e                	mv	a0,s3
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	8ae080e7          	jalr	-1874(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	19048493          	addi	s1,s1,400
    8000187a:	fd4495e3          	bne	s1,s4,80001844 <proc_mapstacks+0x38>
  }
}
    8000187e:	70e2                	ld	ra,56(sp)
    80001880:	7442                	ld	s0,48(sp)
    80001882:	74a2                	ld	s1,40(sp)
    80001884:	7902                	ld	s2,32(sp)
    80001886:	69e2                	ld	s3,24(sp)
    80001888:	6a42                	ld	s4,16(sp)
    8000188a:	6aa2                	ld	s5,8(sp)
    8000188c:	6b02                	ld	s6,0(sp)
    8000188e:	6121                	addi	sp,sp,64
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92e50513          	addi	a0,a0,-1746 # 800081c0 <digits+0x180>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800018a2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018a2:	7139                	addi	sp,sp,-64
    800018a4:	fc06                	sd	ra,56(sp)
    800018a6:	f822                	sd	s0,48(sp)
    800018a8:	f426                	sd	s1,40(sp)
    800018aa:	f04a                	sd	s2,32(sp)
    800018ac:	ec4e                	sd	s3,24(sp)
    800018ae:	e852                	sd	s4,16(sp)
    800018b0:	e456                	sd	s5,8(sp)
    800018b2:	e05a                	sd	s6,0(sp)
    800018b4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018b6:	00007597          	auipc	a1,0x7
    800018ba:	91258593          	addi	a1,a1,-1774 # 800081c8 <digits+0x188>
    800018be:	00010517          	auipc	a0,0x10
    800018c2:	9e250513          	addi	a0,a0,-1566 # 800112a0 <pid_lock>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	26c080e7          	jalr	620(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	90258593          	addi	a1,a1,-1790 # 800081d0 <digits+0x190>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9e250513          	addi	a0,a0,-1566 # 800112b8 <wait_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	254080e7          	jalr	596(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	00010497          	auipc	s1,0x10
    800018ea:	dea48493          	addi	s1,s1,-534 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    800018ee:	00007b17          	auipc	s6,0x7
    800018f2:	8f2b0b13          	addi	s6,s6,-1806 # 800081e0 <digits+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    800018f6:	8aa6                	mv	s5,s1
    800018f8:	00006a17          	auipc	s4,0x6
    800018fc:	708a0a13          	addi	s4,s4,1800 # 80008000 <etext>
    80001900:	04000937          	lui	s2,0x4000
    80001904:	197d                	addi	s2,s2,-1
    80001906:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001908:	00016997          	auipc	s3,0x16
    8000190c:	1c898993          	addi	s3,s3,456 # 80017ad0 <tickslock>
      initlock(&p->lock, "proc");
    80001910:	85da                	mv	a1,s6
    80001912:	8526                	mv	a0,s1
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	21e080e7          	jalr	542(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000191c:	415487b3          	sub	a5,s1,s5
    80001920:	8791                	srai	a5,a5,0x4
    80001922:	000a3703          	ld	a4,0(s4)
    80001926:	02e787b3          	mul	a5,a5,a4
    8000192a:	2785                	addiw	a5,a5,1
    8000192c:	00d7979b          	slliw	a5,a5,0xd
    80001930:	40f907b3          	sub	a5,s2,a5
    80001934:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001936:	19048493          	addi	s1,s1,400
    8000193a:	fd349be3          	bne	s1,s3,80001910 <procinit+0x6e>
  }
}
    8000193e:	70e2                	ld	ra,56(sp)
    80001940:	7442                	ld	s0,48(sp)
    80001942:	74a2                	ld	s1,40(sp)
    80001944:	7902                	ld	s2,32(sp)
    80001946:	69e2                	ld	s3,24(sp)
    80001948:	6a42                	ld	s4,16(sp)
    8000194a:	6aa2                	ld	s5,8(sp)
    8000194c:	6b02                	ld	s6,0(sp)
    8000194e:	6121                	addi	sp,sp,64
    80001950:	8082                	ret

0000000080001952 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001952:	1141                	addi	sp,sp,-16
    80001954:	e422                	sd	s0,8(sp)
    80001956:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001958:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000195a:	2501                	sext.w	a0,a0
    8000195c:	6422                	ld	s0,8(sp)
    8000195e:	0141                	addi	sp,sp,16
    80001960:	8082                	ret

0000000080001962 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001962:	1141                	addi	sp,sp,-16
    80001964:	e422                	sd	s0,8(sp)
    80001966:	0800                	addi	s0,sp,16
    80001968:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000196a:	2781                	sext.w	a5,a5
    8000196c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000196e:	00010517          	auipc	a0,0x10
    80001972:	96250513          	addi	a0,a0,-1694 # 800112d0 <cpus>
    80001976:	953e                	add	a0,a0,a5
    80001978:	6422                	ld	s0,8(sp)
    8000197a:	0141                	addi	sp,sp,16
    8000197c:	8082                	ret

000000008000197e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000197e:	1101                	addi	sp,sp,-32
    80001980:	ec06                	sd	ra,24(sp)
    80001982:	e822                	sd	s0,16(sp)
    80001984:	e426                	sd	s1,8(sp)
    80001986:	1000                	addi	s0,sp,32
  push_off();
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	1ee080e7          	jalr	494(ra) # 80000b76 <push_off>
    80001990:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
    80001996:	00010717          	auipc	a4,0x10
    8000199a:	90a70713          	addi	a4,a4,-1782 # 800112a0 <pid_lock>
    8000199e:	97ba                	add	a5,a5,a4
    800019a0:	7b84                	ld	s1,48(a5)
  pop_off();
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	274080e7          	jalr	628(ra) # 80000c16 <pop_off>
  return p;
}
    800019aa:	8526                	mv	a0,s1
    800019ac:	60e2                	ld	ra,24(sp)
    800019ae:	6442                	ld	s0,16(sp)
    800019b0:	64a2                	ld	s1,8(sp)
    800019b2:	6105                	addi	sp,sp,32
    800019b4:	8082                	ret

00000000800019b6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019b6:	1141                	addi	sp,sp,-16
    800019b8:	e406                	sd	ra,8(sp)
    800019ba:	e022                	sd	s0,0(sp)
    800019bc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019be:	00000097          	auipc	ra,0x0
    800019c2:	fc0080e7          	jalr	-64(ra) # 8000197e <myproc>
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	2b0080e7          	jalr	688(ra) # 80000c76 <release>

  if (first) {
    800019ce:	00007797          	auipc	a5,0x7
    800019d2:	eb27a783          	lw	a5,-334(a5) # 80008880 <first.1>
    800019d6:	eb89                	bnez	a5,800019e8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019d8:	00001097          	auipc	ra,0x1
    800019dc:	116080e7          	jalr	278(ra) # 80002aee <usertrapret>
}
    800019e0:	60a2                	ld	ra,8(sp)
    800019e2:	6402                	ld	s0,0(sp)
    800019e4:	0141                	addi	sp,sp,16
    800019e6:	8082                	ret
    first = 0;
    800019e8:	00007797          	auipc	a5,0x7
    800019ec:	e807ac23          	sw	zero,-360(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    800019f0:	4505                	li	a0,1
    800019f2:	00002097          	auipc	ra,0x2
    800019f6:	fee080e7          	jalr	-18(ra) # 800039e0 <fsinit>
    800019fa:	bff9                	j	800019d8 <forkret+0x22>

00000000800019fc <allocpid>:
allocpid() {
    800019fc:	1101                	addi	sp,sp,-32
    800019fe:	ec06                	sd	ra,24(sp)
    80001a00:	e822                	sd	s0,16(sp)
    80001a02:	e426                	sd	s1,8(sp)
    80001a04:	e04a                	sd	s2,0(sp)
    80001a06:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a08:	00010917          	auipc	s2,0x10
    80001a0c:	89890913          	addi	s2,s2,-1896 # 800112a0 <pid_lock>
    80001a10:	854a                	mv	a0,s2
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	1b0080e7          	jalr	432(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	e6a78793          	addi	a5,a5,-406 # 80008884 <nextpid>
    80001a22:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a24:	0014871b          	addiw	a4,s1,1
    80001a28:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a2a:	854a                	mv	a0,s2
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	24a080e7          	jalr	586(ra) # 80000c76 <release>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret

0000000080001a42 <proc_pagetable>:
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	e04a                	sd	s2,0(sp)
    80001a4c:	1000                	addi	s0,sp,32
    80001a4e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a50:	00000097          	auipc	ra,0x0
    80001a54:	8b6080e7          	jalr	-1866(ra) # 80001306 <uvmcreate>
    80001a58:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a5a:	c121                	beqz	a0,80001a9a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a5c:	4729                	li	a4,10
    80001a5e:	00005697          	auipc	a3,0x5
    80001a62:	5a268693          	addi	a3,a3,1442 # 80007000 <_trampoline>
    80001a66:	6605                	lui	a2,0x1
    80001a68:	040005b7          	lui	a1,0x4000
    80001a6c:	15fd                	addi	a1,a1,-1
    80001a6e:	05b2                	slli	a1,a1,0xc
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	61e080e7          	jalr	1566(ra) # 8000108e <mappages>
    80001a78:	02054863          	bltz	a0,80001aa8 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a7c:	4719                	li	a4,6
    80001a7e:	05893683          	ld	a3,88(s2)
    80001a82:	6605                	lui	a2,0x1
    80001a84:	020005b7          	lui	a1,0x2000
    80001a88:	15fd                	addi	a1,a1,-1
    80001a8a:	05b6                	slli	a1,a1,0xd
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	fffff097          	auipc	ra,0xfffff
    80001a92:	600080e7          	jalr	1536(ra) # 8000108e <mappages>
    80001a96:	02054163          	bltz	a0,80001ab8 <proc_pagetable+0x76>
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6902                	ld	s2,0(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    uvmfree(pagetable, 0);
    80001aa8:	4581                	li	a1,0
    80001aaa:	8526                	mv	a0,s1
    80001aac:	00000097          	auipc	ra,0x0
    80001ab0:	a56080e7          	jalr	-1450(ra) # 80001502 <uvmfree>
    return 0;
    80001ab4:	4481                	li	s1,0
    80001ab6:	b7d5                	j	80001a9a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab8:	4681                	li	a3,0
    80001aba:	4605                	li	a2,1
    80001abc:	040005b7          	lui	a1,0x4000
    80001ac0:	15fd                	addi	a1,a1,-1
    80001ac2:	05b2                	slli	a1,a1,0xc
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	77c080e7          	jalr	1916(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ace:	4581                	li	a1,0
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	00000097          	auipc	ra,0x0
    80001ad6:	a30080e7          	jalr	-1488(ra) # 80001502 <uvmfree>
    return 0;
    80001ada:	4481                	li	s1,0
    80001adc:	bf7d                	j	80001a9a <proc_pagetable+0x58>

0000000080001ade <proc_freepagetable>:
{
    80001ade:	1101                	addi	sp,sp,-32
    80001ae0:	ec06                	sd	ra,24(sp)
    80001ae2:	e822                	sd	s0,16(sp)
    80001ae4:	e426                	sd	s1,8(sp)
    80001ae6:	e04a                	sd	s2,0(sp)
    80001ae8:	1000                	addi	s0,sp,32
    80001aea:	84aa                	mv	s1,a0
    80001aec:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	fffff097          	auipc	ra,0xfffff
    80001afe:	748080e7          	jalr	1864(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b02:	4681                	li	a3,0
    80001b04:	4605                	li	a2,1
    80001b06:	020005b7          	lui	a1,0x2000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b6                	slli	a1,a1,0xd
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	732080e7          	jalr	1842(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b18:	85ca                	mv	a1,s2
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	9e6080e7          	jalr	-1562(ra) # 80001502 <uvmfree>
}
    80001b24:	60e2                	ld	ra,24(sp)
    80001b26:	6442                	ld	s0,16(sp)
    80001b28:	64a2                	ld	s1,8(sp)
    80001b2a:	6902                	ld	s2,0(sp)
    80001b2c:	6105                	addi	sp,sp,32
    80001b2e:	8082                	ret

0000000080001b30 <freeproc>:
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	1000                	addi	s0,sp,32
    80001b3a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b3c:	6d28                	ld	a0,88(a0)
    80001b3e:	c509                	beqz	a0,80001b48 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	e96080e7          	jalr	-362(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b48:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b4c:	68a8                	ld	a0,80(s1)
    80001b4e:	c511                	beqz	a0,80001b5a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b50:	64ac                	ld	a1,72(s1)
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	f8c080e7          	jalr	-116(ra) # 80001ade <proc_freepagetable>
  p->pagetable = 0;
    80001b5a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b5e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b62:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b66:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b6a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b6e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b72:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b76:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b7a:	0004ac23          	sw	zero,24(s1)
  p->ttime = ticks;
    80001b7e:	00007797          	auipc	a5,0x7
    80001b82:	4b27a783          	lw	a5,1202(a5) # 80009030 <ticks>
    80001b86:	16f4a623          	sw	a5,364(s1)
}
    80001b8a:	60e2                	ld	ra,24(sp)
    80001b8c:	6442                	ld	s0,16(sp)
    80001b8e:	64a2                	ld	s1,8(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret

0000000080001b94 <allocproc>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	e04a                	sd	s2,0(sp)
    80001b9e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ba0:	00010497          	auipc	s1,0x10
    80001ba4:	b3048493          	addi	s1,s1,-1232 # 800116d0 <proc>
    80001ba8:	00016917          	auipc	s2,0x16
    80001bac:	f2890913          	addi	s2,s2,-216 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	fffff097          	auipc	ra,0xfffff
    80001bb6:	010080e7          	jalr	16(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bba:	4c9c                	lw	a5,24(s1)
    80001bbc:	cf81                	beqz	a5,80001bd4 <allocproc+0x40>
      release(&p->lock);
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	0b6080e7          	jalr	182(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc8:	19048493          	addi	s1,s1,400
    80001bcc:	ff2492e3          	bne	s1,s2,80001bb0 <allocproc+0x1c>
  return 0;
    80001bd0:	4481                	li	s1,0
    80001bd2:	a889                	j	80001c24 <allocproc+0x90>
  p->pid = allocpid();
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	e28080e7          	jalr	-472(ra) # 800019fc <allocpid>
    80001bdc:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bde:	4785                	li	a5,1
    80001be0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	ef0080e7          	jalr	-272(ra) # 80000ad2 <kalloc>
    80001bea:	892a                	mv	s2,a0
    80001bec:	eca8                	sd	a0,88(s1)
    80001bee:	c131                	beqz	a0,80001c32 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	00000097          	auipc	ra,0x0
    80001bf6:	e50080e7          	jalr	-432(ra) # 80001a42 <proc_pagetable>
    80001bfa:	892a                	mv	s2,a0
    80001bfc:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001bfe:	c531                	beqz	a0,80001c4a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c00:	07000613          	li	a2,112
    80001c04:	4581                	li	a1,0
    80001c06:	06048513          	addi	a0,s1,96
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	0b4080e7          	jalr	180(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c12:	00000797          	auipc	a5,0x0
    80001c16:	da478793          	addi	a5,a5,-604 # 800019b6 <forkret>
    80001c1a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c1c:	60bc                	ld	a5,64(s1)
    80001c1e:	6705                	lui	a4,0x1
    80001c20:	97ba                	add	a5,a5,a4
    80001c22:	f4bc                	sd	a5,104(s1)
}
    80001c24:	8526                	mv	a0,s1
    80001c26:	60e2                	ld	ra,24(sp)
    80001c28:	6442                	ld	s0,16(sp)
    80001c2a:	64a2                	ld	s1,8(sp)
    80001c2c:	6902                	ld	s2,0(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret
    freeproc(p);
    80001c32:	8526                	mv	a0,s1
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	efc080e7          	jalr	-260(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	038080e7          	jalr	56(ra) # 80000c76 <release>
    return 0;
    80001c46:	84ca                	mv	s1,s2
    80001c48:	bff1                	j	80001c24 <allocproc+0x90>
    freeproc(p);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	00000097          	auipc	ra,0x0
    80001c50:	ee4080e7          	jalr	-284(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001c54:	8526                	mv	a0,s1
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	020080e7          	jalr	32(ra) # 80000c76 <release>
    return 0;
    80001c5e:	84ca                	mv	s1,s2
    80001c60:	b7d1                	j	80001c24 <allocproc+0x90>

0000000080001c62 <userinit>:
{
    80001c62:	1101                	addi	sp,sp,-32
    80001c64:	ec06                	sd	ra,24(sp)
    80001c66:	e822                	sd	s0,16(sp)
    80001c68:	e426                	sd	s1,8(sp)
    80001c6a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	f28080e7          	jalr	-216(ra) # 80001b94 <allocproc>
    80001c74:	84aa                	mv	s1,a0
  initproc = p;
    80001c76:	00007797          	auipc	a5,0x7
    80001c7a:	3aa7b923          	sd	a0,946(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c7e:	03400613          	li	a2,52
    80001c82:	00007597          	auipc	a1,0x7
    80001c86:	c0e58593          	addi	a1,a1,-1010 # 80008890 <initcode>
    80001c8a:	6928                	ld	a0,80(a0)
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	6a8080e7          	jalr	1704(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001c94:	6785                	lui	a5,0x1
    80001c96:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001c98:	6cb8                	ld	a4,88(s1)
    80001c9a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001c9e:	6cb8                	ld	a4,88(s1)
    80001ca0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ca2:	4641                	li	a2,16
    80001ca4:	00006597          	auipc	a1,0x6
    80001ca8:	54458593          	addi	a1,a1,1348 # 800081e8 <digits+0x1a8>
    80001cac:	15848513          	addi	a0,s1,344
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	160080e7          	jalr	352(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001cb8:	00006517          	auipc	a0,0x6
    80001cbc:	54050513          	addi	a0,a0,1344 # 800081f8 <digits+0x1b8>
    80001cc0:	00002097          	auipc	ra,0x2
    80001cc4:	74e080e7          	jalr	1870(ra) # 8000440e <namei>
    80001cc8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ccc:	478d                	li	a5,3
    80001cce:	cc9c                	sw	a5,24(s1)
  p->ready = p->ctime = ticks;
    80001cd0:	00007717          	auipc	a4,0x7
    80001cd4:	36072703          	lw	a4,864(a4) # 80009030 <ticks>
    80001cd8:	16e4a423          	sw	a4,360(s1)
    80001cdc:	18e4a623          	sw	a4,396(s1)
  p->stime = p->retime = p->rutime = p->timerinterupts = p->mask = 0;
    80001ce0:	1804a423          	sw	zero,392(s1)
    80001ce4:	1804a023          	sw	zero,384(s1)
    80001ce8:	1604ac23          	sw	zero,376(s1)
    80001cec:	1604aa23          	sw	zero,372(s1)
    80001cf0:	1604a823          	sw	zero,368(s1)
  p->average_bursttime = QUANTUM * 100;
    80001cf4:	1f400713          	li	a4,500
    80001cf8:	16e4ae23          	sw	a4,380(s1)
  p->priority = NORMALPRIORITY;
    80001cfc:	18f4a223          	sw	a5,388(s1)
  release(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	f74080e7          	jalr	-140(ra) # 80000c76 <release>
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6105                	addi	sp,sp,32
    80001d12:	8082                	ret

0000000080001d14 <growproc>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	e04a                	sd	s2,0(sp)
    80001d1e:	1000                	addi	s0,sp,32
    80001d20:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	c5c080e7          	jalr	-932(ra) # 8000197e <myproc>
    80001d2a:	892a                	mv	s2,a0
  sz = p->sz;
    80001d2c:	652c                	ld	a1,72(a0)
    80001d2e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d32:	00904f63          	bgtz	s1,80001d50 <growproc+0x3c>
  } else if(n < 0){
    80001d36:	0204cc63          	bltz	s1,80001d6e <growproc+0x5a>
  p->sz = sz;
    80001d3a:	1602                	slli	a2,a2,0x20
    80001d3c:	9201                	srli	a2,a2,0x20
    80001d3e:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d42:	4501                	li	a0,0
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6902                	ld	s2,0(sp)
    80001d4c:	6105                	addi	sp,sp,32
    80001d4e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d50:	9e25                	addw	a2,a2,s1
    80001d52:	1602                	slli	a2,a2,0x20
    80001d54:	9201                	srli	a2,a2,0x20
    80001d56:	1582                	slli	a1,a1,0x20
    80001d58:	9181                	srli	a1,a1,0x20
    80001d5a:	6928                	ld	a0,80(a0)
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	692080e7          	jalr	1682(ra) # 800013ee <uvmalloc>
    80001d64:	0005061b          	sext.w	a2,a0
    80001d68:	fa69                	bnez	a2,80001d3a <growproc+0x26>
      return -1;
    80001d6a:	557d                	li	a0,-1
    80001d6c:	bfe1                	j	80001d44 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6e:	9e25                	addw	a2,a2,s1
    80001d70:	1602                	slli	a2,a2,0x20
    80001d72:	9201                	srli	a2,a2,0x20
    80001d74:	1582                	slli	a1,a1,0x20
    80001d76:	9181                	srli	a1,a1,0x20
    80001d78:	6928                	ld	a0,80(a0)
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	62c080e7          	jalr	1580(ra) # 800013a6 <uvmdealloc>
    80001d82:	0005061b          	sext.w	a2,a0
    80001d86:	bf55                	j	80001d3a <growproc+0x26>

0000000080001d88 <fork>:
{
    80001d88:	7139                	addi	sp,sp,-64
    80001d8a:	fc06                	sd	ra,56(sp)
    80001d8c:	f822                	sd	s0,48(sp)
    80001d8e:	f426                	sd	s1,40(sp)
    80001d90:	f04a                	sd	s2,32(sp)
    80001d92:	ec4e                	sd	s3,24(sp)
    80001d94:	e852                	sd	s4,16(sp)
    80001d96:	e456                	sd	s5,8(sp)
    80001d98:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	be4080e7          	jalr	-1052(ra) # 8000197e <myproc>
    80001da2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	df0080e7          	jalr	-528(ra) # 80001b94 <allocproc>
    80001dac:	14050a63          	beqz	a0,80001f00 <fork+0x178>
    80001db0:	89aa                	mv	s3,a0
  np->ctime = ticks;
    80001db2:	00007797          	auipc	a5,0x7
    80001db6:	27e7a783          	lw	a5,638(a5) # 80009030 <ticks>
    80001dba:	16f52423          	sw	a5,360(a0)
  np->stime = np->retime = np->rutime = np->timerinterupts = 0;
    80001dbe:	18052023          	sw	zero,384(a0)
    80001dc2:	16052c23          	sw	zero,376(a0)
    80001dc6:	16052a23          	sw	zero,372(a0)
    80001dca:	16052823          	sw	zero,368(a0)
  np->average_bursttime = QUANTUM * 100;
    80001dce:	1f400793          	li	a5,500
    80001dd2:	16f52e23          	sw	a5,380(a0)
  np->mask = p->mask;
    80001dd6:	188aa783          	lw	a5,392(s5)
    80001dda:	18f52423          	sw	a5,392(a0)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dde:	048ab603          	ld	a2,72(s5)
    80001de2:	692c                	ld	a1,80(a0)
    80001de4:	050ab503          	ld	a0,80(s5)
    80001de8:	fffff097          	auipc	ra,0xfffff
    80001dec:	752080e7          	jalr	1874(ra) # 8000153a <uvmcopy>
    80001df0:	04054863          	bltz	a0,80001e40 <fork+0xb8>
  np->sz = p->sz;
    80001df4:	048ab783          	ld	a5,72(s5)
    80001df8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dfc:	058ab683          	ld	a3,88(s5)
    80001e00:	87b6                	mv	a5,a3
    80001e02:	0589b703          	ld	a4,88(s3)
    80001e06:	12068693          	addi	a3,a3,288
    80001e0a:	0007b803          	ld	a6,0(a5)
    80001e0e:	6788                	ld	a0,8(a5)
    80001e10:	6b8c                	ld	a1,16(a5)
    80001e12:	6f90                	ld	a2,24(a5)
    80001e14:	01073023          	sd	a6,0(a4)
    80001e18:	e708                	sd	a0,8(a4)
    80001e1a:	eb0c                	sd	a1,16(a4)
    80001e1c:	ef10                	sd	a2,24(a4)
    80001e1e:	02078793          	addi	a5,a5,32
    80001e22:	02070713          	addi	a4,a4,32
    80001e26:	fed792e3          	bne	a5,a3,80001e0a <fork+0x82>
  np->trapframe->a0 = 0;
    80001e2a:	0589b783          	ld	a5,88(s3)
    80001e2e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e32:	0d0a8493          	addi	s1,s5,208
    80001e36:	0d098913          	addi	s2,s3,208
    80001e3a:	150a8a13          	addi	s4,s5,336
    80001e3e:	a00d                	j	80001e60 <fork+0xd8>
    freeproc(np);
    80001e40:	854e                	mv	a0,s3
    80001e42:	00000097          	auipc	ra,0x0
    80001e46:	cee080e7          	jalr	-786(ra) # 80001b30 <freeproc>
    release(&np->lock);
    80001e4a:	854e                	mv	a0,s3
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	e2a080e7          	jalr	-470(ra) # 80000c76 <release>
    return -1;
    80001e54:	597d                	li	s2,-1
    80001e56:	a859                	j	80001eec <fork+0x164>
  for(i = 0; i < NOFILE; i++)
    80001e58:	04a1                	addi	s1,s1,8
    80001e5a:	0921                	addi	s2,s2,8
    80001e5c:	01448b63          	beq	s1,s4,80001e72 <fork+0xea>
    if(p->ofile[i])
    80001e60:	6088                	ld	a0,0(s1)
    80001e62:	d97d                	beqz	a0,80001e58 <fork+0xd0>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e64:	00003097          	auipc	ra,0x3
    80001e68:	c44080e7          	jalr	-956(ra) # 80004aa8 <filedup>
    80001e6c:	00a93023          	sd	a0,0(s2)
    80001e70:	b7e5                	j	80001e58 <fork+0xd0>
  np->cwd = idup(p->cwd);
    80001e72:	150ab503          	ld	a0,336(s5)
    80001e76:	00002097          	auipc	ra,0x2
    80001e7a:	da4080e7          	jalr	-604(ra) # 80003c1a <idup>
    80001e7e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e82:	4641                	li	a2,16
    80001e84:	158a8593          	addi	a1,s5,344
    80001e88:	15898513          	addi	a0,s3,344
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	f84080e7          	jalr	-124(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001e94:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	ddc080e7          	jalr	-548(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001ea2:	0000f497          	auipc	s1,0xf
    80001ea6:	41648493          	addi	s1,s1,1046 # 800112b8 <wait_lock>
    80001eaa:	8526                	mv	a0,s1
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	d16080e7          	jalr	-746(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001eb4:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001eb8:	8526                	mv	a0,s1
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	dbc080e7          	jalr	-580(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001ec2:	854e                	mv	a0,s3
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	cfe080e7          	jalr	-770(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001ecc:	478d                	li	a5,3
    80001ece:	00f9ac23          	sw	a5,24(s3)
  np->ready = ticks;
    80001ed2:	00007717          	auipc	a4,0x7
    80001ed6:	15e72703          	lw	a4,350(a4) # 80009030 <ticks>
    80001eda:	18e9a623          	sw	a4,396(s3)
  np->priority = NORMALPRIORITY;
    80001ede:	18f9a223          	sw	a5,388(s3)
  release(&np->lock);
    80001ee2:	854e                	mv	a0,s3
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	d92080e7          	jalr	-622(ra) # 80000c76 <release>
}
    80001eec:	854a                	mv	a0,s2
    80001eee:	70e2                	ld	ra,56(sp)
    80001ef0:	7442                	ld	s0,48(sp)
    80001ef2:	74a2                	ld	s1,40(sp)
    80001ef4:	7902                	ld	s2,32(sp)
    80001ef6:	69e2                	ld	s3,24(sp)
    80001ef8:	6a42                	ld	s4,16(sp)
    80001efa:	6aa2                	ld	s5,8(sp)
    80001efc:	6121                	addi	sp,sp,64
    80001efe:	8082                	ret
    return -1;
    80001f00:	597d                	li	s2,-1
    80001f02:	b7ed                	j	80001eec <fork+0x164>

0000000080001f04 <evalruratio>:
{
    80001f04:	1141                	addi	sp,sp,-16
    80001f06:	e422                	sd	s0,8(sp)
    80001f08:	0800                	addi	s0,sp,16
    80001f0a:	87aa                	mv	a5,a0
  if(p->rutime + p->stime != 0)
    80001f0c:	17852683          	lw	a3,376(a0)
    80001f10:	17052703          	lw	a4,368(a0)
    80001f14:	9f35                	addw	a4,a4,a3
    80001f16:	0007051b          	sext.w	a0,a4
    80001f1a:	cd19                	beqz	a0,80001f38 <evalruratio+0x34>
    return (p->rutime * deacyfactors[p->priority]) / (p->rutime + p->stime);
    80001f1c:	1847a783          	lw	a5,388(a5)
    80001f20:	00279613          	slli	a2,a5,0x2
    80001f24:	00006797          	auipc	a5,0x6
    80001f28:	38478793          	addi	a5,a5,900 # 800082a8 <deacyfactors>
    80001f2c:	97b2                	add	a5,a5,a2
    80001f2e:	4388                	lw	a0,0(a5)
    80001f30:	02d5053b          	mulw	a0,a0,a3
    80001f34:	02e5453b          	divw	a0,a0,a4
}
    80001f38:	6422                	ld	s0,8(sp)
    80001f3a:	0141                	addi	sp,sp,16
    80001f3c:	8082                	ret

0000000080001f3e <runprocess>:
{
    80001f3e:	7179                	addi	sp,sp,-48
    80001f40:	f406                	sd	ra,40(sp)
    80001f42:	f022                	sd	s0,32(sp)
    80001f44:	ec26                	sd	s1,24(sp)
    80001f46:	e84a                	sd	s2,16(sp)
    80001f48:	e44e                	sd	s3,8(sp)
    80001f4a:	e052                	sd	s4,0(sp)
    80001f4c:	1800                	addi	s0,sp,48
    80001f4e:	84aa                	mv	s1,a0
    80001f50:	892e                	mv	s2,a1
  p->state = RUNNING;
    80001f52:	4791                	li	a5,4
    80001f54:	cd1c                	sw	a5,24(a0)
  c->proc = p;
    80001f56:	e188                	sd	a0,0(a1)
  ticks0 = ticks;
    80001f58:	00007997          	auipc	s3,0x7
    80001f5c:	0d898993          	addi	s3,s3,216 # 80009030 <ticks>
    80001f60:	0009aa03          	lw	s4,0(s3)
  swtch(&c->context, &p->context);
    80001f64:	06050593          	addi	a1,a0,96
    80001f68:	00890513          	addi	a0,s2,8
    80001f6c:	00001097          	auipc	ra,0x1
    80001f70:	ad8080e7          	jalr	-1320(ra) # 80002a44 <swtch>
  p->average_bursttime = ALPHA * (ticks-ticks0) + ((100-ALPHA) * p->average_bursttime)/100;
    80001f74:	0009a783          	lw	a5,0(s3)
    80001f78:	414787bb          	subw	a5,a5,s4
    80001f7c:	03200713          	li	a4,50
    80001f80:	02e787bb          	mulw	a5,a5,a4
    80001f84:	17c4a683          	lw	a3,380(s1)
    80001f88:	01f6d71b          	srliw	a4,a3,0x1f
    80001f8c:	9f35                	addw	a4,a4,a3
    80001f8e:	4017571b          	sraiw	a4,a4,0x1
    80001f92:	9fb9                	addw	a5,a5,a4
    80001f94:	16f4ae23          	sw	a5,380(s1)
  c->proc = 0;
    80001f98:	00093023          	sd	zero,0(s2)
}
    80001f9c:	70a2                	ld	ra,40(sp)
    80001f9e:	7402                	ld	s0,32(sp)
    80001fa0:	64e2                	ld	s1,24(sp)
    80001fa2:	6942                	ld	s2,16(sp)
    80001fa4:	69a2                	ld	s3,8(sp)
    80001fa6:	6a02                	ld	s4,0(sp)
    80001fa8:	6145                	addi	sp,sp,48
    80001faa:	8082                	ret

0000000080001fac <runscheduler>:
{
    80001fac:	7119                	addi	sp,sp,-128
    80001fae:	fc86                	sd	ra,120(sp)
    80001fb0:	f8a2                	sd	s0,112(sp)
    80001fb2:	f4a6                	sd	s1,104(sp)
    80001fb4:	f0ca                	sd	s2,96(sp)
    80001fb6:	ecce                	sd	s3,88(sp)
    80001fb8:	e8d2                	sd	s4,80(sp)
    80001fba:	e4d6                	sd	s5,72(sp)
    80001fbc:	e0da                	sd	s6,64(sp)
    80001fbe:	fc5e                	sd	s7,56(sp)
    80001fc0:	f862                	sd	s8,48(sp)
    80001fc2:	f466                	sd	s9,40(sp)
    80001fc4:	f06a                	sd	s10,32(sp)
    80001fc6:	ec6e                	sd	s11,24(sp)
    80001fc8:	0100                	addi	s0,sp,128
    80001fca:	8c2a                	mv	s8,a0
    80001fcc:	8792                	mv	a5,tp
  int id = r_tp();
    80001fce:	2781                	sext.w	a5,a5
  struct cpu *c = &cpus[id];
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	0000f717          	auipc	a4,0xf
    80001fd6:	2fe70713          	addi	a4,a4,766 # 800112d0 <cpus>
    80001fda:	973e                	add	a4,a4,a5
    80001fdc:	f8e43423          	sd	a4,-120(s0)
  c->proc = 0;
    80001fe0:	0000f717          	auipc	a4,0xf
    80001fe4:	2c070713          	addi	a4,a4,704 # 800112a0 <pid_lock>
    80001fe8:	97ba                	add	a5,a5,a4
    80001fea:	0207b823          	sd	zero,48(a5)
      if(p->state == RUNNABLE){
    80001fee:	4b0d                	li	s6,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff0:	00016b97          	auipc	s7,0x16
    80001ff4:	ae0b8b93          	addi	s7,s7,-1312 # 80017ad0 <tickslock>
        else if(criterion == BURST && p->average_bursttime < minp->average_bursttime){
    80001ff8:	4d05                	li	s10,1
        else if(criterion == RURATIO && evalruratio(p) < evalruratio(minp)){
    80001ffa:	4d89                	li	s11,2
    80001ffc:	a0d1                	j	800020c0 <runscheduler+0x114>
        else if(criterion == BURST && p->average_bursttime < minp->average_bursttime){
    80001ffe:	fec92703          	lw	a4,-20(s2)
    80002002:	17caa783          	lw	a5,380(s5)
    80002006:	04f74d63          	blt	a4,a5,80002060 <runscheduler+0xb4>
          release(&p->lock);
    8000200a:	8552                	mv	a0,s4
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	c6a080e7          	jalr	-918(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002014:	0979fa63          	bgeu	s3,s7,800020a8 <runscheduler+0xfc>
    80002018:	19048493          	addi	s1,s1,400
    8000201c:	19090913          	addi	s2,s2,400
    80002020:	8a26                	mv	s4,s1
      acquire(&p->lock);
    80002022:	8526                	mv	a0,s1
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	b9e080e7          	jalr	-1122(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE){
    8000202c:	89ca                	mv	s3,s2
    8000202e:	e8892783          	lw	a5,-376(s2)
    80002032:	07679263          	bne	a5,s6,80002096 <runscheduler+0xea>
        if(!minp)
    80002036:	0a0a8563          	beqz	s5,800020e0 <runscheduler+0x134>
        else if(criterion == BURST && p->average_bursttime < minp->average_bursttime){
    8000203a:	fdac02e3          	beq	s8,s10,80001ffe <runscheduler+0x52>
        else if(criterion == RURATIO && evalruratio(p) < evalruratio(minp)){
    8000203e:	03bc0863          	beq	s8,s11,8000206e <runscheduler+0xc2>
        else if(criterion == READY && p->ready < minp->ready){
    80002042:	fd6c14e3          	bne	s8,s6,8000200a <runscheduler+0x5e>
    80002046:	ffc92703          	lw	a4,-4(s2)
    8000204a:	18caa783          	lw	a5,396(s5)
    8000204e:	faf75ee3          	bge	a4,a5,8000200a <runscheduler+0x5e>
          release(&minp->lock);
    80002052:	8556                	mv	a0,s5
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	c22080e7          	jalr	-990(ra) # 80000c76 <release>
          minp = p;
    8000205c:	8aa6                	mv	s5,s1
    8000205e:	bf5d                	j	80002014 <runscheduler+0x68>
          release(&minp->lock);
    80002060:	8556                	mv	a0,s5
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	c14080e7          	jalr	-1004(ra) # 80000c76 <release>
          minp = p;
    8000206a:	8aa6                	mv	s5,s1
    8000206c:	b765                	j	80002014 <runscheduler+0x68>
        else if(criterion == RURATIO && evalruratio(p) < evalruratio(minp)){
    8000206e:	8526                	mv	a0,s1
    80002070:	00000097          	auipc	ra,0x0
    80002074:	e94080e7          	jalr	-364(ra) # 80001f04 <evalruratio>
    80002078:	8caa                	mv	s9,a0
    8000207a:	8556                	mv	a0,s5
    8000207c:	00000097          	auipc	ra,0x0
    80002080:	e88080e7          	jalr	-376(ra) # 80001f04 <evalruratio>
    80002084:	f8acd3e3          	bge	s9,a0,8000200a <runscheduler+0x5e>
          release(&minp->lock);
    80002088:	8556                	mv	a0,s5
    8000208a:	fffff097          	auipc	ra,0xfffff
    8000208e:	bec080e7          	jalr	-1044(ra) # 80000c76 <release>
          minp = p;
    80002092:	8aa6                	mv	s5,s1
    80002094:	b741                	j	80002014 <runscheduler+0x68>
        release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bde080e7          	jalr	-1058(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020a0:	f7796ce3          	bltu	s2,s7,80002018 <runscheduler+0x6c>
    if(minp){
    800020a4:	000a8e63          	beqz	s5,800020c0 <runscheduler+0x114>
      runprocess(minp, c);
    800020a8:	f8843583          	ld	a1,-120(s0)
    800020ac:	8556                	mv	a0,s5
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	e90080e7          	jalr	-368(ra) # 80001f3e <runprocess>
      release(&minp->lock);
    800020b6:	8556                	mv	a0,s5
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	bbe080e7          	jalr	-1090(ra) # 80000c76 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020c0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020c4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020c8:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020cc:	0000f497          	auipc	s1,0xf
    800020d0:	60448493          	addi	s1,s1,1540 # 800116d0 <proc>
    800020d4:	0000f917          	auipc	s2,0xf
    800020d8:	78c90913          	addi	s2,s2,1932 # 80011860 <proc+0x190>
    minp = 0;
    800020dc:	4a81                	li	s5,0
    800020de:	b789                	j	80002020 <runscheduler+0x74>
    800020e0:	8aa6                	mv	s5,s1
    800020e2:	bf0d                	j	80002014 <runscheduler+0x68>

00000000800020e4 <scheduler>:
{
    800020e4:	7179                	addi	sp,sp,-48
    800020e6:	f406                	sd	ra,40(sp)
    800020e8:	f022                	sd	s0,32(sp)
    800020ea:	ec26                	sd	s1,24(sp)
    800020ec:	e84a                	sd	s2,16(sp)
    800020ee:	e44e                	sd	s3,8(sp)
    800020f0:	e052                	sd	s4,0(sp)
    800020f2:	1800                	addi	s0,sp,48
  asm volatile("mv %0, tp" : "=r" (x) );
    800020f4:	8792                	mv	a5,tp
  int id = r_tp();
    800020f6:	2781                	sext.w	a5,a5
  struct cpu *c = &cpus[id];
    800020f8:	079e                	slli	a5,a5,0x7
    800020fa:	0000fa17          	auipc	s4,0xf
    800020fe:	1d6a0a13          	addi	s4,s4,470 # 800112d0 <cpus>
    80002102:	9a3e                	add	s4,s4,a5
    c->proc = 0;
    80002104:	0000f717          	auipc	a4,0xf
    80002108:	19c70713          	addi	a4,a4,412 # 800112a0 <pid_lock>
    8000210c:	97ba                	add	a5,a5,a4
    8000210e:	0207b823          	sd	zero,48(a5)
        if(p->state == RUNNABLE)
    80002112:	498d                	li	s3,3
      for(p = proc; p < &proc[NPROC]; p++) {
    80002114:	00016917          	auipc	s2,0x16
    80002118:	9bc90913          	addi	s2,s2,-1604 # 80017ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000211c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002120:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002124:	10079073          	csrw	sstatus,a5
    80002128:	0000f497          	auipc	s1,0xf
    8000212c:	5a848493          	addi	s1,s1,1448 # 800116d0 <proc>
    80002130:	a811                	j	80002144 <scheduler+0x60>
        release(&p->lock);
    80002132:	8526                	mv	a0,s1
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	b42080e7          	jalr	-1214(ra) # 80000c76 <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    8000213c:	19048493          	addi	s1,s1,400
    80002140:	fd248ee3          	beq	s1,s2,8000211c <scheduler+0x38>
        acquire(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	a7c080e7          	jalr	-1412(ra) # 80000bc2 <acquire>
        if(p->state == RUNNABLE)
    8000214e:	4c9c                	lw	a5,24(s1)
    80002150:	ff3791e3          	bne	a5,s3,80002132 <scheduler+0x4e>
          runprocess(p, c);
    80002154:	85d2                	mv	a1,s4
    80002156:	8526                	mv	a0,s1
    80002158:	00000097          	auipc	ra,0x0
    8000215c:	de6080e7          	jalr	-538(ra) # 80001f3e <runprocess>
    80002160:	bfc9                	j	80002132 <scheduler+0x4e>

0000000080002162 <sched>:
{
    80002162:	7179                	addi	sp,sp,-48
    80002164:	f406                	sd	ra,40(sp)
    80002166:	f022                	sd	s0,32(sp)
    80002168:	ec26                	sd	s1,24(sp)
    8000216a:	e84a                	sd	s2,16(sp)
    8000216c:	e44e                	sd	s3,8(sp)
    8000216e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002170:	00000097          	auipc	ra,0x0
    80002174:	80e080e7          	jalr	-2034(ra) # 8000197e <myproc>
    80002178:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	9ce080e7          	jalr	-1586(ra) # 80000b48 <holding>
    80002182:	c93d                	beqz	a0,800021f8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002184:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002186:	2781                	sext.w	a5,a5
    80002188:	079e                	slli	a5,a5,0x7
    8000218a:	0000f717          	auipc	a4,0xf
    8000218e:	11670713          	addi	a4,a4,278 # 800112a0 <pid_lock>
    80002192:	97ba                	add	a5,a5,a4
    80002194:	0a87a703          	lw	a4,168(a5)
    80002198:	4785                	li	a5,1
    8000219a:	06f71763          	bne	a4,a5,80002208 <sched+0xa6>
  if(p->state == RUNNING)
    8000219e:	4c98                	lw	a4,24(s1)
    800021a0:	4791                	li	a5,4
    800021a2:	06f70b63          	beq	a4,a5,80002218 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021a6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021aa:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021ac:	efb5                	bnez	a5,80002228 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021ae:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021b0:	0000f917          	auipc	s2,0xf
    800021b4:	0f090913          	addi	s2,s2,240 # 800112a0 <pid_lock>
    800021b8:	2781                	sext.w	a5,a5
    800021ba:	079e                	slli	a5,a5,0x7
    800021bc:	97ca                	add	a5,a5,s2
    800021be:	0ac7a983          	lw	s3,172(a5)
    800021c2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021c4:	2781                	sext.w	a5,a5
    800021c6:	079e                	slli	a5,a5,0x7
    800021c8:	0000f597          	auipc	a1,0xf
    800021cc:	11058593          	addi	a1,a1,272 # 800112d8 <cpus+0x8>
    800021d0:	95be                	add	a1,a1,a5
    800021d2:	06048513          	addi	a0,s1,96
    800021d6:	00001097          	auipc	ra,0x1
    800021da:	86e080e7          	jalr	-1938(ra) # 80002a44 <swtch>
    800021de:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021e0:	2781                	sext.w	a5,a5
    800021e2:	079e                	slli	a5,a5,0x7
    800021e4:	97ca                	add	a5,a5,s2
    800021e6:	0b37a623          	sw	s3,172(a5)
}
    800021ea:	70a2                	ld	ra,40(sp)
    800021ec:	7402                	ld	s0,32(sp)
    800021ee:	64e2                	ld	s1,24(sp)
    800021f0:	6942                	ld	s2,16(sp)
    800021f2:	69a2                	ld	s3,8(sp)
    800021f4:	6145                	addi	sp,sp,48
    800021f6:	8082                	ret
    panic("sched p->lock");
    800021f8:	00006517          	auipc	a0,0x6
    800021fc:	00850513          	addi	a0,a0,8 # 80008200 <digits+0x1c0>
    80002200:	ffffe097          	auipc	ra,0xffffe
    80002204:	32a080e7          	jalr	810(ra) # 8000052a <panic>
    panic("sched locks");
    80002208:	00006517          	auipc	a0,0x6
    8000220c:	00850513          	addi	a0,a0,8 # 80008210 <digits+0x1d0>
    80002210:	ffffe097          	auipc	ra,0xffffe
    80002214:	31a080e7          	jalr	794(ra) # 8000052a <panic>
    panic("sched running");
    80002218:	00006517          	auipc	a0,0x6
    8000221c:	00850513          	addi	a0,a0,8 # 80008220 <digits+0x1e0>
    80002220:	ffffe097          	auipc	ra,0xffffe
    80002224:	30a080e7          	jalr	778(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002228:	00006517          	auipc	a0,0x6
    8000222c:	00850513          	addi	a0,a0,8 # 80008230 <digits+0x1f0>
    80002230:	ffffe097          	auipc	ra,0xffffe
    80002234:	2fa080e7          	jalr	762(ra) # 8000052a <panic>

0000000080002238 <yield>:
{
    80002238:	1101                	addi	sp,sp,-32
    8000223a:	ec06                	sd	ra,24(sp)
    8000223c:	e822                	sd	s0,16(sp)
    8000223e:	e426                	sd	s1,8(sp)
    80002240:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	73c080e7          	jalr	1852(ra) # 8000197e <myproc>
    8000224a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	976080e7          	jalr	-1674(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002254:	478d                	li	a5,3
    80002256:	cc9c                	sw	a5,24(s1)
  p->ready = ticks; //just for logics, never used!
    80002258:	00007797          	auipc	a5,0x7
    8000225c:	dd87a783          	lw	a5,-552(a5) # 80009030 <ticks>
    80002260:	18f4a623          	sw	a5,396(s1)
  sched();
    80002264:	00000097          	auipc	ra,0x0
    80002268:	efe080e7          	jalr	-258(ra) # 80002162 <sched>
  release(&p->lock);
    8000226c:	8526                	mv	a0,s1
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a08080e7          	jalr	-1528(ra) # 80000c76 <release>
}
    80002276:	60e2                	ld	ra,24(sp)
    80002278:	6442                	ld	s0,16(sp)
    8000227a:	64a2                	ld	s1,8(sp)
    8000227c:	6105                	addi	sp,sp,32
    8000227e:	8082                	ret

0000000080002280 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002280:	7179                	addi	sp,sp,-48
    80002282:	f406                	sd	ra,40(sp)
    80002284:	f022                	sd	s0,32(sp)
    80002286:	ec26                	sd	s1,24(sp)
    80002288:	e84a                	sd	s2,16(sp)
    8000228a:	e44e                	sd	s3,8(sp)
    8000228c:	1800                	addi	s0,sp,48
    8000228e:	89aa                	mv	s3,a0
    80002290:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	6ec080e7          	jalr	1772(ra) # 8000197e <myproc>
    8000229a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	926080e7          	jalr	-1754(ra) # 80000bc2 <acquire>
  release(lk);
    800022a4:	854a                	mv	a0,s2
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	9d0080e7          	jalr	-1584(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    800022ae:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022b2:	4789                	li	a5,2
    800022b4:	cc9c                	sw	a5,24(s1)

  sched();
    800022b6:	00000097          	auipc	ra,0x0
    800022ba:	eac080e7          	jalr	-340(ra) # 80002162 <sched>

  // Tidy up.
  p->chan = 0;
    800022be:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022c2:	8526                	mv	a0,s1
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	9b2080e7          	jalr	-1614(ra) # 80000c76 <release>
  acquire(lk);
    800022cc:	854a                	mv	a0,s2
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	8f4080e7          	jalr	-1804(ra) # 80000bc2 <acquire>
}
    800022d6:	70a2                	ld	ra,40(sp)
    800022d8:	7402                	ld	s0,32(sp)
    800022da:	64e2                	ld	s1,24(sp)
    800022dc:	6942                	ld	s2,16(sp)
    800022de:	69a2                	ld	s3,8(sp)
    800022e0:	6145                	addi	sp,sp,48
    800022e2:	8082                	ret

00000000800022e4 <wait>:
{
    800022e4:	715d                	addi	sp,sp,-80
    800022e6:	e486                	sd	ra,72(sp)
    800022e8:	e0a2                	sd	s0,64(sp)
    800022ea:	fc26                	sd	s1,56(sp)
    800022ec:	f84a                	sd	s2,48(sp)
    800022ee:	f44e                	sd	s3,40(sp)
    800022f0:	f052                	sd	s4,32(sp)
    800022f2:	ec56                	sd	s5,24(sp)
    800022f4:	e85a                	sd	s6,16(sp)
    800022f6:	e45e                	sd	s7,8(sp)
    800022f8:	e062                	sd	s8,0(sp)
    800022fa:	0880                	addi	s0,sp,80
    800022fc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	680080e7          	jalr	1664(ra) # 8000197e <myproc>
    80002306:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002308:	0000f517          	auipc	a0,0xf
    8000230c:	fb050513          	addi	a0,a0,-80 # 800112b8 <wait_lock>
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	8b2080e7          	jalr	-1870(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002318:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000231a:	4a15                	li	s4,5
        havekids = 1;
    8000231c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000231e:	00015997          	auipc	s3,0x15
    80002322:	7b298993          	addi	s3,s3,1970 # 80017ad0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002326:	0000fc17          	auipc	s8,0xf
    8000232a:	f92c0c13          	addi	s8,s8,-110 # 800112b8 <wait_lock>
    havekids = 0;
    8000232e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002330:	0000f497          	auipc	s1,0xf
    80002334:	3a048493          	addi	s1,s1,928 # 800116d0 <proc>
    80002338:	a0bd                	j	800023a6 <wait+0xc2>
          pid = np->pid;
    8000233a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000233e:	000b0e63          	beqz	s6,8000235a <wait+0x76>
    80002342:	4691                	li	a3,4
    80002344:	02c48613          	addi	a2,s1,44
    80002348:	85da                	mv	a1,s6
    8000234a:	05093503          	ld	a0,80(s2)
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	2f0080e7          	jalr	752(ra) # 8000163e <copyout>
    80002356:	02054563          	bltz	a0,80002380 <wait+0x9c>
          freeproc(np);
    8000235a:	8526                	mv	a0,s1
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	7d4080e7          	jalr	2004(ra) # 80001b30 <freeproc>
          release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	910080e7          	jalr	-1776(ra) # 80000c76 <release>
          release(&wait_lock);
    8000236e:	0000f517          	auipc	a0,0xf
    80002372:	f4a50513          	addi	a0,a0,-182 # 800112b8 <wait_lock>
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	900080e7          	jalr	-1792(ra) # 80000c76 <release>
          return pid;
    8000237e:	a09d                	j	800023e4 <wait+0x100>
            release(&np->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	8f4080e7          	jalr	-1804(ra) # 80000c76 <release>
            release(&wait_lock);
    8000238a:	0000f517          	auipc	a0,0xf
    8000238e:	f2e50513          	addi	a0,a0,-210 # 800112b8 <wait_lock>
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	8e4080e7          	jalr	-1820(ra) # 80000c76 <release>
            return -1;
    8000239a:	59fd                	li	s3,-1
    8000239c:	a0a1                	j	800023e4 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000239e:	19048493          	addi	s1,s1,400
    800023a2:	03348463          	beq	s1,s3,800023ca <wait+0xe6>
      if(np->parent == p){
    800023a6:	7c9c                	ld	a5,56(s1)
    800023a8:	ff279be3          	bne	a5,s2,8000239e <wait+0xba>
        acquire(&np->lock);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	814080e7          	jalr	-2028(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800023b6:	4c9c                	lw	a5,24(s1)
    800023b8:	f94781e3          	beq	a5,s4,8000233a <wait+0x56>
        release(&np->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8b8080e7          	jalr	-1864(ra) # 80000c76 <release>
        havekids = 1;
    800023c6:	8756                	mv	a4,s5
    800023c8:	bfd9                	j	8000239e <wait+0xba>
    if(!havekids || p->killed){
    800023ca:	c701                	beqz	a4,800023d2 <wait+0xee>
    800023cc:	02892783          	lw	a5,40(s2)
    800023d0:	c79d                	beqz	a5,800023fe <wait+0x11a>
      release(&wait_lock);
    800023d2:	0000f517          	auipc	a0,0xf
    800023d6:	ee650513          	addi	a0,a0,-282 # 800112b8 <wait_lock>
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	89c080e7          	jalr	-1892(ra) # 80000c76 <release>
      return -1;
    800023e2:	59fd                	li	s3,-1
}
    800023e4:	854e                	mv	a0,s3
    800023e6:	60a6                	ld	ra,72(sp)
    800023e8:	6406                	ld	s0,64(sp)
    800023ea:	74e2                	ld	s1,56(sp)
    800023ec:	7942                	ld	s2,48(sp)
    800023ee:	79a2                	ld	s3,40(sp)
    800023f0:	7a02                	ld	s4,32(sp)
    800023f2:	6ae2                	ld	s5,24(sp)
    800023f4:	6b42                	ld	s6,16(sp)
    800023f6:	6ba2                	ld	s7,8(sp)
    800023f8:	6c02                	ld	s8,0(sp)
    800023fa:	6161                	addi	sp,sp,80
    800023fc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023fe:	85e2                	mv	a1,s8
    80002400:	854a                	mv	a0,s2
    80002402:	00000097          	auipc	ra,0x0
    80002406:	e7e080e7          	jalr	-386(ra) # 80002280 <sleep>
    havekids = 0;
    8000240a:	b715                	j	8000232e <wait+0x4a>

000000008000240c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000240c:	7139                	addi	sp,sp,-64
    8000240e:	fc06                	sd	ra,56(sp)
    80002410:	f822                	sd	s0,48(sp)
    80002412:	f426                	sd	s1,40(sp)
    80002414:	f04a                	sd	s2,32(sp)
    80002416:	ec4e                	sd	s3,24(sp)
    80002418:	e852                	sd	s4,16(sp)
    8000241a:	e456                	sd	s5,8(sp)
    8000241c:	e05a                	sd	s6,0(sp)
    8000241e:	0080                	addi	s0,sp,64
    80002420:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002422:	0000f497          	auipc	s1,0xf
    80002426:	2ae48493          	addi	s1,s1,686 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000242a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000242c:	4b0d                	li	s6,3
        p->ready = ticks;
    8000242e:	00007a97          	auipc	s5,0x7
    80002432:	c02a8a93          	addi	s5,s5,-1022 # 80009030 <ticks>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002436:	00015917          	auipc	s2,0x15
    8000243a:	69a90913          	addi	s2,s2,1690 # 80017ad0 <tickslock>
    8000243e:	a811                	j	80002452 <wakeup+0x46>
      }
      release(&p->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	834080e7          	jalr	-1996(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000244a:	19048493          	addi	s1,s1,400
    8000244e:	03248a63          	beq	s1,s2,80002482 <wakeup+0x76>
    if(p != myproc()){
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	52c080e7          	jalr	1324(ra) # 8000197e <myproc>
    8000245a:	fea488e3          	beq	s1,a0,8000244a <wakeup+0x3e>
      acquire(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	ffffe097          	auipc	ra,0xffffe
    80002464:	762080e7          	jalr	1890(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002468:	4c9c                	lw	a5,24(s1)
    8000246a:	fd379be3          	bne	a5,s3,80002440 <wakeup+0x34>
    8000246e:	709c                	ld	a5,32(s1)
    80002470:	fd4798e3          	bne	a5,s4,80002440 <wakeup+0x34>
        p->state = RUNNABLE;
    80002474:	0164ac23          	sw	s6,24(s1)
        p->ready = ticks;
    80002478:	000aa783          	lw	a5,0(s5)
    8000247c:	18f4a623          	sw	a5,396(s1)
    80002480:	b7c1                	j	80002440 <wakeup+0x34>
    }
  }
}
    80002482:	70e2                	ld	ra,56(sp)
    80002484:	7442                	ld	s0,48(sp)
    80002486:	74a2                	ld	s1,40(sp)
    80002488:	7902                	ld	s2,32(sp)
    8000248a:	69e2                	ld	s3,24(sp)
    8000248c:	6a42                	ld	s4,16(sp)
    8000248e:	6aa2                	ld	s5,8(sp)
    80002490:	6b02                	ld	s6,0(sp)
    80002492:	6121                	addi	sp,sp,64
    80002494:	8082                	ret

0000000080002496 <reparent>:
{
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	e052                	sd	s4,0(sp)
    800024a4:	1800                	addi	s0,sp,48
    800024a6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a8:	0000f497          	auipc	s1,0xf
    800024ac:	22848493          	addi	s1,s1,552 # 800116d0 <proc>
      pp->parent = initproc;
    800024b0:	00007a17          	auipc	s4,0x7
    800024b4:	b78a0a13          	addi	s4,s4,-1160 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b8:	00015997          	auipc	s3,0x15
    800024bc:	61898993          	addi	s3,s3,1560 # 80017ad0 <tickslock>
    800024c0:	a029                	j	800024ca <reparent+0x34>
    800024c2:	19048493          	addi	s1,s1,400
    800024c6:	01348d63          	beq	s1,s3,800024e0 <reparent+0x4a>
    if(pp->parent == p){
    800024ca:	7c9c                	ld	a5,56(s1)
    800024cc:	ff279be3          	bne	a5,s2,800024c2 <reparent+0x2c>
      pp->parent = initproc;
    800024d0:	000a3503          	ld	a0,0(s4)
    800024d4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024d6:	00000097          	auipc	ra,0x0
    800024da:	f36080e7          	jalr	-202(ra) # 8000240c <wakeup>
    800024de:	b7d5                	j	800024c2 <reparent+0x2c>
}
    800024e0:	70a2                	ld	ra,40(sp)
    800024e2:	7402                	ld	s0,32(sp)
    800024e4:	64e2                	ld	s1,24(sp)
    800024e6:	6942                	ld	s2,16(sp)
    800024e8:	69a2                	ld	s3,8(sp)
    800024ea:	6a02                	ld	s4,0(sp)
    800024ec:	6145                	addi	sp,sp,48
    800024ee:	8082                	ret

00000000800024f0 <exit>:
{
    800024f0:	7179                	addi	sp,sp,-48
    800024f2:	f406                	sd	ra,40(sp)
    800024f4:	f022                	sd	s0,32(sp)
    800024f6:	ec26                	sd	s1,24(sp)
    800024f8:	e84a                	sd	s2,16(sp)
    800024fa:	e44e                	sd	s3,8(sp)
    800024fc:	e052                	sd	s4,0(sp)
    800024fe:	1800                	addi	s0,sp,48
    80002500:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	47c080e7          	jalr	1148(ra) # 8000197e <myproc>
    8000250a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000250c:	00007797          	auipc	a5,0x7
    80002510:	b1c7b783          	ld	a5,-1252(a5) # 80009028 <initproc>
    80002514:	0d050493          	addi	s1,a0,208
    80002518:	15050913          	addi	s2,a0,336
    8000251c:	02a79363          	bne	a5,a0,80002542 <exit+0x52>
    panic("init exiting");
    80002520:	00006517          	auipc	a0,0x6
    80002524:	d2850513          	addi	a0,a0,-728 # 80008248 <digits+0x208>
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	002080e7          	jalr	2(ra) # 8000052a <panic>
      fileclose(f);
    80002530:	00002097          	auipc	ra,0x2
    80002534:	5ca080e7          	jalr	1482(ra) # 80004afa <fileclose>
      p->ofile[fd] = 0;
    80002538:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000253c:	04a1                	addi	s1,s1,8
    8000253e:	01248563          	beq	s1,s2,80002548 <exit+0x58>
    if(p->ofile[fd]){
    80002542:	6088                	ld	a0,0(s1)
    80002544:	f575                	bnez	a0,80002530 <exit+0x40>
    80002546:	bfdd                	j	8000253c <exit+0x4c>
  begin_op();
    80002548:	00002097          	auipc	ra,0x2
    8000254c:	0e6080e7          	jalr	230(ra) # 8000462e <begin_op>
  iput(p->cwd);
    80002550:	1509b503          	ld	a0,336(s3)
    80002554:	00002097          	auipc	ra,0x2
    80002558:	8be080e7          	jalr	-1858(ra) # 80003e12 <iput>
  end_op();
    8000255c:	00002097          	auipc	ra,0x2
    80002560:	152080e7          	jalr	338(ra) # 800046ae <end_op>
  p->cwd = 0;
    80002564:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002568:	0000f497          	auipc	s1,0xf
    8000256c:	d5048493          	addi	s1,s1,-688 # 800112b8 <wait_lock>
    80002570:	8526                	mv	a0,s1
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	650080e7          	jalr	1616(ra) # 80000bc2 <acquire>
  reparent(p);
    8000257a:	854e                	mv	a0,s3
    8000257c:	00000097          	auipc	ra,0x0
    80002580:	f1a080e7          	jalr	-230(ra) # 80002496 <reparent>
  wakeup(p->parent);
    80002584:	0389b503          	ld	a0,56(s3)
    80002588:	00000097          	auipc	ra,0x0
    8000258c:	e84080e7          	jalr	-380(ra) # 8000240c <wakeup>
  acquire(&p->lock);
    80002590:	854e                	mv	a0,s3
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	630080e7          	jalr	1584(ra) # 80000bc2 <acquire>
  p->xstate = status;
    8000259a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000259e:	4795                	li	a5,5
    800025a0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800025a4:	8526                	mv	a0,s1
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	6d0080e7          	jalr	1744(ra) # 80000c76 <release>
  sched();
    800025ae:	00000097          	auipc	ra,0x0
    800025b2:	bb4080e7          	jalr	-1100(ra) # 80002162 <sched>
  panic("zombie exit");
    800025b6:	00006517          	auipc	a0,0x6
    800025ba:	ca250513          	addi	a0,a0,-862 # 80008258 <digits+0x218>
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	f6c080e7          	jalr	-148(ra) # 8000052a <panic>

00000000800025c6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800025c6:	7179                	addi	sp,sp,-48
    800025c8:	f406                	sd	ra,40(sp)
    800025ca:	f022                	sd	s0,32(sp)
    800025cc:	ec26                	sd	s1,24(sp)
    800025ce:	e84a                	sd	s2,16(sp)
    800025d0:	e44e                	sd	s3,8(sp)
    800025d2:	1800                	addi	s0,sp,48
    800025d4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025d6:	0000f497          	auipc	s1,0xf
    800025da:	0fa48493          	addi	s1,s1,250 # 800116d0 <proc>
    800025de:	00015997          	auipc	s3,0x15
    800025e2:	4f298993          	addi	s3,s3,1266 # 80017ad0 <tickslock>
    acquire(&p->lock);
    800025e6:	8526                	mv	a0,s1
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	5da080e7          	jalr	1498(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800025f0:	589c                	lw	a5,48(s1)
    800025f2:	01278d63          	beq	a5,s2,8000260c <kill+0x46>
        p->ready = ticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	67e080e7          	jalr	1662(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002600:	19048493          	addi	s1,s1,400
    80002604:	ff3491e3          	bne	s1,s3,800025e6 <kill+0x20>
  }
  return -1;
    80002608:	557d                	li	a0,-1
    8000260a:	a829                	j	80002624 <kill+0x5e>
      p->killed = 1;
    8000260c:	4785                	li	a5,1
    8000260e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002610:	4c98                	lw	a4,24(s1)
    80002612:	4789                	li	a5,2
    80002614:	00f70f63          	beq	a4,a5,80002632 <kill+0x6c>
      release(&p->lock);
    80002618:	8526                	mv	a0,s1
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	65c080e7          	jalr	1628(ra) # 80000c76 <release>
      return 0;
    80002622:	4501                	li	a0,0
}
    80002624:	70a2                	ld	ra,40(sp)
    80002626:	7402                	ld	s0,32(sp)
    80002628:	64e2                	ld	s1,24(sp)
    8000262a:	6942                	ld	s2,16(sp)
    8000262c:	69a2                	ld	s3,8(sp)
    8000262e:	6145                	addi	sp,sp,48
    80002630:	8082                	ret
        p->state = RUNNABLE;
    80002632:	478d                	li	a5,3
    80002634:	cc9c                	sw	a5,24(s1)
        p->ready = ticks;
    80002636:	00007797          	auipc	a5,0x7
    8000263a:	9fa7a783          	lw	a5,-1542(a5) # 80009030 <ticks>
    8000263e:	18f4a623          	sw	a5,396(s1)
    80002642:	bfd9                	j	80002618 <kill+0x52>

0000000080002644 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002644:	7179                	addi	sp,sp,-48
    80002646:	f406                	sd	ra,40(sp)
    80002648:	f022                	sd	s0,32(sp)
    8000264a:	ec26                	sd	s1,24(sp)
    8000264c:	e84a                	sd	s2,16(sp)
    8000264e:	e44e                	sd	s3,8(sp)
    80002650:	e052                	sd	s4,0(sp)
    80002652:	1800                	addi	s0,sp,48
    80002654:	84aa                	mv	s1,a0
    80002656:	892e                	mv	s2,a1
    80002658:	89b2                	mv	s3,a2
    8000265a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000265c:	fffff097          	auipc	ra,0xfffff
    80002660:	322080e7          	jalr	802(ra) # 8000197e <myproc>
  if(user_dst){
    80002664:	c08d                	beqz	s1,80002686 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002666:	86d2                	mv	a3,s4
    80002668:	864e                	mv	a2,s3
    8000266a:	85ca                	mv	a1,s2
    8000266c:	6928                	ld	a0,80(a0)
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	fd0080e7          	jalr	-48(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002676:	70a2                	ld	ra,40(sp)
    80002678:	7402                	ld	s0,32(sp)
    8000267a:	64e2                	ld	s1,24(sp)
    8000267c:	6942                	ld	s2,16(sp)
    8000267e:	69a2                	ld	s3,8(sp)
    80002680:	6a02                	ld	s4,0(sp)
    80002682:	6145                	addi	sp,sp,48
    80002684:	8082                	ret
    memmove((char *)dst, src, len);
    80002686:	000a061b          	sext.w	a2,s4
    8000268a:	85ce                	mv	a1,s3
    8000268c:	854a                	mv	a0,s2
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	68c080e7          	jalr	1676(ra) # 80000d1a <memmove>
    return 0;
    80002696:	8526                	mv	a0,s1
    80002698:	bff9                	j	80002676 <either_copyout+0x32>

000000008000269a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000269a:	7179                	addi	sp,sp,-48
    8000269c:	f406                	sd	ra,40(sp)
    8000269e:	f022                	sd	s0,32(sp)
    800026a0:	ec26                	sd	s1,24(sp)
    800026a2:	e84a                	sd	s2,16(sp)
    800026a4:	e44e                	sd	s3,8(sp)
    800026a6:	e052                	sd	s4,0(sp)
    800026a8:	1800                	addi	s0,sp,48
    800026aa:	892a                	mv	s2,a0
    800026ac:	84ae                	mv	s1,a1
    800026ae:	89b2                	mv	s3,a2
    800026b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026b2:	fffff097          	auipc	ra,0xfffff
    800026b6:	2cc080e7          	jalr	716(ra) # 8000197e <myproc>
  if(user_src){
    800026ba:	c08d                	beqz	s1,800026dc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026bc:	86d2                	mv	a3,s4
    800026be:	864e                	mv	a2,s3
    800026c0:	85ca                	mv	a1,s2
    800026c2:	6928                	ld	a0,80(a0)
    800026c4:	fffff097          	auipc	ra,0xfffff
    800026c8:	006080e7          	jalr	6(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026cc:	70a2                	ld	ra,40(sp)
    800026ce:	7402                	ld	s0,32(sp)
    800026d0:	64e2                	ld	s1,24(sp)
    800026d2:	6942                	ld	s2,16(sp)
    800026d4:	69a2                	ld	s3,8(sp)
    800026d6:	6a02                	ld	s4,0(sp)
    800026d8:	6145                	addi	sp,sp,48
    800026da:	8082                	ret
    memmove(dst, (char*)src, len);
    800026dc:	000a061b          	sext.w	a2,s4
    800026e0:	85ce                	mv	a1,s3
    800026e2:	854a                	mv	a0,s2
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	636080e7          	jalr	1590(ra) # 80000d1a <memmove>
    return 0;
    800026ec:	8526                	mv	a0,s1
    800026ee:	bff9                	j	800026cc <either_copyin+0x32>

00000000800026f0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800026f0:	715d                	addi	sp,sp,-80
    800026f2:	e486                	sd	ra,72(sp)
    800026f4:	e0a2                	sd	s0,64(sp)
    800026f6:	fc26                	sd	s1,56(sp)
    800026f8:	f84a                	sd	s2,48(sp)
    800026fa:	f44e                	sd	s3,40(sp)
    800026fc:	f052                	sd	s4,32(sp)
    800026fe:	ec56                	sd	s5,24(sp)
    80002700:	e85a                	sd	s6,16(sp)
    80002702:	e45e                	sd	s7,8(sp)
    80002704:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002706:	00006517          	auipc	a0,0x6
    8000270a:	9c250513          	addi	a0,a0,-1598 # 800080c8 <digits+0x88>
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	e66080e7          	jalr	-410(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002716:	0000f497          	auipc	s1,0xf
    8000271a:	11248493          	addi	s1,s1,274 # 80011828 <proc+0x158>
    8000271e:	00015917          	auipc	s2,0x15
    80002722:	50a90913          	addi	s2,s2,1290 # 80017c28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002726:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002728:	00006997          	auipc	s3,0x6
    8000272c:	b4098993          	addi	s3,s3,-1216 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002730:	00006a97          	auipc	s5,0x6
    80002734:	b40a8a93          	addi	s5,s5,-1216 # 80008270 <digits+0x230>
    printf("\n");
    80002738:	00006a17          	auipc	s4,0x6
    8000273c:	990a0a13          	addi	s4,s4,-1648 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002740:	00006b97          	auipc	s7,0x6
    80002744:	b68b8b93          	addi	s7,s7,-1176 # 800082a8 <deacyfactors>
    80002748:	a00d                	j	8000276a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000274a:	ed86a583          	lw	a1,-296(a3)
    8000274e:	8556                	mv	a0,s5
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	e24080e7          	jalr	-476(ra) # 80000574 <printf>
    printf("\n");
    80002758:	8552                	mv	a0,s4
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	e1a080e7          	jalr	-486(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002762:	19048493          	addi	s1,s1,400
    80002766:	03248263          	beq	s1,s2,8000278a <procdump+0x9a>
    if(p->state == UNUSED)
    8000276a:	86a6                	mv	a3,s1
    8000276c:	ec04a783          	lw	a5,-320(s1)
    80002770:	dbed                	beqz	a5,80002762 <procdump+0x72>
      state = "???";
    80002772:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002774:	fcfb6be3          	bltu	s6,a5,8000274a <procdump+0x5a>
    80002778:	02079713          	slli	a4,a5,0x20
    8000277c:	01d75793          	srli	a5,a4,0x1d
    80002780:	97de                	add	a5,a5,s7
    80002782:	6f90                	ld	a2,24(a5)
    80002784:	f279                	bnez	a2,8000274a <procdump+0x5a>
      state = "???";
    80002786:	864e                	mv	a2,s3
    80002788:	b7c9                	j	8000274a <procdump+0x5a>
  }
}
    8000278a:	60a6                	ld	ra,72(sp)
    8000278c:	6406                	ld	s0,64(sp)
    8000278e:	74e2                	ld	s1,56(sp)
    80002790:	7942                	ld	s2,48(sp)
    80002792:	79a2                	ld	s3,40(sp)
    80002794:	7a02                	ld	s4,32(sp)
    80002796:	6ae2                	ld	s5,24(sp)
    80002798:	6b42                	ld	s6,16(sp)
    8000279a:	6ba2                	ld	s7,8(sp)
    8000279c:	6161                	addi	sp,sp,80
    8000279e:	8082                	ret

00000000800027a0 <trace>:

int
trace(int mask, int pid)
{
    800027a0:	7179                	addi	sp,sp,-48
    800027a2:	f406                	sd	ra,40(sp)
    800027a4:	f022                	sd	s0,32(sp)
    800027a6:	ec26                	sd	s1,24(sp)
    800027a8:	e84a                	sd	s2,16(sp)
    800027aa:	e44e                	sd	s3,8(sp)
    800027ac:	e052                	sd	s4,0(sp)
    800027ae:	1800                	addi	s0,sp,48
    800027b0:	8a2a                	mv	s4,a0
    800027b2:	892e                	mv	s2,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800027b4:	0000f497          	auipc	s1,0xf
    800027b8:	f1c48493          	addi	s1,s1,-228 # 800116d0 <proc>
    800027bc:	00015997          	auipc	s3,0x15
    800027c0:	31498993          	addi	s3,s3,788 # 80017ad0 <tickslock>
    acquire(&p->lock);
    800027c4:	8526                	mv	a0,s1
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	3fc080e7          	jalr	1020(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800027ce:	589c                	lw	a5,48(s1)
    800027d0:	01278d63          	beq	a5,s2,800027ea <trace+0x4a>
      p->mask = mask;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027d4:	8526                	mv	a0,s1
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	4a0080e7          	jalr	1184(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800027de:	19048493          	addi	s1,s1,400
    800027e2:	ff3491e3          	bne	s1,s3,800027c4 <trace+0x24>
  }
  return -1;
    800027e6:	557d                	li	a0,-1
    800027e8:	a809                	j	800027fa <trace+0x5a>
      p->mask = mask;
    800027ea:	1944a423          	sw	s4,392(s1)
      release(&p->lock);
    800027ee:	8526                	mv	a0,s1
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	486080e7          	jalr	1158(ra) # 80000c76 <release>
      return 0;
    800027f8:	4501                	li	a0,0
}
    800027fa:	70a2                	ld	ra,40(sp)
    800027fc:	7402                	ld	s0,32(sp)
    800027fe:	64e2                	ld	s1,24(sp)
    80002800:	6942                	ld	s2,16(sp)
    80002802:	69a2                	ld	s3,8(sp)
    80002804:	6a02                	ld	s4,0(sp)
    80002806:	6145                	addi	sp,sp,48
    80002808:	8082                	ret

000000008000280a <updateticks>:

void
updateticks(void)
{
    8000280a:	7139                	addi	sp,sp,-64
    8000280c:	fc06                	sd	ra,56(sp)
    8000280e:	f822                	sd	s0,48(sp)
    80002810:	f426                	sd	s1,40(sp)
    80002812:	f04a                	sd	s2,32(sp)
    80002814:	ec4e                	sd	s3,24(sp)
    80002816:	e852                	sd	s4,16(sp)
    80002818:	e456                	sd	s5,8(sp)
    8000281a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++){
    8000281c:	0000f497          	auipc	s1,0xf
    80002820:	eb448493          	addi	s1,s1,-332 # 800116d0 <proc>
    acquire(&p->lock);
    if(p->state == SLEEPING){
    80002824:	4989                	li	s3,2
      p->stime++;
    }
    else if(p->state == RUNNABLE){
    80002826:	4a0d                	li	s4,3
      p->retime++;
    }
    else if(p->state == RUNNING){
    80002828:	4a91                	li	s5,4
  for(p = proc; p < &proc[NPROC]; p++){
    8000282a:	00015917          	auipc	s2,0x15
    8000282e:	2a690913          	addi	s2,s2,678 # 80017ad0 <tickslock>
    80002832:	a839                	j	80002850 <updateticks+0x46>
      p->stime++;
    80002834:	1704a783          	lw	a5,368(s1)
    80002838:	2785                	addiw	a5,a5,1
    8000283a:	16f4a823          	sw	a5,368(s1)
      p->rutime++;
    }
    release(&p->lock);
    8000283e:	8526                	mv	a0,s1
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	436080e7          	jalr	1078(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002848:	19048493          	addi	s1,s1,400
    8000284c:	03248a63          	beq	s1,s2,80002880 <updateticks+0x76>
    acquire(&p->lock);
    80002850:	8526                	mv	a0,s1
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	370080e7          	jalr	880(ra) # 80000bc2 <acquire>
    if(p->state == SLEEPING){
    8000285a:	4c9c                	lw	a5,24(s1)
    8000285c:	fd378ce3          	beq	a5,s3,80002834 <updateticks+0x2a>
    else if(p->state == RUNNABLE){
    80002860:	01478a63          	beq	a5,s4,80002874 <updateticks+0x6a>
    else if(p->state == RUNNING){
    80002864:	fd579de3          	bne	a5,s5,8000283e <updateticks+0x34>
      p->rutime++;
    80002868:	1784a783          	lw	a5,376(s1)
    8000286c:	2785                	addiw	a5,a5,1
    8000286e:	16f4ac23          	sw	a5,376(s1)
    80002872:	b7f1                	j	8000283e <updateticks+0x34>
      p->retime++;
    80002874:	1744a783          	lw	a5,372(s1)
    80002878:	2785                	addiw	a5,a5,1
    8000287a:	16f4aa23          	sw	a5,372(s1)
    8000287e:	b7c1                	j	8000283e <updateticks+0x34>
  }
}
    80002880:	70e2                	ld	ra,56(sp)
    80002882:	7442                	ld	s0,48(sp)
    80002884:	74a2                	ld	s1,40(sp)
    80002886:	7902                	ld	s2,32(sp)
    80002888:	69e2                	ld	s3,24(sp)
    8000288a:	6a42                	ld	s4,16(sp)
    8000288c:	6aa2                	ld	s5,8(sp)
    8000288e:	6121                	addi	sp,sp,64
    80002890:	8082                	ret

0000000080002892 <wait_stat>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait_stat(uint64 stataddr, uint64 perfaddr)
{
    80002892:	711d                	addi	sp,sp,-96
    80002894:	ec86                	sd	ra,88(sp)
    80002896:	e8a2                	sd	s0,80(sp)
    80002898:	e4a6                	sd	s1,72(sp)
    8000289a:	e0ca                	sd	s2,64(sp)
    8000289c:	fc4e                	sd	s3,56(sp)
    8000289e:	f852                	sd	s4,48(sp)
    800028a0:	f456                	sd	s5,40(sp)
    800028a2:	f05a                	sd	s6,32(sp)
    800028a4:	ec5e                	sd	s7,24(sp)
    800028a6:	e862                	sd	s8,16(sp)
    800028a8:	e466                	sd	s9,8(sp)
    800028aa:	1080                	addi	s0,sp,96
    800028ac:	8baa                	mv	s7,a0
    800028ae:	8b2e                	mv	s6,a1
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	0ce080e7          	jalr	206(ra) # 8000197e <myproc>
    800028b8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800028ba:	0000f517          	auipc	a0,0xf
    800028be:	9fe50513          	addi	a0,a0,-1538 # 800112b8 <wait_lock>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800028ca:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    800028cc:	4a15                	li	s4,5
        havekids = 1;
    800028ce:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800028d0:	00015997          	auipc	s3,0x15
    800028d4:	20098993          	addi	s3,s3,512 # 80017ad0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800028d8:	0000fc97          	auipc	s9,0xf
    800028dc:	9e0c8c93          	addi	s9,s9,-1568 # 800112b8 <wait_lock>
    havekids = 0;
    800028e0:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800028e2:	0000f497          	auipc	s1,0xf
    800028e6:	dee48493          	addi	s1,s1,-530 # 800116d0 <proc>
    800028ea:	a065                	j	80002992 <wait_stat+0x100>
          pid = np->pid;
    800028ec:	0304a983          	lw	s3,48(s1)
          if(stataddr != 0 && copyout(p->pagetable, stataddr, (char *)&np->xstate,
    800028f0:	000b8e63          	beqz	s7,8000290c <wait_stat+0x7a>
    800028f4:	4691                	li	a3,4
    800028f6:	02c48613          	addi	a2,s1,44
    800028fa:	85de                	mv	a1,s7
    800028fc:	05093503          	ld	a0,80(s2)
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	d3e080e7          	jalr	-706(ra) # 8000163e <copyout>
    80002908:	04054363          	bltz	a0,8000294e <wait_stat+0xbc>
          freeproc(np);
    8000290c:	8526                	mv	a0,s1
    8000290e:	fffff097          	auipc	ra,0xfffff
    80002912:	222080e7          	jalr	546(ra) # 80001b30 <freeproc>
          if(perfaddr != 0 && copyout(p->pagetable, perfaddr, (char *)&np->ctime,
    80002916:	000b0e63          	beqz	s6,80002932 <wait_stat+0xa0>
    8000291a:	46e1                	li	a3,24
    8000291c:	16848613          	addi	a2,s1,360
    80002920:	85da                	mv	a1,s6
    80002922:	05093503          	ld	a0,80(s2)
    80002926:	fffff097          	auipc	ra,0xfffff
    8000292a:	d18080e7          	jalr	-744(ra) # 8000163e <copyout>
    8000292e:	02054f63          	bltz	a0,8000296c <wait_stat+0xda>
          release(&np->lock);
    80002932:	8526                	mv	a0,s1
    80002934:	ffffe097          	auipc	ra,0xffffe
    80002938:	342080e7          	jalr	834(ra) # 80000c76 <release>
          release(&wait_lock);
    8000293c:	0000f517          	auipc	a0,0xf
    80002940:	97c50513          	addi	a0,a0,-1668 # 800112b8 <wait_lock>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	332080e7          	jalr	818(ra) # 80000c76 <release>
          return pid;
    8000294c:	a051                	j	800029d0 <wait_stat+0x13e>
            release(&np->lock);
    8000294e:	8526                	mv	a0,s1
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	326080e7          	jalr	806(ra) # 80000c76 <release>
            release(&wait_lock);
    80002958:	0000f517          	auipc	a0,0xf
    8000295c:	96050513          	addi	a0,a0,-1696 # 800112b8 <wait_lock>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	316080e7          	jalr	790(ra) # 80000c76 <release>
            return -1;
    80002968:	59fd                	li	s3,-1
    8000296a:	a09d                	j	800029d0 <wait_stat+0x13e>
            release(&np->lock);
    8000296c:	8526                	mv	a0,s1
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	308080e7          	jalr	776(ra) # 80000c76 <release>
            release(&wait_lock);
    80002976:	0000f517          	auipc	a0,0xf
    8000297a:	94250513          	addi	a0,a0,-1726 # 800112b8 <wait_lock>
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	2f8080e7          	jalr	760(ra) # 80000c76 <release>
            return -1;
    80002986:	59fd                	li	s3,-1
    80002988:	a0a1                	j	800029d0 <wait_stat+0x13e>
    for(np = proc; np < &proc[NPROC]; np++){
    8000298a:	19048493          	addi	s1,s1,400
    8000298e:	03348463          	beq	s1,s3,800029b6 <wait_stat+0x124>
      if(np->parent == p){
    80002992:	7c9c                	ld	a5,56(s1)
    80002994:	ff279be3          	bne	a5,s2,8000298a <wait_stat+0xf8>
        acquire(&np->lock);
    80002998:	8526                	mv	a0,s1
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	228080e7          	jalr	552(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800029a2:	4c9c                	lw	a5,24(s1)
    800029a4:	f54784e3          	beq	a5,s4,800028ec <wait_stat+0x5a>
        release(&np->lock);
    800029a8:	8526                	mv	a0,s1
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	2cc080e7          	jalr	716(ra) # 80000c76 <release>
        havekids = 1;
    800029b2:	8756                	mv	a4,s5
    800029b4:	bfd9                	j	8000298a <wait_stat+0xf8>
    if(!havekids || p->killed){
    800029b6:	c701                	beqz	a4,800029be <wait_stat+0x12c>
    800029b8:	02892783          	lw	a5,40(s2)
    800029bc:	cb85                	beqz	a5,800029ec <wait_stat+0x15a>
      release(&wait_lock);
    800029be:	0000f517          	auipc	a0,0xf
    800029c2:	8fa50513          	addi	a0,a0,-1798 # 800112b8 <wait_lock>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	2b0080e7          	jalr	688(ra) # 80000c76 <release>
      return -1;
    800029ce:	59fd                	li	s3,-1
  }
}
    800029d0:	854e                	mv	a0,s3
    800029d2:	60e6                	ld	ra,88(sp)
    800029d4:	6446                	ld	s0,80(sp)
    800029d6:	64a6                	ld	s1,72(sp)
    800029d8:	6906                	ld	s2,64(sp)
    800029da:	79e2                	ld	s3,56(sp)
    800029dc:	7a42                	ld	s4,48(sp)
    800029de:	7aa2                	ld	s5,40(sp)
    800029e0:	7b02                	ld	s6,32(sp)
    800029e2:	6be2                	ld	s7,24(sp)
    800029e4:	6c42                	ld	s8,16(sp)
    800029e6:	6ca2                	ld	s9,8(sp)
    800029e8:	6125                	addi	sp,sp,96
    800029ea:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800029ec:	85e6                	mv	a1,s9
    800029ee:	854a                	mv	a0,s2
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	890080e7          	jalr	-1904(ra) # 80002280 <sleep>
    havekids = 0;
    800029f8:	b5e5                	j	800028e0 <wait_stat+0x4e>

00000000800029fa <set_priority>:

int
set_priority(int priority)
{
    800029fa:	1101                	addi	sp,sp,-32
    800029fc:	ec06                	sd	ra,24(sp)
    800029fe:	e822                	sd	s0,16(sp)
    80002a00:	e426                	sd	s1,8(sp)
    80002a02:	e04a                	sd	s2,0(sp)
    80002a04:	1000                	addi	s0,sp,32
    80002a06:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002a08:	fffff097          	auipc	ra,0xfffff
    80002a0c:	f76080e7          	jalr	-138(ra) # 8000197e <myproc>

  if(priority < TESTHIGHPRIORITY || priority > TESTLOWPRIORITY)
    80002a10:	fff9071b          	addiw	a4,s2,-1
    80002a14:	4791                	li	a5,4
    80002a16:	02e7e563          	bltu	a5,a4,80002a40 <set_priority+0x46>
    80002a1a:	84aa                	mv	s1,a0
    return -1;
  acquire(&p->lock);
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	1a6080e7          	jalr	422(ra) # 80000bc2 <acquire>
  p->priority = priority;
    80002a24:	1924a223          	sw	s2,388(s1)
  release(&p->lock);
    80002a28:	8526                	mv	a0,s1
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	24c080e7          	jalr	588(ra) # 80000c76 <release>
  return 0;
    80002a32:	4501                	li	a0,0
    80002a34:	60e2                	ld	ra,24(sp)
    80002a36:	6442                	ld	s0,16(sp)
    80002a38:	64a2                	ld	s1,8(sp)
    80002a3a:	6902                	ld	s2,0(sp)
    80002a3c:	6105                	addi	sp,sp,32
    80002a3e:	8082                	ret
    return -1;
    80002a40:	557d                	li	a0,-1
    80002a42:	bfcd                	j	80002a34 <set_priority+0x3a>

0000000080002a44 <swtch>:
    80002a44:	00153023          	sd	ra,0(a0)
    80002a48:	00253423          	sd	sp,8(a0)
    80002a4c:	e900                	sd	s0,16(a0)
    80002a4e:	ed04                	sd	s1,24(a0)
    80002a50:	03253023          	sd	s2,32(a0)
    80002a54:	03353423          	sd	s3,40(a0)
    80002a58:	03453823          	sd	s4,48(a0)
    80002a5c:	03553c23          	sd	s5,56(a0)
    80002a60:	05653023          	sd	s6,64(a0)
    80002a64:	05753423          	sd	s7,72(a0)
    80002a68:	05853823          	sd	s8,80(a0)
    80002a6c:	05953c23          	sd	s9,88(a0)
    80002a70:	07a53023          	sd	s10,96(a0)
    80002a74:	07b53423          	sd	s11,104(a0)
    80002a78:	0005b083          	ld	ra,0(a1)
    80002a7c:	0085b103          	ld	sp,8(a1)
    80002a80:	6980                	ld	s0,16(a1)
    80002a82:	6d84                	ld	s1,24(a1)
    80002a84:	0205b903          	ld	s2,32(a1)
    80002a88:	0285b983          	ld	s3,40(a1)
    80002a8c:	0305ba03          	ld	s4,48(a1)
    80002a90:	0385ba83          	ld	s5,56(a1)
    80002a94:	0405bb03          	ld	s6,64(a1)
    80002a98:	0485bb83          	ld	s7,72(a1)
    80002a9c:	0505bc03          	ld	s8,80(a1)
    80002aa0:	0585bc83          	ld	s9,88(a1)
    80002aa4:	0605bd03          	ld	s10,96(a1)
    80002aa8:	0685bd83          	ld	s11,104(a1)
    80002aac:	8082                	ret

0000000080002aae <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002aae:	1141                	addi	sp,sp,-16
    80002ab0:	e406                	sd	ra,8(sp)
    80002ab2:	e022                	sd	s0,0(sp)
    80002ab4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ab6:	00006597          	auipc	a1,0x6
    80002aba:	83a58593          	addi	a1,a1,-1990 # 800082f0 <states.0+0x30>
    80002abe:	00015517          	auipc	a0,0x15
    80002ac2:	01250513          	addi	a0,a0,18 # 80017ad0 <tickslock>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	06c080e7          	jalr	108(ra) # 80000b32 <initlock>
}
    80002ace:	60a2                	ld	ra,8(sp)
    80002ad0:	6402                	ld	s0,0(sp)
    80002ad2:	0141                	addi	sp,sp,16
    80002ad4:	8082                	ret

0000000080002ad6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002ad6:	1141                	addi	sp,sp,-16
    80002ad8:	e422                	sd	s0,8(sp)
    80002ada:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002adc:	00003797          	auipc	a5,0x3
    80002ae0:	64478793          	addi	a5,a5,1604 # 80006120 <kernelvec>
    80002ae4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ae8:	6422                	ld	s0,8(sp)
    80002aea:	0141                	addi	sp,sp,16
    80002aec:	8082                	ret

0000000080002aee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002aee:	1141                	addi	sp,sp,-16
    80002af0:	e406                	sd	ra,8(sp)
    80002af2:	e022                	sd	s0,0(sp)
    80002af4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	e88080e7          	jalr	-376(ra) # 8000197e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b08:	00004617          	auipc	a2,0x4
    80002b0c:	4f860613          	addi	a2,a2,1272 # 80007000 <_trampoline>
    80002b10:	00004697          	auipc	a3,0x4
    80002b14:	4f068693          	addi	a3,a3,1264 # 80007000 <_trampoline>
    80002b18:	8e91                	sub	a3,a3,a2
    80002b1a:	040007b7          	lui	a5,0x4000
    80002b1e:	17fd                	addi	a5,a5,-1
    80002b20:	07b2                	slli	a5,a5,0xc
    80002b22:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b24:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b28:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b2a:	180026f3          	csrr	a3,satp
    80002b2e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b30:	6d38                	ld	a4,88(a0)
    80002b32:	6134                	ld	a3,64(a0)
    80002b34:	6585                	lui	a1,0x1
    80002b36:	96ae                	add	a3,a3,a1
    80002b38:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b3a:	6d38                	ld	a4,88(a0)
    80002b3c:	00000697          	auipc	a3,0x0
    80002b40:	14668693          	addi	a3,a3,326 # 80002c82 <usertrap>
    80002b44:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b46:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b48:	8692                	mv	a3,tp
    80002b4a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b50:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b54:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b58:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b5c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b5e:	6f18                	ld	a4,24(a4)
    80002b60:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b64:	692c                	ld	a1,80(a0)
    80002b66:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b68:	00004717          	auipc	a4,0x4
    80002b6c:	52870713          	addi	a4,a4,1320 # 80007090 <userret>
    80002b70:	8f11                	sub	a4,a4,a2
    80002b72:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b74:	577d                	li	a4,-1
    80002b76:	177e                	slli	a4,a4,0x3f
    80002b78:	8dd9                	or	a1,a1,a4
    80002b7a:	02000537          	lui	a0,0x2000
    80002b7e:	157d                	addi	a0,a0,-1
    80002b80:	0536                	slli	a0,a0,0xd
    80002b82:	9782                	jalr	a5
}
    80002b84:	60a2                	ld	ra,8(sp)
    80002b86:	6402                	ld	s0,0(sp)
    80002b88:	0141                	addi	sp,sp,16
    80002b8a:	8082                	ret

0000000080002b8c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b8c:	1101                	addi	sp,sp,-32
    80002b8e:	ec06                	sd	ra,24(sp)
    80002b90:	e822                	sd	s0,16(sp)
    80002b92:	e426                	sd	s1,8(sp)
    80002b94:	e04a                	sd	s2,0(sp)
    80002b96:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b98:	00015917          	auipc	s2,0x15
    80002b9c:	f3890913          	addi	s2,s2,-200 # 80017ad0 <tickslock>
    80002ba0:	854a                	mv	a0,s2
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	020080e7          	jalr	32(ra) # 80000bc2 <acquire>
  ticks++;
    80002baa:	00006497          	auipc	s1,0x6
    80002bae:	48648493          	addi	s1,s1,1158 # 80009030 <ticks>
    80002bb2:	409c                	lw	a5,0(s1)
    80002bb4:	2785                	addiw	a5,a5,1
    80002bb6:	c09c                	sw	a5,0(s1)
  updateticks();
    80002bb8:	00000097          	auipc	ra,0x0
    80002bbc:	c52080e7          	jalr	-942(ra) # 8000280a <updateticks>
  wakeup(&ticks);
    80002bc0:	8526                	mv	a0,s1
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	84a080e7          	jalr	-1974(ra) # 8000240c <wakeup>
  release(&tickslock);
    80002bca:	854a                	mv	a0,s2
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	0aa080e7          	jalr	170(ra) # 80000c76 <release>
}
    80002bd4:	60e2                	ld	ra,24(sp)
    80002bd6:	6442                	ld	s0,16(sp)
    80002bd8:	64a2                	ld	s1,8(sp)
    80002bda:	6902                	ld	s2,0(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	e426                	sd	s1,8(sp)
    80002be8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bea:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002bee:	00074d63          	bltz	a4,80002c08 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002bf2:	57fd                	li	a5,-1
    80002bf4:	17fe                	slli	a5,a5,0x3f
    80002bf6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bf8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bfa:	06f70363          	beq	a4,a5,80002c60 <devintr+0x80>
  }
}
    80002bfe:	60e2                	ld	ra,24(sp)
    80002c00:	6442                	ld	s0,16(sp)
    80002c02:	64a2                	ld	s1,8(sp)
    80002c04:	6105                	addi	sp,sp,32
    80002c06:	8082                	ret
     (scause & 0xff) == 9){
    80002c08:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c0c:	46a5                	li	a3,9
    80002c0e:	fed792e3          	bne	a5,a3,80002bf2 <devintr+0x12>
    int irq = plic_claim();
    80002c12:	00003097          	auipc	ra,0x3
    80002c16:	616080e7          	jalr	1558(ra) # 80006228 <plic_claim>
    80002c1a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c1c:	47a9                	li	a5,10
    80002c1e:	02f50763          	beq	a0,a5,80002c4c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c22:	4785                	li	a5,1
    80002c24:	02f50963          	beq	a0,a5,80002c56 <devintr+0x76>
    return 1;
    80002c28:	4505                	li	a0,1
    } else if(irq){
    80002c2a:	d8f1                	beqz	s1,80002bfe <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c2c:	85a6                	mv	a1,s1
    80002c2e:	00005517          	auipc	a0,0x5
    80002c32:	6ca50513          	addi	a0,a0,1738 # 800082f8 <states.0+0x38>
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	93e080e7          	jalr	-1730(ra) # 80000574 <printf>
      plic_complete(irq);
    80002c3e:	8526                	mv	a0,s1
    80002c40:	00003097          	auipc	ra,0x3
    80002c44:	60c080e7          	jalr	1548(ra) # 8000624c <plic_complete>
    return 1;
    80002c48:	4505                	li	a0,1
    80002c4a:	bf55                	j	80002bfe <devintr+0x1e>
      uartintr();
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	d3a080e7          	jalr	-710(ra) # 80000986 <uartintr>
    80002c54:	b7ed                	j	80002c3e <devintr+0x5e>
      virtio_disk_intr();
    80002c56:	00004097          	auipc	ra,0x4
    80002c5a:	a88080e7          	jalr	-1400(ra) # 800066de <virtio_disk_intr>
    80002c5e:	b7c5                	j	80002c3e <devintr+0x5e>
    if(cpuid() == 0){
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	cf2080e7          	jalr	-782(ra) # 80001952 <cpuid>
    80002c68:	c901                	beqz	a0,80002c78 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c6a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c6e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c70:	14479073          	csrw	sip,a5
    return 2;
    80002c74:	4509                	li	a0,2
    80002c76:	b761                	j	80002bfe <devintr+0x1e>
      clockintr();
    80002c78:	00000097          	auipc	ra,0x0
    80002c7c:	f14080e7          	jalr	-236(ra) # 80002b8c <clockintr>
    80002c80:	b7ed                	j	80002c6a <devintr+0x8a>

0000000080002c82 <usertrap>:
{
    80002c82:	1101                	addi	sp,sp,-32
    80002c84:	ec06                	sd	ra,24(sp)
    80002c86:	e822                	sd	s0,16(sp)
    80002c88:	e426                	sd	s1,8(sp)
    80002c8a:	e04a                	sd	s2,0(sp)
    80002c8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c8e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c92:	1007f793          	andi	a5,a5,256
    80002c96:	e3ad                	bnez	a5,80002cf8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c98:	00003797          	auipc	a5,0x3
    80002c9c:	48878793          	addi	a5,a5,1160 # 80006120 <kernelvec>
    80002ca0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	cda080e7          	jalr	-806(ra) # 8000197e <myproc>
    80002cac:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb0:	14102773          	csrr	a4,sepc
    80002cb4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cb6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cba:	47a1                	li	a5,8
    80002cbc:	04f71c63          	bne	a4,a5,80002d14 <usertrap+0x92>
    if(p->killed)
    80002cc0:	551c                	lw	a5,40(a0)
    80002cc2:	e3b9                	bnez	a5,80002d08 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002cc4:	6cb8                	ld	a4,88(s1)
    80002cc6:	6f1c                	ld	a5,24(a4)
    80002cc8:	0791                	addi	a5,a5,4
    80002cca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ccc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cd0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cd4:	10079073          	csrw	sstatus,a5
    syscall();
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	388080e7          	jalr	904(ra) # 80003060 <syscall>
  if(p->killed)
    80002ce0:	549c                	lw	a5,40(s1)
    80002ce2:	e3cd                	bnez	a5,80002d84 <usertrap+0x102>
  usertrapret();
    80002ce4:	00000097          	auipc	ra,0x0
    80002ce8:	e0a080e7          	jalr	-502(ra) # 80002aee <usertrapret>
}
    80002cec:	60e2                	ld	ra,24(sp)
    80002cee:	6442                	ld	s0,16(sp)
    80002cf0:	64a2                	ld	s1,8(sp)
    80002cf2:	6902                	ld	s2,0(sp)
    80002cf4:	6105                	addi	sp,sp,32
    80002cf6:	8082                	ret
    panic("usertrap: not from user mode");
    80002cf8:	00005517          	auipc	a0,0x5
    80002cfc:	62050513          	addi	a0,a0,1568 # 80008318 <states.0+0x58>
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	82a080e7          	jalr	-2006(ra) # 8000052a <panic>
      exit(-1);
    80002d08:	557d                	li	a0,-1
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	7e6080e7          	jalr	2022(ra) # 800024f0 <exit>
    80002d12:	bf4d                	j	80002cc4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	ecc080e7          	jalr	-308(ra) # 80002be0 <devintr>
    80002d1c:	892a                	mv	s2,a0
    80002d1e:	c501                	beqz	a0,80002d26 <usertrap+0xa4>
  if(p->killed)
    80002d20:	549c                	lw	a5,40(s1)
    80002d22:	c3a1                	beqz	a5,80002d62 <usertrap+0xe0>
    80002d24:	a815                	j	80002d58 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d26:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d2a:	5890                	lw	a2,48(s1)
    80002d2c:	00005517          	auipc	a0,0x5
    80002d30:	60c50513          	addi	a0,a0,1548 # 80008338 <states.0+0x78>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	840080e7          	jalr	-1984(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d3c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d40:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d44:	00005517          	auipc	a0,0x5
    80002d48:	62450513          	addi	a0,a0,1572 # 80008368 <states.0+0xa8>
    80002d4c:	ffffe097          	auipc	ra,0xffffe
    80002d50:	828080e7          	jalr	-2008(ra) # 80000574 <printf>
    p->killed = 1;
    80002d54:	4785                	li	a5,1
    80002d56:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002d58:	557d                	li	a0,-1
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	796080e7          	jalr	1942(ra) # 800024f0 <exit>
    if(which_dev == 2){
    80002d62:	4789                	li	a5,2
    80002d64:	f8f910e3          	bne	s2,a5,80002ce4 <usertrap+0x62>
      p->timerinterupts++;
    80002d68:	1804a783          	lw	a5,384(s1)
    80002d6c:	2785                	addiw	a5,a5,1
    80002d6e:	18f4a023          	sw	a5,384(s1)
      if(p->timerinterupts%QUANTUM == 0)
    80002d72:	4715                	li	a4,5
    80002d74:	02e7e7bb          	remw	a5,a5,a4
    80002d78:	f7b5                	bnez	a5,80002ce4 <usertrap+0x62>
        yield();
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	4be080e7          	jalr	1214(ra) # 80002238 <yield>
    80002d82:	b78d                	j	80002ce4 <usertrap+0x62>
  int which_dev = 0;
    80002d84:	4901                	li	s2,0
    80002d86:	bfc9                	j	80002d58 <usertrap+0xd6>

0000000080002d88 <kerneltrap>:
{
    80002d88:	7179                	addi	sp,sp,-48
    80002d8a:	f406                	sd	ra,40(sp)
    80002d8c:	f022                	sd	s0,32(sp)
    80002d8e:	ec26                	sd	s1,24(sp)
    80002d90:	e84a                	sd	s2,16(sp)
    80002d92:	e44e                	sd	s3,8(sp)
    80002d94:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d96:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d9a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d9e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002da2:	1004f793          	andi	a5,s1,256
    80002da6:	cb85                	beqz	a5,80002dd6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002da8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002dac:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dae:	ef85                	bnez	a5,80002de6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002db0:	00000097          	auipc	ra,0x0
    80002db4:	e30080e7          	jalr	-464(ra) # 80002be0 <devintr>
    80002db8:	cd1d                	beqz	a0,80002df6 <kerneltrap+0x6e>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dba:	4789                	li	a5,2
    80002dbc:	06f50a63          	beq	a0,a5,80002e30 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dc0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dc4:	10049073          	csrw	sstatus,s1
}
    80002dc8:	70a2                	ld	ra,40(sp)
    80002dca:	7402                	ld	s0,32(sp)
    80002dcc:	64e2                	ld	s1,24(sp)
    80002dce:	6942                	ld	s2,16(sp)
    80002dd0:	69a2                	ld	s3,8(sp)
    80002dd2:	6145                	addi	sp,sp,48
    80002dd4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002dd6:	00005517          	auipc	a0,0x5
    80002dda:	5b250513          	addi	a0,a0,1458 # 80008388 <states.0+0xc8>
    80002dde:	ffffd097          	auipc	ra,0xffffd
    80002de2:	74c080e7          	jalr	1868(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002de6:	00005517          	auipc	a0,0x5
    80002dea:	5ca50513          	addi	a0,a0,1482 # 800083b0 <states.0+0xf0>
    80002dee:	ffffd097          	auipc	ra,0xffffd
    80002df2:	73c080e7          	jalr	1852(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002df6:	85ce                	mv	a1,s3
    80002df8:	00005517          	auipc	a0,0x5
    80002dfc:	5d850513          	addi	a0,a0,1496 # 800083d0 <states.0+0x110>
    80002e00:	ffffd097          	auipc	ra,0xffffd
    80002e04:	774080e7          	jalr	1908(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e08:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e0c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e10:	00005517          	auipc	a0,0x5
    80002e14:	5d050513          	addi	a0,a0,1488 # 800083e0 <states.0+0x120>
    80002e18:	ffffd097          	auipc	ra,0xffffd
    80002e1c:	75c080e7          	jalr	1884(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002e20:	00005517          	auipc	a0,0x5
    80002e24:	5d850513          	addi	a0,a0,1496 # 800083f8 <states.0+0x138>
    80002e28:	ffffd097          	auipc	ra,0xffffd
    80002e2c:	702080e7          	jalr	1794(ra) # 8000052a <panic>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	b4e080e7          	jalr	-1202(ra) # 8000197e <myproc>
    80002e38:	d541                	beqz	a0,80002dc0 <kerneltrap+0x38>
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	b44080e7          	jalr	-1212(ra) # 8000197e <myproc>
    80002e42:	4d18                	lw	a4,24(a0)
    80002e44:	4791                	li	a5,4
    80002e46:	f6f71de3          	bne	a4,a5,80002dc0 <kerneltrap+0x38>
      yield();
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	3ee080e7          	jalr	1006(ra) # 80002238 <yield>
    80002e52:	b7bd                	j	80002dc0 <kerneltrap+0x38>

0000000080002e54 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	1000                	addi	s0,sp,32
    80002e5e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	b1e080e7          	jalr	-1250(ra) # 8000197e <myproc>
  switch (n) {
    80002e68:	4795                	li	a5,5
    80002e6a:	0497e163          	bltu	a5,s1,80002eac <argraw+0x58>
    80002e6e:	048a                	slli	s1,s1,0x2
    80002e70:	00005717          	auipc	a4,0x5
    80002e74:	61870713          	addi	a4,a4,1560 # 80008488 <states.0+0x1c8>
    80002e78:	94ba                	add	s1,s1,a4
    80002e7a:	409c                	lw	a5,0(s1)
    80002e7c:	97ba                	add	a5,a5,a4
    80002e7e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e80:	6d3c                	ld	a5,88(a0)
    80002e82:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e84:	60e2                	ld	ra,24(sp)
    80002e86:	6442                	ld	s0,16(sp)
    80002e88:	64a2                	ld	s1,8(sp)
    80002e8a:	6105                	addi	sp,sp,32
    80002e8c:	8082                	ret
    return p->trapframe->a1;
    80002e8e:	6d3c                	ld	a5,88(a0)
    80002e90:	7fa8                	ld	a0,120(a5)
    80002e92:	bfcd                	j	80002e84 <argraw+0x30>
    return p->trapframe->a2;
    80002e94:	6d3c                	ld	a5,88(a0)
    80002e96:	63c8                	ld	a0,128(a5)
    80002e98:	b7f5                	j	80002e84 <argraw+0x30>
    return p->trapframe->a3;
    80002e9a:	6d3c                	ld	a5,88(a0)
    80002e9c:	67c8                	ld	a0,136(a5)
    80002e9e:	b7dd                	j	80002e84 <argraw+0x30>
    return p->trapframe->a4;
    80002ea0:	6d3c                	ld	a5,88(a0)
    80002ea2:	6bc8                	ld	a0,144(a5)
    80002ea4:	b7c5                	j	80002e84 <argraw+0x30>
    return p->trapframe->a5;
    80002ea6:	6d3c                	ld	a5,88(a0)
    80002ea8:	6fc8                	ld	a0,152(a5)
    80002eaa:	bfe9                	j	80002e84 <argraw+0x30>
  panic("argraw");
    80002eac:	00005517          	auipc	a0,0x5
    80002eb0:	55c50513          	addi	a0,a0,1372 # 80008408 <states.0+0x148>
    80002eb4:	ffffd097          	auipc	ra,0xffffd
    80002eb8:	676080e7          	jalr	1654(ra) # 8000052a <panic>

0000000080002ebc <fetchaddr>:
{
    80002ebc:	1101                	addi	sp,sp,-32
    80002ebe:	ec06                	sd	ra,24(sp)
    80002ec0:	e822                	sd	s0,16(sp)
    80002ec2:	e426                	sd	s1,8(sp)
    80002ec4:	e04a                	sd	s2,0(sp)
    80002ec6:	1000                	addi	s0,sp,32
    80002ec8:	84aa                	mv	s1,a0
    80002eca:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	ab2080e7          	jalr	-1358(ra) # 8000197e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002ed4:	653c                	ld	a5,72(a0)
    80002ed6:	02f4f863          	bgeu	s1,a5,80002f06 <fetchaddr+0x4a>
    80002eda:	00848713          	addi	a4,s1,8
    80002ede:	02e7e663          	bltu	a5,a4,80002f0a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ee2:	46a1                	li	a3,8
    80002ee4:	8626                	mv	a2,s1
    80002ee6:	85ca                	mv	a1,s2
    80002ee8:	6928                	ld	a0,80(a0)
    80002eea:	ffffe097          	auipc	ra,0xffffe
    80002eee:	7e0080e7          	jalr	2016(ra) # 800016ca <copyin>
    80002ef2:	00a03533          	snez	a0,a0
    80002ef6:	40a00533          	neg	a0,a0
}
    80002efa:	60e2                	ld	ra,24(sp)
    80002efc:	6442                	ld	s0,16(sp)
    80002efe:	64a2                	ld	s1,8(sp)
    80002f00:	6902                	ld	s2,0(sp)
    80002f02:	6105                	addi	sp,sp,32
    80002f04:	8082                	ret
    return -1;
    80002f06:	557d                	li	a0,-1
    80002f08:	bfcd                	j	80002efa <fetchaddr+0x3e>
    80002f0a:	557d                	li	a0,-1
    80002f0c:	b7fd                	j	80002efa <fetchaddr+0x3e>

0000000080002f0e <fetchstr>:
{
    80002f0e:	7179                	addi	sp,sp,-48
    80002f10:	f406                	sd	ra,40(sp)
    80002f12:	f022                	sd	s0,32(sp)
    80002f14:	ec26                	sd	s1,24(sp)
    80002f16:	e84a                	sd	s2,16(sp)
    80002f18:	e44e                	sd	s3,8(sp)
    80002f1a:	1800                	addi	s0,sp,48
    80002f1c:	892a                	mv	s2,a0
    80002f1e:	84ae                	mv	s1,a1
    80002f20:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f22:	fffff097          	auipc	ra,0xfffff
    80002f26:	a5c080e7          	jalr	-1444(ra) # 8000197e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002f2a:	86ce                	mv	a3,s3
    80002f2c:	864a                	mv	a2,s2
    80002f2e:	85a6                	mv	a1,s1
    80002f30:	6928                	ld	a0,80(a0)
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	826080e7          	jalr	-2010(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002f3a:	00054763          	bltz	a0,80002f48 <fetchstr+0x3a>
  return strlen(buf);
    80002f3e:	8526                	mv	a0,s1
    80002f40:	ffffe097          	auipc	ra,0xffffe
    80002f44:	f02080e7          	jalr	-254(ra) # 80000e42 <strlen>
}
    80002f48:	70a2                	ld	ra,40(sp)
    80002f4a:	7402                	ld	s0,32(sp)
    80002f4c:	64e2                	ld	s1,24(sp)
    80002f4e:	6942                	ld	s2,16(sp)
    80002f50:	69a2                	ld	s3,8(sp)
    80002f52:	6145                	addi	sp,sp,48
    80002f54:	8082                	ret

0000000080002f56 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	e426                	sd	s1,8(sp)
    80002f5e:	1000                	addi	s0,sp,32
    80002f60:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f62:	00000097          	auipc	ra,0x0
    80002f66:	ef2080e7          	jalr	-270(ra) # 80002e54 <argraw>
    80002f6a:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f6c:	4501                	li	a0,0
    80002f6e:	60e2                	ld	ra,24(sp)
    80002f70:	6442                	ld	s0,16(sp)
    80002f72:	64a2                	ld	s1,8(sp)
    80002f74:	6105                	addi	sp,sp,32
    80002f76:	8082                	ret

0000000080002f78 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f78:	1101                	addi	sp,sp,-32
    80002f7a:	ec06                	sd	ra,24(sp)
    80002f7c:	e822                	sd	s0,16(sp)
    80002f7e:	e426                	sd	s1,8(sp)
    80002f80:	1000                	addi	s0,sp,32
    80002f82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f84:	00000097          	auipc	ra,0x0
    80002f88:	ed0080e7          	jalr	-304(ra) # 80002e54 <argraw>
    80002f8c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f8e:	4501                	li	a0,0
    80002f90:	60e2                	ld	ra,24(sp)
    80002f92:	6442                	ld	s0,16(sp)
    80002f94:	64a2                	ld	s1,8(sp)
    80002f96:	6105                	addi	sp,sp,32
    80002f98:	8082                	ret

0000000080002f9a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f9a:	1101                	addi	sp,sp,-32
    80002f9c:	ec06                	sd	ra,24(sp)
    80002f9e:	e822                	sd	s0,16(sp)
    80002fa0:	e426                	sd	s1,8(sp)
    80002fa2:	e04a                	sd	s2,0(sp)
    80002fa4:	1000                	addi	s0,sp,32
    80002fa6:	84ae                	mv	s1,a1
    80002fa8:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	eaa080e7          	jalr	-342(ra) # 80002e54 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002fb2:	864a                	mv	a2,s2
    80002fb4:	85a6                	mv	a1,s1
    80002fb6:	00000097          	auipc	ra,0x0
    80002fba:	f58080e7          	jalr	-168(ra) # 80002f0e <fetchstr>
}
    80002fbe:	60e2                	ld	ra,24(sp)
    80002fc0:	6442                	ld	s0,16(sp)
    80002fc2:	64a2                	ld	s1,8(sp)
    80002fc4:	6902                	ld	s2,0(sp)
    80002fc6:	6105                	addi	sp,sp,32
    80002fc8:	8082                	ret

0000000080002fca <printtrace>:
[SYS_set_priority]   "set_priority",
};

void
printtrace(struct proc *p, int num, int arg)
{
    80002fca:	1141                	addi	sp,sp,-16
    80002fcc:	e406                	sd	ra,8(sp)
    80002fce:	e022                	sd	s0,0(sp)
    80002fd0:	0800                	addi	s0,sp,16
  if(num == SYS_fork)
    80002fd2:	4785                	li	a5,1
    80002fd4:	04f58163          	beq	a1,a5,80003016 <printtrace+0x4c>
    80002fd8:	86b2                	mv	a3,a2
    printf("%d: syscall %s NULL -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
  else if(num == SYS_kill || num == SYS_sbrk)
    80002fda:	4799                	li	a5,6
    80002fdc:	00f58563          	beq	a1,a5,80002fe6 <printtrace+0x1c>
    80002fe0:	47b1                	li	a5,12
    80002fe2:	04f59a63          	bne	a1,a5,80003036 <printtrace+0x6c>
    printf("%d: syscall %s %d -> %d\n", p->pid, sysnames[num], arg, p->trapframe->a0);
    80002fe6:	6d3c                	ld	a5,88(a0)
    80002fe8:	00459613          	slli	a2,a1,0x4
    80002fec:	40b605b3          	sub	a1,a2,a1
    80002ff0:	7bb8                	ld	a4,112(a5)
    80002ff2:	00006617          	auipc	a2,0x6
    80002ff6:	8d660613          	addi	a2,a2,-1834 # 800088c8 <sysnames>
    80002ffa:	962e                	add	a2,a2,a1
    80002ffc:	590c                	lw	a1,48(a0)
    80002ffe:	00005517          	auipc	a0,0x5
    80003002:	43250513          	addi	a0,a0,1074 # 80008430 <states.0+0x170>
    80003006:	ffffd097          	auipc	ra,0xffffd
    8000300a:	56e080e7          	jalr	1390(ra) # 80000574 <printf>
  else
    printf("%d: syscall %s -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
}
    8000300e:	60a2                	ld	ra,8(sp)
    80003010:	6402                	ld	s0,0(sp)
    80003012:	0141                	addi	sp,sp,16
    80003014:	8082                	ret
    printf("%d: syscall %s NULL -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
    80003016:	6d3c                	ld	a5,88(a0)
    80003018:	7bb4                	ld	a3,112(a5)
    8000301a:	00006617          	auipc	a2,0x6
    8000301e:	8bd60613          	addi	a2,a2,-1859 # 800088d7 <sysnames+0xf>
    80003022:	590c                	lw	a1,48(a0)
    80003024:	00005517          	auipc	a0,0x5
    80003028:	3ec50513          	addi	a0,a0,1004 # 80008410 <states.0+0x150>
    8000302c:	ffffd097          	auipc	ra,0xffffd
    80003030:	548080e7          	jalr	1352(ra) # 80000574 <printf>
    80003034:	bfe9                	j	8000300e <printtrace+0x44>
    printf("%d: syscall %s -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
    80003036:	6d3c                	ld	a5,88(a0)
    80003038:	00459613          	slli	a2,a1,0x4
    8000303c:	40b605b3          	sub	a1,a2,a1
    80003040:	7bb4                	ld	a3,112(a5)
    80003042:	00006617          	auipc	a2,0x6
    80003046:	88660613          	addi	a2,a2,-1914 # 800088c8 <sysnames>
    8000304a:	962e                	add	a2,a2,a1
    8000304c:	590c                	lw	a1,48(a0)
    8000304e:	00005517          	auipc	a0,0x5
    80003052:	40250513          	addi	a0,a0,1026 # 80008450 <states.0+0x190>
    80003056:	ffffd097          	auipc	ra,0xffffd
    8000305a:	51e080e7          	jalr	1310(ra) # 80000574 <printf>
}
    8000305e:	bf45                	j	8000300e <printtrace+0x44>

0000000080003060 <syscall>:

void
syscall(void)
{
    80003060:	7139                	addi	sp,sp,-64
    80003062:	fc06                	sd	ra,56(sp)
    80003064:	f822                	sd	s0,48(sp)
    80003066:	f426                	sd	s1,40(sp)
    80003068:	f04a                	sd	s2,32(sp)
    8000306a:	ec4e                	sd	s3,24(sp)
    8000306c:	0080                	addi	s0,sp,64
  int arg, num;
  struct proc *p = myproc();
    8000306e:	fffff097          	auipc	ra,0xfffff
    80003072:	910080e7          	jalr	-1776(ra) # 8000197e <myproc>
    80003076:	84aa                	mv	s1,a0

  argint(0, &arg);
    80003078:	fcc40593          	addi	a1,s0,-52
    8000307c:	4501                	li	a0,0
    8000307e:	00000097          	auipc	ra,0x0
    80003082:	ed8080e7          	jalr	-296(ra) # 80002f56 <argint>
  num = p->trapframe->a7;
    80003086:	0584b903          	ld	s2,88(s1)
    8000308a:	0a893783          	ld	a5,168(s2)
    8000308e:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003092:	37fd                	addiw	a5,a5,-1
    80003094:	475d                	li	a4,23
    80003096:	02f76d63          	bltu	a4,a5,800030d0 <syscall+0x70>
    8000309a:	00399713          	slli	a4,s3,0x3
    8000309e:	00005797          	auipc	a5,0x5
    800030a2:	40278793          	addi	a5,a5,1026 # 800084a0 <syscalls>
    800030a6:	97ba                	add	a5,a5,a4
    800030a8:	639c                	ld	a5,0(a5)
    800030aa:	c39d                	beqz	a5,800030d0 <syscall+0x70>
    p->trapframe->a0 = syscalls[num]();
    800030ac:	9782                	jalr	a5
    800030ae:	06a93823          	sd	a0,112(s2)
    if(p->mask & (1 << num)){
    800030b2:	1884a783          	lw	a5,392(s1)
    800030b6:	4137d7bb          	sraw	a5,a5,s3
    800030ba:	8b85                	andi	a5,a5,1
    800030bc:	cb8d                	beqz	a5,800030ee <syscall+0x8e>
      printtrace(p, num, arg);
    800030be:	fcc42603          	lw	a2,-52(s0)
    800030c2:	85ce                	mv	a1,s3
    800030c4:	8526                	mv	a0,s1
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	f04080e7          	jalr	-252(ra) # 80002fca <printtrace>
    800030ce:	a005                	j	800030ee <syscall+0x8e>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    800030d0:	86ce                	mv	a3,s3
    800030d2:	15848613          	addi	a2,s1,344
    800030d6:	588c                	lw	a1,48(s1)
    800030d8:	00005517          	auipc	a0,0x5
    800030dc:	39050513          	addi	a0,a0,912 # 80008468 <states.0+0x1a8>
    800030e0:	ffffd097          	auipc	ra,0xffffd
    800030e4:	494080e7          	jalr	1172(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800030e8:	6cbc                	ld	a5,88(s1)
    800030ea:	577d                	li	a4,-1
    800030ec:	fbb8                	sd	a4,112(a5)
  }
}
    800030ee:	70e2                	ld	ra,56(sp)
    800030f0:	7442                	ld	s0,48(sp)
    800030f2:	74a2                	ld	s1,40(sp)
    800030f4:	7902                	ld	s2,32(sp)
    800030f6:	69e2                	ld	s3,24(sp)
    800030f8:	6121                	addi	sp,sp,64
    800030fa:	8082                	ret

00000000800030fc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800030fc:	1101                	addi	sp,sp,-32
    800030fe:	ec06                	sd	ra,24(sp)
    80003100:	e822                	sd	s0,16(sp)
    80003102:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003104:	fec40593          	addi	a1,s0,-20
    80003108:	4501                	li	a0,0
    8000310a:	00000097          	auipc	ra,0x0
    8000310e:	e4c080e7          	jalr	-436(ra) # 80002f56 <argint>
    return -1;
    80003112:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003114:	00054963          	bltz	a0,80003126 <sys_exit+0x2a>
  exit(n);
    80003118:	fec42503          	lw	a0,-20(s0)
    8000311c:	fffff097          	auipc	ra,0xfffff
    80003120:	3d4080e7          	jalr	980(ra) # 800024f0 <exit>
  return 0;  // not reached
    80003124:	4781                	li	a5,0
}
    80003126:	853e                	mv	a0,a5
    80003128:	60e2                	ld	ra,24(sp)
    8000312a:	6442                	ld	s0,16(sp)
    8000312c:	6105                	addi	sp,sp,32
    8000312e:	8082                	ret

0000000080003130 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003130:	1141                	addi	sp,sp,-16
    80003132:	e406                	sd	ra,8(sp)
    80003134:	e022                	sd	s0,0(sp)
    80003136:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	846080e7          	jalr	-1978(ra) # 8000197e <myproc>
}
    80003140:	5908                	lw	a0,48(a0)
    80003142:	60a2                	ld	ra,8(sp)
    80003144:	6402                	ld	s0,0(sp)
    80003146:	0141                	addi	sp,sp,16
    80003148:	8082                	ret

000000008000314a <sys_fork>:

uint64
sys_fork(void)
{
    8000314a:	1141                	addi	sp,sp,-16
    8000314c:	e406                	sd	ra,8(sp)
    8000314e:	e022                	sd	s0,0(sp)
    80003150:	0800                	addi	s0,sp,16
  return fork();
    80003152:	fffff097          	auipc	ra,0xfffff
    80003156:	c36080e7          	jalr	-970(ra) # 80001d88 <fork>
}
    8000315a:	60a2                	ld	ra,8(sp)
    8000315c:	6402                	ld	s0,0(sp)
    8000315e:	0141                	addi	sp,sp,16
    80003160:	8082                	ret

0000000080003162 <sys_wait>:

uint64
sys_wait(void)
{
    80003162:	1101                	addi	sp,sp,-32
    80003164:	ec06                	sd	ra,24(sp)
    80003166:	e822                	sd	s0,16(sp)
    80003168:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000316a:	fe840593          	addi	a1,s0,-24
    8000316e:	4501                	li	a0,0
    80003170:	00000097          	auipc	ra,0x0
    80003174:	e08080e7          	jalr	-504(ra) # 80002f78 <argaddr>
    80003178:	87aa                	mv	a5,a0
    return -1;
    8000317a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000317c:	0007c863          	bltz	a5,8000318c <sys_wait+0x2a>
  return wait(p);
    80003180:	fe843503          	ld	a0,-24(s0)
    80003184:	fffff097          	auipc	ra,0xfffff
    80003188:	160080e7          	jalr	352(ra) # 800022e4 <wait>
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	6105                	addi	sp,sp,32
    80003192:	8082                	ret

0000000080003194 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003194:	7179                	addi	sp,sp,-48
    80003196:	f406                	sd	ra,40(sp)
    80003198:	f022                	sd	s0,32(sp)
    8000319a:	ec26                	sd	s1,24(sp)
    8000319c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000319e:	fdc40593          	addi	a1,s0,-36
    800031a2:	4501                	li	a0,0
    800031a4:	00000097          	auipc	ra,0x0
    800031a8:	db2080e7          	jalr	-590(ra) # 80002f56 <argint>
    return -1;
    800031ac:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800031ae:	00054f63          	bltz	a0,800031cc <sys_sbrk+0x38>
  addr = myproc()->sz;
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	7cc080e7          	jalr	1996(ra) # 8000197e <myproc>
    800031ba:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800031bc:	fdc42503          	lw	a0,-36(s0)
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	b54080e7          	jalr	-1196(ra) # 80001d14 <growproc>
    800031c8:	00054863          	bltz	a0,800031d8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800031cc:	8526                	mv	a0,s1
    800031ce:	70a2                	ld	ra,40(sp)
    800031d0:	7402                	ld	s0,32(sp)
    800031d2:	64e2                	ld	s1,24(sp)
    800031d4:	6145                	addi	sp,sp,48
    800031d6:	8082                	ret
    return -1;
    800031d8:	54fd                	li	s1,-1
    800031da:	bfcd                	j	800031cc <sys_sbrk+0x38>

00000000800031dc <sys_sleep>:

uint64
sys_sleep(void)
{
    800031dc:	7139                	addi	sp,sp,-64
    800031de:	fc06                	sd	ra,56(sp)
    800031e0:	f822                	sd	s0,48(sp)
    800031e2:	f426                	sd	s1,40(sp)
    800031e4:	f04a                	sd	s2,32(sp)
    800031e6:	ec4e                	sd	s3,24(sp)
    800031e8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800031ea:	fcc40593          	addi	a1,s0,-52
    800031ee:	4501                	li	a0,0
    800031f0:	00000097          	auipc	ra,0x0
    800031f4:	d66080e7          	jalr	-666(ra) # 80002f56 <argint>
    return -1;
    800031f8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031fa:	06054563          	bltz	a0,80003264 <sys_sleep+0x88>
  acquire(&tickslock);
    800031fe:	00015517          	auipc	a0,0x15
    80003202:	8d250513          	addi	a0,a0,-1838 # 80017ad0 <tickslock>
    80003206:	ffffe097          	auipc	ra,0xffffe
    8000320a:	9bc080e7          	jalr	-1604(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000320e:	00006917          	auipc	s2,0x6
    80003212:	e2292903          	lw	s2,-478(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003216:	fcc42783          	lw	a5,-52(s0)
    8000321a:	cf85                	beqz	a5,80003252 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000321c:	00015997          	auipc	s3,0x15
    80003220:	8b498993          	addi	s3,s3,-1868 # 80017ad0 <tickslock>
    80003224:	00006497          	auipc	s1,0x6
    80003228:	e0c48493          	addi	s1,s1,-500 # 80009030 <ticks>
    if(myproc()->killed){
    8000322c:	ffffe097          	auipc	ra,0xffffe
    80003230:	752080e7          	jalr	1874(ra) # 8000197e <myproc>
    80003234:	551c                	lw	a5,40(a0)
    80003236:	ef9d                	bnez	a5,80003274 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003238:	85ce                	mv	a1,s3
    8000323a:	8526                	mv	a0,s1
    8000323c:	fffff097          	auipc	ra,0xfffff
    80003240:	044080e7          	jalr	68(ra) # 80002280 <sleep>
  while(ticks - ticks0 < n){
    80003244:	409c                	lw	a5,0(s1)
    80003246:	412787bb          	subw	a5,a5,s2
    8000324a:	fcc42703          	lw	a4,-52(s0)
    8000324e:	fce7efe3          	bltu	a5,a4,8000322c <sys_sleep+0x50>
  }
  release(&tickslock);
    80003252:	00015517          	auipc	a0,0x15
    80003256:	87e50513          	addi	a0,a0,-1922 # 80017ad0 <tickslock>
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	a1c080e7          	jalr	-1508(ra) # 80000c76 <release>
  return 0;
    80003262:	4781                	li	a5,0
}
    80003264:	853e                	mv	a0,a5
    80003266:	70e2                	ld	ra,56(sp)
    80003268:	7442                	ld	s0,48(sp)
    8000326a:	74a2                	ld	s1,40(sp)
    8000326c:	7902                	ld	s2,32(sp)
    8000326e:	69e2                	ld	s3,24(sp)
    80003270:	6121                	addi	sp,sp,64
    80003272:	8082                	ret
      release(&tickslock);
    80003274:	00015517          	auipc	a0,0x15
    80003278:	85c50513          	addi	a0,a0,-1956 # 80017ad0 <tickslock>
    8000327c:	ffffe097          	auipc	ra,0xffffe
    80003280:	9fa080e7          	jalr	-1542(ra) # 80000c76 <release>
      return -1;
    80003284:	57fd                	li	a5,-1
    80003286:	bff9                	j	80003264 <sys_sleep+0x88>

0000000080003288 <sys_kill>:

uint64
sys_kill(void)
{
    80003288:	1101                	addi	sp,sp,-32
    8000328a:	ec06                	sd	ra,24(sp)
    8000328c:	e822                	sd	s0,16(sp)
    8000328e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003290:	fec40593          	addi	a1,s0,-20
    80003294:	4501                	li	a0,0
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	cc0080e7          	jalr	-832(ra) # 80002f56 <argint>
    8000329e:	87aa                	mv	a5,a0
    return -1;
    800032a0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800032a2:	0007c863          	bltz	a5,800032b2 <sys_kill+0x2a>
  return kill(pid);
    800032a6:	fec42503          	lw	a0,-20(s0)
    800032aa:	fffff097          	auipc	ra,0xfffff
    800032ae:	31c080e7          	jalr	796(ra) # 800025c6 <kill>
}
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800032c4:	00015517          	auipc	a0,0x15
    800032c8:	80c50513          	addi	a0,a0,-2036 # 80017ad0 <tickslock>
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	8f6080e7          	jalr	-1802(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800032d4:	00006497          	auipc	s1,0x6
    800032d8:	d5c4a483          	lw	s1,-676(s1) # 80009030 <ticks>
  release(&tickslock);
    800032dc:	00014517          	auipc	a0,0x14
    800032e0:	7f450513          	addi	a0,a0,2036 # 80017ad0 <tickslock>
    800032e4:	ffffe097          	auipc	ra,0xffffe
    800032e8:	992080e7          	jalr	-1646(ra) # 80000c76 <release>
  return xticks;
}
    800032ec:	02049513          	slli	a0,s1,0x20
    800032f0:	9101                	srli	a0,a0,0x20
    800032f2:	60e2                	ld	ra,24(sp)
    800032f4:	6442                	ld	s0,16(sp)
    800032f6:	64a2                	ld	s1,8(sp)
    800032f8:	6105                	addi	sp,sp,32
    800032fa:	8082                	ret

00000000800032fc <sys_trace>:

uint64
sys_trace(void)
{
    800032fc:	1101                	addi	sp,sp,-32
    800032fe:	ec06                	sd	ra,24(sp)
    80003300:	e822                	sd	s0,16(sp)
    80003302:	1000                	addi	s0,sp,32
  int mask, pid;
  
  if(argint(0, &mask) < 0 || argint(1, &pid) < 0)
    80003304:	fec40593          	addi	a1,s0,-20
    80003308:	4501                	li	a0,0
    8000330a:	00000097          	auipc	ra,0x0
    8000330e:	c4c080e7          	jalr	-948(ra) # 80002f56 <argint>
    return -1;
    80003312:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0 || argint(1, &pid) < 0)
    80003314:	02054563          	bltz	a0,8000333e <sys_trace+0x42>
    80003318:	fe840593          	addi	a1,s0,-24
    8000331c:	4505                	li	a0,1
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	c38080e7          	jalr	-968(ra) # 80002f56 <argint>
    return -1;
    80003326:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0 || argint(1, &pid) < 0)
    80003328:	00054b63          	bltz	a0,8000333e <sys_trace+0x42>
  return trace(mask, pid);
    8000332c:	fe842583          	lw	a1,-24(s0)
    80003330:	fec42503          	lw	a0,-20(s0)
    80003334:	fffff097          	auipc	ra,0xfffff
    80003338:	46c080e7          	jalr	1132(ra) # 800027a0 <trace>
    8000333c:	87aa                	mv	a5,a0
}
    8000333e:	853e                	mv	a0,a5
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <sys_wait_stat>:

uint64
sys_wait_stat(void)
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	1000                	addi	s0,sp,32
  uint64 status, perf;
  if(argaddr(0, &status) < 0 || argaddr(1, &perf) < 0)
    80003350:	fe840593          	addi	a1,s0,-24
    80003354:	4501                	li	a0,0
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	c22080e7          	jalr	-990(ra) # 80002f78 <argaddr>
    return -1;
    8000335e:	57fd                	li	a5,-1
  if(argaddr(0, &status) < 0 || argaddr(1, &perf) < 0)
    80003360:	02054563          	bltz	a0,8000338a <sys_wait_stat+0x42>
    80003364:	fe040593          	addi	a1,s0,-32
    80003368:	4505                	li	a0,1
    8000336a:	00000097          	auipc	ra,0x0
    8000336e:	c0e080e7          	jalr	-1010(ra) # 80002f78 <argaddr>
    return -1;
    80003372:	57fd                	li	a5,-1
  if(argaddr(0, &status) < 0 || argaddr(1, &perf) < 0)
    80003374:	00054b63          	bltz	a0,8000338a <sys_wait_stat+0x42>
  return wait_stat(status, perf);
    80003378:	fe043583          	ld	a1,-32(s0)
    8000337c:	fe843503          	ld	a0,-24(s0)
    80003380:	fffff097          	auipc	ra,0xfffff
    80003384:	512080e7          	jalr	1298(ra) # 80002892 <wait_stat>
    80003388:	87aa                	mv	a5,a0
}
    8000338a:	853e                	mv	a0,a5
    8000338c:	60e2                	ld	ra,24(sp)
    8000338e:	6442                	ld	s0,16(sp)
    80003390:	6105                	addi	sp,sp,32
    80003392:	8082                	ret

0000000080003394 <sys_set_priority>:

uint64
sys_set_priority(void)
{
    80003394:	1101                	addi	sp,sp,-32
    80003396:	ec06                	sd	ra,24(sp)
    80003398:	e822                	sd	s0,16(sp)
    8000339a:	1000                	addi	s0,sp,32
  int priority;
  if(argint(0, &priority) < 0)
    8000339c:	fec40593          	addi	a1,s0,-20
    800033a0:	4501                	li	a0,0
    800033a2:	00000097          	auipc	ra,0x0
    800033a6:	bb4080e7          	jalr	-1100(ra) # 80002f56 <argint>
    800033aa:	87aa                	mv	a5,a0
    return -1;
    800033ac:	557d                	li	a0,-1
  if(argint(0, &priority) < 0)
    800033ae:	0007c863          	bltz	a5,800033be <sys_set_priority+0x2a>
  return set_priority(priority);
    800033b2:	fec42503          	lw	a0,-20(s0)
    800033b6:	fffff097          	auipc	ra,0xfffff
    800033ba:	644080e7          	jalr	1604(ra) # 800029fa <set_priority>
}
    800033be:	60e2                	ld	ra,24(sp)
    800033c0:	6442                	ld	s0,16(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret

00000000800033c6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033c6:	7179                	addi	sp,sp,-48
    800033c8:	f406                	sd	ra,40(sp)
    800033ca:	f022                	sd	s0,32(sp)
    800033cc:	ec26                	sd	s1,24(sp)
    800033ce:	e84a                	sd	s2,16(sp)
    800033d0:	e44e                	sd	s3,8(sp)
    800033d2:	e052                	sd	s4,0(sp)
    800033d4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033d6:	00005597          	auipc	a1,0x5
    800033da:	19258593          	addi	a1,a1,402 # 80008568 <syscalls+0xc8>
    800033de:	00014517          	auipc	a0,0x14
    800033e2:	70a50513          	addi	a0,a0,1802 # 80017ae8 <bcache>
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	74c080e7          	jalr	1868(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033ee:	0001c797          	auipc	a5,0x1c
    800033f2:	6fa78793          	addi	a5,a5,1786 # 8001fae8 <bcache+0x8000>
    800033f6:	0001d717          	auipc	a4,0x1d
    800033fa:	95a70713          	addi	a4,a4,-1702 # 8001fd50 <bcache+0x8268>
    800033fe:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003402:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003406:	00014497          	auipc	s1,0x14
    8000340a:	6fa48493          	addi	s1,s1,1786 # 80017b00 <bcache+0x18>
    b->next = bcache.head.next;
    8000340e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003410:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003412:	00005a17          	auipc	s4,0x5
    80003416:	15ea0a13          	addi	s4,s4,350 # 80008570 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000341a:	2b893783          	ld	a5,696(s2)
    8000341e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003420:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003424:	85d2                	mv	a1,s4
    80003426:	01048513          	addi	a0,s1,16
    8000342a:	00001097          	auipc	ra,0x1
    8000342e:	4c2080e7          	jalr	1218(ra) # 800048ec <initsleeplock>
    bcache.head.next->prev = b;
    80003432:	2b893783          	ld	a5,696(s2)
    80003436:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003438:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000343c:	45848493          	addi	s1,s1,1112
    80003440:	fd349de3          	bne	s1,s3,8000341a <binit+0x54>
  }
}
    80003444:	70a2                	ld	ra,40(sp)
    80003446:	7402                	ld	s0,32(sp)
    80003448:	64e2                	ld	s1,24(sp)
    8000344a:	6942                	ld	s2,16(sp)
    8000344c:	69a2                	ld	s3,8(sp)
    8000344e:	6a02                	ld	s4,0(sp)
    80003450:	6145                	addi	sp,sp,48
    80003452:	8082                	ret

0000000080003454 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003454:	7179                	addi	sp,sp,-48
    80003456:	f406                	sd	ra,40(sp)
    80003458:	f022                	sd	s0,32(sp)
    8000345a:	ec26                	sd	s1,24(sp)
    8000345c:	e84a                	sd	s2,16(sp)
    8000345e:	e44e                	sd	s3,8(sp)
    80003460:	1800                	addi	s0,sp,48
    80003462:	892a                	mv	s2,a0
    80003464:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003466:	00014517          	auipc	a0,0x14
    8000346a:	68250513          	addi	a0,a0,1666 # 80017ae8 <bcache>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	754080e7          	jalr	1876(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003476:	0001d497          	auipc	s1,0x1d
    8000347a:	92a4b483          	ld	s1,-1750(s1) # 8001fda0 <bcache+0x82b8>
    8000347e:	0001d797          	auipc	a5,0x1d
    80003482:	8d278793          	addi	a5,a5,-1838 # 8001fd50 <bcache+0x8268>
    80003486:	02f48f63          	beq	s1,a5,800034c4 <bread+0x70>
    8000348a:	873e                	mv	a4,a5
    8000348c:	a021                	j	80003494 <bread+0x40>
    8000348e:	68a4                	ld	s1,80(s1)
    80003490:	02e48a63          	beq	s1,a4,800034c4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003494:	449c                	lw	a5,8(s1)
    80003496:	ff279ce3          	bne	a5,s2,8000348e <bread+0x3a>
    8000349a:	44dc                	lw	a5,12(s1)
    8000349c:	ff3799e3          	bne	a5,s3,8000348e <bread+0x3a>
      b->refcnt++;
    800034a0:	40bc                	lw	a5,64(s1)
    800034a2:	2785                	addiw	a5,a5,1
    800034a4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034a6:	00014517          	auipc	a0,0x14
    800034aa:	64250513          	addi	a0,a0,1602 # 80017ae8 <bcache>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	7c8080e7          	jalr	1992(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800034b6:	01048513          	addi	a0,s1,16
    800034ba:	00001097          	auipc	ra,0x1
    800034be:	46c080e7          	jalr	1132(ra) # 80004926 <acquiresleep>
      return b;
    800034c2:	a8b9                	j	80003520 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034c4:	0001d497          	auipc	s1,0x1d
    800034c8:	8d44b483          	ld	s1,-1836(s1) # 8001fd98 <bcache+0x82b0>
    800034cc:	0001d797          	auipc	a5,0x1d
    800034d0:	88478793          	addi	a5,a5,-1916 # 8001fd50 <bcache+0x8268>
    800034d4:	00f48863          	beq	s1,a5,800034e4 <bread+0x90>
    800034d8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034da:	40bc                	lw	a5,64(s1)
    800034dc:	cf81                	beqz	a5,800034f4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034de:	64a4                	ld	s1,72(s1)
    800034e0:	fee49de3          	bne	s1,a4,800034da <bread+0x86>
  panic("bget: no buffers");
    800034e4:	00005517          	auipc	a0,0x5
    800034e8:	09450513          	addi	a0,a0,148 # 80008578 <syscalls+0xd8>
    800034ec:	ffffd097          	auipc	ra,0xffffd
    800034f0:	03e080e7          	jalr	62(ra) # 8000052a <panic>
      b->dev = dev;
    800034f4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034f8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034fc:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003500:	4785                	li	a5,1
    80003502:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003504:	00014517          	auipc	a0,0x14
    80003508:	5e450513          	addi	a0,a0,1508 # 80017ae8 <bcache>
    8000350c:	ffffd097          	auipc	ra,0xffffd
    80003510:	76a080e7          	jalr	1898(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003514:	01048513          	addi	a0,s1,16
    80003518:	00001097          	auipc	ra,0x1
    8000351c:	40e080e7          	jalr	1038(ra) # 80004926 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003520:	409c                	lw	a5,0(s1)
    80003522:	cb89                	beqz	a5,80003534 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003524:	8526                	mv	a0,s1
    80003526:	70a2                	ld	ra,40(sp)
    80003528:	7402                	ld	s0,32(sp)
    8000352a:	64e2                	ld	s1,24(sp)
    8000352c:	6942                	ld	s2,16(sp)
    8000352e:	69a2                	ld	s3,8(sp)
    80003530:	6145                	addi	sp,sp,48
    80003532:	8082                	ret
    virtio_disk_rw(b, 0);
    80003534:	4581                	li	a1,0
    80003536:	8526                	mv	a0,s1
    80003538:	00003097          	auipc	ra,0x3
    8000353c:	f1e080e7          	jalr	-226(ra) # 80006456 <virtio_disk_rw>
    b->valid = 1;
    80003540:	4785                	li	a5,1
    80003542:	c09c                	sw	a5,0(s1)
  return b;
    80003544:	b7c5                	j	80003524 <bread+0xd0>

0000000080003546 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003546:	1101                	addi	sp,sp,-32
    80003548:	ec06                	sd	ra,24(sp)
    8000354a:	e822                	sd	s0,16(sp)
    8000354c:	e426                	sd	s1,8(sp)
    8000354e:	1000                	addi	s0,sp,32
    80003550:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003552:	0541                	addi	a0,a0,16
    80003554:	00001097          	auipc	ra,0x1
    80003558:	46c080e7          	jalr	1132(ra) # 800049c0 <holdingsleep>
    8000355c:	cd01                	beqz	a0,80003574 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000355e:	4585                	li	a1,1
    80003560:	8526                	mv	a0,s1
    80003562:	00003097          	auipc	ra,0x3
    80003566:	ef4080e7          	jalr	-268(ra) # 80006456 <virtio_disk_rw>
}
    8000356a:	60e2                	ld	ra,24(sp)
    8000356c:	6442                	ld	s0,16(sp)
    8000356e:	64a2                	ld	s1,8(sp)
    80003570:	6105                	addi	sp,sp,32
    80003572:	8082                	ret
    panic("bwrite");
    80003574:	00005517          	auipc	a0,0x5
    80003578:	01c50513          	addi	a0,a0,28 # 80008590 <syscalls+0xf0>
    8000357c:	ffffd097          	auipc	ra,0xffffd
    80003580:	fae080e7          	jalr	-82(ra) # 8000052a <panic>

0000000080003584 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003584:	1101                	addi	sp,sp,-32
    80003586:	ec06                	sd	ra,24(sp)
    80003588:	e822                	sd	s0,16(sp)
    8000358a:	e426                	sd	s1,8(sp)
    8000358c:	e04a                	sd	s2,0(sp)
    8000358e:	1000                	addi	s0,sp,32
    80003590:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003592:	01050913          	addi	s2,a0,16
    80003596:	854a                	mv	a0,s2
    80003598:	00001097          	auipc	ra,0x1
    8000359c:	428080e7          	jalr	1064(ra) # 800049c0 <holdingsleep>
    800035a0:	c92d                	beqz	a0,80003612 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035a2:	854a                	mv	a0,s2
    800035a4:	00001097          	auipc	ra,0x1
    800035a8:	3d8080e7          	jalr	984(ra) # 8000497c <releasesleep>

  acquire(&bcache.lock);
    800035ac:	00014517          	auipc	a0,0x14
    800035b0:	53c50513          	addi	a0,a0,1340 # 80017ae8 <bcache>
    800035b4:	ffffd097          	auipc	ra,0xffffd
    800035b8:	60e080e7          	jalr	1550(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800035bc:	40bc                	lw	a5,64(s1)
    800035be:	37fd                	addiw	a5,a5,-1
    800035c0:	0007871b          	sext.w	a4,a5
    800035c4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035c6:	eb05                	bnez	a4,800035f6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035c8:	68bc                	ld	a5,80(s1)
    800035ca:	64b8                	ld	a4,72(s1)
    800035cc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035ce:	64bc                	ld	a5,72(s1)
    800035d0:	68b8                	ld	a4,80(s1)
    800035d2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035d4:	0001c797          	auipc	a5,0x1c
    800035d8:	51478793          	addi	a5,a5,1300 # 8001fae8 <bcache+0x8000>
    800035dc:	2b87b703          	ld	a4,696(a5)
    800035e0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035e2:	0001c717          	auipc	a4,0x1c
    800035e6:	76e70713          	addi	a4,a4,1902 # 8001fd50 <bcache+0x8268>
    800035ea:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035ec:	2b87b703          	ld	a4,696(a5)
    800035f0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035f2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800035f6:	00014517          	auipc	a0,0x14
    800035fa:	4f250513          	addi	a0,a0,1266 # 80017ae8 <bcache>
    800035fe:	ffffd097          	auipc	ra,0xffffd
    80003602:	678080e7          	jalr	1656(ra) # 80000c76 <release>
}
    80003606:	60e2                	ld	ra,24(sp)
    80003608:	6442                	ld	s0,16(sp)
    8000360a:	64a2                	ld	s1,8(sp)
    8000360c:	6902                	ld	s2,0(sp)
    8000360e:	6105                	addi	sp,sp,32
    80003610:	8082                	ret
    panic("brelse");
    80003612:	00005517          	auipc	a0,0x5
    80003616:	f8650513          	addi	a0,a0,-122 # 80008598 <syscalls+0xf8>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	f10080e7          	jalr	-240(ra) # 8000052a <panic>

0000000080003622 <bpin>:

void
bpin(struct buf *b) {
    80003622:	1101                	addi	sp,sp,-32
    80003624:	ec06                	sd	ra,24(sp)
    80003626:	e822                	sd	s0,16(sp)
    80003628:	e426                	sd	s1,8(sp)
    8000362a:	1000                	addi	s0,sp,32
    8000362c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000362e:	00014517          	auipc	a0,0x14
    80003632:	4ba50513          	addi	a0,a0,1210 # 80017ae8 <bcache>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	58c080e7          	jalr	1420(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000363e:	40bc                	lw	a5,64(s1)
    80003640:	2785                	addiw	a5,a5,1
    80003642:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003644:	00014517          	auipc	a0,0x14
    80003648:	4a450513          	addi	a0,a0,1188 # 80017ae8 <bcache>
    8000364c:	ffffd097          	auipc	ra,0xffffd
    80003650:	62a080e7          	jalr	1578(ra) # 80000c76 <release>
}
    80003654:	60e2                	ld	ra,24(sp)
    80003656:	6442                	ld	s0,16(sp)
    80003658:	64a2                	ld	s1,8(sp)
    8000365a:	6105                	addi	sp,sp,32
    8000365c:	8082                	ret

000000008000365e <bunpin>:

void
bunpin(struct buf *b) {
    8000365e:	1101                	addi	sp,sp,-32
    80003660:	ec06                	sd	ra,24(sp)
    80003662:	e822                	sd	s0,16(sp)
    80003664:	e426                	sd	s1,8(sp)
    80003666:	1000                	addi	s0,sp,32
    80003668:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000366a:	00014517          	auipc	a0,0x14
    8000366e:	47e50513          	addi	a0,a0,1150 # 80017ae8 <bcache>
    80003672:	ffffd097          	auipc	ra,0xffffd
    80003676:	550080e7          	jalr	1360(ra) # 80000bc2 <acquire>
  b->refcnt--;
    8000367a:	40bc                	lw	a5,64(s1)
    8000367c:	37fd                	addiw	a5,a5,-1
    8000367e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003680:	00014517          	auipc	a0,0x14
    80003684:	46850513          	addi	a0,a0,1128 # 80017ae8 <bcache>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	5ee080e7          	jalr	1518(ra) # 80000c76 <release>
}
    80003690:	60e2                	ld	ra,24(sp)
    80003692:	6442                	ld	s0,16(sp)
    80003694:	64a2                	ld	s1,8(sp)
    80003696:	6105                	addi	sp,sp,32
    80003698:	8082                	ret

000000008000369a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000369a:	1101                	addi	sp,sp,-32
    8000369c:	ec06                	sd	ra,24(sp)
    8000369e:	e822                	sd	s0,16(sp)
    800036a0:	e426                	sd	s1,8(sp)
    800036a2:	e04a                	sd	s2,0(sp)
    800036a4:	1000                	addi	s0,sp,32
    800036a6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036a8:	00d5d59b          	srliw	a1,a1,0xd
    800036ac:	0001d797          	auipc	a5,0x1d
    800036b0:	b187a783          	lw	a5,-1256(a5) # 800201c4 <sb+0x1c>
    800036b4:	9dbd                	addw	a1,a1,a5
    800036b6:	00000097          	auipc	ra,0x0
    800036ba:	d9e080e7          	jalr	-610(ra) # 80003454 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036be:	0074f713          	andi	a4,s1,7
    800036c2:	4785                	li	a5,1
    800036c4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036c8:	14ce                	slli	s1,s1,0x33
    800036ca:	90d9                	srli	s1,s1,0x36
    800036cc:	00950733          	add	a4,a0,s1
    800036d0:	05874703          	lbu	a4,88(a4)
    800036d4:	00e7f6b3          	and	a3,a5,a4
    800036d8:	c69d                	beqz	a3,80003706 <bfree+0x6c>
    800036da:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036dc:	94aa                	add	s1,s1,a0
    800036de:	fff7c793          	not	a5,a5
    800036e2:	8ff9                	and	a5,a5,a4
    800036e4:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800036e8:	00001097          	auipc	ra,0x1
    800036ec:	11e080e7          	jalr	286(ra) # 80004806 <log_write>
  brelse(bp);
    800036f0:	854a                	mv	a0,s2
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	e92080e7          	jalr	-366(ra) # 80003584 <brelse>
}
    800036fa:	60e2                	ld	ra,24(sp)
    800036fc:	6442                	ld	s0,16(sp)
    800036fe:	64a2                	ld	s1,8(sp)
    80003700:	6902                	ld	s2,0(sp)
    80003702:	6105                	addi	sp,sp,32
    80003704:	8082                	ret
    panic("freeing free block");
    80003706:	00005517          	auipc	a0,0x5
    8000370a:	e9a50513          	addi	a0,a0,-358 # 800085a0 <syscalls+0x100>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	e1c080e7          	jalr	-484(ra) # 8000052a <panic>

0000000080003716 <balloc>:
{
    80003716:	711d                	addi	sp,sp,-96
    80003718:	ec86                	sd	ra,88(sp)
    8000371a:	e8a2                	sd	s0,80(sp)
    8000371c:	e4a6                	sd	s1,72(sp)
    8000371e:	e0ca                	sd	s2,64(sp)
    80003720:	fc4e                	sd	s3,56(sp)
    80003722:	f852                	sd	s4,48(sp)
    80003724:	f456                	sd	s5,40(sp)
    80003726:	f05a                	sd	s6,32(sp)
    80003728:	ec5e                	sd	s7,24(sp)
    8000372a:	e862                	sd	s8,16(sp)
    8000372c:	e466                	sd	s9,8(sp)
    8000372e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003730:	0001d797          	auipc	a5,0x1d
    80003734:	a7c7a783          	lw	a5,-1412(a5) # 800201ac <sb+0x4>
    80003738:	cbd1                	beqz	a5,800037cc <balloc+0xb6>
    8000373a:	8baa                	mv	s7,a0
    8000373c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000373e:	0001db17          	auipc	s6,0x1d
    80003742:	a6ab0b13          	addi	s6,s6,-1430 # 800201a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003746:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003748:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000374a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000374c:	6c89                	lui	s9,0x2
    8000374e:	a831                	j	8000376a <balloc+0x54>
    brelse(bp);
    80003750:	854a                	mv	a0,s2
    80003752:	00000097          	auipc	ra,0x0
    80003756:	e32080e7          	jalr	-462(ra) # 80003584 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000375a:	015c87bb          	addw	a5,s9,s5
    8000375e:	00078a9b          	sext.w	s5,a5
    80003762:	004b2703          	lw	a4,4(s6)
    80003766:	06eaf363          	bgeu	s5,a4,800037cc <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000376a:	41fad79b          	sraiw	a5,s5,0x1f
    8000376e:	0137d79b          	srliw	a5,a5,0x13
    80003772:	015787bb          	addw	a5,a5,s5
    80003776:	40d7d79b          	sraiw	a5,a5,0xd
    8000377a:	01cb2583          	lw	a1,28(s6)
    8000377e:	9dbd                	addw	a1,a1,a5
    80003780:	855e                	mv	a0,s7
    80003782:	00000097          	auipc	ra,0x0
    80003786:	cd2080e7          	jalr	-814(ra) # 80003454 <bread>
    8000378a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000378c:	004b2503          	lw	a0,4(s6)
    80003790:	000a849b          	sext.w	s1,s5
    80003794:	8662                	mv	a2,s8
    80003796:	faa4fde3          	bgeu	s1,a0,80003750 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000379a:	41f6579b          	sraiw	a5,a2,0x1f
    8000379e:	01d7d69b          	srliw	a3,a5,0x1d
    800037a2:	00c6873b          	addw	a4,a3,a2
    800037a6:	00777793          	andi	a5,a4,7
    800037aa:	9f95                	subw	a5,a5,a3
    800037ac:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037b0:	4037571b          	sraiw	a4,a4,0x3
    800037b4:	00e906b3          	add	a3,s2,a4
    800037b8:	0586c683          	lbu	a3,88(a3)
    800037bc:	00d7f5b3          	and	a1,a5,a3
    800037c0:	cd91                	beqz	a1,800037dc <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c2:	2605                	addiw	a2,a2,1
    800037c4:	2485                	addiw	s1,s1,1
    800037c6:	fd4618e3          	bne	a2,s4,80003796 <balloc+0x80>
    800037ca:	b759                	j	80003750 <balloc+0x3a>
  panic("balloc: out of blocks");
    800037cc:	00005517          	auipc	a0,0x5
    800037d0:	dec50513          	addi	a0,a0,-532 # 800085b8 <syscalls+0x118>
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	d56080e7          	jalr	-682(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037dc:	974a                	add	a4,a4,s2
    800037de:	8fd5                	or	a5,a5,a3
    800037e0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800037e4:	854a                	mv	a0,s2
    800037e6:	00001097          	auipc	ra,0x1
    800037ea:	020080e7          	jalr	32(ra) # 80004806 <log_write>
        brelse(bp);
    800037ee:	854a                	mv	a0,s2
    800037f0:	00000097          	auipc	ra,0x0
    800037f4:	d94080e7          	jalr	-620(ra) # 80003584 <brelse>
  bp = bread(dev, bno);
    800037f8:	85a6                	mv	a1,s1
    800037fa:	855e                	mv	a0,s7
    800037fc:	00000097          	auipc	ra,0x0
    80003800:	c58080e7          	jalr	-936(ra) # 80003454 <bread>
    80003804:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003806:	40000613          	li	a2,1024
    8000380a:	4581                	li	a1,0
    8000380c:	05850513          	addi	a0,a0,88
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	4ae080e7          	jalr	1198(ra) # 80000cbe <memset>
  log_write(bp);
    80003818:	854a                	mv	a0,s2
    8000381a:	00001097          	auipc	ra,0x1
    8000381e:	fec080e7          	jalr	-20(ra) # 80004806 <log_write>
  brelse(bp);
    80003822:	854a                	mv	a0,s2
    80003824:	00000097          	auipc	ra,0x0
    80003828:	d60080e7          	jalr	-672(ra) # 80003584 <brelse>
}
    8000382c:	8526                	mv	a0,s1
    8000382e:	60e6                	ld	ra,88(sp)
    80003830:	6446                	ld	s0,80(sp)
    80003832:	64a6                	ld	s1,72(sp)
    80003834:	6906                	ld	s2,64(sp)
    80003836:	79e2                	ld	s3,56(sp)
    80003838:	7a42                	ld	s4,48(sp)
    8000383a:	7aa2                	ld	s5,40(sp)
    8000383c:	7b02                	ld	s6,32(sp)
    8000383e:	6be2                	ld	s7,24(sp)
    80003840:	6c42                	ld	s8,16(sp)
    80003842:	6ca2                	ld	s9,8(sp)
    80003844:	6125                	addi	sp,sp,96
    80003846:	8082                	ret

0000000080003848 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003848:	7179                	addi	sp,sp,-48
    8000384a:	f406                	sd	ra,40(sp)
    8000384c:	f022                	sd	s0,32(sp)
    8000384e:	ec26                	sd	s1,24(sp)
    80003850:	e84a                	sd	s2,16(sp)
    80003852:	e44e                	sd	s3,8(sp)
    80003854:	e052                	sd	s4,0(sp)
    80003856:	1800                	addi	s0,sp,48
    80003858:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000385a:	47ad                	li	a5,11
    8000385c:	04b7fe63          	bgeu	a5,a1,800038b8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003860:	ff45849b          	addiw	s1,a1,-12
    80003864:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003868:	0ff00793          	li	a5,255
    8000386c:	0ae7e463          	bltu	a5,a4,80003914 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003870:	08052583          	lw	a1,128(a0)
    80003874:	c5b5                	beqz	a1,800038e0 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003876:	00092503          	lw	a0,0(s2)
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	bda080e7          	jalr	-1062(ra) # 80003454 <bread>
    80003882:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003884:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003888:	02049713          	slli	a4,s1,0x20
    8000388c:	01e75593          	srli	a1,a4,0x1e
    80003890:	00b784b3          	add	s1,a5,a1
    80003894:	0004a983          	lw	s3,0(s1)
    80003898:	04098e63          	beqz	s3,800038f4 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000389c:	8552                	mv	a0,s4
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	ce6080e7          	jalr	-794(ra) # 80003584 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038a6:	854e                	mv	a0,s3
    800038a8:	70a2                	ld	ra,40(sp)
    800038aa:	7402                	ld	s0,32(sp)
    800038ac:	64e2                	ld	s1,24(sp)
    800038ae:	6942                	ld	s2,16(sp)
    800038b0:	69a2                	ld	s3,8(sp)
    800038b2:	6a02                	ld	s4,0(sp)
    800038b4:	6145                	addi	sp,sp,48
    800038b6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800038b8:	02059793          	slli	a5,a1,0x20
    800038bc:	01e7d593          	srli	a1,a5,0x1e
    800038c0:	00b504b3          	add	s1,a0,a1
    800038c4:	0504a983          	lw	s3,80(s1)
    800038c8:	fc099fe3          	bnez	s3,800038a6 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800038cc:	4108                	lw	a0,0(a0)
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	e48080e7          	jalr	-440(ra) # 80003716 <balloc>
    800038d6:	0005099b          	sext.w	s3,a0
    800038da:	0534a823          	sw	s3,80(s1)
    800038de:	b7e1                	j	800038a6 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800038e0:	4108                	lw	a0,0(a0)
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	e34080e7          	jalr	-460(ra) # 80003716 <balloc>
    800038ea:	0005059b          	sext.w	a1,a0
    800038ee:	08b92023          	sw	a1,128(s2)
    800038f2:	b751                	j	80003876 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800038f4:	00092503          	lw	a0,0(s2)
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	e1e080e7          	jalr	-482(ra) # 80003716 <balloc>
    80003900:	0005099b          	sext.w	s3,a0
    80003904:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003908:	8552                	mv	a0,s4
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	efc080e7          	jalr	-260(ra) # 80004806 <log_write>
    80003912:	b769                	j	8000389c <bmap+0x54>
  panic("bmap: out of range");
    80003914:	00005517          	auipc	a0,0x5
    80003918:	cbc50513          	addi	a0,a0,-836 # 800085d0 <syscalls+0x130>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	c0e080e7          	jalr	-1010(ra) # 8000052a <panic>

0000000080003924 <iget>:
{
    80003924:	7179                	addi	sp,sp,-48
    80003926:	f406                	sd	ra,40(sp)
    80003928:	f022                	sd	s0,32(sp)
    8000392a:	ec26                	sd	s1,24(sp)
    8000392c:	e84a                	sd	s2,16(sp)
    8000392e:	e44e                	sd	s3,8(sp)
    80003930:	e052                	sd	s4,0(sp)
    80003932:	1800                	addi	s0,sp,48
    80003934:	89aa                	mv	s3,a0
    80003936:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003938:	0001d517          	auipc	a0,0x1d
    8000393c:	89050513          	addi	a0,a0,-1904 # 800201c8 <itable>
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	282080e7          	jalr	642(ra) # 80000bc2 <acquire>
  empty = 0;
    80003948:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000394a:	0001d497          	auipc	s1,0x1d
    8000394e:	89648493          	addi	s1,s1,-1898 # 800201e0 <itable+0x18>
    80003952:	0001e697          	auipc	a3,0x1e
    80003956:	31e68693          	addi	a3,a3,798 # 80021c70 <log>
    8000395a:	a039                	j	80003968 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000395c:	02090b63          	beqz	s2,80003992 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003960:	08848493          	addi	s1,s1,136
    80003964:	02d48a63          	beq	s1,a3,80003998 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003968:	449c                	lw	a5,8(s1)
    8000396a:	fef059e3          	blez	a5,8000395c <iget+0x38>
    8000396e:	4098                	lw	a4,0(s1)
    80003970:	ff3716e3          	bne	a4,s3,8000395c <iget+0x38>
    80003974:	40d8                	lw	a4,4(s1)
    80003976:	ff4713e3          	bne	a4,s4,8000395c <iget+0x38>
      ip->ref++;
    8000397a:	2785                	addiw	a5,a5,1
    8000397c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000397e:	0001d517          	auipc	a0,0x1d
    80003982:	84a50513          	addi	a0,a0,-1974 # 800201c8 <itable>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	2f0080e7          	jalr	752(ra) # 80000c76 <release>
      return ip;
    8000398e:	8926                	mv	s2,s1
    80003990:	a03d                	j	800039be <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003992:	f7f9                	bnez	a5,80003960 <iget+0x3c>
    80003994:	8926                	mv	s2,s1
    80003996:	b7e9                	j	80003960 <iget+0x3c>
  if(empty == 0)
    80003998:	02090c63          	beqz	s2,800039d0 <iget+0xac>
  ip->dev = dev;
    8000399c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039a0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039a4:	4785                	li	a5,1
    800039a6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039aa:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039ae:	0001d517          	auipc	a0,0x1d
    800039b2:	81a50513          	addi	a0,a0,-2022 # 800201c8 <itable>
    800039b6:	ffffd097          	auipc	ra,0xffffd
    800039ba:	2c0080e7          	jalr	704(ra) # 80000c76 <release>
}
    800039be:	854a                	mv	a0,s2
    800039c0:	70a2                	ld	ra,40(sp)
    800039c2:	7402                	ld	s0,32(sp)
    800039c4:	64e2                	ld	s1,24(sp)
    800039c6:	6942                	ld	s2,16(sp)
    800039c8:	69a2                	ld	s3,8(sp)
    800039ca:	6a02                	ld	s4,0(sp)
    800039cc:	6145                	addi	sp,sp,48
    800039ce:	8082                	ret
    panic("iget: no inodes");
    800039d0:	00005517          	auipc	a0,0x5
    800039d4:	c1850513          	addi	a0,a0,-1000 # 800085e8 <syscalls+0x148>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	b52080e7          	jalr	-1198(ra) # 8000052a <panic>

00000000800039e0 <fsinit>:
fsinit(int dev) {
    800039e0:	7179                	addi	sp,sp,-48
    800039e2:	f406                	sd	ra,40(sp)
    800039e4:	f022                	sd	s0,32(sp)
    800039e6:	ec26                	sd	s1,24(sp)
    800039e8:	e84a                	sd	s2,16(sp)
    800039ea:	e44e                	sd	s3,8(sp)
    800039ec:	1800                	addi	s0,sp,48
    800039ee:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039f0:	4585                	li	a1,1
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	a62080e7          	jalr	-1438(ra) # 80003454 <bread>
    800039fa:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039fc:	0001c997          	auipc	s3,0x1c
    80003a00:	7ac98993          	addi	s3,s3,1964 # 800201a8 <sb>
    80003a04:	02000613          	li	a2,32
    80003a08:	05850593          	addi	a1,a0,88
    80003a0c:	854e                	mv	a0,s3
    80003a0e:	ffffd097          	auipc	ra,0xffffd
    80003a12:	30c080e7          	jalr	780(ra) # 80000d1a <memmove>
  brelse(bp);
    80003a16:	8526                	mv	a0,s1
    80003a18:	00000097          	auipc	ra,0x0
    80003a1c:	b6c080e7          	jalr	-1172(ra) # 80003584 <brelse>
  if(sb.magic != FSMAGIC)
    80003a20:	0009a703          	lw	a4,0(s3)
    80003a24:	102037b7          	lui	a5,0x10203
    80003a28:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a2c:	02f71263          	bne	a4,a5,80003a50 <fsinit+0x70>
  initlog(dev, &sb);
    80003a30:	0001c597          	auipc	a1,0x1c
    80003a34:	77858593          	addi	a1,a1,1912 # 800201a8 <sb>
    80003a38:	854a                	mv	a0,s2
    80003a3a:	00001097          	auipc	ra,0x1
    80003a3e:	b4e080e7          	jalr	-1202(ra) # 80004588 <initlog>
}
    80003a42:	70a2                	ld	ra,40(sp)
    80003a44:	7402                	ld	s0,32(sp)
    80003a46:	64e2                	ld	s1,24(sp)
    80003a48:	6942                	ld	s2,16(sp)
    80003a4a:	69a2                	ld	s3,8(sp)
    80003a4c:	6145                	addi	sp,sp,48
    80003a4e:	8082                	ret
    panic("invalid file system");
    80003a50:	00005517          	auipc	a0,0x5
    80003a54:	ba850513          	addi	a0,a0,-1112 # 800085f8 <syscalls+0x158>
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	ad2080e7          	jalr	-1326(ra) # 8000052a <panic>

0000000080003a60 <iinit>:
{
    80003a60:	7179                	addi	sp,sp,-48
    80003a62:	f406                	sd	ra,40(sp)
    80003a64:	f022                	sd	s0,32(sp)
    80003a66:	ec26                	sd	s1,24(sp)
    80003a68:	e84a                	sd	s2,16(sp)
    80003a6a:	e44e                	sd	s3,8(sp)
    80003a6c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a6e:	00005597          	auipc	a1,0x5
    80003a72:	ba258593          	addi	a1,a1,-1118 # 80008610 <syscalls+0x170>
    80003a76:	0001c517          	auipc	a0,0x1c
    80003a7a:	75250513          	addi	a0,a0,1874 # 800201c8 <itable>
    80003a7e:	ffffd097          	auipc	ra,0xffffd
    80003a82:	0b4080e7          	jalr	180(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a86:	0001c497          	auipc	s1,0x1c
    80003a8a:	76a48493          	addi	s1,s1,1898 # 800201f0 <itable+0x28>
    80003a8e:	0001e997          	auipc	s3,0x1e
    80003a92:	1f298993          	addi	s3,s3,498 # 80021c80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a96:	00005917          	auipc	s2,0x5
    80003a9a:	b8290913          	addi	s2,s2,-1150 # 80008618 <syscalls+0x178>
    80003a9e:	85ca                	mv	a1,s2
    80003aa0:	8526                	mv	a0,s1
    80003aa2:	00001097          	auipc	ra,0x1
    80003aa6:	e4a080e7          	jalr	-438(ra) # 800048ec <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003aaa:	08848493          	addi	s1,s1,136
    80003aae:	ff3498e3          	bne	s1,s3,80003a9e <iinit+0x3e>
}
    80003ab2:	70a2                	ld	ra,40(sp)
    80003ab4:	7402                	ld	s0,32(sp)
    80003ab6:	64e2                	ld	s1,24(sp)
    80003ab8:	6942                	ld	s2,16(sp)
    80003aba:	69a2                	ld	s3,8(sp)
    80003abc:	6145                	addi	sp,sp,48
    80003abe:	8082                	ret

0000000080003ac0 <ialloc>:
{
    80003ac0:	715d                	addi	sp,sp,-80
    80003ac2:	e486                	sd	ra,72(sp)
    80003ac4:	e0a2                	sd	s0,64(sp)
    80003ac6:	fc26                	sd	s1,56(sp)
    80003ac8:	f84a                	sd	s2,48(sp)
    80003aca:	f44e                	sd	s3,40(sp)
    80003acc:	f052                	sd	s4,32(sp)
    80003ace:	ec56                	sd	s5,24(sp)
    80003ad0:	e85a                	sd	s6,16(sp)
    80003ad2:	e45e                	sd	s7,8(sp)
    80003ad4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ad6:	0001c717          	auipc	a4,0x1c
    80003ada:	6de72703          	lw	a4,1758(a4) # 800201b4 <sb+0xc>
    80003ade:	4785                	li	a5,1
    80003ae0:	04e7fa63          	bgeu	a5,a4,80003b34 <ialloc+0x74>
    80003ae4:	8aaa                	mv	s5,a0
    80003ae6:	8bae                	mv	s7,a1
    80003ae8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003aea:	0001ca17          	auipc	s4,0x1c
    80003aee:	6bea0a13          	addi	s4,s4,1726 # 800201a8 <sb>
    80003af2:	00048b1b          	sext.w	s6,s1
    80003af6:	0044d793          	srli	a5,s1,0x4
    80003afa:	018a2583          	lw	a1,24(s4)
    80003afe:	9dbd                	addw	a1,a1,a5
    80003b00:	8556                	mv	a0,s5
    80003b02:	00000097          	auipc	ra,0x0
    80003b06:	952080e7          	jalr	-1710(ra) # 80003454 <bread>
    80003b0a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b0c:	05850993          	addi	s3,a0,88
    80003b10:	00f4f793          	andi	a5,s1,15
    80003b14:	079a                	slli	a5,a5,0x6
    80003b16:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b18:	00099783          	lh	a5,0(s3)
    80003b1c:	c785                	beqz	a5,80003b44 <ialloc+0x84>
    brelse(bp);
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	a66080e7          	jalr	-1434(ra) # 80003584 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b26:	0485                	addi	s1,s1,1
    80003b28:	00ca2703          	lw	a4,12(s4)
    80003b2c:	0004879b          	sext.w	a5,s1
    80003b30:	fce7e1e3          	bltu	a5,a4,80003af2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003b34:	00005517          	auipc	a0,0x5
    80003b38:	aec50513          	addi	a0,a0,-1300 # 80008620 <syscalls+0x180>
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	9ee080e7          	jalr	-1554(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003b44:	04000613          	li	a2,64
    80003b48:	4581                	li	a1,0
    80003b4a:	854e                	mv	a0,s3
    80003b4c:	ffffd097          	auipc	ra,0xffffd
    80003b50:	172080e7          	jalr	370(ra) # 80000cbe <memset>
      dip->type = type;
    80003b54:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b58:	854a                	mv	a0,s2
    80003b5a:	00001097          	auipc	ra,0x1
    80003b5e:	cac080e7          	jalr	-852(ra) # 80004806 <log_write>
      brelse(bp);
    80003b62:	854a                	mv	a0,s2
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	a20080e7          	jalr	-1504(ra) # 80003584 <brelse>
      return iget(dev, inum);
    80003b6c:	85da                	mv	a1,s6
    80003b6e:	8556                	mv	a0,s5
    80003b70:	00000097          	auipc	ra,0x0
    80003b74:	db4080e7          	jalr	-588(ra) # 80003924 <iget>
}
    80003b78:	60a6                	ld	ra,72(sp)
    80003b7a:	6406                	ld	s0,64(sp)
    80003b7c:	74e2                	ld	s1,56(sp)
    80003b7e:	7942                	ld	s2,48(sp)
    80003b80:	79a2                	ld	s3,40(sp)
    80003b82:	7a02                	ld	s4,32(sp)
    80003b84:	6ae2                	ld	s5,24(sp)
    80003b86:	6b42                	ld	s6,16(sp)
    80003b88:	6ba2                	ld	s7,8(sp)
    80003b8a:	6161                	addi	sp,sp,80
    80003b8c:	8082                	ret

0000000080003b8e <iupdate>:
{
    80003b8e:	1101                	addi	sp,sp,-32
    80003b90:	ec06                	sd	ra,24(sp)
    80003b92:	e822                	sd	s0,16(sp)
    80003b94:	e426                	sd	s1,8(sp)
    80003b96:	e04a                	sd	s2,0(sp)
    80003b98:	1000                	addi	s0,sp,32
    80003b9a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b9c:	415c                	lw	a5,4(a0)
    80003b9e:	0047d79b          	srliw	a5,a5,0x4
    80003ba2:	0001c597          	auipc	a1,0x1c
    80003ba6:	61e5a583          	lw	a1,1566(a1) # 800201c0 <sb+0x18>
    80003baa:	9dbd                	addw	a1,a1,a5
    80003bac:	4108                	lw	a0,0(a0)
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	8a6080e7          	jalr	-1882(ra) # 80003454 <bread>
    80003bb6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bb8:	05850793          	addi	a5,a0,88
    80003bbc:	40c8                	lw	a0,4(s1)
    80003bbe:	893d                	andi	a0,a0,15
    80003bc0:	051a                	slli	a0,a0,0x6
    80003bc2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003bc4:	04449703          	lh	a4,68(s1)
    80003bc8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003bcc:	04649703          	lh	a4,70(s1)
    80003bd0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003bd4:	04849703          	lh	a4,72(s1)
    80003bd8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003bdc:	04a49703          	lh	a4,74(s1)
    80003be0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003be4:	44f8                	lw	a4,76(s1)
    80003be6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003be8:	03400613          	li	a2,52
    80003bec:	05048593          	addi	a1,s1,80
    80003bf0:	0531                	addi	a0,a0,12
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	128080e7          	jalr	296(ra) # 80000d1a <memmove>
  log_write(bp);
    80003bfa:	854a                	mv	a0,s2
    80003bfc:	00001097          	auipc	ra,0x1
    80003c00:	c0a080e7          	jalr	-1014(ra) # 80004806 <log_write>
  brelse(bp);
    80003c04:	854a                	mv	a0,s2
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	97e080e7          	jalr	-1666(ra) # 80003584 <brelse>
}
    80003c0e:	60e2                	ld	ra,24(sp)
    80003c10:	6442                	ld	s0,16(sp)
    80003c12:	64a2                	ld	s1,8(sp)
    80003c14:	6902                	ld	s2,0(sp)
    80003c16:	6105                	addi	sp,sp,32
    80003c18:	8082                	ret

0000000080003c1a <idup>:
{
    80003c1a:	1101                	addi	sp,sp,-32
    80003c1c:	ec06                	sd	ra,24(sp)
    80003c1e:	e822                	sd	s0,16(sp)
    80003c20:	e426                	sd	s1,8(sp)
    80003c22:	1000                	addi	s0,sp,32
    80003c24:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c26:	0001c517          	auipc	a0,0x1c
    80003c2a:	5a250513          	addi	a0,a0,1442 # 800201c8 <itable>
    80003c2e:	ffffd097          	auipc	ra,0xffffd
    80003c32:	f94080e7          	jalr	-108(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003c36:	449c                	lw	a5,8(s1)
    80003c38:	2785                	addiw	a5,a5,1
    80003c3a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c3c:	0001c517          	auipc	a0,0x1c
    80003c40:	58c50513          	addi	a0,a0,1420 # 800201c8 <itable>
    80003c44:	ffffd097          	auipc	ra,0xffffd
    80003c48:	032080e7          	jalr	50(ra) # 80000c76 <release>
}
    80003c4c:	8526                	mv	a0,s1
    80003c4e:	60e2                	ld	ra,24(sp)
    80003c50:	6442                	ld	s0,16(sp)
    80003c52:	64a2                	ld	s1,8(sp)
    80003c54:	6105                	addi	sp,sp,32
    80003c56:	8082                	ret

0000000080003c58 <ilock>:
{
    80003c58:	1101                	addi	sp,sp,-32
    80003c5a:	ec06                	sd	ra,24(sp)
    80003c5c:	e822                	sd	s0,16(sp)
    80003c5e:	e426                	sd	s1,8(sp)
    80003c60:	e04a                	sd	s2,0(sp)
    80003c62:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c64:	c115                	beqz	a0,80003c88 <ilock+0x30>
    80003c66:	84aa                	mv	s1,a0
    80003c68:	451c                	lw	a5,8(a0)
    80003c6a:	00f05f63          	blez	a5,80003c88 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c6e:	0541                	addi	a0,a0,16
    80003c70:	00001097          	auipc	ra,0x1
    80003c74:	cb6080e7          	jalr	-842(ra) # 80004926 <acquiresleep>
  if(ip->valid == 0){
    80003c78:	40bc                	lw	a5,64(s1)
    80003c7a:	cf99                	beqz	a5,80003c98 <ilock+0x40>
}
    80003c7c:	60e2                	ld	ra,24(sp)
    80003c7e:	6442                	ld	s0,16(sp)
    80003c80:	64a2                	ld	s1,8(sp)
    80003c82:	6902                	ld	s2,0(sp)
    80003c84:	6105                	addi	sp,sp,32
    80003c86:	8082                	ret
    panic("ilock");
    80003c88:	00005517          	auipc	a0,0x5
    80003c8c:	9b050513          	addi	a0,a0,-1616 # 80008638 <syscalls+0x198>
    80003c90:	ffffd097          	auipc	ra,0xffffd
    80003c94:	89a080e7          	jalr	-1894(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c98:	40dc                	lw	a5,4(s1)
    80003c9a:	0047d79b          	srliw	a5,a5,0x4
    80003c9e:	0001c597          	auipc	a1,0x1c
    80003ca2:	5225a583          	lw	a1,1314(a1) # 800201c0 <sb+0x18>
    80003ca6:	9dbd                	addw	a1,a1,a5
    80003ca8:	4088                	lw	a0,0(s1)
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	7aa080e7          	jalr	1962(ra) # 80003454 <bread>
    80003cb2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cb4:	05850593          	addi	a1,a0,88
    80003cb8:	40dc                	lw	a5,4(s1)
    80003cba:	8bbd                	andi	a5,a5,15
    80003cbc:	079a                	slli	a5,a5,0x6
    80003cbe:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cc0:	00059783          	lh	a5,0(a1)
    80003cc4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cc8:	00259783          	lh	a5,2(a1)
    80003ccc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cd0:	00459783          	lh	a5,4(a1)
    80003cd4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cd8:	00659783          	lh	a5,6(a1)
    80003cdc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003ce0:	459c                	lw	a5,8(a1)
    80003ce2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ce4:	03400613          	li	a2,52
    80003ce8:	05b1                	addi	a1,a1,12
    80003cea:	05048513          	addi	a0,s1,80
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	02c080e7          	jalr	44(ra) # 80000d1a <memmove>
    brelse(bp);
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	88c080e7          	jalr	-1908(ra) # 80003584 <brelse>
    ip->valid = 1;
    80003d00:	4785                	li	a5,1
    80003d02:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d04:	04449783          	lh	a5,68(s1)
    80003d08:	fbb5                	bnez	a5,80003c7c <ilock+0x24>
      panic("ilock: no type");
    80003d0a:	00005517          	auipc	a0,0x5
    80003d0e:	93650513          	addi	a0,a0,-1738 # 80008640 <syscalls+0x1a0>
    80003d12:	ffffd097          	auipc	ra,0xffffd
    80003d16:	818080e7          	jalr	-2024(ra) # 8000052a <panic>

0000000080003d1a <iunlock>:
{
    80003d1a:	1101                	addi	sp,sp,-32
    80003d1c:	ec06                	sd	ra,24(sp)
    80003d1e:	e822                	sd	s0,16(sp)
    80003d20:	e426                	sd	s1,8(sp)
    80003d22:	e04a                	sd	s2,0(sp)
    80003d24:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d26:	c905                	beqz	a0,80003d56 <iunlock+0x3c>
    80003d28:	84aa                	mv	s1,a0
    80003d2a:	01050913          	addi	s2,a0,16
    80003d2e:	854a                	mv	a0,s2
    80003d30:	00001097          	auipc	ra,0x1
    80003d34:	c90080e7          	jalr	-880(ra) # 800049c0 <holdingsleep>
    80003d38:	cd19                	beqz	a0,80003d56 <iunlock+0x3c>
    80003d3a:	449c                	lw	a5,8(s1)
    80003d3c:	00f05d63          	blez	a5,80003d56 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d40:	854a                	mv	a0,s2
    80003d42:	00001097          	auipc	ra,0x1
    80003d46:	c3a080e7          	jalr	-966(ra) # 8000497c <releasesleep>
}
    80003d4a:	60e2                	ld	ra,24(sp)
    80003d4c:	6442                	ld	s0,16(sp)
    80003d4e:	64a2                	ld	s1,8(sp)
    80003d50:	6902                	ld	s2,0(sp)
    80003d52:	6105                	addi	sp,sp,32
    80003d54:	8082                	ret
    panic("iunlock");
    80003d56:	00005517          	auipc	a0,0x5
    80003d5a:	8fa50513          	addi	a0,a0,-1798 # 80008650 <syscalls+0x1b0>
    80003d5e:	ffffc097          	auipc	ra,0xffffc
    80003d62:	7cc080e7          	jalr	1996(ra) # 8000052a <panic>

0000000080003d66 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d66:	7179                	addi	sp,sp,-48
    80003d68:	f406                	sd	ra,40(sp)
    80003d6a:	f022                	sd	s0,32(sp)
    80003d6c:	ec26                	sd	s1,24(sp)
    80003d6e:	e84a                	sd	s2,16(sp)
    80003d70:	e44e                	sd	s3,8(sp)
    80003d72:	e052                	sd	s4,0(sp)
    80003d74:	1800                	addi	s0,sp,48
    80003d76:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d78:	05050493          	addi	s1,a0,80
    80003d7c:	08050913          	addi	s2,a0,128
    80003d80:	a021                	j	80003d88 <itrunc+0x22>
    80003d82:	0491                	addi	s1,s1,4
    80003d84:	01248d63          	beq	s1,s2,80003d9e <itrunc+0x38>
    if(ip->addrs[i]){
    80003d88:	408c                	lw	a1,0(s1)
    80003d8a:	dde5                	beqz	a1,80003d82 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d8c:	0009a503          	lw	a0,0(s3)
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	90a080e7          	jalr	-1782(ra) # 8000369a <bfree>
      ip->addrs[i] = 0;
    80003d98:	0004a023          	sw	zero,0(s1)
    80003d9c:	b7dd                	j	80003d82 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d9e:	0809a583          	lw	a1,128(s3)
    80003da2:	e185                	bnez	a1,80003dc2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003da4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003da8:	854e                	mv	a0,s3
    80003daa:	00000097          	auipc	ra,0x0
    80003dae:	de4080e7          	jalr	-540(ra) # 80003b8e <iupdate>
}
    80003db2:	70a2                	ld	ra,40(sp)
    80003db4:	7402                	ld	s0,32(sp)
    80003db6:	64e2                	ld	s1,24(sp)
    80003db8:	6942                	ld	s2,16(sp)
    80003dba:	69a2                	ld	s3,8(sp)
    80003dbc:	6a02                	ld	s4,0(sp)
    80003dbe:	6145                	addi	sp,sp,48
    80003dc0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dc2:	0009a503          	lw	a0,0(s3)
    80003dc6:	fffff097          	auipc	ra,0xfffff
    80003dca:	68e080e7          	jalr	1678(ra) # 80003454 <bread>
    80003dce:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dd0:	05850493          	addi	s1,a0,88
    80003dd4:	45850913          	addi	s2,a0,1112
    80003dd8:	a021                	j	80003de0 <itrunc+0x7a>
    80003dda:	0491                	addi	s1,s1,4
    80003ddc:	01248b63          	beq	s1,s2,80003df2 <itrunc+0x8c>
      if(a[j])
    80003de0:	408c                	lw	a1,0(s1)
    80003de2:	dde5                	beqz	a1,80003dda <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003de4:	0009a503          	lw	a0,0(s3)
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	8b2080e7          	jalr	-1870(ra) # 8000369a <bfree>
    80003df0:	b7ed                	j	80003dda <itrunc+0x74>
    brelse(bp);
    80003df2:	8552                	mv	a0,s4
    80003df4:	fffff097          	auipc	ra,0xfffff
    80003df8:	790080e7          	jalr	1936(ra) # 80003584 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003dfc:	0809a583          	lw	a1,128(s3)
    80003e00:	0009a503          	lw	a0,0(s3)
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	896080e7          	jalr	-1898(ra) # 8000369a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e0c:	0809a023          	sw	zero,128(s3)
    80003e10:	bf51                	j	80003da4 <itrunc+0x3e>

0000000080003e12 <iput>:
{
    80003e12:	1101                	addi	sp,sp,-32
    80003e14:	ec06                	sd	ra,24(sp)
    80003e16:	e822                	sd	s0,16(sp)
    80003e18:	e426                	sd	s1,8(sp)
    80003e1a:	e04a                	sd	s2,0(sp)
    80003e1c:	1000                	addi	s0,sp,32
    80003e1e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e20:	0001c517          	auipc	a0,0x1c
    80003e24:	3a850513          	addi	a0,a0,936 # 800201c8 <itable>
    80003e28:	ffffd097          	auipc	ra,0xffffd
    80003e2c:	d9a080e7          	jalr	-614(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e30:	4498                	lw	a4,8(s1)
    80003e32:	4785                	li	a5,1
    80003e34:	02f70363          	beq	a4,a5,80003e5a <iput+0x48>
  ip->ref--;
    80003e38:	449c                	lw	a5,8(s1)
    80003e3a:	37fd                	addiw	a5,a5,-1
    80003e3c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e3e:	0001c517          	auipc	a0,0x1c
    80003e42:	38a50513          	addi	a0,a0,906 # 800201c8 <itable>
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	e30080e7          	jalr	-464(ra) # 80000c76 <release>
}
    80003e4e:	60e2                	ld	ra,24(sp)
    80003e50:	6442                	ld	s0,16(sp)
    80003e52:	64a2                	ld	s1,8(sp)
    80003e54:	6902                	ld	s2,0(sp)
    80003e56:	6105                	addi	sp,sp,32
    80003e58:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e5a:	40bc                	lw	a5,64(s1)
    80003e5c:	dff1                	beqz	a5,80003e38 <iput+0x26>
    80003e5e:	04a49783          	lh	a5,74(s1)
    80003e62:	fbf9                	bnez	a5,80003e38 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e64:	01048913          	addi	s2,s1,16
    80003e68:	854a                	mv	a0,s2
    80003e6a:	00001097          	auipc	ra,0x1
    80003e6e:	abc080e7          	jalr	-1348(ra) # 80004926 <acquiresleep>
    release(&itable.lock);
    80003e72:	0001c517          	auipc	a0,0x1c
    80003e76:	35650513          	addi	a0,a0,854 # 800201c8 <itable>
    80003e7a:	ffffd097          	auipc	ra,0xffffd
    80003e7e:	dfc080e7          	jalr	-516(ra) # 80000c76 <release>
    itrunc(ip);
    80003e82:	8526                	mv	a0,s1
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	ee2080e7          	jalr	-286(ra) # 80003d66 <itrunc>
    ip->type = 0;
    80003e8c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e90:	8526                	mv	a0,s1
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	cfc080e7          	jalr	-772(ra) # 80003b8e <iupdate>
    ip->valid = 0;
    80003e9a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e9e:	854a                	mv	a0,s2
    80003ea0:	00001097          	auipc	ra,0x1
    80003ea4:	adc080e7          	jalr	-1316(ra) # 8000497c <releasesleep>
    acquire(&itable.lock);
    80003ea8:	0001c517          	auipc	a0,0x1c
    80003eac:	32050513          	addi	a0,a0,800 # 800201c8 <itable>
    80003eb0:	ffffd097          	auipc	ra,0xffffd
    80003eb4:	d12080e7          	jalr	-750(ra) # 80000bc2 <acquire>
    80003eb8:	b741                	j	80003e38 <iput+0x26>

0000000080003eba <iunlockput>:
{
    80003eba:	1101                	addi	sp,sp,-32
    80003ebc:	ec06                	sd	ra,24(sp)
    80003ebe:	e822                	sd	s0,16(sp)
    80003ec0:	e426                	sd	s1,8(sp)
    80003ec2:	1000                	addi	s0,sp,32
    80003ec4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	e54080e7          	jalr	-428(ra) # 80003d1a <iunlock>
  iput(ip);
    80003ece:	8526                	mv	a0,s1
    80003ed0:	00000097          	auipc	ra,0x0
    80003ed4:	f42080e7          	jalr	-190(ra) # 80003e12 <iput>
}
    80003ed8:	60e2                	ld	ra,24(sp)
    80003eda:	6442                	ld	s0,16(sp)
    80003edc:	64a2                	ld	s1,8(sp)
    80003ede:	6105                	addi	sp,sp,32
    80003ee0:	8082                	ret

0000000080003ee2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ee2:	1141                	addi	sp,sp,-16
    80003ee4:	e422                	sd	s0,8(sp)
    80003ee6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ee8:	411c                	lw	a5,0(a0)
    80003eea:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003eec:	415c                	lw	a5,4(a0)
    80003eee:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ef0:	04451783          	lh	a5,68(a0)
    80003ef4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ef8:	04a51783          	lh	a5,74(a0)
    80003efc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f00:	04c56783          	lwu	a5,76(a0)
    80003f04:	e99c                	sd	a5,16(a1)
}
    80003f06:	6422                	ld	s0,8(sp)
    80003f08:	0141                	addi	sp,sp,16
    80003f0a:	8082                	ret

0000000080003f0c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f0c:	457c                	lw	a5,76(a0)
    80003f0e:	0ed7e963          	bltu	a5,a3,80004000 <readi+0xf4>
{
    80003f12:	7159                	addi	sp,sp,-112
    80003f14:	f486                	sd	ra,104(sp)
    80003f16:	f0a2                	sd	s0,96(sp)
    80003f18:	eca6                	sd	s1,88(sp)
    80003f1a:	e8ca                	sd	s2,80(sp)
    80003f1c:	e4ce                	sd	s3,72(sp)
    80003f1e:	e0d2                	sd	s4,64(sp)
    80003f20:	fc56                	sd	s5,56(sp)
    80003f22:	f85a                	sd	s6,48(sp)
    80003f24:	f45e                	sd	s7,40(sp)
    80003f26:	f062                	sd	s8,32(sp)
    80003f28:	ec66                	sd	s9,24(sp)
    80003f2a:	e86a                	sd	s10,16(sp)
    80003f2c:	e46e                	sd	s11,8(sp)
    80003f2e:	1880                	addi	s0,sp,112
    80003f30:	8baa                	mv	s7,a0
    80003f32:	8c2e                	mv	s8,a1
    80003f34:	8ab2                	mv	s5,a2
    80003f36:	84b6                	mv	s1,a3
    80003f38:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f3a:	9f35                	addw	a4,a4,a3
    return 0;
    80003f3c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f3e:	0ad76063          	bltu	a4,a3,80003fde <readi+0xd2>
  if(off + n > ip->size)
    80003f42:	00e7f463          	bgeu	a5,a4,80003f4a <readi+0x3e>
    n = ip->size - off;
    80003f46:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f4a:	0a0b0963          	beqz	s6,80003ffc <readi+0xf0>
    80003f4e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f50:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f54:	5cfd                	li	s9,-1
    80003f56:	a82d                	j	80003f90 <readi+0x84>
    80003f58:	020a1d93          	slli	s11,s4,0x20
    80003f5c:	020ddd93          	srli	s11,s11,0x20
    80003f60:	05890793          	addi	a5,s2,88
    80003f64:	86ee                	mv	a3,s11
    80003f66:	963e                	add	a2,a2,a5
    80003f68:	85d6                	mv	a1,s5
    80003f6a:	8562                	mv	a0,s8
    80003f6c:	ffffe097          	auipc	ra,0xffffe
    80003f70:	6d8080e7          	jalr	1752(ra) # 80002644 <either_copyout>
    80003f74:	05950d63          	beq	a0,s9,80003fce <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f78:	854a                	mv	a0,s2
    80003f7a:	fffff097          	auipc	ra,0xfffff
    80003f7e:	60a080e7          	jalr	1546(ra) # 80003584 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f82:	013a09bb          	addw	s3,s4,s3
    80003f86:	009a04bb          	addw	s1,s4,s1
    80003f8a:	9aee                	add	s5,s5,s11
    80003f8c:	0569f763          	bgeu	s3,s6,80003fda <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f90:	000ba903          	lw	s2,0(s7)
    80003f94:	00a4d59b          	srliw	a1,s1,0xa
    80003f98:	855e                	mv	a0,s7
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	8ae080e7          	jalr	-1874(ra) # 80003848 <bmap>
    80003fa2:	0005059b          	sext.w	a1,a0
    80003fa6:	854a                	mv	a0,s2
    80003fa8:	fffff097          	auipc	ra,0xfffff
    80003fac:	4ac080e7          	jalr	1196(ra) # 80003454 <bread>
    80003fb0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fb2:	3ff4f613          	andi	a2,s1,1023
    80003fb6:	40cd07bb          	subw	a5,s10,a2
    80003fba:	413b073b          	subw	a4,s6,s3
    80003fbe:	8a3e                	mv	s4,a5
    80003fc0:	2781                	sext.w	a5,a5
    80003fc2:	0007069b          	sext.w	a3,a4
    80003fc6:	f8f6f9e3          	bgeu	a3,a5,80003f58 <readi+0x4c>
    80003fca:	8a3a                	mv	s4,a4
    80003fcc:	b771                	j	80003f58 <readi+0x4c>
      brelse(bp);
    80003fce:	854a                	mv	a0,s2
    80003fd0:	fffff097          	auipc	ra,0xfffff
    80003fd4:	5b4080e7          	jalr	1460(ra) # 80003584 <brelse>
      tot = -1;
    80003fd8:	59fd                	li	s3,-1
  }
  return tot;
    80003fda:	0009851b          	sext.w	a0,s3
}
    80003fde:	70a6                	ld	ra,104(sp)
    80003fe0:	7406                	ld	s0,96(sp)
    80003fe2:	64e6                	ld	s1,88(sp)
    80003fe4:	6946                	ld	s2,80(sp)
    80003fe6:	69a6                	ld	s3,72(sp)
    80003fe8:	6a06                	ld	s4,64(sp)
    80003fea:	7ae2                	ld	s5,56(sp)
    80003fec:	7b42                	ld	s6,48(sp)
    80003fee:	7ba2                	ld	s7,40(sp)
    80003ff0:	7c02                	ld	s8,32(sp)
    80003ff2:	6ce2                	ld	s9,24(sp)
    80003ff4:	6d42                	ld	s10,16(sp)
    80003ff6:	6da2                	ld	s11,8(sp)
    80003ff8:	6165                	addi	sp,sp,112
    80003ffa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ffc:	89da                	mv	s3,s6
    80003ffe:	bff1                	j	80003fda <readi+0xce>
    return 0;
    80004000:	4501                	li	a0,0
}
    80004002:	8082                	ret

0000000080004004 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004004:	457c                	lw	a5,76(a0)
    80004006:	10d7e863          	bltu	a5,a3,80004116 <writei+0x112>
{
    8000400a:	7159                	addi	sp,sp,-112
    8000400c:	f486                	sd	ra,104(sp)
    8000400e:	f0a2                	sd	s0,96(sp)
    80004010:	eca6                	sd	s1,88(sp)
    80004012:	e8ca                	sd	s2,80(sp)
    80004014:	e4ce                	sd	s3,72(sp)
    80004016:	e0d2                	sd	s4,64(sp)
    80004018:	fc56                	sd	s5,56(sp)
    8000401a:	f85a                	sd	s6,48(sp)
    8000401c:	f45e                	sd	s7,40(sp)
    8000401e:	f062                	sd	s8,32(sp)
    80004020:	ec66                	sd	s9,24(sp)
    80004022:	e86a                	sd	s10,16(sp)
    80004024:	e46e                	sd	s11,8(sp)
    80004026:	1880                	addi	s0,sp,112
    80004028:	8b2a                	mv	s6,a0
    8000402a:	8c2e                	mv	s8,a1
    8000402c:	8ab2                	mv	s5,a2
    8000402e:	8936                	mv	s2,a3
    80004030:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004032:	00e687bb          	addw	a5,a3,a4
    80004036:	0ed7e263          	bltu	a5,a3,8000411a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000403a:	00043737          	lui	a4,0x43
    8000403e:	0ef76063          	bltu	a4,a5,8000411e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004042:	0c0b8863          	beqz	s7,80004112 <writei+0x10e>
    80004046:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004048:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000404c:	5cfd                	li	s9,-1
    8000404e:	a091                	j	80004092 <writei+0x8e>
    80004050:	02099d93          	slli	s11,s3,0x20
    80004054:	020ddd93          	srli	s11,s11,0x20
    80004058:	05848793          	addi	a5,s1,88
    8000405c:	86ee                	mv	a3,s11
    8000405e:	8656                	mv	a2,s5
    80004060:	85e2                	mv	a1,s8
    80004062:	953e                	add	a0,a0,a5
    80004064:	ffffe097          	auipc	ra,0xffffe
    80004068:	636080e7          	jalr	1590(ra) # 8000269a <either_copyin>
    8000406c:	07950263          	beq	a0,s9,800040d0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004070:	8526                	mv	a0,s1
    80004072:	00000097          	auipc	ra,0x0
    80004076:	794080e7          	jalr	1940(ra) # 80004806 <log_write>
    brelse(bp);
    8000407a:	8526                	mv	a0,s1
    8000407c:	fffff097          	auipc	ra,0xfffff
    80004080:	508080e7          	jalr	1288(ra) # 80003584 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004084:	01498a3b          	addw	s4,s3,s4
    80004088:	0129893b          	addw	s2,s3,s2
    8000408c:	9aee                	add	s5,s5,s11
    8000408e:	057a7663          	bgeu	s4,s7,800040da <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004092:	000b2483          	lw	s1,0(s6)
    80004096:	00a9559b          	srliw	a1,s2,0xa
    8000409a:	855a                	mv	a0,s6
    8000409c:	fffff097          	auipc	ra,0xfffff
    800040a0:	7ac080e7          	jalr	1964(ra) # 80003848 <bmap>
    800040a4:	0005059b          	sext.w	a1,a0
    800040a8:	8526                	mv	a0,s1
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	3aa080e7          	jalr	938(ra) # 80003454 <bread>
    800040b2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040b4:	3ff97513          	andi	a0,s2,1023
    800040b8:	40ad07bb          	subw	a5,s10,a0
    800040bc:	414b873b          	subw	a4,s7,s4
    800040c0:	89be                	mv	s3,a5
    800040c2:	2781                	sext.w	a5,a5
    800040c4:	0007069b          	sext.w	a3,a4
    800040c8:	f8f6f4e3          	bgeu	a3,a5,80004050 <writei+0x4c>
    800040cc:	89ba                	mv	s3,a4
    800040ce:	b749                	j	80004050 <writei+0x4c>
      brelse(bp);
    800040d0:	8526                	mv	a0,s1
    800040d2:	fffff097          	auipc	ra,0xfffff
    800040d6:	4b2080e7          	jalr	1202(ra) # 80003584 <brelse>
  }

  if(off > ip->size)
    800040da:	04cb2783          	lw	a5,76(s6)
    800040de:	0127f463          	bgeu	a5,s2,800040e6 <writei+0xe2>
    ip->size = off;
    800040e2:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040e6:	855a                	mv	a0,s6
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	aa6080e7          	jalr	-1370(ra) # 80003b8e <iupdate>

  return tot;
    800040f0:	000a051b          	sext.w	a0,s4
}
    800040f4:	70a6                	ld	ra,104(sp)
    800040f6:	7406                	ld	s0,96(sp)
    800040f8:	64e6                	ld	s1,88(sp)
    800040fa:	6946                	ld	s2,80(sp)
    800040fc:	69a6                	ld	s3,72(sp)
    800040fe:	6a06                	ld	s4,64(sp)
    80004100:	7ae2                	ld	s5,56(sp)
    80004102:	7b42                	ld	s6,48(sp)
    80004104:	7ba2                	ld	s7,40(sp)
    80004106:	7c02                	ld	s8,32(sp)
    80004108:	6ce2                	ld	s9,24(sp)
    8000410a:	6d42                	ld	s10,16(sp)
    8000410c:	6da2                	ld	s11,8(sp)
    8000410e:	6165                	addi	sp,sp,112
    80004110:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004112:	8a5e                	mv	s4,s7
    80004114:	bfc9                	j	800040e6 <writei+0xe2>
    return -1;
    80004116:	557d                	li	a0,-1
}
    80004118:	8082                	ret
    return -1;
    8000411a:	557d                	li	a0,-1
    8000411c:	bfe1                	j	800040f4 <writei+0xf0>
    return -1;
    8000411e:	557d                	li	a0,-1
    80004120:	bfd1                	j	800040f4 <writei+0xf0>

0000000080004122 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004122:	1141                	addi	sp,sp,-16
    80004124:	e406                	sd	ra,8(sp)
    80004126:	e022                	sd	s0,0(sp)
    80004128:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000412a:	4639                	li	a2,14
    8000412c:	ffffd097          	auipc	ra,0xffffd
    80004130:	c6a080e7          	jalr	-918(ra) # 80000d96 <strncmp>
}
    80004134:	60a2                	ld	ra,8(sp)
    80004136:	6402                	ld	s0,0(sp)
    80004138:	0141                	addi	sp,sp,16
    8000413a:	8082                	ret

000000008000413c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000413c:	7139                	addi	sp,sp,-64
    8000413e:	fc06                	sd	ra,56(sp)
    80004140:	f822                	sd	s0,48(sp)
    80004142:	f426                	sd	s1,40(sp)
    80004144:	f04a                	sd	s2,32(sp)
    80004146:	ec4e                	sd	s3,24(sp)
    80004148:	e852                	sd	s4,16(sp)
    8000414a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000414c:	04451703          	lh	a4,68(a0)
    80004150:	4785                	li	a5,1
    80004152:	00f71a63          	bne	a4,a5,80004166 <dirlookup+0x2a>
    80004156:	892a                	mv	s2,a0
    80004158:	89ae                	mv	s3,a1
    8000415a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000415c:	457c                	lw	a5,76(a0)
    8000415e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004160:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004162:	e79d                	bnez	a5,80004190 <dirlookup+0x54>
    80004164:	a8a5                	j	800041dc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004166:	00004517          	auipc	a0,0x4
    8000416a:	4f250513          	addi	a0,a0,1266 # 80008658 <syscalls+0x1b8>
    8000416e:	ffffc097          	auipc	ra,0xffffc
    80004172:	3bc080e7          	jalr	956(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004176:	00004517          	auipc	a0,0x4
    8000417a:	4fa50513          	addi	a0,a0,1274 # 80008670 <syscalls+0x1d0>
    8000417e:	ffffc097          	auipc	ra,0xffffc
    80004182:	3ac080e7          	jalr	940(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004186:	24c1                	addiw	s1,s1,16
    80004188:	04c92783          	lw	a5,76(s2)
    8000418c:	04f4f763          	bgeu	s1,a5,800041da <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004190:	4741                	li	a4,16
    80004192:	86a6                	mv	a3,s1
    80004194:	fc040613          	addi	a2,s0,-64
    80004198:	4581                	li	a1,0
    8000419a:	854a                	mv	a0,s2
    8000419c:	00000097          	auipc	ra,0x0
    800041a0:	d70080e7          	jalr	-656(ra) # 80003f0c <readi>
    800041a4:	47c1                	li	a5,16
    800041a6:	fcf518e3          	bne	a0,a5,80004176 <dirlookup+0x3a>
    if(de.inum == 0)
    800041aa:	fc045783          	lhu	a5,-64(s0)
    800041ae:	dfe1                	beqz	a5,80004186 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041b0:	fc240593          	addi	a1,s0,-62
    800041b4:	854e                	mv	a0,s3
    800041b6:	00000097          	auipc	ra,0x0
    800041ba:	f6c080e7          	jalr	-148(ra) # 80004122 <namecmp>
    800041be:	f561                	bnez	a0,80004186 <dirlookup+0x4a>
      if(poff)
    800041c0:	000a0463          	beqz	s4,800041c8 <dirlookup+0x8c>
        *poff = off;
    800041c4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041c8:	fc045583          	lhu	a1,-64(s0)
    800041cc:	00092503          	lw	a0,0(s2)
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	754080e7          	jalr	1876(ra) # 80003924 <iget>
    800041d8:	a011                	j	800041dc <dirlookup+0xa0>
  return 0;
    800041da:	4501                	li	a0,0
}
    800041dc:	70e2                	ld	ra,56(sp)
    800041de:	7442                	ld	s0,48(sp)
    800041e0:	74a2                	ld	s1,40(sp)
    800041e2:	7902                	ld	s2,32(sp)
    800041e4:	69e2                	ld	s3,24(sp)
    800041e6:	6a42                	ld	s4,16(sp)
    800041e8:	6121                	addi	sp,sp,64
    800041ea:	8082                	ret

00000000800041ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041ec:	711d                	addi	sp,sp,-96
    800041ee:	ec86                	sd	ra,88(sp)
    800041f0:	e8a2                	sd	s0,80(sp)
    800041f2:	e4a6                	sd	s1,72(sp)
    800041f4:	e0ca                	sd	s2,64(sp)
    800041f6:	fc4e                	sd	s3,56(sp)
    800041f8:	f852                	sd	s4,48(sp)
    800041fa:	f456                	sd	s5,40(sp)
    800041fc:	f05a                	sd	s6,32(sp)
    800041fe:	ec5e                	sd	s7,24(sp)
    80004200:	e862                	sd	s8,16(sp)
    80004202:	e466                	sd	s9,8(sp)
    80004204:	1080                	addi	s0,sp,96
    80004206:	84aa                	mv	s1,a0
    80004208:	8aae                	mv	s5,a1
    8000420a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000420c:	00054703          	lbu	a4,0(a0)
    80004210:	02f00793          	li	a5,47
    80004214:	02f70363          	beq	a4,a5,8000423a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	766080e7          	jalr	1894(ra) # 8000197e <myproc>
    80004220:	15053503          	ld	a0,336(a0)
    80004224:	00000097          	auipc	ra,0x0
    80004228:	9f6080e7          	jalr	-1546(ra) # 80003c1a <idup>
    8000422c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000422e:	02f00913          	li	s2,47
  len = path - s;
    80004232:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004234:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004236:	4b85                	li	s7,1
    80004238:	a865                	j	800042f0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000423a:	4585                	li	a1,1
    8000423c:	4505                	li	a0,1
    8000423e:	fffff097          	auipc	ra,0xfffff
    80004242:	6e6080e7          	jalr	1766(ra) # 80003924 <iget>
    80004246:	89aa                	mv	s3,a0
    80004248:	b7dd                	j	8000422e <namex+0x42>
      iunlockput(ip);
    8000424a:	854e                	mv	a0,s3
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	c6e080e7          	jalr	-914(ra) # 80003eba <iunlockput>
      return 0;
    80004254:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004256:	854e                	mv	a0,s3
    80004258:	60e6                	ld	ra,88(sp)
    8000425a:	6446                	ld	s0,80(sp)
    8000425c:	64a6                	ld	s1,72(sp)
    8000425e:	6906                	ld	s2,64(sp)
    80004260:	79e2                	ld	s3,56(sp)
    80004262:	7a42                	ld	s4,48(sp)
    80004264:	7aa2                	ld	s5,40(sp)
    80004266:	7b02                	ld	s6,32(sp)
    80004268:	6be2                	ld	s7,24(sp)
    8000426a:	6c42                	ld	s8,16(sp)
    8000426c:	6ca2                	ld	s9,8(sp)
    8000426e:	6125                	addi	sp,sp,96
    80004270:	8082                	ret
      iunlock(ip);
    80004272:	854e                	mv	a0,s3
    80004274:	00000097          	auipc	ra,0x0
    80004278:	aa6080e7          	jalr	-1370(ra) # 80003d1a <iunlock>
      return ip;
    8000427c:	bfe9                	j	80004256 <namex+0x6a>
      iunlockput(ip);
    8000427e:	854e                	mv	a0,s3
    80004280:	00000097          	auipc	ra,0x0
    80004284:	c3a080e7          	jalr	-966(ra) # 80003eba <iunlockput>
      return 0;
    80004288:	89e6                	mv	s3,s9
    8000428a:	b7f1                	j	80004256 <namex+0x6a>
  len = path - s;
    8000428c:	40b48633          	sub	a2,s1,a1
    80004290:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004294:	099c5463          	bge	s8,s9,8000431c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004298:	4639                	li	a2,14
    8000429a:	8552                	mv	a0,s4
    8000429c:	ffffd097          	auipc	ra,0xffffd
    800042a0:	a7e080e7          	jalr	-1410(ra) # 80000d1a <memmove>
  while(*path == '/')
    800042a4:	0004c783          	lbu	a5,0(s1)
    800042a8:	01279763          	bne	a5,s2,800042b6 <namex+0xca>
    path++;
    800042ac:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042ae:	0004c783          	lbu	a5,0(s1)
    800042b2:	ff278de3          	beq	a5,s2,800042ac <namex+0xc0>
    ilock(ip);
    800042b6:	854e                	mv	a0,s3
    800042b8:	00000097          	auipc	ra,0x0
    800042bc:	9a0080e7          	jalr	-1632(ra) # 80003c58 <ilock>
    if(ip->type != T_DIR){
    800042c0:	04499783          	lh	a5,68(s3)
    800042c4:	f97793e3          	bne	a5,s7,8000424a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042c8:	000a8563          	beqz	s5,800042d2 <namex+0xe6>
    800042cc:	0004c783          	lbu	a5,0(s1)
    800042d0:	d3cd                	beqz	a5,80004272 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042d2:	865a                	mv	a2,s6
    800042d4:	85d2                	mv	a1,s4
    800042d6:	854e                	mv	a0,s3
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	e64080e7          	jalr	-412(ra) # 8000413c <dirlookup>
    800042e0:	8caa                	mv	s9,a0
    800042e2:	dd51                	beqz	a0,8000427e <namex+0x92>
    iunlockput(ip);
    800042e4:	854e                	mv	a0,s3
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	bd4080e7          	jalr	-1068(ra) # 80003eba <iunlockput>
    ip = next;
    800042ee:	89e6                	mv	s3,s9
  while(*path == '/')
    800042f0:	0004c783          	lbu	a5,0(s1)
    800042f4:	05279763          	bne	a5,s2,80004342 <namex+0x156>
    path++;
    800042f8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042fa:	0004c783          	lbu	a5,0(s1)
    800042fe:	ff278de3          	beq	a5,s2,800042f8 <namex+0x10c>
  if(*path == 0)
    80004302:	c79d                	beqz	a5,80004330 <namex+0x144>
    path++;
    80004304:	85a6                	mv	a1,s1
  len = path - s;
    80004306:	8cda                	mv	s9,s6
    80004308:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000430a:	01278963          	beq	a5,s2,8000431c <namex+0x130>
    8000430e:	dfbd                	beqz	a5,8000428c <namex+0xa0>
    path++;
    80004310:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004312:	0004c783          	lbu	a5,0(s1)
    80004316:	ff279ce3          	bne	a5,s2,8000430e <namex+0x122>
    8000431a:	bf8d                	j	8000428c <namex+0xa0>
    memmove(name, s, len);
    8000431c:	2601                	sext.w	a2,a2
    8000431e:	8552                	mv	a0,s4
    80004320:	ffffd097          	auipc	ra,0xffffd
    80004324:	9fa080e7          	jalr	-1542(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004328:	9cd2                	add	s9,s9,s4
    8000432a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000432e:	bf9d                	j	800042a4 <namex+0xb8>
  if(nameiparent){
    80004330:	f20a83e3          	beqz	s5,80004256 <namex+0x6a>
    iput(ip);
    80004334:	854e                	mv	a0,s3
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	adc080e7          	jalr	-1316(ra) # 80003e12 <iput>
    return 0;
    8000433e:	4981                	li	s3,0
    80004340:	bf19                	j	80004256 <namex+0x6a>
  if(*path == 0)
    80004342:	d7fd                	beqz	a5,80004330 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004344:	0004c783          	lbu	a5,0(s1)
    80004348:	85a6                	mv	a1,s1
    8000434a:	b7d1                	j	8000430e <namex+0x122>

000000008000434c <dirlink>:
{
    8000434c:	7139                	addi	sp,sp,-64
    8000434e:	fc06                	sd	ra,56(sp)
    80004350:	f822                	sd	s0,48(sp)
    80004352:	f426                	sd	s1,40(sp)
    80004354:	f04a                	sd	s2,32(sp)
    80004356:	ec4e                	sd	s3,24(sp)
    80004358:	e852                	sd	s4,16(sp)
    8000435a:	0080                	addi	s0,sp,64
    8000435c:	892a                	mv	s2,a0
    8000435e:	8a2e                	mv	s4,a1
    80004360:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004362:	4601                	li	a2,0
    80004364:	00000097          	auipc	ra,0x0
    80004368:	dd8080e7          	jalr	-552(ra) # 8000413c <dirlookup>
    8000436c:	e93d                	bnez	a0,800043e2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000436e:	04c92483          	lw	s1,76(s2)
    80004372:	c49d                	beqz	s1,800043a0 <dirlink+0x54>
    80004374:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004376:	4741                	li	a4,16
    80004378:	86a6                	mv	a3,s1
    8000437a:	fc040613          	addi	a2,s0,-64
    8000437e:	4581                	li	a1,0
    80004380:	854a                	mv	a0,s2
    80004382:	00000097          	auipc	ra,0x0
    80004386:	b8a080e7          	jalr	-1142(ra) # 80003f0c <readi>
    8000438a:	47c1                	li	a5,16
    8000438c:	06f51163          	bne	a0,a5,800043ee <dirlink+0xa2>
    if(de.inum == 0)
    80004390:	fc045783          	lhu	a5,-64(s0)
    80004394:	c791                	beqz	a5,800043a0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004396:	24c1                	addiw	s1,s1,16
    80004398:	04c92783          	lw	a5,76(s2)
    8000439c:	fcf4ede3          	bltu	s1,a5,80004376 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043a0:	4639                	li	a2,14
    800043a2:	85d2                	mv	a1,s4
    800043a4:	fc240513          	addi	a0,s0,-62
    800043a8:	ffffd097          	auipc	ra,0xffffd
    800043ac:	a2a080e7          	jalr	-1494(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800043b0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043b4:	4741                	li	a4,16
    800043b6:	86a6                	mv	a3,s1
    800043b8:	fc040613          	addi	a2,s0,-64
    800043bc:	4581                	li	a1,0
    800043be:	854a                	mv	a0,s2
    800043c0:	00000097          	auipc	ra,0x0
    800043c4:	c44080e7          	jalr	-956(ra) # 80004004 <writei>
    800043c8:	872a                	mv	a4,a0
    800043ca:	47c1                	li	a5,16
  return 0;
    800043cc:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043ce:	02f71863          	bne	a4,a5,800043fe <dirlink+0xb2>
}
    800043d2:	70e2                	ld	ra,56(sp)
    800043d4:	7442                	ld	s0,48(sp)
    800043d6:	74a2                	ld	s1,40(sp)
    800043d8:	7902                	ld	s2,32(sp)
    800043da:	69e2                	ld	s3,24(sp)
    800043dc:	6a42                	ld	s4,16(sp)
    800043de:	6121                	addi	sp,sp,64
    800043e0:	8082                	ret
    iput(ip);
    800043e2:	00000097          	auipc	ra,0x0
    800043e6:	a30080e7          	jalr	-1488(ra) # 80003e12 <iput>
    return -1;
    800043ea:	557d                	li	a0,-1
    800043ec:	b7dd                	j	800043d2 <dirlink+0x86>
      panic("dirlink read");
    800043ee:	00004517          	auipc	a0,0x4
    800043f2:	29250513          	addi	a0,a0,658 # 80008680 <syscalls+0x1e0>
    800043f6:	ffffc097          	auipc	ra,0xffffc
    800043fa:	134080e7          	jalr	308(ra) # 8000052a <panic>
    panic("dirlink");
    800043fe:	00004517          	auipc	a0,0x4
    80004402:	39250513          	addi	a0,a0,914 # 80008790 <syscalls+0x2f0>
    80004406:	ffffc097          	auipc	ra,0xffffc
    8000440a:	124080e7          	jalr	292(ra) # 8000052a <panic>

000000008000440e <namei>:

struct inode*
namei(char *path)
{
    8000440e:	1101                	addi	sp,sp,-32
    80004410:	ec06                	sd	ra,24(sp)
    80004412:	e822                	sd	s0,16(sp)
    80004414:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004416:	fe040613          	addi	a2,s0,-32
    8000441a:	4581                	li	a1,0
    8000441c:	00000097          	auipc	ra,0x0
    80004420:	dd0080e7          	jalr	-560(ra) # 800041ec <namex>
}
    80004424:	60e2                	ld	ra,24(sp)
    80004426:	6442                	ld	s0,16(sp)
    80004428:	6105                	addi	sp,sp,32
    8000442a:	8082                	ret

000000008000442c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000442c:	1141                	addi	sp,sp,-16
    8000442e:	e406                	sd	ra,8(sp)
    80004430:	e022                	sd	s0,0(sp)
    80004432:	0800                	addi	s0,sp,16
    80004434:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004436:	4585                	li	a1,1
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	db4080e7          	jalr	-588(ra) # 800041ec <namex>
}
    80004440:	60a2                	ld	ra,8(sp)
    80004442:	6402                	ld	s0,0(sp)
    80004444:	0141                	addi	sp,sp,16
    80004446:	8082                	ret

0000000080004448 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004448:	1101                	addi	sp,sp,-32
    8000444a:	ec06                	sd	ra,24(sp)
    8000444c:	e822                	sd	s0,16(sp)
    8000444e:	e426                	sd	s1,8(sp)
    80004450:	e04a                	sd	s2,0(sp)
    80004452:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004454:	0001e917          	auipc	s2,0x1e
    80004458:	81c90913          	addi	s2,s2,-2020 # 80021c70 <log>
    8000445c:	01892583          	lw	a1,24(s2)
    80004460:	02892503          	lw	a0,40(s2)
    80004464:	fffff097          	auipc	ra,0xfffff
    80004468:	ff0080e7          	jalr	-16(ra) # 80003454 <bread>
    8000446c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000446e:	02c92683          	lw	a3,44(s2)
    80004472:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004474:	02d05863          	blez	a3,800044a4 <write_head+0x5c>
    80004478:	0001e797          	auipc	a5,0x1e
    8000447c:	82878793          	addi	a5,a5,-2008 # 80021ca0 <log+0x30>
    80004480:	05c50713          	addi	a4,a0,92
    80004484:	36fd                	addiw	a3,a3,-1
    80004486:	02069613          	slli	a2,a3,0x20
    8000448a:	01e65693          	srli	a3,a2,0x1e
    8000448e:	0001e617          	auipc	a2,0x1e
    80004492:	81660613          	addi	a2,a2,-2026 # 80021ca4 <log+0x34>
    80004496:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004498:	4390                	lw	a2,0(a5)
    8000449a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000449c:	0791                	addi	a5,a5,4
    8000449e:	0711                	addi	a4,a4,4
    800044a0:	fed79ce3          	bne	a5,a3,80004498 <write_head+0x50>
  }
  bwrite(buf);
    800044a4:	8526                	mv	a0,s1
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	0a0080e7          	jalr	160(ra) # 80003546 <bwrite>
  brelse(buf);
    800044ae:	8526                	mv	a0,s1
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	0d4080e7          	jalr	212(ra) # 80003584 <brelse>
}
    800044b8:	60e2                	ld	ra,24(sp)
    800044ba:	6442                	ld	s0,16(sp)
    800044bc:	64a2                	ld	s1,8(sp)
    800044be:	6902                	ld	s2,0(sp)
    800044c0:	6105                	addi	sp,sp,32
    800044c2:	8082                	ret

00000000800044c4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c4:	0001d797          	auipc	a5,0x1d
    800044c8:	7d87a783          	lw	a5,2008(a5) # 80021c9c <log+0x2c>
    800044cc:	0af05d63          	blez	a5,80004586 <install_trans+0xc2>
{
    800044d0:	7139                	addi	sp,sp,-64
    800044d2:	fc06                	sd	ra,56(sp)
    800044d4:	f822                	sd	s0,48(sp)
    800044d6:	f426                	sd	s1,40(sp)
    800044d8:	f04a                	sd	s2,32(sp)
    800044da:	ec4e                	sd	s3,24(sp)
    800044dc:	e852                	sd	s4,16(sp)
    800044de:	e456                	sd	s5,8(sp)
    800044e0:	e05a                	sd	s6,0(sp)
    800044e2:	0080                	addi	s0,sp,64
    800044e4:	8b2a                	mv	s6,a0
    800044e6:	0001da97          	auipc	s5,0x1d
    800044ea:	7baa8a93          	addi	s5,s5,1978 # 80021ca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ee:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044f0:	0001d997          	auipc	s3,0x1d
    800044f4:	78098993          	addi	s3,s3,1920 # 80021c70 <log>
    800044f8:	a00d                	j	8000451a <install_trans+0x56>
    brelse(lbuf);
    800044fa:	854a                	mv	a0,s2
    800044fc:	fffff097          	auipc	ra,0xfffff
    80004500:	088080e7          	jalr	136(ra) # 80003584 <brelse>
    brelse(dbuf);
    80004504:	8526                	mv	a0,s1
    80004506:	fffff097          	auipc	ra,0xfffff
    8000450a:	07e080e7          	jalr	126(ra) # 80003584 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000450e:	2a05                	addiw	s4,s4,1
    80004510:	0a91                	addi	s5,s5,4
    80004512:	02c9a783          	lw	a5,44(s3)
    80004516:	04fa5e63          	bge	s4,a5,80004572 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000451a:	0189a583          	lw	a1,24(s3)
    8000451e:	014585bb          	addw	a1,a1,s4
    80004522:	2585                	addiw	a1,a1,1
    80004524:	0289a503          	lw	a0,40(s3)
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	f2c080e7          	jalr	-212(ra) # 80003454 <bread>
    80004530:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004532:	000aa583          	lw	a1,0(s5)
    80004536:	0289a503          	lw	a0,40(s3)
    8000453a:	fffff097          	auipc	ra,0xfffff
    8000453e:	f1a080e7          	jalr	-230(ra) # 80003454 <bread>
    80004542:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004544:	40000613          	li	a2,1024
    80004548:	05890593          	addi	a1,s2,88
    8000454c:	05850513          	addi	a0,a0,88
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	7ca080e7          	jalr	1994(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004558:	8526                	mv	a0,s1
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	fec080e7          	jalr	-20(ra) # 80003546 <bwrite>
    if(recovering == 0)
    80004562:	f80b1ce3          	bnez	s6,800044fa <install_trans+0x36>
      bunpin(dbuf);
    80004566:	8526                	mv	a0,s1
    80004568:	fffff097          	auipc	ra,0xfffff
    8000456c:	0f6080e7          	jalr	246(ra) # 8000365e <bunpin>
    80004570:	b769                	j	800044fa <install_trans+0x36>
}
    80004572:	70e2                	ld	ra,56(sp)
    80004574:	7442                	ld	s0,48(sp)
    80004576:	74a2                	ld	s1,40(sp)
    80004578:	7902                	ld	s2,32(sp)
    8000457a:	69e2                	ld	s3,24(sp)
    8000457c:	6a42                	ld	s4,16(sp)
    8000457e:	6aa2                	ld	s5,8(sp)
    80004580:	6b02                	ld	s6,0(sp)
    80004582:	6121                	addi	sp,sp,64
    80004584:	8082                	ret
    80004586:	8082                	ret

0000000080004588 <initlog>:
{
    80004588:	7179                	addi	sp,sp,-48
    8000458a:	f406                	sd	ra,40(sp)
    8000458c:	f022                	sd	s0,32(sp)
    8000458e:	ec26                	sd	s1,24(sp)
    80004590:	e84a                	sd	s2,16(sp)
    80004592:	e44e                	sd	s3,8(sp)
    80004594:	1800                	addi	s0,sp,48
    80004596:	892a                	mv	s2,a0
    80004598:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000459a:	0001d497          	auipc	s1,0x1d
    8000459e:	6d648493          	addi	s1,s1,1750 # 80021c70 <log>
    800045a2:	00004597          	auipc	a1,0x4
    800045a6:	0ee58593          	addi	a1,a1,238 # 80008690 <syscalls+0x1f0>
    800045aa:	8526                	mv	a0,s1
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	586080e7          	jalr	1414(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    800045b4:	0149a583          	lw	a1,20(s3)
    800045b8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800045ba:	0109a783          	lw	a5,16(s3)
    800045be:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045c0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045c4:	854a                	mv	a0,s2
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	e8e080e7          	jalr	-370(ra) # 80003454 <bread>
  log.lh.n = lh->n;
    800045ce:	4d34                	lw	a3,88(a0)
    800045d0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045d2:	02d05663          	blez	a3,800045fe <initlog+0x76>
    800045d6:	05c50793          	addi	a5,a0,92
    800045da:	0001d717          	auipc	a4,0x1d
    800045de:	6c670713          	addi	a4,a4,1734 # 80021ca0 <log+0x30>
    800045e2:	36fd                	addiw	a3,a3,-1
    800045e4:	02069613          	slli	a2,a3,0x20
    800045e8:	01e65693          	srli	a3,a2,0x1e
    800045ec:	06050613          	addi	a2,a0,96
    800045f0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045f2:	4390                	lw	a2,0(a5)
    800045f4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045f6:	0791                	addi	a5,a5,4
    800045f8:	0711                	addi	a4,a4,4
    800045fa:	fed79ce3          	bne	a5,a3,800045f2 <initlog+0x6a>
  brelse(buf);
    800045fe:	fffff097          	auipc	ra,0xfffff
    80004602:	f86080e7          	jalr	-122(ra) # 80003584 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004606:	4505                	li	a0,1
    80004608:	00000097          	auipc	ra,0x0
    8000460c:	ebc080e7          	jalr	-324(ra) # 800044c4 <install_trans>
  log.lh.n = 0;
    80004610:	0001d797          	auipc	a5,0x1d
    80004614:	6807a623          	sw	zero,1676(a5) # 80021c9c <log+0x2c>
  write_head(); // clear the log
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	e30080e7          	jalr	-464(ra) # 80004448 <write_head>
}
    80004620:	70a2                	ld	ra,40(sp)
    80004622:	7402                	ld	s0,32(sp)
    80004624:	64e2                	ld	s1,24(sp)
    80004626:	6942                	ld	s2,16(sp)
    80004628:	69a2                	ld	s3,8(sp)
    8000462a:	6145                	addi	sp,sp,48
    8000462c:	8082                	ret

000000008000462e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000462e:	1101                	addi	sp,sp,-32
    80004630:	ec06                	sd	ra,24(sp)
    80004632:	e822                	sd	s0,16(sp)
    80004634:	e426                	sd	s1,8(sp)
    80004636:	e04a                	sd	s2,0(sp)
    80004638:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000463a:	0001d517          	auipc	a0,0x1d
    8000463e:	63650513          	addi	a0,a0,1590 # 80021c70 <log>
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	580080e7          	jalr	1408(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    8000464a:	0001d497          	auipc	s1,0x1d
    8000464e:	62648493          	addi	s1,s1,1574 # 80021c70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004652:	4979                	li	s2,30
    80004654:	a039                	j	80004662 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004656:	85a6                	mv	a1,s1
    80004658:	8526                	mv	a0,s1
    8000465a:	ffffe097          	auipc	ra,0xffffe
    8000465e:	c26080e7          	jalr	-986(ra) # 80002280 <sleep>
    if(log.committing){
    80004662:	50dc                	lw	a5,36(s1)
    80004664:	fbed                	bnez	a5,80004656 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004666:	509c                	lw	a5,32(s1)
    80004668:	0017871b          	addiw	a4,a5,1
    8000466c:	0007069b          	sext.w	a3,a4
    80004670:	0027179b          	slliw	a5,a4,0x2
    80004674:	9fb9                	addw	a5,a5,a4
    80004676:	0017979b          	slliw	a5,a5,0x1
    8000467a:	54d8                	lw	a4,44(s1)
    8000467c:	9fb9                	addw	a5,a5,a4
    8000467e:	00f95963          	bge	s2,a5,80004690 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004682:	85a6                	mv	a1,s1
    80004684:	8526                	mv	a0,s1
    80004686:	ffffe097          	auipc	ra,0xffffe
    8000468a:	bfa080e7          	jalr	-1030(ra) # 80002280 <sleep>
    8000468e:	bfd1                	j	80004662 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004690:	0001d517          	auipc	a0,0x1d
    80004694:	5e050513          	addi	a0,a0,1504 # 80021c70 <log>
    80004698:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	5dc080e7          	jalr	1500(ra) # 80000c76 <release>
      break;
    }
  }
}
    800046a2:	60e2                	ld	ra,24(sp)
    800046a4:	6442                	ld	s0,16(sp)
    800046a6:	64a2                	ld	s1,8(sp)
    800046a8:	6902                	ld	s2,0(sp)
    800046aa:	6105                	addi	sp,sp,32
    800046ac:	8082                	ret

00000000800046ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046ae:	7139                	addi	sp,sp,-64
    800046b0:	fc06                	sd	ra,56(sp)
    800046b2:	f822                	sd	s0,48(sp)
    800046b4:	f426                	sd	s1,40(sp)
    800046b6:	f04a                	sd	s2,32(sp)
    800046b8:	ec4e                	sd	s3,24(sp)
    800046ba:	e852                	sd	s4,16(sp)
    800046bc:	e456                	sd	s5,8(sp)
    800046be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046c0:	0001d497          	auipc	s1,0x1d
    800046c4:	5b048493          	addi	s1,s1,1456 # 80021c70 <log>
    800046c8:	8526                	mv	a0,s1
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	4f8080e7          	jalr	1272(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    800046d2:	509c                	lw	a5,32(s1)
    800046d4:	37fd                	addiw	a5,a5,-1
    800046d6:	0007891b          	sext.w	s2,a5
    800046da:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046dc:	50dc                	lw	a5,36(s1)
    800046de:	e7b9                	bnez	a5,8000472c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046e0:	04091e63          	bnez	s2,8000473c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046e4:	0001d497          	auipc	s1,0x1d
    800046e8:	58c48493          	addi	s1,s1,1420 # 80021c70 <log>
    800046ec:	4785                	li	a5,1
    800046ee:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046f0:	8526                	mv	a0,s1
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	584080e7          	jalr	1412(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046fa:	54dc                	lw	a5,44(s1)
    800046fc:	06f04763          	bgtz	a5,8000476a <end_op+0xbc>
    acquire(&log.lock);
    80004700:	0001d497          	auipc	s1,0x1d
    80004704:	57048493          	addi	s1,s1,1392 # 80021c70 <log>
    80004708:	8526                	mv	a0,s1
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	4b8080e7          	jalr	1208(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004712:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004716:	8526                	mv	a0,s1
    80004718:	ffffe097          	auipc	ra,0xffffe
    8000471c:	cf4080e7          	jalr	-780(ra) # 8000240c <wakeup>
    release(&log.lock);
    80004720:	8526                	mv	a0,s1
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	554080e7          	jalr	1364(ra) # 80000c76 <release>
}
    8000472a:	a03d                	j	80004758 <end_op+0xaa>
    panic("log.committing");
    8000472c:	00004517          	auipc	a0,0x4
    80004730:	f6c50513          	addi	a0,a0,-148 # 80008698 <syscalls+0x1f8>
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	df6080e7          	jalr	-522(ra) # 8000052a <panic>
    wakeup(&log);
    8000473c:	0001d497          	auipc	s1,0x1d
    80004740:	53448493          	addi	s1,s1,1332 # 80021c70 <log>
    80004744:	8526                	mv	a0,s1
    80004746:	ffffe097          	auipc	ra,0xffffe
    8000474a:	cc6080e7          	jalr	-826(ra) # 8000240c <wakeup>
  release(&log.lock);
    8000474e:	8526                	mv	a0,s1
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	526080e7          	jalr	1318(ra) # 80000c76 <release>
}
    80004758:	70e2                	ld	ra,56(sp)
    8000475a:	7442                	ld	s0,48(sp)
    8000475c:	74a2                	ld	s1,40(sp)
    8000475e:	7902                	ld	s2,32(sp)
    80004760:	69e2                	ld	s3,24(sp)
    80004762:	6a42                	ld	s4,16(sp)
    80004764:	6aa2                	ld	s5,8(sp)
    80004766:	6121                	addi	sp,sp,64
    80004768:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000476a:	0001da97          	auipc	s5,0x1d
    8000476e:	536a8a93          	addi	s5,s5,1334 # 80021ca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004772:	0001da17          	auipc	s4,0x1d
    80004776:	4fea0a13          	addi	s4,s4,1278 # 80021c70 <log>
    8000477a:	018a2583          	lw	a1,24(s4)
    8000477e:	012585bb          	addw	a1,a1,s2
    80004782:	2585                	addiw	a1,a1,1
    80004784:	028a2503          	lw	a0,40(s4)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	ccc080e7          	jalr	-820(ra) # 80003454 <bread>
    80004790:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004792:	000aa583          	lw	a1,0(s5)
    80004796:	028a2503          	lw	a0,40(s4)
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	cba080e7          	jalr	-838(ra) # 80003454 <bread>
    800047a2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047a4:	40000613          	li	a2,1024
    800047a8:	05850593          	addi	a1,a0,88
    800047ac:	05848513          	addi	a0,s1,88
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	56a080e7          	jalr	1386(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    800047b8:	8526                	mv	a0,s1
    800047ba:	fffff097          	auipc	ra,0xfffff
    800047be:	d8c080e7          	jalr	-628(ra) # 80003546 <bwrite>
    brelse(from);
    800047c2:	854e                	mv	a0,s3
    800047c4:	fffff097          	auipc	ra,0xfffff
    800047c8:	dc0080e7          	jalr	-576(ra) # 80003584 <brelse>
    brelse(to);
    800047cc:	8526                	mv	a0,s1
    800047ce:	fffff097          	auipc	ra,0xfffff
    800047d2:	db6080e7          	jalr	-586(ra) # 80003584 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047d6:	2905                	addiw	s2,s2,1
    800047d8:	0a91                	addi	s5,s5,4
    800047da:	02ca2783          	lw	a5,44(s4)
    800047de:	f8f94ee3          	blt	s2,a5,8000477a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047e2:	00000097          	auipc	ra,0x0
    800047e6:	c66080e7          	jalr	-922(ra) # 80004448 <write_head>
    install_trans(0); // Now install writes to home locations
    800047ea:	4501                	li	a0,0
    800047ec:	00000097          	auipc	ra,0x0
    800047f0:	cd8080e7          	jalr	-808(ra) # 800044c4 <install_trans>
    log.lh.n = 0;
    800047f4:	0001d797          	auipc	a5,0x1d
    800047f8:	4a07a423          	sw	zero,1192(a5) # 80021c9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047fc:	00000097          	auipc	ra,0x0
    80004800:	c4c080e7          	jalr	-948(ra) # 80004448 <write_head>
    80004804:	bdf5                	j	80004700 <end_op+0x52>

0000000080004806 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004806:	1101                	addi	sp,sp,-32
    80004808:	ec06                	sd	ra,24(sp)
    8000480a:	e822                	sd	s0,16(sp)
    8000480c:	e426                	sd	s1,8(sp)
    8000480e:	e04a                	sd	s2,0(sp)
    80004810:	1000                	addi	s0,sp,32
    80004812:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004814:	0001d917          	auipc	s2,0x1d
    80004818:	45c90913          	addi	s2,s2,1116 # 80021c70 <log>
    8000481c:	854a                	mv	a0,s2
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	3a4080e7          	jalr	932(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004826:	02c92603          	lw	a2,44(s2)
    8000482a:	47f5                	li	a5,29
    8000482c:	06c7c563          	blt	a5,a2,80004896 <log_write+0x90>
    80004830:	0001d797          	auipc	a5,0x1d
    80004834:	45c7a783          	lw	a5,1116(a5) # 80021c8c <log+0x1c>
    80004838:	37fd                	addiw	a5,a5,-1
    8000483a:	04f65e63          	bge	a2,a5,80004896 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000483e:	0001d797          	auipc	a5,0x1d
    80004842:	4527a783          	lw	a5,1106(a5) # 80021c90 <log+0x20>
    80004846:	06f05063          	blez	a5,800048a6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000484a:	4781                	li	a5,0
    8000484c:	06c05563          	blez	a2,800048b6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004850:	44cc                	lw	a1,12(s1)
    80004852:	0001d717          	auipc	a4,0x1d
    80004856:	44e70713          	addi	a4,a4,1102 # 80021ca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000485a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000485c:	4314                	lw	a3,0(a4)
    8000485e:	04b68c63          	beq	a3,a1,800048b6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004862:	2785                	addiw	a5,a5,1
    80004864:	0711                	addi	a4,a4,4
    80004866:	fef61be3          	bne	a2,a5,8000485c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000486a:	0621                	addi	a2,a2,8
    8000486c:	060a                	slli	a2,a2,0x2
    8000486e:	0001d797          	auipc	a5,0x1d
    80004872:	40278793          	addi	a5,a5,1026 # 80021c70 <log>
    80004876:	963e                	add	a2,a2,a5
    80004878:	44dc                	lw	a5,12(s1)
    8000487a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000487c:	8526                	mv	a0,s1
    8000487e:	fffff097          	auipc	ra,0xfffff
    80004882:	da4080e7          	jalr	-604(ra) # 80003622 <bpin>
    log.lh.n++;
    80004886:	0001d717          	auipc	a4,0x1d
    8000488a:	3ea70713          	addi	a4,a4,1002 # 80021c70 <log>
    8000488e:	575c                	lw	a5,44(a4)
    80004890:	2785                	addiw	a5,a5,1
    80004892:	d75c                	sw	a5,44(a4)
    80004894:	a835                	j	800048d0 <log_write+0xca>
    panic("too big a transaction");
    80004896:	00004517          	auipc	a0,0x4
    8000489a:	e1250513          	addi	a0,a0,-494 # 800086a8 <syscalls+0x208>
    8000489e:	ffffc097          	auipc	ra,0xffffc
    800048a2:	c8c080e7          	jalr	-884(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    800048a6:	00004517          	auipc	a0,0x4
    800048aa:	e1a50513          	addi	a0,a0,-486 # 800086c0 <syscalls+0x220>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	c7c080e7          	jalr	-900(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    800048b6:	00878713          	addi	a4,a5,8
    800048ba:	00271693          	slli	a3,a4,0x2
    800048be:	0001d717          	auipc	a4,0x1d
    800048c2:	3b270713          	addi	a4,a4,946 # 80021c70 <log>
    800048c6:	9736                	add	a4,a4,a3
    800048c8:	44d4                	lw	a3,12(s1)
    800048ca:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048cc:	faf608e3          	beq	a2,a5,8000487c <log_write+0x76>
  }
  release(&log.lock);
    800048d0:	0001d517          	auipc	a0,0x1d
    800048d4:	3a050513          	addi	a0,a0,928 # 80021c70 <log>
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	39e080e7          	jalr	926(ra) # 80000c76 <release>
}
    800048e0:	60e2                	ld	ra,24(sp)
    800048e2:	6442                	ld	s0,16(sp)
    800048e4:	64a2                	ld	s1,8(sp)
    800048e6:	6902                	ld	s2,0(sp)
    800048e8:	6105                	addi	sp,sp,32
    800048ea:	8082                	ret

00000000800048ec <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048ec:	1101                	addi	sp,sp,-32
    800048ee:	ec06                	sd	ra,24(sp)
    800048f0:	e822                	sd	s0,16(sp)
    800048f2:	e426                	sd	s1,8(sp)
    800048f4:	e04a                	sd	s2,0(sp)
    800048f6:	1000                	addi	s0,sp,32
    800048f8:	84aa                	mv	s1,a0
    800048fa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048fc:	00004597          	auipc	a1,0x4
    80004900:	de458593          	addi	a1,a1,-540 # 800086e0 <syscalls+0x240>
    80004904:	0521                	addi	a0,a0,8
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	22c080e7          	jalr	556(ra) # 80000b32 <initlock>
  lk->name = name;
    8000490e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004912:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004916:	0204a423          	sw	zero,40(s1)
}
    8000491a:	60e2                	ld	ra,24(sp)
    8000491c:	6442                	ld	s0,16(sp)
    8000491e:	64a2                	ld	s1,8(sp)
    80004920:	6902                	ld	s2,0(sp)
    80004922:	6105                	addi	sp,sp,32
    80004924:	8082                	ret

0000000080004926 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004926:	1101                	addi	sp,sp,-32
    80004928:	ec06                	sd	ra,24(sp)
    8000492a:	e822                	sd	s0,16(sp)
    8000492c:	e426                	sd	s1,8(sp)
    8000492e:	e04a                	sd	s2,0(sp)
    80004930:	1000                	addi	s0,sp,32
    80004932:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004934:	00850913          	addi	s2,a0,8
    80004938:	854a                	mv	a0,s2
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	288080e7          	jalr	648(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004942:	409c                	lw	a5,0(s1)
    80004944:	cb89                	beqz	a5,80004956 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004946:	85ca                	mv	a1,s2
    80004948:	8526                	mv	a0,s1
    8000494a:	ffffe097          	auipc	ra,0xffffe
    8000494e:	936080e7          	jalr	-1738(ra) # 80002280 <sleep>
  while (lk->locked) {
    80004952:	409c                	lw	a5,0(s1)
    80004954:	fbed                	bnez	a5,80004946 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004956:	4785                	li	a5,1
    80004958:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000495a:	ffffd097          	auipc	ra,0xffffd
    8000495e:	024080e7          	jalr	36(ra) # 8000197e <myproc>
    80004962:	591c                	lw	a5,48(a0)
    80004964:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004966:	854a                	mv	a0,s2
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	30e080e7          	jalr	782(ra) # 80000c76 <release>
}
    80004970:	60e2                	ld	ra,24(sp)
    80004972:	6442                	ld	s0,16(sp)
    80004974:	64a2                	ld	s1,8(sp)
    80004976:	6902                	ld	s2,0(sp)
    80004978:	6105                	addi	sp,sp,32
    8000497a:	8082                	ret

000000008000497c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000497c:	1101                	addi	sp,sp,-32
    8000497e:	ec06                	sd	ra,24(sp)
    80004980:	e822                	sd	s0,16(sp)
    80004982:	e426                	sd	s1,8(sp)
    80004984:	e04a                	sd	s2,0(sp)
    80004986:	1000                	addi	s0,sp,32
    80004988:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000498a:	00850913          	addi	s2,a0,8
    8000498e:	854a                	mv	a0,s2
    80004990:	ffffc097          	auipc	ra,0xffffc
    80004994:	232080e7          	jalr	562(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004998:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000499c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049a0:	8526                	mv	a0,s1
    800049a2:	ffffe097          	auipc	ra,0xffffe
    800049a6:	a6a080e7          	jalr	-1430(ra) # 8000240c <wakeup>
  release(&lk->lk);
    800049aa:	854a                	mv	a0,s2
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	2ca080e7          	jalr	714(ra) # 80000c76 <release>
}
    800049b4:	60e2                	ld	ra,24(sp)
    800049b6:	6442                	ld	s0,16(sp)
    800049b8:	64a2                	ld	s1,8(sp)
    800049ba:	6902                	ld	s2,0(sp)
    800049bc:	6105                	addi	sp,sp,32
    800049be:	8082                	ret

00000000800049c0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049c0:	7179                	addi	sp,sp,-48
    800049c2:	f406                	sd	ra,40(sp)
    800049c4:	f022                	sd	s0,32(sp)
    800049c6:	ec26                	sd	s1,24(sp)
    800049c8:	e84a                	sd	s2,16(sp)
    800049ca:	e44e                	sd	s3,8(sp)
    800049cc:	1800                	addi	s0,sp,48
    800049ce:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049d0:	00850913          	addi	s2,a0,8
    800049d4:	854a                	mv	a0,s2
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	1ec080e7          	jalr	492(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049de:	409c                	lw	a5,0(s1)
    800049e0:	ef99                	bnez	a5,800049fe <holdingsleep+0x3e>
    800049e2:	4481                	li	s1,0
  release(&lk->lk);
    800049e4:	854a                	mv	a0,s2
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	290080e7          	jalr	656(ra) # 80000c76 <release>
  return r;
}
    800049ee:	8526                	mv	a0,s1
    800049f0:	70a2                	ld	ra,40(sp)
    800049f2:	7402                	ld	s0,32(sp)
    800049f4:	64e2                	ld	s1,24(sp)
    800049f6:	6942                	ld	s2,16(sp)
    800049f8:	69a2                	ld	s3,8(sp)
    800049fa:	6145                	addi	sp,sp,48
    800049fc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049fe:	0284a983          	lw	s3,40(s1)
    80004a02:	ffffd097          	auipc	ra,0xffffd
    80004a06:	f7c080e7          	jalr	-132(ra) # 8000197e <myproc>
    80004a0a:	5904                	lw	s1,48(a0)
    80004a0c:	413484b3          	sub	s1,s1,s3
    80004a10:	0014b493          	seqz	s1,s1
    80004a14:	bfc1                	j	800049e4 <holdingsleep+0x24>

0000000080004a16 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a16:	1141                	addi	sp,sp,-16
    80004a18:	e406                	sd	ra,8(sp)
    80004a1a:	e022                	sd	s0,0(sp)
    80004a1c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a1e:	00004597          	auipc	a1,0x4
    80004a22:	cd258593          	addi	a1,a1,-814 # 800086f0 <syscalls+0x250>
    80004a26:	0001d517          	auipc	a0,0x1d
    80004a2a:	39250513          	addi	a0,a0,914 # 80021db8 <ftable>
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	104080e7          	jalr	260(ra) # 80000b32 <initlock>
}
    80004a36:	60a2                	ld	ra,8(sp)
    80004a38:	6402                	ld	s0,0(sp)
    80004a3a:	0141                	addi	sp,sp,16
    80004a3c:	8082                	ret

0000000080004a3e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a3e:	1101                	addi	sp,sp,-32
    80004a40:	ec06                	sd	ra,24(sp)
    80004a42:	e822                	sd	s0,16(sp)
    80004a44:	e426                	sd	s1,8(sp)
    80004a46:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a48:	0001d517          	auipc	a0,0x1d
    80004a4c:	37050513          	addi	a0,a0,880 # 80021db8 <ftable>
    80004a50:	ffffc097          	auipc	ra,0xffffc
    80004a54:	172080e7          	jalr	370(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a58:	0001d497          	auipc	s1,0x1d
    80004a5c:	37848493          	addi	s1,s1,888 # 80021dd0 <ftable+0x18>
    80004a60:	0001e717          	auipc	a4,0x1e
    80004a64:	31070713          	addi	a4,a4,784 # 80022d70 <ftable+0xfb8>
    if(f->ref == 0){
    80004a68:	40dc                	lw	a5,4(s1)
    80004a6a:	cf99                	beqz	a5,80004a88 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a6c:	02848493          	addi	s1,s1,40
    80004a70:	fee49ce3          	bne	s1,a4,80004a68 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a74:	0001d517          	auipc	a0,0x1d
    80004a78:	34450513          	addi	a0,a0,836 # 80021db8 <ftable>
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	1fa080e7          	jalr	506(ra) # 80000c76 <release>
  return 0;
    80004a84:	4481                	li	s1,0
    80004a86:	a819                	j	80004a9c <filealloc+0x5e>
      f->ref = 1;
    80004a88:	4785                	li	a5,1
    80004a8a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a8c:	0001d517          	auipc	a0,0x1d
    80004a90:	32c50513          	addi	a0,a0,812 # 80021db8 <ftable>
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	1e2080e7          	jalr	482(ra) # 80000c76 <release>
}
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	60e2                	ld	ra,24(sp)
    80004aa0:	6442                	ld	s0,16(sp)
    80004aa2:	64a2                	ld	s1,8(sp)
    80004aa4:	6105                	addi	sp,sp,32
    80004aa6:	8082                	ret

0000000080004aa8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004aa8:	1101                	addi	sp,sp,-32
    80004aaa:	ec06                	sd	ra,24(sp)
    80004aac:	e822                	sd	s0,16(sp)
    80004aae:	e426                	sd	s1,8(sp)
    80004ab0:	1000                	addi	s0,sp,32
    80004ab2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ab4:	0001d517          	auipc	a0,0x1d
    80004ab8:	30450513          	addi	a0,a0,772 # 80021db8 <ftable>
    80004abc:	ffffc097          	auipc	ra,0xffffc
    80004ac0:	106080e7          	jalr	262(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004ac4:	40dc                	lw	a5,4(s1)
    80004ac6:	02f05263          	blez	a5,80004aea <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004aca:	2785                	addiw	a5,a5,1
    80004acc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ace:	0001d517          	auipc	a0,0x1d
    80004ad2:	2ea50513          	addi	a0,a0,746 # 80021db8 <ftable>
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	1a0080e7          	jalr	416(ra) # 80000c76 <release>
  return f;
}
    80004ade:	8526                	mv	a0,s1
    80004ae0:	60e2                	ld	ra,24(sp)
    80004ae2:	6442                	ld	s0,16(sp)
    80004ae4:	64a2                	ld	s1,8(sp)
    80004ae6:	6105                	addi	sp,sp,32
    80004ae8:	8082                	ret
    panic("filedup");
    80004aea:	00004517          	auipc	a0,0x4
    80004aee:	c0e50513          	addi	a0,a0,-1010 # 800086f8 <syscalls+0x258>
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	a38080e7          	jalr	-1480(ra) # 8000052a <panic>

0000000080004afa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004afa:	7139                	addi	sp,sp,-64
    80004afc:	fc06                	sd	ra,56(sp)
    80004afe:	f822                	sd	s0,48(sp)
    80004b00:	f426                	sd	s1,40(sp)
    80004b02:	f04a                	sd	s2,32(sp)
    80004b04:	ec4e                	sd	s3,24(sp)
    80004b06:	e852                	sd	s4,16(sp)
    80004b08:	e456                	sd	s5,8(sp)
    80004b0a:	0080                	addi	s0,sp,64
    80004b0c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b0e:	0001d517          	auipc	a0,0x1d
    80004b12:	2aa50513          	addi	a0,a0,682 # 80021db8 <ftable>
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	0ac080e7          	jalr	172(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b1e:	40dc                	lw	a5,4(s1)
    80004b20:	06f05163          	blez	a5,80004b82 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b24:	37fd                	addiw	a5,a5,-1
    80004b26:	0007871b          	sext.w	a4,a5
    80004b2a:	c0dc                	sw	a5,4(s1)
    80004b2c:	06e04363          	bgtz	a4,80004b92 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b30:	0004a903          	lw	s2,0(s1)
    80004b34:	0094ca83          	lbu	s5,9(s1)
    80004b38:	0104ba03          	ld	s4,16(s1)
    80004b3c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b40:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b44:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b48:	0001d517          	auipc	a0,0x1d
    80004b4c:	27050513          	addi	a0,a0,624 # 80021db8 <ftable>
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	126080e7          	jalr	294(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004b58:	4785                	li	a5,1
    80004b5a:	04f90d63          	beq	s2,a5,80004bb4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b5e:	3979                	addiw	s2,s2,-2
    80004b60:	4785                	li	a5,1
    80004b62:	0527e063          	bltu	a5,s2,80004ba2 <fileclose+0xa8>
    begin_op();
    80004b66:	00000097          	auipc	ra,0x0
    80004b6a:	ac8080e7          	jalr	-1336(ra) # 8000462e <begin_op>
    iput(ff.ip);
    80004b6e:	854e                	mv	a0,s3
    80004b70:	fffff097          	auipc	ra,0xfffff
    80004b74:	2a2080e7          	jalr	674(ra) # 80003e12 <iput>
    end_op();
    80004b78:	00000097          	auipc	ra,0x0
    80004b7c:	b36080e7          	jalr	-1226(ra) # 800046ae <end_op>
    80004b80:	a00d                	j	80004ba2 <fileclose+0xa8>
    panic("fileclose");
    80004b82:	00004517          	auipc	a0,0x4
    80004b86:	b7e50513          	addi	a0,a0,-1154 # 80008700 <syscalls+0x260>
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	9a0080e7          	jalr	-1632(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004b92:	0001d517          	auipc	a0,0x1d
    80004b96:	22650513          	addi	a0,a0,550 # 80021db8 <ftable>
    80004b9a:	ffffc097          	auipc	ra,0xffffc
    80004b9e:	0dc080e7          	jalr	220(ra) # 80000c76 <release>
  }
}
    80004ba2:	70e2                	ld	ra,56(sp)
    80004ba4:	7442                	ld	s0,48(sp)
    80004ba6:	74a2                	ld	s1,40(sp)
    80004ba8:	7902                	ld	s2,32(sp)
    80004baa:	69e2                	ld	s3,24(sp)
    80004bac:	6a42                	ld	s4,16(sp)
    80004bae:	6aa2                	ld	s5,8(sp)
    80004bb0:	6121                	addi	sp,sp,64
    80004bb2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bb4:	85d6                	mv	a1,s5
    80004bb6:	8552                	mv	a0,s4
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	34c080e7          	jalr	844(ra) # 80004f04 <pipeclose>
    80004bc0:	b7cd                	j	80004ba2 <fileclose+0xa8>

0000000080004bc2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bc2:	715d                	addi	sp,sp,-80
    80004bc4:	e486                	sd	ra,72(sp)
    80004bc6:	e0a2                	sd	s0,64(sp)
    80004bc8:	fc26                	sd	s1,56(sp)
    80004bca:	f84a                	sd	s2,48(sp)
    80004bcc:	f44e                	sd	s3,40(sp)
    80004bce:	0880                	addi	s0,sp,80
    80004bd0:	84aa                	mv	s1,a0
    80004bd2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bd4:	ffffd097          	auipc	ra,0xffffd
    80004bd8:	daa080e7          	jalr	-598(ra) # 8000197e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bdc:	409c                	lw	a5,0(s1)
    80004bde:	37f9                	addiw	a5,a5,-2
    80004be0:	4705                	li	a4,1
    80004be2:	04f76763          	bltu	a4,a5,80004c30 <filestat+0x6e>
    80004be6:	892a                	mv	s2,a0
    ilock(f->ip);
    80004be8:	6c88                	ld	a0,24(s1)
    80004bea:	fffff097          	auipc	ra,0xfffff
    80004bee:	06e080e7          	jalr	110(ra) # 80003c58 <ilock>
    stati(f->ip, &st);
    80004bf2:	fb840593          	addi	a1,s0,-72
    80004bf6:	6c88                	ld	a0,24(s1)
    80004bf8:	fffff097          	auipc	ra,0xfffff
    80004bfc:	2ea080e7          	jalr	746(ra) # 80003ee2 <stati>
    iunlock(f->ip);
    80004c00:	6c88                	ld	a0,24(s1)
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	118080e7          	jalr	280(ra) # 80003d1a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c0a:	46e1                	li	a3,24
    80004c0c:	fb840613          	addi	a2,s0,-72
    80004c10:	85ce                	mv	a1,s3
    80004c12:	05093503          	ld	a0,80(s2)
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	a28080e7          	jalr	-1496(ra) # 8000163e <copyout>
    80004c1e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c22:	60a6                	ld	ra,72(sp)
    80004c24:	6406                	ld	s0,64(sp)
    80004c26:	74e2                	ld	s1,56(sp)
    80004c28:	7942                	ld	s2,48(sp)
    80004c2a:	79a2                	ld	s3,40(sp)
    80004c2c:	6161                	addi	sp,sp,80
    80004c2e:	8082                	ret
  return -1;
    80004c30:	557d                	li	a0,-1
    80004c32:	bfc5                	j	80004c22 <filestat+0x60>

0000000080004c34 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c34:	7179                	addi	sp,sp,-48
    80004c36:	f406                	sd	ra,40(sp)
    80004c38:	f022                	sd	s0,32(sp)
    80004c3a:	ec26                	sd	s1,24(sp)
    80004c3c:	e84a                	sd	s2,16(sp)
    80004c3e:	e44e                	sd	s3,8(sp)
    80004c40:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c42:	00854783          	lbu	a5,8(a0)
    80004c46:	c3d5                	beqz	a5,80004cea <fileread+0xb6>
    80004c48:	84aa                	mv	s1,a0
    80004c4a:	89ae                	mv	s3,a1
    80004c4c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c4e:	411c                	lw	a5,0(a0)
    80004c50:	4705                	li	a4,1
    80004c52:	04e78963          	beq	a5,a4,80004ca4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c56:	470d                	li	a4,3
    80004c58:	04e78d63          	beq	a5,a4,80004cb2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c5c:	4709                	li	a4,2
    80004c5e:	06e79e63          	bne	a5,a4,80004cda <fileread+0xa6>
    ilock(f->ip);
    80004c62:	6d08                	ld	a0,24(a0)
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	ff4080e7          	jalr	-12(ra) # 80003c58 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c6c:	874a                	mv	a4,s2
    80004c6e:	5094                	lw	a3,32(s1)
    80004c70:	864e                	mv	a2,s3
    80004c72:	4585                	li	a1,1
    80004c74:	6c88                	ld	a0,24(s1)
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	296080e7          	jalr	662(ra) # 80003f0c <readi>
    80004c7e:	892a                	mv	s2,a0
    80004c80:	00a05563          	blez	a0,80004c8a <fileread+0x56>
      f->off += r;
    80004c84:	509c                	lw	a5,32(s1)
    80004c86:	9fa9                	addw	a5,a5,a0
    80004c88:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c8a:	6c88                	ld	a0,24(s1)
    80004c8c:	fffff097          	auipc	ra,0xfffff
    80004c90:	08e080e7          	jalr	142(ra) # 80003d1a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c94:	854a                	mv	a0,s2
    80004c96:	70a2                	ld	ra,40(sp)
    80004c98:	7402                	ld	s0,32(sp)
    80004c9a:	64e2                	ld	s1,24(sp)
    80004c9c:	6942                	ld	s2,16(sp)
    80004c9e:	69a2                	ld	s3,8(sp)
    80004ca0:	6145                	addi	sp,sp,48
    80004ca2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ca4:	6908                	ld	a0,16(a0)
    80004ca6:	00000097          	auipc	ra,0x0
    80004caa:	3c0080e7          	jalr	960(ra) # 80005066 <piperead>
    80004cae:	892a                	mv	s2,a0
    80004cb0:	b7d5                	j	80004c94 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004cb2:	02451783          	lh	a5,36(a0)
    80004cb6:	03079693          	slli	a3,a5,0x30
    80004cba:	92c1                	srli	a3,a3,0x30
    80004cbc:	4725                	li	a4,9
    80004cbe:	02d76863          	bltu	a4,a3,80004cee <fileread+0xba>
    80004cc2:	0792                	slli	a5,a5,0x4
    80004cc4:	0001d717          	auipc	a4,0x1d
    80004cc8:	05470713          	addi	a4,a4,84 # 80021d18 <devsw>
    80004ccc:	97ba                	add	a5,a5,a4
    80004cce:	639c                	ld	a5,0(a5)
    80004cd0:	c38d                	beqz	a5,80004cf2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004cd2:	4505                	li	a0,1
    80004cd4:	9782                	jalr	a5
    80004cd6:	892a                	mv	s2,a0
    80004cd8:	bf75                	j	80004c94 <fileread+0x60>
    panic("fileread");
    80004cda:	00004517          	auipc	a0,0x4
    80004cde:	a3650513          	addi	a0,a0,-1482 # 80008710 <syscalls+0x270>
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	848080e7          	jalr	-1976(ra) # 8000052a <panic>
    return -1;
    80004cea:	597d                	li	s2,-1
    80004cec:	b765                	j	80004c94 <fileread+0x60>
      return -1;
    80004cee:	597d                	li	s2,-1
    80004cf0:	b755                	j	80004c94 <fileread+0x60>
    80004cf2:	597d                	li	s2,-1
    80004cf4:	b745                	j	80004c94 <fileread+0x60>

0000000080004cf6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004cf6:	715d                	addi	sp,sp,-80
    80004cf8:	e486                	sd	ra,72(sp)
    80004cfa:	e0a2                	sd	s0,64(sp)
    80004cfc:	fc26                	sd	s1,56(sp)
    80004cfe:	f84a                	sd	s2,48(sp)
    80004d00:	f44e                	sd	s3,40(sp)
    80004d02:	f052                	sd	s4,32(sp)
    80004d04:	ec56                	sd	s5,24(sp)
    80004d06:	e85a                	sd	s6,16(sp)
    80004d08:	e45e                	sd	s7,8(sp)
    80004d0a:	e062                	sd	s8,0(sp)
    80004d0c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d0e:	00954783          	lbu	a5,9(a0)
    80004d12:	10078663          	beqz	a5,80004e1e <filewrite+0x128>
    80004d16:	892a                	mv	s2,a0
    80004d18:	8aae                	mv	s5,a1
    80004d1a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d1c:	411c                	lw	a5,0(a0)
    80004d1e:	4705                	li	a4,1
    80004d20:	02e78263          	beq	a5,a4,80004d44 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d24:	470d                	li	a4,3
    80004d26:	02e78663          	beq	a5,a4,80004d52 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d2a:	4709                	li	a4,2
    80004d2c:	0ee79163          	bne	a5,a4,80004e0e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d30:	0ac05d63          	blez	a2,80004dea <filewrite+0xf4>
    int i = 0;
    80004d34:	4981                	li	s3,0
    80004d36:	6b05                	lui	s6,0x1
    80004d38:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d3c:	6b85                	lui	s7,0x1
    80004d3e:	c00b8b9b          	addiw	s7,s7,-1024
    80004d42:	a861                	j	80004dda <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d44:	6908                	ld	a0,16(a0)
    80004d46:	00000097          	auipc	ra,0x0
    80004d4a:	22e080e7          	jalr	558(ra) # 80004f74 <pipewrite>
    80004d4e:	8a2a                	mv	s4,a0
    80004d50:	a045                	j	80004df0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d52:	02451783          	lh	a5,36(a0)
    80004d56:	03079693          	slli	a3,a5,0x30
    80004d5a:	92c1                	srli	a3,a3,0x30
    80004d5c:	4725                	li	a4,9
    80004d5e:	0cd76263          	bltu	a4,a3,80004e22 <filewrite+0x12c>
    80004d62:	0792                	slli	a5,a5,0x4
    80004d64:	0001d717          	auipc	a4,0x1d
    80004d68:	fb470713          	addi	a4,a4,-76 # 80021d18 <devsw>
    80004d6c:	97ba                	add	a5,a5,a4
    80004d6e:	679c                	ld	a5,8(a5)
    80004d70:	cbdd                	beqz	a5,80004e26 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d72:	4505                	li	a0,1
    80004d74:	9782                	jalr	a5
    80004d76:	8a2a                	mv	s4,a0
    80004d78:	a8a5                	j	80004df0 <filewrite+0xfa>
    80004d7a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d7e:	00000097          	auipc	ra,0x0
    80004d82:	8b0080e7          	jalr	-1872(ra) # 8000462e <begin_op>
      ilock(f->ip);
    80004d86:	01893503          	ld	a0,24(s2)
    80004d8a:	fffff097          	auipc	ra,0xfffff
    80004d8e:	ece080e7          	jalr	-306(ra) # 80003c58 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d92:	8762                	mv	a4,s8
    80004d94:	02092683          	lw	a3,32(s2)
    80004d98:	01598633          	add	a2,s3,s5
    80004d9c:	4585                	li	a1,1
    80004d9e:	01893503          	ld	a0,24(s2)
    80004da2:	fffff097          	auipc	ra,0xfffff
    80004da6:	262080e7          	jalr	610(ra) # 80004004 <writei>
    80004daa:	84aa                	mv	s1,a0
    80004dac:	00a05763          	blez	a0,80004dba <filewrite+0xc4>
        f->off += r;
    80004db0:	02092783          	lw	a5,32(s2)
    80004db4:	9fa9                	addw	a5,a5,a0
    80004db6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004dba:	01893503          	ld	a0,24(s2)
    80004dbe:	fffff097          	auipc	ra,0xfffff
    80004dc2:	f5c080e7          	jalr	-164(ra) # 80003d1a <iunlock>
      end_op();
    80004dc6:	00000097          	auipc	ra,0x0
    80004dca:	8e8080e7          	jalr	-1816(ra) # 800046ae <end_op>

      if(r != n1){
    80004dce:	009c1f63          	bne	s8,s1,80004dec <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004dd2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004dd6:	0149db63          	bge	s3,s4,80004dec <filewrite+0xf6>
      int n1 = n - i;
    80004dda:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004dde:	84be                	mv	s1,a5
    80004de0:	2781                	sext.w	a5,a5
    80004de2:	f8fb5ce3          	bge	s6,a5,80004d7a <filewrite+0x84>
    80004de6:	84de                	mv	s1,s7
    80004de8:	bf49                	j	80004d7a <filewrite+0x84>
    int i = 0;
    80004dea:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004dec:	013a1f63          	bne	s4,s3,80004e0a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004df0:	8552                	mv	a0,s4
    80004df2:	60a6                	ld	ra,72(sp)
    80004df4:	6406                	ld	s0,64(sp)
    80004df6:	74e2                	ld	s1,56(sp)
    80004df8:	7942                	ld	s2,48(sp)
    80004dfa:	79a2                	ld	s3,40(sp)
    80004dfc:	7a02                	ld	s4,32(sp)
    80004dfe:	6ae2                	ld	s5,24(sp)
    80004e00:	6b42                	ld	s6,16(sp)
    80004e02:	6ba2                	ld	s7,8(sp)
    80004e04:	6c02                	ld	s8,0(sp)
    80004e06:	6161                	addi	sp,sp,80
    80004e08:	8082                	ret
    ret = (i == n ? n : -1);
    80004e0a:	5a7d                	li	s4,-1
    80004e0c:	b7d5                	j	80004df0 <filewrite+0xfa>
    panic("filewrite");
    80004e0e:	00004517          	auipc	a0,0x4
    80004e12:	91250513          	addi	a0,a0,-1774 # 80008720 <syscalls+0x280>
    80004e16:	ffffb097          	auipc	ra,0xffffb
    80004e1a:	714080e7          	jalr	1812(ra) # 8000052a <panic>
    return -1;
    80004e1e:	5a7d                	li	s4,-1
    80004e20:	bfc1                	j	80004df0 <filewrite+0xfa>
      return -1;
    80004e22:	5a7d                	li	s4,-1
    80004e24:	b7f1                	j	80004df0 <filewrite+0xfa>
    80004e26:	5a7d                	li	s4,-1
    80004e28:	b7e1                	j	80004df0 <filewrite+0xfa>

0000000080004e2a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e2a:	7179                	addi	sp,sp,-48
    80004e2c:	f406                	sd	ra,40(sp)
    80004e2e:	f022                	sd	s0,32(sp)
    80004e30:	ec26                	sd	s1,24(sp)
    80004e32:	e84a                	sd	s2,16(sp)
    80004e34:	e44e                	sd	s3,8(sp)
    80004e36:	e052                	sd	s4,0(sp)
    80004e38:	1800                	addi	s0,sp,48
    80004e3a:	84aa                	mv	s1,a0
    80004e3c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e3e:	0005b023          	sd	zero,0(a1)
    80004e42:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	bf8080e7          	jalr	-1032(ra) # 80004a3e <filealloc>
    80004e4e:	e088                	sd	a0,0(s1)
    80004e50:	c551                	beqz	a0,80004edc <pipealloc+0xb2>
    80004e52:	00000097          	auipc	ra,0x0
    80004e56:	bec080e7          	jalr	-1044(ra) # 80004a3e <filealloc>
    80004e5a:	00aa3023          	sd	a0,0(s4)
    80004e5e:	c92d                	beqz	a0,80004ed0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e60:	ffffc097          	auipc	ra,0xffffc
    80004e64:	c72080e7          	jalr	-910(ra) # 80000ad2 <kalloc>
    80004e68:	892a                	mv	s2,a0
    80004e6a:	c125                	beqz	a0,80004eca <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e6c:	4985                	li	s3,1
    80004e6e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e72:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e76:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e7a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e7e:	00004597          	auipc	a1,0x4
    80004e82:	8b258593          	addi	a1,a1,-1870 # 80008730 <syscalls+0x290>
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	cac080e7          	jalr	-852(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004e8e:	609c                	ld	a5,0(s1)
    80004e90:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e94:	609c                	ld	a5,0(s1)
    80004e96:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e9a:	609c                	ld	a5,0(s1)
    80004e9c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ea0:	609c                	ld	a5,0(s1)
    80004ea2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ea6:	000a3783          	ld	a5,0(s4)
    80004eaa:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004eae:	000a3783          	ld	a5,0(s4)
    80004eb2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004eb6:	000a3783          	ld	a5,0(s4)
    80004eba:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ebe:	000a3783          	ld	a5,0(s4)
    80004ec2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ec6:	4501                	li	a0,0
    80004ec8:	a025                	j	80004ef0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004eca:	6088                	ld	a0,0(s1)
    80004ecc:	e501                	bnez	a0,80004ed4 <pipealloc+0xaa>
    80004ece:	a039                	j	80004edc <pipealloc+0xb2>
    80004ed0:	6088                	ld	a0,0(s1)
    80004ed2:	c51d                	beqz	a0,80004f00 <pipealloc+0xd6>
    fileclose(*f0);
    80004ed4:	00000097          	auipc	ra,0x0
    80004ed8:	c26080e7          	jalr	-986(ra) # 80004afa <fileclose>
  if(*f1)
    80004edc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ee0:	557d                	li	a0,-1
  if(*f1)
    80004ee2:	c799                	beqz	a5,80004ef0 <pipealloc+0xc6>
    fileclose(*f1);
    80004ee4:	853e                	mv	a0,a5
    80004ee6:	00000097          	auipc	ra,0x0
    80004eea:	c14080e7          	jalr	-1004(ra) # 80004afa <fileclose>
  return -1;
    80004eee:	557d                	li	a0,-1
}
    80004ef0:	70a2                	ld	ra,40(sp)
    80004ef2:	7402                	ld	s0,32(sp)
    80004ef4:	64e2                	ld	s1,24(sp)
    80004ef6:	6942                	ld	s2,16(sp)
    80004ef8:	69a2                	ld	s3,8(sp)
    80004efa:	6a02                	ld	s4,0(sp)
    80004efc:	6145                	addi	sp,sp,48
    80004efe:	8082                	ret
  return -1;
    80004f00:	557d                	li	a0,-1
    80004f02:	b7fd                	j	80004ef0 <pipealloc+0xc6>

0000000080004f04 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f04:	1101                	addi	sp,sp,-32
    80004f06:	ec06                	sd	ra,24(sp)
    80004f08:	e822                	sd	s0,16(sp)
    80004f0a:	e426                	sd	s1,8(sp)
    80004f0c:	e04a                	sd	s2,0(sp)
    80004f0e:	1000                	addi	s0,sp,32
    80004f10:	84aa                	mv	s1,a0
    80004f12:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f14:	ffffc097          	auipc	ra,0xffffc
    80004f18:	cae080e7          	jalr	-850(ra) # 80000bc2 <acquire>
  if(writable){
    80004f1c:	02090d63          	beqz	s2,80004f56 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f20:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f24:	21848513          	addi	a0,s1,536
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	4e4080e7          	jalr	1252(ra) # 8000240c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f30:	2204b783          	ld	a5,544(s1)
    80004f34:	eb95                	bnez	a5,80004f68 <pipeclose+0x64>
    release(&pi->lock);
    80004f36:	8526                	mv	a0,s1
    80004f38:	ffffc097          	auipc	ra,0xffffc
    80004f3c:	d3e080e7          	jalr	-706(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004f40:	8526                	mv	a0,s1
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	a94080e7          	jalr	-1388(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004f4a:	60e2                	ld	ra,24(sp)
    80004f4c:	6442                	ld	s0,16(sp)
    80004f4e:	64a2                	ld	s1,8(sp)
    80004f50:	6902                	ld	s2,0(sp)
    80004f52:	6105                	addi	sp,sp,32
    80004f54:	8082                	ret
    pi->readopen = 0;
    80004f56:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f5a:	21c48513          	addi	a0,s1,540
    80004f5e:	ffffd097          	auipc	ra,0xffffd
    80004f62:	4ae080e7          	jalr	1198(ra) # 8000240c <wakeup>
    80004f66:	b7e9                	j	80004f30 <pipeclose+0x2c>
    release(&pi->lock);
    80004f68:	8526                	mv	a0,s1
    80004f6a:	ffffc097          	auipc	ra,0xffffc
    80004f6e:	d0c080e7          	jalr	-756(ra) # 80000c76 <release>
}
    80004f72:	bfe1                	j	80004f4a <pipeclose+0x46>

0000000080004f74 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f74:	711d                	addi	sp,sp,-96
    80004f76:	ec86                	sd	ra,88(sp)
    80004f78:	e8a2                	sd	s0,80(sp)
    80004f7a:	e4a6                	sd	s1,72(sp)
    80004f7c:	e0ca                	sd	s2,64(sp)
    80004f7e:	fc4e                	sd	s3,56(sp)
    80004f80:	f852                	sd	s4,48(sp)
    80004f82:	f456                	sd	s5,40(sp)
    80004f84:	f05a                	sd	s6,32(sp)
    80004f86:	ec5e                	sd	s7,24(sp)
    80004f88:	e862                	sd	s8,16(sp)
    80004f8a:	1080                	addi	s0,sp,96
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	8aae                	mv	s5,a1
    80004f90:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f92:	ffffd097          	auipc	ra,0xffffd
    80004f96:	9ec080e7          	jalr	-1556(ra) # 8000197e <myproc>
    80004f9a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	ffffc097          	auipc	ra,0xffffc
    80004fa2:	c24080e7          	jalr	-988(ra) # 80000bc2 <acquire>
  while(i < n){
    80004fa6:	0b405363          	blez	s4,8000504c <pipewrite+0xd8>
  int i = 0;
    80004faa:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fac:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fae:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004fb2:	21c48b93          	addi	s7,s1,540
    80004fb6:	a089                	j	80004ff8 <pipewrite+0x84>
      release(&pi->lock);
    80004fb8:	8526                	mv	a0,s1
    80004fba:	ffffc097          	auipc	ra,0xffffc
    80004fbe:	cbc080e7          	jalr	-836(ra) # 80000c76 <release>
      return -1;
    80004fc2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fc4:	854a                	mv	a0,s2
    80004fc6:	60e6                	ld	ra,88(sp)
    80004fc8:	6446                	ld	s0,80(sp)
    80004fca:	64a6                	ld	s1,72(sp)
    80004fcc:	6906                	ld	s2,64(sp)
    80004fce:	79e2                	ld	s3,56(sp)
    80004fd0:	7a42                	ld	s4,48(sp)
    80004fd2:	7aa2                	ld	s5,40(sp)
    80004fd4:	7b02                	ld	s6,32(sp)
    80004fd6:	6be2                	ld	s7,24(sp)
    80004fd8:	6c42                	ld	s8,16(sp)
    80004fda:	6125                	addi	sp,sp,96
    80004fdc:	8082                	ret
      wakeup(&pi->nread);
    80004fde:	8562                	mv	a0,s8
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	42c080e7          	jalr	1068(ra) # 8000240c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fe8:	85a6                	mv	a1,s1
    80004fea:	855e                	mv	a0,s7
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	294080e7          	jalr	660(ra) # 80002280 <sleep>
  while(i < n){
    80004ff4:	05495d63          	bge	s2,s4,8000504e <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004ff8:	2204a783          	lw	a5,544(s1)
    80004ffc:	dfd5                	beqz	a5,80004fb8 <pipewrite+0x44>
    80004ffe:	0289a783          	lw	a5,40(s3)
    80005002:	fbdd                	bnez	a5,80004fb8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005004:	2184a783          	lw	a5,536(s1)
    80005008:	21c4a703          	lw	a4,540(s1)
    8000500c:	2007879b          	addiw	a5,a5,512
    80005010:	fcf707e3          	beq	a4,a5,80004fde <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005014:	4685                	li	a3,1
    80005016:	01590633          	add	a2,s2,s5
    8000501a:	faf40593          	addi	a1,s0,-81
    8000501e:	0509b503          	ld	a0,80(s3)
    80005022:	ffffc097          	auipc	ra,0xffffc
    80005026:	6a8080e7          	jalr	1704(ra) # 800016ca <copyin>
    8000502a:	03650263          	beq	a0,s6,8000504e <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000502e:	21c4a783          	lw	a5,540(s1)
    80005032:	0017871b          	addiw	a4,a5,1
    80005036:	20e4ae23          	sw	a4,540(s1)
    8000503a:	1ff7f793          	andi	a5,a5,511
    8000503e:	97a6                	add	a5,a5,s1
    80005040:	faf44703          	lbu	a4,-81(s0)
    80005044:	00e78c23          	sb	a4,24(a5)
      i++;
    80005048:	2905                	addiw	s2,s2,1
    8000504a:	b76d                	j	80004ff4 <pipewrite+0x80>
  int i = 0;
    8000504c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000504e:	21848513          	addi	a0,s1,536
    80005052:	ffffd097          	auipc	ra,0xffffd
    80005056:	3ba080e7          	jalr	954(ra) # 8000240c <wakeup>
  release(&pi->lock);
    8000505a:	8526                	mv	a0,s1
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	c1a080e7          	jalr	-998(ra) # 80000c76 <release>
  return i;
    80005064:	b785                	j	80004fc4 <pipewrite+0x50>

0000000080005066 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005066:	715d                	addi	sp,sp,-80
    80005068:	e486                	sd	ra,72(sp)
    8000506a:	e0a2                	sd	s0,64(sp)
    8000506c:	fc26                	sd	s1,56(sp)
    8000506e:	f84a                	sd	s2,48(sp)
    80005070:	f44e                	sd	s3,40(sp)
    80005072:	f052                	sd	s4,32(sp)
    80005074:	ec56                	sd	s5,24(sp)
    80005076:	e85a                	sd	s6,16(sp)
    80005078:	0880                	addi	s0,sp,80
    8000507a:	84aa                	mv	s1,a0
    8000507c:	892e                	mv	s2,a1
    8000507e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005080:	ffffd097          	auipc	ra,0xffffd
    80005084:	8fe080e7          	jalr	-1794(ra) # 8000197e <myproc>
    80005088:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000508a:	8526                	mv	a0,s1
    8000508c:	ffffc097          	auipc	ra,0xffffc
    80005090:	b36080e7          	jalr	-1226(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005094:	2184a703          	lw	a4,536(s1)
    80005098:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000509c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050a0:	02f71463          	bne	a4,a5,800050c8 <piperead+0x62>
    800050a4:	2244a783          	lw	a5,548(s1)
    800050a8:	c385                	beqz	a5,800050c8 <piperead+0x62>
    if(pr->killed){
    800050aa:	028a2783          	lw	a5,40(s4)
    800050ae:	ebc1                	bnez	a5,8000513e <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050b0:	85a6                	mv	a1,s1
    800050b2:	854e                	mv	a0,s3
    800050b4:	ffffd097          	auipc	ra,0xffffd
    800050b8:	1cc080e7          	jalr	460(ra) # 80002280 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050bc:	2184a703          	lw	a4,536(s1)
    800050c0:	21c4a783          	lw	a5,540(s1)
    800050c4:	fef700e3          	beq	a4,a5,800050a4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050ca:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050cc:	05505363          	blez	s5,80005112 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800050d0:	2184a783          	lw	a5,536(s1)
    800050d4:	21c4a703          	lw	a4,540(s1)
    800050d8:	02f70d63          	beq	a4,a5,80005112 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050dc:	0017871b          	addiw	a4,a5,1
    800050e0:	20e4ac23          	sw	a4,536(s1)
    800050e4:	1ff7f793          	andi	a5,a5,511
    800050e8:	97a6                	add	a5,a5,s1
    800050ea:	0187c783          	lbu	a5,24(a5)
    800050ee:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050f2:	4685                	li	a3,1
    800050f4:	fbf40613          	addi	a2,s0,-65
    800050f8:	85ca                	mv	a1,s2
    800050fa:	050a3503          	ld	a0,80(s4)
    800050fe:	ffffc097          	auipc	ra,0xffffc
    80005102:	540080e7          	jalr	1344(ra) # 8000163e <copyout>
    80005106:	01650663          	beq	a0,s6,80005112 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000510a:	2985                	addiw	s3,s3,1
    8000510c:	0905                	addi	s2,s2,1
    8000510e:	fd3a91e3          	bne	s5,s3,800050d0 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005112:	21c48513          	addi	a0,s1,540
    80005116:	ffffd097          	auipc	ra,0xffffd
    8000511a:	2f6080e7          	jalr	758(ra) # 8000240c <wakeup>
  release(&pi->lock);
    8000511e:	8526                	mv	a0,s1
    80005120:	ffffc097          	auipc	ra,0xffffc
    80005124:	b56080e7          	jalr	-1194(ra) # 80000c76 <release>
  return i;
}
    80005128:	854e                	mv	a0,s3
    8000512a:	60a6                	ld	ra,72(sp)
    8000512c:	6406                	ld	s0,64(sp)
    8000512e:	74e2                	ld	s1,56(sp)
    80005130:	7942                	ld	s2,48(sp)
    80005132:	79a2                	ld	s3,40(sp)
    80005134:	7a02                	ld	s4,32(sp)
    80005136:	6ae2                	ld	s5,24(sp)
    80005138:	6b42                	ld	s6,16(sp)
    8000513a:	6161                	addi	sp,sp,80
    8000513c:	8082                	ret
      release(&pi->lock);
    8000513e:	8526                	mv	a0,s1
    80005140:	ffffc097          	auipc	ra,0xffffc
    80005144:	b36080e7          	jalr	-1226(ra) # 80000c76 <release>
      return -1;
    80005148:	59fd                	li	s3,-1
    8000514a:	bff9                	j	80005128 <piperead+0xc2>

000000008000514c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000514c:	de010113          	addi	sp,sp,-544
    80005150:	20113c23          	sd	ra,536(sp)
    80005154:	20813823          	sd	s0,528(sp)
    80005158:	20913423          	sd	s1,520(sp)
    8000515c:	21213023          	sd	s2,512(sp)
    80005160:	ffce                	sd	s3,504(sp)
    80005162:	fbd2                	sd	s4,496(sp)
    80005164:	f7d6                	sd	s5,488(sp)
    80005166:	f3da                	sd	s6,480(sp)
    80005168:	efde                	sd	s7,472(sp)
    8000516a:	ebe2                	sd	s8,464(sp)
    8000516c:	e7e6                	sd	s9,456(sp)
    8000516e:	e3ea                	sd	s10,448(sp)
    80005170:	ff6e                	sd	s11,440(sp)
    80005172:	1400                	addi	s0,sp,544
    80005174:	892a                	mv	s2,a0
    80005176:	dea43423          	sd	a0,-536(s0)
    8000517a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000517e:	ffffd097          	auipc	ra,0xffffd
    80005182:	800080e7          	jalr	-2048(ra) # 8000197e <myproc>
    80005186:	84aa                	mv	s1,a0

  begin_op();
    80005188:	fffff097          	auipc	ra,0xfffff
    8000518c:	4a6080e7          	jalr	1190(ra) # 8000462e <begin_op>

  if((ip = namei(path)) == 0){
    80005190:	854a                	mv	a0,s2
    80005192:	fffff097          	auipc	ra,0xfffff
    80005196:	27c080e7          	jalr	636(ra) # 8000440e <namei>
    8000519a:	c93d                	beqz	a0,80005210 <exec+0xc4>
    8000519c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000519e:	fffff097          	auipc	ra,0xfffff
    800051a2:	aba080e7          	jalr	-1350(ra) # 80003c58 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051a6:	04000713          	li	a4,64
    800051aa:	4681                	li	a3,0
    800051ac:	e4840613          	addi	a2,s0,-440
    800051b0:	4581                	li	a1,0
    800051b2:	8556                	mv	a0,s5
    800051b4:	fffff097          	auipc	ra,0xfffff
    800051b8:	d58080e7          	jalr	-680(ra) # 80003f0c <readi>
    800051bc:	04000793          	li	a5,64
    800051c0:	00f51a63          	bne	a0,a5,800051d4 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800051c4:	e4842703          	lw	a4,-440(s0)
    800051c8:	464c47b7          	lui	a5,0x464c4
    800051cc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051d0:	04f70663          	beq	a4,a5,8000521c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051d4:	8556                	mv	a0,s5
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	ce4080e7          	jalr	-796(ra) # 80003eba <iunlockput>
    end_op();
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	4d0080e7          	jalr	1232(ra) # 800046ae <end_op>
  }
  return -1;
    800051e6:	557d                	li	a0,-1
}
    800051e8:	21813083          	ld	ra,536(sp)
    800051ec:	21013403          	ld	s0,528(sp)
    800051f0:	20813483          	ld	s1,520(sp)
    800051f4:	20013903          	ld	s2,512(sp)
    800051f8:	79fe                	ld	s3,504(sp)
    800051fa:	7a5e                	ld	s4,496(sp)
    800051fc:	7abe                	ld	s5,488(sp)
    800051fe:	7b1e                	ld	s6,480(sp)
    80005200:	6bfe                	ld	s7,472(sp)
    80005202:	6c5e                	ld	s8,464(sp)
    80005204:	6cbe                	ld	s9,456(sp)
    80005206:	6d1e                	ld	s10,448(sp)
    80005208:	7dfa                	ld	s11,440(sp)
    8000520a:	22010113          	addi	sp,sp,544
    8000520e:	8082                	ret
    end_op();
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	49e080e7          	jalr	1182(ra) # 800046ae <end_op>
    return -1;
    80005218:	557d                	li	a0,-1
    8000521a:	b7f9                	j	800051e8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000521c:	8526                	mv	a0,s1
    8000521e:	ffffd097          	auipc	ra,0xffffd
    80005222:	824080e7          	jalr	-2012(ra) # 80001a42 <proc_pagetable>
    80005226:	8b2a                	mv	s6,a0
    80005228:	d555                	beqz	a0,800051d4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000522a:	e6842783          	lw	a5,-408(s0)
    8000522e:	e8045703          	lhu	a4,-384(s0)
    80005232:	c735                	beqz	a4,8000529e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005234:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005236:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000523a:	6a05                	lui	s4,0x1
    8000523c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005240:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005244:	6d85                	lui	s11,0x1
    80005246:	7d7d                	lui	s10,0xfffff
    80005248:	ac1d                	j	8000547e <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000524a:	00003517          	auipc	a0,0x3
    8000524e:	4ee50513          	addi	a0,a0,1262 # 80008738 <syscalls+0x298>
    80005252:	ffffb097          	auipc	ra,0xffffb
    80005256:	2d8080e7          	jalr	728(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000525a:	874a                	mv	a4,s2
    8000525c:	009c86bb          	addw	a3,s9,s1
    80005260:	4581                	li	a1,0
    80005262:	8556                	mv	a0,s5
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	ca8080e7          	jalr	-856(ra) # 80003f0c <readi>
    8000526c:	2501                	sext.w	a0,a0
    8000526e:	1aa91863          	bne	s2,a0,8000541e <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005272:	009d84bb          	addw	s1,s11,s1
    80005276:	013d09bb          	addw	s3,s10,s3
    8000527a:	1f74f263          	bgeu	s1,s7,8000545e <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    8000527e:	02049593          	slli	a1,s1,0x20
    80005282:	9181                	srli	a1,a1,0x20
    80005284:	95e2                	add	a1,a1,s8
    80005286:	855a                	mv	a0,s6
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	dc4080e7          	jalr	-572(ra) # 8000104c <walkaddr>
    80005290:	862a                	mv	a2,a0
    if(pa == 0)
    80005292:	dd45                	beqz	a0,8000524a <exec+0xfe>
      n = PGSIZE;
    80005294:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005296:	fd49f2e3          	bgeu	s3,s4,8000525a <exec+0x10e>
      n = sz - i;
    8000529a:	894e                	mv	s2,s3
    8000529c:	bf7d                	j	8000525a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000529e:	4481                	li	s1,0
  iunlockput(ip);
    800052a0:	8556                	mv	a0,s5
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	c18080e7          	jalr	-1000(ra) # 80003eba <iunlockput>
  end_op();
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	404080e7          	jalr	1028(ra) # 800046ae <end_op>
  p = myproc();
    800052b2:	ffffc097          	auipc	ra,0xffffc
    800052b6:	6cc080e7          	jalr	1740(ra) # 8000197e <myproc>
    800052ba:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052bc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800052c0:	6785                	lui	a5,0x1
    800052c2:	17fd                	addi	a5,a5,-1
    800052c4:	94be                	add	s1,s1,a5
    800052c6:	77fd                	lui	a5,0xfffff
    800052c8:	8fe5                	and	a5,a5,s1
    800052ca:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800052ce:	6609                	lui	a2,0x2
    800052d0:	963e                	add	a2,a2,a5
    800052d2:	85be                	mv	a1,a5
    800052d4:	855a                	mv	a0,s6
    800052d6:	ffffc097          	auipc	ra,0xffffc
    800052da:	118080e7          	jalr	280(ra) # 800013ee <uvmalloc>
    800052de:	8c2a                	mv	s8,a0
  ip = 0;
    800052e0:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800052e2:	12050e63          	beqz	a0,8000541e <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052e6:	75f9                	lui	a1,0xffffe
    800052e8:	95aa                	add	a1,a1,a0
    800052ea:	855a                	mv	a0,s6
    800052ec:	ffffc097          	auipc	ra,0xffffc
    800052f0:	320080e7          	jalr	800(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    800052f4:	7afd                	lui	s5,0xfffff
    800052f6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052f8:	df043783          	ld	a5,-528(s0)
    800052fc:	6388                	ld	a0,0(a5)
    800052fe:	c925                	beqz	a0,8000536e <exec+0x222>
    80005300:	e8840993          	addi	s3,s0,-376
    80005304:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005308:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000530a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000530c:	ffffc097          	auipc	ra,0xffffc
    80005310:	b36080e7          	jalr	-1226(ra) # 80000e42 <strlen>
    80005314:	0015079b          	addiw	a5,a0,1
    80005318:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000531c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005320:	13596363          	bltu	s2,s5,80005446 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005324:	df043d83          	ld	s11,-528(s0)
    80005328:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000532c:	8552                	mv	a0,s4
    8000532e:	ffffc097          	auipc	ra,0xffffc
    80005332:	b14080e7          	jalr	-1260(ra) # 80000e42 <strlen>
    80005336:	0015069b          	addiw	a3,a0,1
    8000533a:	8652                	mv	a2,s4
    8000533c:	85ca                	mv	a1,s2
    8000533e:	855a                	mv	a0,s6
    80005340:	ffffc097          	auipc	ra,0xffffc
    80005344:	2fe080e7          	jalr	766(ra) # 8000163e <copyout>
    80005348:	10054363          	bltz	a0,8000544e <exec+0x302>
    ustack[argc] = sp;
    8000534c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005350:	0485                	addi	s1,s1,1
    80005352:	008d8793          	addi	a5,s11,8
    80005356:	def43823          	sd	a5,-528(s0)
    8000535a:	008db503          	ld	a0,8(s11)
    8000535e:	c911                	beqz	a0,80005372 <exec+0x226>
    if(argc >= MAXARG)
    80005360:	09a1                	addi	s3,s3,8
    80005362:	fb3c95e3          	bne	s9,s3,8000530c <exec+0x1c0>
  sz = sz1;
    80005366:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000536a:	4a81                	li	s5,0
    8000536c:	a84d                	j	8000541e <exec+0x2d2>
  sp = sz;
    8000536e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005370:	4481                	li	s1,0
  ustack[argc] = 0;
    80005372:	00349793          	slli	a5,s1,0x3
    80005376:	f9040713          	addi	a4,s0,-112
    8000537a:	97ba                	add	a5,a5,a4
    8000537c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005380:	00148693          	addi	a3,s1,1
    80005384:	068e                	slli	a3,a3,0x3
    80005386:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000538a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000538e:	01597663          	bgeu	s2,s5,8000539a <exec+0x24e>
  sz = sz1;
    80005392:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005396:	4a81                	li	s5,0
    80005398:	a059                	j	8000541e <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000539a:	e8840613          	addi	a2,s0,-376
    8000539e:	85ca                	mv	a1,s2
    800053a0:	855a                	mv	a0,s6
    800053a2:	ffffc097          	auipc	ra,0xffffc
    800053a6:	29c080e7          	jalr	668(ra) # 8000163e <copyout>
    800053aa:	0a054663          	bltz	a0,80005456 <exec+0x30a>
  p->trapframe->a1 = sp;
    800053ae:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800053b2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053b6:	de843783          	ld	a5,-536(s0)
    800053ba:	0007c703          	lbu	a4,0(a5)
    800053be:	cf11                	beqz	a4,800053da <exec+0x28e>
    800053c0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053c2:	02f00693          	li	a3,47
    800053c6:	a039                	j	800053d4 <exec+0x288>
      last = s+1;
    800053c8:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053cc:	0785                	addi	a5,a5,1
    800053ce:	fff7c703          	lbu	a4,-1(a5)
    800053d2:	c701                	beqz	a4,800053da <exec+0x28e>
    if(*s == '/')
    800053d4:	fed71ce3          	bne	a4,a3,800053cc <exec+0x280>
    800053d8:	bfc5                	j	800053c8 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800053da:	4641                	li	a2,16
    800053dc:	de843583          	ld	a1,-536(s0)
    800053e0:	158b8513          	addi	a0,s7,344
    800053e4:	ffffc097          	auipc	ra,0xffffc
    800053e8:	a2c080e7          	jalr	-1492(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    800053ec:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800053f0:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800053f4:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053f8:	058bb783          	ld	a5,88(s7)
    800053fc:	e6043703          	ld	a4,-416(s0)
    80005400:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005402:	058bb783          	ld	a5,88(s7)
    80005406:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000540a:	85ea                	mv	a1,s10
    8000540c:	ffffc097          	auipc	ra,0xffffc
    80005410:	6d2080e7          	jalr	1746(ra) # 80001ade <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005414:	0004851b          	sext.w	a0,s1
    80005418:	bbc1                	j	800051e8 <exec+0x9c>
    8000541a:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000541e:	df843583          	ld	a1,-520(s0)
    80005422:	855a                	mv	a0,s6
    80005424:	ffffc097          	auipc	ra,0xffffc
    80005428:	6ba080e7          	jalr	1722(ra) # 80001ade <proc_freepagetable>
  if(ip){
    8000542c:	da0a94e3          	bnez	s5,800051d4 <exec+0x88>
  return -1;
    80005430:	557d                	li	a0,-1
    80005432:	bb5d                	j	800051e8 <exec+0x9c>
    80005434:	de943c23          	sd	s1,-520(s0)
    80005438:	b7dd                	j	8000541e <exec+0x2d2>
    8000543a:	de943c23          	sd	s1,-520(s0)
    8000543e:	b7c5                	j	8000541e <exec+0x2d2>
    80005440:	de943c23          	sd	s1,-520(s0)
    80005444:	bfe9                	j	8000541e <exec+0x2d2>
  sz = sz1;
    80005446:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000544a:	4a81                	li	s5,0
    8000544c:	bfc9                	j	8000541e <exec+0x2d2>
  sz = sz1;
    8000544e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005452:	4a81                	li	s5,0
    80005454:	b7e9                	j	8000541e <exec+0x2d2>
  sz = sz1;
    80005456:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000545a:	4a81                	li	s5,0
    8000545c:	b7c9                	j	8000541e <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000545e:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005462:	e0843783          	ld	a5,-504(s0)
    80005466:	0017869b          	addiw	a3,a5,1
    8000546a:	e0d43423          	sd	a3,-504(s0)
    8000546e:	e0043783          	ld	a5,-512(s0)
    80005472:	0387879b          	addiw	a5,a5,56
    80005476:	e8045703          	lhu	a4,-384(s0)
    8000547a:	e2e6d3e3          	bge	a3,a4,800052a0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000547e:	2781                	sext.w	a5,a5
    80005480:	e0f43023          	sd	a5,-512(s0)
    80005484:	03800713          	li	a4,56
    80005488:	86be                	mv	a3,a5
    8000548a:	e1040613          	addi	a2,s0,-496
    8000548e:	4581                	li	a1,0
    80005490:	8556                	mv	a0,s5
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	a7a080e7          	jalr	-1414(ra) # 80003f0c <readi>
    8000549a:	03800793          	li	a5,56
    8000549e:	f6f51ee3          	bne	a0,a5,8000541a <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800054a2:	e1042783          	lw	a5,-496(s0)
    800054a6:	4705                	li	a4,1
    800054a8:	fae79de3          	bne	a5,a4,80005462 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800054ac:	e3843603          	ld	a2,-456(s0)
    800054b0:	e3043783          	ld	a5,-464(s0)
    800054b4:	f8f660e3          	bltu	a2,a5,80005434 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054b8:	e2043783          	ld	a5,-480(s0)
    800054bc:	963e                	add	a2,a2,a5
    800054be:	f6f66ee3          	bltu	a2,a5,8000543a <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800054c2:	85a6                	mv	a1,s1
    800054c4:	855a                	mv	a0,s6
    800054c6:	ffffc097          	auipc	ra,0xffffc
    800054ca:	f28080e7          	jalr	-216(ra) # 800013ee <uvmalloc>
    800054ce:	dea43c23          	sd	a0,-520(s0)
    800054d2:	d53d                	beqz	a0,80005440 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800054d4:	e2043c03          	ld	s8,-480(s0)
    800054d8:	de043783          	ld	a5,-544(s0)
    800054dc:	00fc77b3          	and	a5,s8,a5
    800054e0:	ff9d                	bnez	a5,8000541e <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054e2:	e1842c83          	lw	s9,-488(s0)
    800054e6:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054ea:	f60b8ae3          	beqz	s7,8000545e <exec+0x312>
    800054ee:	89de                	mv	s3,s7
    800054f0:	4481                	li	s1,0
    800054f2:	b371                	j	8000527e <exec+0x132>

00000000800054f4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054f4:	7179                	addi	sp,sp,-48
    800054f6:	f406                	sd	ra,40(sp)
    800054f8:	f022                	sd	s0,32(sp)
    800054fa:	ec26                	sd	s1,24(sp)
    800054fc:	e84a                	sd	s2,16(sp)
    800054fe:	1800                	addi	s0,sp,48
    80005500:	892e                	mv	s2,a1
    80005502:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005504:	fdc40593          	addi	a1,s0,-36
    80005508:	ffffe097          	auipc	ra,0xffffe
    8000550c:	a4e080e7          	jalr	-1458(ra) # 80002f56 <argint>
    80005510:	04054063          	bltz	a0,80005550 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005514:	fdc42703          	lw	a4,-36(s0)
    80005518:	47bd                	li	a5,15
    8000551a:	02e7ed63          	bltu	a5,a4,80005554 <argfd+0x60>
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	460080e7          	jalr	1120(ra) # 8000197e <myproc>
    80005526:	fdc42703          	lw	a4,-36(s0)
    8000552a:	01a70793          	addi	a5,a4,26
    8000552e:	078e                	slli	a5,a5,0x3
    80005530:	953e                	add	a0,a0,a5
    80005532:	611c                	ld	a5,0(a0)
    80005534:	c395                	beqz	a5,80005558 <argfd+0x64>
    return -1;
  if(pfd)
    80005536:	00090463          	beqz	s2,8000553e <argfd+0x4a>
    *pfd = fd;
    8000553a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000553e:	4501                	li	a0,0
  if(pf)
    80005540:	c091                	beqz	s1,80005544 <argfd+0x50>
    *pf = f;
    80005542:	e09c                	sd	a5,0(s1)
}
    80005544:	70a2                	ld	ra,40(sp)
    80005546:	7402                	ld	s0,32(sp)
    80005548:	64e2                	ld	s1,24(sp)
    8000554a:	6942                	ld	s2,16(sp)
    8000554c:	6145                	addi	sp,sp,48
    8000554e:	8082                	ret
    return -1;
    80005550:	557d                	li	a0,-1
    80005552:	bfcd                	j	80005544 <argfd+0x50>
    return -1;
    80005554:	557d                	li	a0,-1
    80005556:	b7fd                	j	80005544 <argfd+0x50>
    80005558:	557d                	li	a0,-1
    8000555a:	b7ed                	j	80005544 <argfd+0x50>

000000008000555c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000555c:	1101                	addi	sp,sp,-32
    8000555e:	ec06                	sd	ra,24(sp)
    80005560:	e822                	sd	s0,16(sp)
    80005562:	e426                	sd	s1,8(sp)
    80005564:	1000                	addi	s0,sp,32
    80005566:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005568:	ffffc097          	auipc	ra,0xffffc
    8000556c:	416080e7          	jalr	1046(ra) # 8000197e <myproc>
    80005570:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005572:	0d050793          	addi	a5,a0,208
    80005576:	4501                	li	a0,0
    80005578:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000557a:	6398                	ld	a4,0(a5)
    8000557c:	cb19                	beqz	a4,80005592 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000557e:	2505                	addiw	a0,a0,1
    80005580:	07a1                	addi	a5,a5,8
    80005582:	fed51ce3          	bne	a0,a3,8000557a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005586:	557d                	li	a0,-1
}
    80005588:	60e2                	ld	ra,24(sp)
    8000558a:	6442                	ld	s0,16(sp)
    8000558c:	64a2                	ld	s1,8(sp)
    8000558e:	6105                	addi	sp,sp,32
    80005590:	8082                	ret
      p->ofile[fd] = f;
    80005592:	01a50793          	addi	a5,a0,26
    80005596:	078e                	slli	a5,a5,0x3
    80005598:	963e                	add	a2,a2,a5
    8000559a:	e204                	sd	s1,0(a2)
      return fd;
    8000559c:	b7f5                	j	80005588 <fdalloc+0x2c>

000000008000559e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000559e:	715d                	addi	sp,sp,-80
    800055a0:	e486                	sd	ra,72(sp)
    800055a2:	e0a2                	sd	s0,64(sp)
    800055a4:	fc26                	sd	s1,56(sp)
    800055a6:	f84a                	sd	s2,48(sp)
    800055a8:	f44e                	sd	s3,40(sp)
    800055aa:	f052                	sd	s4,32(sp)
    800055ac:	ec56                	sd	s5,24(sp)
    800055ae:	0880                	addi	s0,sp,80
    800055b0:	89ae                	mv	s3,a1
    800055b2:	8ab2                	mv	s5,a2
    800055b4:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055b6:	fb040593          	addi	a1,s0,-80
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	e72080e7          	jalr	-398(ra) # 8000442c <nameiparent>
    800055c2:	892a                	mv	s2,a0
    800055c4:	12050e63          	beqz	a0,80005700 <create+0x162>
    return 0;

  ilock(dp);
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	690080e7          	jalr	1680(ra) # 80003c58 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055d0:	4601                	li	a2,0
    800055d2:	fb040593          	addi	a1,s0,-80
    800055d6:	854a                	mv	a0,s2
    800055d8:	fffff097          	auipc	ra,0xfffff
    800055dc:	b64080e7          	jalr	-1180(ra) # 8000413c <dirlookup>
    800055e0:	84aa                	mv	s1,a0
    800055e2:	c921                	beqz	a0,80005632 <create+0x94>
    iunlockput(dp);
    800055e4:	854a                	mv	a0,s2
    800055e6:	fffff097          	auipc	ra,0xfffff
    800055ea:	8d4080e7          	jalr	-1836(ra) # 80003eba <iunlockput>
    ilock(ip);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	668080e7          	jalr	1640(ra) # 80003c58 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055f8:	2981                	sext.w	s3,s3
    800055fa:	4789                	li	a5,2
    800055fc:	02f99463          	bne	s3,a5,80005624 <create+0x86>
    80005600:	0444d783          	lhu	a5,68(s1)
    80005604:	37f9                	addiw	a5,a5,-2
    80005606:	17c2                	slli	a5,a5,0x30
    80005608:	93c1                	srli	a5,a5,0x30
    8000560a:	4705                	li	a4,1
    8000560c:	00f76c63          	bltu	a4,a5,80005624 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005610:	8526                	mv	a0,s1
    80005612:	60a6                	ld	ra,72(sp)
    80005614:	6406                	ld	s0,64(sp)
    80005616:	74e2                	ld	s1,56(sp)
    80005618:	7942                	ld	s2,48(sp)
    8000561a:	79a2                	ld	s3,40(sp)
    8000561c:	7a02                	ld	s4,32(sp)
    8000561e:	6ae2                	ld	s5,24(sp)
    80005620:	6161                	addi	sp,sp,80
    80005622:	8082                	ret
    iunlockput(ip);
    80005624:	8526                	mv	a0,s1
    80005626:	fffff097          	auipc	ra,0xfffff
    8000562a:	894080e7          	jalr	-1900(ra) # 80003eba <iunlockput>
    return 0;
    8000562e:	4481                	li	s1,0
    80005630:	b7c5                	j	80005610 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005632:	85ce                	mv	a1,s3
    80005634:	00092503          	lw	a0,0(s2)
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	488080e7          	jalr	1160(ra) # 80003ac0 <ialloc>
    80005640:	84aa                	mv	s1,a0
    80005642:	c521                	beqz	a0,8000568a <create+0xec>
  ilock(ip);
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	614080e7          	jalr	1556(ra) # 80003c58 <ilock>
  ip->major = major;
    8000564c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005650:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005654:	4a05                	li	s4,1
    80005656:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000565a:	8526                	mv	a0,s1
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	532080e7          	jalr	1330(ra) # 80003b8e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005664:	2981                	sext.w	s3,s3
    80005666:	03498a63          	beq	s3,s4,8000569a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000566a:	40d0                	lw	a2,4(s1)
    8000566c:	fb040593          	addi	a1,s0,-80
    80005670:	854a                	mv	a0,s2
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	cda080e7          	jalr	-806(ra) # 8000434c <dirlink>
    8000567a:	06054b63          	bltz	a0,800056f0 <create+0x152>
  iunlockput(dp);
    8000567e:	854a                	mv	a0,s2
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	83a080e7          	jalr	-1990(ra) # 80003eba <iunlockput>
  return ip;
    80005688:	b761                	j	80005610 <create+0x72>
    panic("create: ialloc");
    8000568a:	00003517          	auipc	a0,0x3
    8000568e:	0ce50513          	addi	a0,a0,206 # 80008758 <syscalls+0x2b8>
    80005692:	ffffb097          	auipc	ra,0xffffb
    80005696:	e98080e7          	jalr	-360(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    8000569a:	04a95783          	lhu	a5,74(s2)
    8000569e:	2785                	addiw	a5,a5,1
    800056a0:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800056a4:	854a                	mv	a0,s2
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	4e8080e7          	jalr	1256(ra) # 80003b8e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056ae:	40d0                	lw	a2,4(s1)
    800056b0:	00003597          	auipc	a1,0x3
    800056b4:	0b858593          	addi	a1,a1,184 # 80008768 <syscalls+0x2c8>
    800056b8:	8526                	mv	a0,s1
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	c92080e7          	jalr	-878(ra) # 8000434c <dirlink>
    800056c2:	00054f63          	bltz	a0,800056e0 <create+0x142>
    800056c6:	00492603          	lw	a2,4(s2)
    800056ca:	00003597          	auipc	a1,0x3
    800056ce:	0a658593          	addi	a1,a1,166 # 80008770 <syscalls+0x2d0>
    800056d2:	8526                	mv	a0,s1
    800056d4:	fffff097          	auipc	ra,0xfffff
    800056d8:	c78080e7          	jalr	-904(ra) # 8000434c <dirlink>
    800056dc:	f80557e3          	bgez	a0,8000566a <create+0xcc>
      panic("create dots");
    800056e0:	00003517          	auipc	a0,0x3
    800056e4:	09850513          	addi	a0,a0,152 # 80008778 <syscalls+0x2d8>
    800056e8:	ffffb097          	auipc	ra,0xffffb
    800056ec:	e42080e7          	jalr	-446(ra) # 8000052a <panic>
    panic("create: dirlink");
    800056f0:	00003517          	auipc	a0,0x3
    800056f4:	09850513          	addi	a0,a0,152 # 80008788 <syscalls+0x2e8>
    800056f8:	ffffb097          	auipc	ra,0xffffb
    800056fc:	e32080e7          	jalr	-462(ra) # 8000052a <panic>
    return 0;
    80005700:	84aa                	mv	s1,a0
    80005702:	b739                	j	80005610 <create+0x72>

0000000080005704 <sys_dup>:
{
    80005704:	7179                	addi	sp,sp,-48
    80005706:	f406                	sd	ra,40(sp)
    80005708:	f022                	sd	s0,32(sp)
    8000570a:	ec26                	sd	s1,24(sp)
    8000570c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000570e:	fd840613          	addi	a2,s0,-40
    80005712:	4581                	li	a1,0
    80005714:	4501                	li	a0,0
    80005716:	00000097          	auipc	ra,0x0
    8000571a:	dde080e7          	jalr	-546(ra) # 800054f4 <argfd>
    return -1;
    8000571e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005720:	02054363          	bltz	a0,80005746 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005724:	fd843503          	ld	a0,-40(s0)
    80005728:	00000097          	auipc	ra,0x0
    8000572c:	e34080e7          	jalr	-460(ra) # 8000555c <fdalloc>
    80005730:	84aa                	mv	s1,a0
    return -1;
    80005732:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005734:	00054963          	bltz	a0,80005746 <sys_dup+0x42>
  filedup(f);
    80005738:	fd843503          	ld	a0,-40(s0)
    8000573c:	fffff097          	auipc	ra,0xfffff
    80005740:	36c080e7          	jalr	876(ra) # 80004aa8 <filedup>
  return fd;
    80005744:	87a6                	mv	a5,s1
}
    80005746:	853e                	mv	a0,a5
    80005748:	70a2                	ld	ra,40(sp)
    8000574a:	7402                	ld	s0,32(sp)
    8000574c:	64e2                	ld	s1,24(sp)
    8000574e:	6145                	addi	sp,sp,48
    80005750:	8082                	ret

0000000080005752 <sys_read>:
{
    80005752:	7179                	addi	sp,sp,-48
    80005754:	f406                	sd	ra,40(sp)
    80005756:	f022                	sd	s0,32(sp)
    80005758:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000575a:	fe840613          	addi	a2,s0,-24
    8000575e:	4581                	li	a1,0
    80005760:	4501                	li	a0,0
    80005762:	00000097          	auipc	ra,0x0
    80005766:	d92080e7          	jalr	-622(ra) # 800054f4 <argfd>
    return -1;
    8000576a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000576c:	04054163          	bltz	a0,800057ae <sys_read+0x5c>
    80005770:	fe440593          	addi	a1,s0,-28
    80005774:	4509                	li	a0,2
    80005776:	ffffd097          	auipc	ra,0xffffd
    8000577a:	7e0080e7          	jalr	2016(ra) # 80002f56 <argint>
    return -1;
    8000577e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005780:	02054763          	bltz	a0,800057ae <sys_read+0x5c>
    80005784:	fd840593          	addi	a1,s0,-40
    80005788:	4505                	li	a0,1
    8000578a:	ffffd097          	auipc	ra,0xffffd
    8000578e:	7ee080e7          	jalr	2030(ra) # 80002f78 <argaddr>
    return -1;
    80005792:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005794:	00054d63          	bltz	a0,800057ae <sys_read+0x5c>
  return fileread(f, p, n);
    80005798:	fe442603          	lw	a2,-28(s0)
    8000579c:	fd843583          	ld	a1,-40(s0)
    800057a0:	fe843503          	ld	a0,-24(s0)
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	490080e7          	jalr	1168(ra) # 80004c34 <fileread>
    800057ac:	87aa                	mv	a5,a0
}
    800057ae:	853e                	mv	a0,a5
    800057b0:	70a2                	ld	ra,40(sp)
    800057b2:	7402                	ld	s0,32(sp)
    800057b4:	6145                	addi	sp,sp,48
    800057b6:	8082                	ret

00000000800057b8 <sys_write>:
{
    800057b8:	7179                	addi	sp,sp,-48
    800057ba:	f406                	sd	ra,40(sp)
    800057bc:	f022                	sd	s0,32(sp)
    800057be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057c0:	fe840613          	addi	a2,s0,-24
    800057c4:	4581                	li	a1,0
    800057c6:	4501                	li	a0,0
    800057c8:	00000097          	auipc	ra,0x0
    800057cc:	d2c080e7          	jalr	-724(ra) # 800054f4 <argfd>
    return -1;
    800057d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057d2:	04054163          	bltz	a0,80005814 <sys_write+0x5c>
    800057d6:	fe440593          	addi	a1,s0,-28
    800057da:	4509                	li	a0,2
    800057dc:	ffffd097          	auipc	ra,0xffffd
    800057e0:	77a080e7          	jalr	1914(ra) # 80002f56 <argint>
    return -1;
    800057e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057e6:	02054763          	bltz	a0,80005814 <sys_write+0x5c>
    800057ea:	fd840593          	addi	a1,s0,-40
    800057ee:	4505                	li	a0,1
    800057f0:	ffffd097          	auipc	ra,0xffffd
    800057f4:	788080e7          	jalr	1928(ra) # 80002f78 <argaddr>
    return -1;
    800057f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057fa:	00054d63          	bltz	a0,80005814 <sys_write+0x5c>
  return filewrite(f, p, n);
    800057fe:	fe442603          	lw	a2,-28(s0)
    80005802:	fd843583          	ld	a1,-40(s0)
    80005806:	fe843503          	ld	a0,-24(s0)
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	4ec080e7          	jalr	1260(ra) # 80004cf6 <filewrite>
    80005812:	87aa                	mv	a5,a0
}
    80005814:	853e                	mv	a0,a5
    80005816:	70a2                	ld	ra,40(sp)
    80005818:	7402                	ld	s0,32(sp)
    8000581a:	6145                	addi	sp,sp,48
    8000581c:	8082                	ret

000000008000581e <sys_close>:
{
    8000581e:	1101                	addi	sp,sp,-32
    80005820:	ec06                	sd	ra,24(sp)
    80005822:	e822                	sd	s0,16(sp)
    80005824:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005826:	fe040613          	addi	a2,s0,-32
    8000582a:	fec40593          	addi	a1,s0,-20
    8000582e:	4501                	li	a0,0
    80005830:	00000097          	auipc	ra,0x0
    80005834:	cc4080e7          	jalr	-828(ra) # 800054f4 <argfd>
    return -1;
    80005838:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000583a:	02054463          	bltz	a0,80005862 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000583e:	ffffc097          	auipc	ra,0xffffc
    80005842:	140080e7          	jalr	320(ra) # 8000197e <myproc>
    80005846:	fec42783          	lw	a5,-20(s0)
    8000584a:	07e9                	addi	a5,a5,26
    8000584c:	078e                	slli	a5,a5,0x3
    8000584e:	97aa                	add	a5,a5,a0
    80005850:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005854:	fe043503          	ld	a0,-32(s0)
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	2a2080e7          	jalr	674(ra) # 80004afa <fileclose>
  return 0;
    80005860:	4781                	li	a5,0
}
    80005862:	853e                	mv	a0,a5
    80005864:	60e2                	ld	ra,24(sp)
    80005866:	6442                	ld	s0,16(sp)
    80005868:	6105                	addi	sp,sp,32
    8000586a:	8082                	ret

000000008000586c <sys_fstat>:
{
    8000586c:	1101                	addi	sp,sp,-32
    8000586e:	ec06                	sd	ra,24(sp)
    80005870:	e822                	sd	s0,16(sp)
    80005872:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005874:	fe840613          	addi	a2,s0,-24
    80005878:	4581                	li	a1,0
    8000587a:	4501                	li	a0,0
    8000587c:	00000097          	auipc	ra,0x0
    80005880:	c78080e7          	jalr	-904(ra) # 800054f4 <argfd>
    return -1;
    80005884:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005886:	02054563          	bltz	a0,800058b0 <sys_fstat+0x44>
    8000588a:	fe040593          	addi	a1,s0,-32
    8000588e:	4505                	li	a0,1
    80005890:	ffffd097          	auipc	ra,0xffffd
    80005894:	6e8080e7          	jalr	1768(ra) # 80002f78 <argaddr>
    return -1;
    80005898:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000589a:	00054b63          	bltz	a0,800058b0 <sys_fstat+0x44>
  return filestat(f, st);
    8000589e:	fe043583          	ld	a1,-32(s0)
    800058a2:	fe843503          	ld	a0,-24(s0)
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	31c080e7          	jalr	796(ra) # 80004bc2 <filestat>
    800058ae:	87aa                	mv	a5,a0
}
    800058b0:	853e                	mv	a0,a5
    800058b2:	60e2                	ld	ra,24(sp)
    800058b4:	6442                	ld	s0,16(sp)
    800058b6:	6105                	addi	sp,sp,32
    800058b8:	8082                	ret

00000000800058ba <sys_link>:
{
    800058ba:	7169                	addi	sp,sp,-304
    800058bc:	f606                	sd	ra,296(sp)
    800058be:	f222                	sd	s0,288(sp)
    800058c0:	ee26                	sd	s1,280(sp)
    800058c2:	ea4a                	sd	s2,272(sp)
    800058c4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058c6:	08000613          	li	a2,128
    800058ca:	ed040593          	addi	a1,s0,-304
    800058ce:	4501                	li	a0,0
    800058d0:	ffffd097          	auipc	ra,0xffffd
    800058d4:	6ca080e7          	jalr	1738(ra) # 80002f9a <argstr>
    return -1;
    800058d8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058da:	10054e63          	bltz	a0,800059f6 <sys_link+0x13c>
    800058de:	08000613          	li	a2,128
    800058e2:	f5040593          	addi	a1,s0,-176
    800058e6:	4505                	li	a0,1
    800058e8:	ffffd097          	auipc	ra,0xffffd
    800058ec:	6b2080e7          	jalr	1714(ra) # 80002f9a <argstr>
    return -1;
    800058f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058f2:	10054263          	bltz	a0,800059f6 <sys_link+0x13c>
  begin_op();
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	d38080e7          	jalr	-712(ra) # 8000462e <begin_op>
  if((ip = namei(old)) == 0){
    800058fe:	ed040513          	addi	a0,s0,-304
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	b0c080e7          	jalr	-1268(ra) # 8000440e <namei>
    8000590a:	84aa                	mv	s1,a0
    8000590c:	c551                	beqz	a0,80005998 <sys_link+0xde>
  ilock(ip);
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	34a080e7          	jalr	842(ra) # 80003c58 <ilock>
  if(ip->type == T_DIR){
    80005916:	04449703          	lh	a4,68(s1)
    8000591a:	4785                	li	a5,1
    8000591c:	08f70463          	beq	a4,a5,800059a4 <sys_link+0xea>
  ip->nlink++;
    80005920:	04a4d783          	lhu	a5,74(s1)
    80005924:	2785                	addiw	a5,a5,1
    80005926:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000592a:	8526                	mv	a0,s1
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	262080e7          	jalr	610(ra) # 80003b8e <iupdate>
  iunlock(ip);
    80005934:	8526                	mv	a0,s1
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	3e4080e7          	jalr	996(ra) # 80003d1a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000593e:	fd040593          	addi	a1,s0,-48
    80005942:	f5040513          	addi	a0,s0,-176
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	ae6080e7          	jalr	-1306(ra) # 8000442c <nameiparent>
    8000594e:	892a                	mv	s2,a0
    80005950:	c935                	beqz	a0,800059c4 <sys_link+0x10a>
  ilock(dp);
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	306080e7          	jalr	774(ra) # 80003c58 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000595a:	00092703          	lw	a4,0(s2)
    8000595e:	409c                	lw	a5,0(s1)
    80005960:	04f71d63          	bne	a4,a5,800059ba <sys_link+0x100>
    80005964:	40d0                	lw	a2,4(s1)
    80005966:	fd040593          	addi	a1,s0,-48
    8000596a:	854a                	mv	a0,s2
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	9e0080e7          	jalr	-1568(ra) # 8000434c <dirlink>
    80005974:	04054363          	bltz	a0,800059ba <sys_link+0x100>
  iunlockput(dp);
    80005978:	854a                	mv	a0,s2
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	540080e7          	jalr	1344(ra) # 80003eba <iunlockput>
  iput(ip);
    80005982:	8526                	mv	a0,s1
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	48e080e7          	jalr	1166(ra) # 80003e12 <iput>
  end_op();
    8000598c:	fffff097          	auipc	ra,0xfffff
    80005990:	d22080e7          	jalr	-734(ra) # 800046ae <end_op>
  return 0;
    80005994:	4781                	li	a5,0
    80005996:	a085                	j	800059f6 <sys_link+0x13c>
    end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	d16080e7          	jalr	-746(ra) # 800046ae <end_op>
    return -1;
    800059a0:	57fd                	li	a5,-1
    800059a2:	a891                	j	800059f6 <sys_link+0x13c>
    iunlockput(ip);
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	514080e7          	jalr	1300(ra) # 80003eba <iunlockput>
    end_op();
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	d00080e7          	jalr	-768(ra) # 800046ae <end_op>
    return -1;
    800059b6:	57fd                	li	a5,-1
    800059b8:	a83d                	j	800059f6 <sys_link+0x13c>
    iunlockput(dp);
    800059ba:	854a                	mv	a0,s2
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	4fe080e7          	jalr	1278(ra) # 80003eba <iunlockput>
  ilock(ip);
    800059c4:	8526                	mv	a0,s1
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	292080e7          	jalr	658(ra) # 80003c58 <ilock>
  ip->nlink--;
    800059ce:	04a4d783          	lhu	a5,74(s1)
    800059d2:	37fd                	addiw	a5,a5,-1
    800059d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059d8:	8526                	mv	a0,s1
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	1b4080e7          	jalr	436(ra) # 80003b8e <iupdate>
  iunlockput(ip);
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	4d6080e7          	jalr	1238(ra) # 80003eba <iunlockput>
  end_op();
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	cc2080e7          	jalr	-830(ra) # 800046ae <end_op>
  return -1;
    800059f4:	57fd                	li	a5,-1
}
    800059f6:	853e                	mv	a0,a5
    800059f8:	70b2                	ld	ra,296(sp)
    800059fa:	7412                	ld	s0,288(sp)
    800059fc:	64f2                	ld	s1,280(sp)
    800059fe:	6952                	ld	s2,272(sp)
    80005a00:	6155                	addi	sp,sp,304
    80005a02:	8082                	ret

0000000080005a04 <sys_unlink>:
{
    80005a04:	7151                	addi	sp,sp,-240
    80005a06:	f586                	sd	ra,232(sp)
    80005a08:	f1a2                	sd	s0,224(sp)
    80005a0a:	eda6                	sd	s1,216(sp)
    80005a0c:	e9ca                	sd	s2,208(sp)
    80005a0e:	e5ce                	sd	s3,200(sp)
    80005a10:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a12:	08000613          	li	a2,128
    80005a16:	f3040593          	addi	a1,s0,-208
    80005a1a:	4501                	li	a0,0
    80005a1c:	ffffd097          	auipc	ra,0xffffd
    80005a20:	57e080e7          	jalr	1406(ra) # 80002f9a <argstr>
    80005a24:	18054163          	bltz	a0,80005ba6 <sys_unlink+0x1a2>
  begin_op();
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	c06080e7          	jalr	-1018(ra) # 8000462e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a30:	fb040593          	addi	a1,s0,-80
    80005a34:	f3040513          	addi	a0,s0,-208
    80005a38:	fffff097          	auipc	ra,0xfffff
    80005a3c:	9f4080e7          	jalr	-1548(ra) # 8000442c <nameiparent>
    80005a40:	84aa                	mv	s1,a0
    80005a42:	c979                	beqz	a0,80005b18 <sys_unlink+0x114>
  ilock(dp);
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	214080e7          	jalr	532(ra) # 80003c58 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a4c:	00003597          	auipc	a1,0x3
    80005a50:	d1c58593          	addi	a1,a1,-740 # 80008768 <syscalls+0x2c8>
    80005a54:	fb040513          	addi	a0,s0,-80
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	6ca080e7          	jalr	1738(ra) # 80004122 <namecmp>
    80005a60:	14050a63          	beqz	a0,80005bb4 <sys_unlink+0x1b0>
    80005a64:	00003597          	auipc	a1,0x3
    80005a68:	d0c58593          	addi	a1,a1,-756 # 80008770 <syscalls+0x2d0>
    80005a6c:	fb040513          	addi	a0,s0,-80
    80005a70:	ffffe097          	auipc	ra,0xffffe
    80005a74:	6b2080e7          	jalr	1714(ra) # 80004122 <namecmp>
    80005a78:	12050e63          	beqz	a0,80005bb4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a7c:	f2c40613          	addi	a2,s0,-212
    80005a80:	fb040593          	addi	a1,s0,-80
    80005a84:	8526                	mv	a0,s1
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	6b6080e7          	jalr	1718(ra) # 8000413c <dirlookup>
    80005a8e:	892a                	mv	s2,a0
    80005a90:	12050263          	beqz	a0,80005bb4 <sys_unlink+0x1b0>
  ilock(ip);
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	1c4080e7          	jalr	452(ra) # 80003c58 <ilock>
  if(ip->nlink < 1)
    80005a9c:	04a91783          	lh	a5,74(s2)
    80005aa0:	08f05263          	blez	a5,80005b24 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005aa4:	04491703          	lh	a4,68(s2)
    80005aa8:	4785                	li	a5,1
    80005aaa:	08f70563          	beq	a4,a5,80005b34 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005aae:	4641                	li	a2,16
    80005ab0:	4581                	li	a1,0
    80005ab2:	fc040513          	addi	a0,s0,-64
    80005ab6:	ffffb097          	auipc	ra,0xffffb
    80005aba:	208080e7          	jalr	520(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005abe:	4741                	li	a4,16
    80005ac0:	f2c42683          	lw	a3,-212(s0)
    80005ac4:	fc040613          	addi	a2,s0,-64
    80005ac8:	4581                	li	a1,0
    80005aca:	8526                	mv	a0,s1
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	538080e7          	jalr	1336(ra) # 80004004 <writei>
    80005ad4:	47c1                	li	a5,16
    80005ad6:	0af51563          	bne	a0,a5,80005b80 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005ada:	04491703          	lh	a4,68(s2)
    80005ade:	4785                	li	a5,1
    80005ae0:	0af70863          	beq	a4,a5,80005b90 <sys_unlink+0x18c>
  iunlockput(dp);
    80005ae4:	8526                	mv	a0,s1
    80005ae6:	ffffe097          	auipc	ra,0xffffe
    80005aea:	3d4080e7          	jalr	980(ra) # 80003eba <iunlockput>
  ip->nlink--;
    80005aee:	04a95783          	lhu	a5,74(s2)
    80005af2:	37fd                	addiw	a5,a5,-1
    80005af4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005af8:	854a                	mv	a0,s2
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	094080e7          	jalr	148(ra) # 80003b8e <iupdate>
  iunlockput(ip);
    80005b02:	854a                	mv	a0,s2
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	3b6080e7          	jalr	950(ra) # 80003eba <iunlockput>
  end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	ba2080e7          	jalr	-1118(ra) # 800046ae <end_op>
  return 0;
    80005b14:	4501                	li	a0,0
    80005b16:	a84d                	j	80005bc8 <sys_unlink+0x1c4>
    end_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	b96080e7          	jalr	-1130(ra) # 800046ae <end_op>
    return -1;
    80005b20:	557d                	li	a0,-1
    80005b22:	a05d                	j	80005bc8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b24:	00003517          	auipc	a0,0x3
    80005b28:	c7450513          	addi	a0,a0,-908 # 80008798 <syscalls+0x2f8>
    80005b2c:	ffffb097          	auipc	ra,0xffffb
    80005b30:	9fe080e7          	jalr	-1538(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b34:	04c92703          	lw	a4,76(s2)
    80005b38:	02000793          	li	a5,32
    80005b3c:	f6e7f9e3          	bgeu	a5,a4,80005aae <sys_unlink+0xaa>
    80005b40:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b44:	4741                	li	a4,16
    80005b46:	86ce                	mv	a3,s3
    80005b48:	f1840613          	addi	a2,s0,-232
    80005b4c:	4581                	li	a1,0
    80005b4e:	854a                	mv	a0,s2
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	3bc080e7          	jalr	956(ra) # 80003f0c <readi>
    80005b58:	47c1                	li	a5,16
    80005b5a:	00f51b63          	bne	a0,a5,80005b70 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b5e:	f1845783          	lhu	a5,-232(s0)
    80005b62:	e7a1                	bnez	a5,80005baa <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b64:	29c1                	addiw	s3,s3,16
    80005b66:	04c92783          	lw	a5,76(s2)
    80005b6a:	fcf9ede3          	bltu	s3,a5,80005b44 <sys_unlink+0x140>
    80005b6e:	b781                	j	80005aae <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b70:	00003517          	auipc	a0,0x3
    80005b74:	c4050513          	addi	a0,a0,-960 # 800087b0 <syscalls+0x310>
    80005b78:	ffffb097          	auipc	ra,0xffffb
    80005b7c:	9b2080e7          	jalr	-1614(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005b80:	00003517          	auipc	a0,0x3
    80005b84:	c4850513          	addi	a0,a0,-952 # 800087c8 <syscalls+0x328>
    80005b88:	ffffb097          	auipc	ra,0xffffb
    80005b8c:	9a2080e7          	jalr	-1630(ra) # 8000052a <panic>
    dp->nlink--;
    80005b90:	04a4d783          	lhu	a5,74(s1)
    80005b94:	37fd                	addiw	a5,a5,-1
    80005b96:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b9a:	8526                	mv	a0,s1
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	ff2080e7          	jalr	-14(ra) # 80003b8e <iupdate>
    80005ba4:	b781                	j	80005ae4 <sys_unlink+0xe0>
    return -1;
    80005ba6:	557d                	li	a0,-1
    80005ba8:	a005                	j	80005bc8 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005baa:	854a                	mv	a0,s2
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	30e080e7          	jalr	782(ra) # 80003eba <iunlockput>
  iunlockput(dp);
    80005bb4:	8526                	mv	a0,s1
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	304080e7          	jalr	772(ra) # 80003eba <iunlockput>
  end_op();
    80005bbe:	fffff097          	auipc	ra,0xfffff
    80005bc2:	af0080e7          	jalr	-1296(ra) # 800046ae <end_op>
  return -1;
    80005bc6:	557d                	li	a0,-1
}
    80005bc8:	70ae                	ld	ra,232(sp)
    80005bca:	740e                	ld	s0,224(sp)
    80005bcc:	64ee                	ld	s1,216(sp)
    80005bce:	694e                	ld	s2,208(sp)
    80005bd0:	69ae                	ld	s3,200(sp)
    80005bd2:	616d                	addi	sp,sp,240
    80005bd4:	8082                	ret

0000000080005bd6 <sys_open>:

uint64
sys_open(void)
{
    80005bd6:	7131                	addi	sp,sp,-192
    80005bd8:	fd06                	sd	ra,184(sp)
    80005bda:	f922                	sd	s0,176(sp)
    80005bdc:	f526                	sd	s1,168(sp)
    80005bde:	f14a                	sd	s2,160(sp)
    80005be0:	ed4e                	sd	s3,152(sp)
    80005be2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005be4:	08000613          	li	a2,128
    80005be8:	f5040593          	addi	a1,s0,-176
    80005bec:	4501                	li	a0,0
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	3ac080e7          	jalr	940(ra) # 80002f9a <argstr>
    return -1;
    80005bf6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005bf8:	0c054163          	bltz	a0,80005cba <sys_open+0xe4>
    80005bfc:	f4c40593          	addi	a1,s0,-180
    80005c00:	4505                	li	a0,1
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	354080e7          	jalr	852(ra) # 80002f56 <argint>
    80005c0a:	0a054863          	bltz	a0,80005cba <sys_open+0xe4>

  begin_op();
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	a20080e7          	jalr	-1504(ra) # 8000462e <begin_op>

  if(omode & O_CREATE){
    80005c16:	f4c42783          	lw	a5,-180(s0)
    80005c1a:	2007f793          	andi	a5,a5,512
    80005c1e:	cbdd                	beqz	a5,80005cd4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c20:	4681                	li	a3,0
    80005c22:	4601                	li	a2,0
    80005c24:	4589                	li	a1,2
    80005c26:	f5040513          	addi	a0,s0,-176
    80005c2a:	00000097          	auipc	ra,0x0
    80005c2e:	974080e7          	jalr	-1676(ra) # 8000559e <create>
    80005c32:	892a                	mv	s2,a0
    if(ip == 0){
    80005c34:	c959                	beqz	a0,80005cca <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c36:	04491703          	lh	a4,68(s2)
    80005c3a:	478d                	li	a5,3
    80005c3c:	00f71763          	bne	a4,a5,80005c4a <sys_open+0x74>
    80005c40:	04695703          	lhu	a4,70(s2)
    80005c44:	47a5                	li	a5,9
    80005c46:	0ce7ec63          	bltu	a5,a4,80005d1e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	df4080e7          	jalr	-524(ra) # 80004a3e <filealloc>
    80005c52:	89aa                	mv	s3,a0
    80005c54:	10050263          	beqz	a0,80005d58 <sys_open+0x182>
    80005c58:	00000097          	auipc	ra,0x0
    80005c5c:	904080e7          	jalr	-1788(ra) # 8000555c <fdalloc>
    80005c60:	84aa                	mv	s1,a0
    80005c62:	0e054663          	bltz	a0,80005d4e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c66:	04491703          	lh	a4,68(s2)
    80005c6a:	478d                	li	a5,3
    80005c6c:	0cf70463          	beq	a4,a5,80005d34 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c70:	4789                	li	a5,2
    80005c72:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c76:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c7a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c7e:	f4c42783          	lw	a5,-180(s0)
    80005c82:	0017c713          	xori	a4,a5,1
    80005c86:	8b05                	andi	a4,a4,1
    80005c88:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c8c:	0037f713          	andi	a4,a5,3
    80005c90:	00e03733          	snez	a4,a4
    80005c94:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c98:	4007f793          	andi	a5,a5,1024
    80005c9c:	c791                	beqz	a5,80005ca8 <sys_open+0xd2>
    80005c9e:	04491703          	lh	a4,68(s2)
    80005ca2:	4789                	li	a5,2
    80005ca4:	08f70f63          	beq	a4,a5,80005d42 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005ca8:	854a                	mv	a0,s2
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	070080e7          	jalr	112(ra) # 80003d1a <iunlock>
  end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	9fc080e7          	jalr	-1540(ra) # 800046ae <end_op>

  return fd;
}
    80005cba:	8526                	mv	a0,s1
    80005cbc:	70ea                	ld	ra,184(sp)
    80005cbe:	744a                	ld	s0,176(sp)
    80005cc0:	74aa                	ld	s1,168(sp)
    80005cc2:	790a                	ld	s2,160(sp)
    80005cc4:	69ea                	ld	s3,152(sp)
    80005cc6:	6129                	addi	sp,sp,192
    80005cc8:	8082                	ret
      end_op();
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	9e4080e7          	jalr	-1564(ra) # 800046ae <end_op>
      return -1;
    80005cd2:	b7e5                	j	80005cba <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005cd4:	f5040513          	addi	a0,s0,-176
    80005cd8:	ffffe097          	auipc	ra,0xffffe
    80005cdc:	736080e7          	jalr	1846(ra) # 8000440e <namei>
    80005ce0:	892a                	mv	s2,a0
    80005ce2:	c905                	beqz	a0,80005d12 <sys_open+0x13c>
    ilock(ip);
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	f74080e7          	jalr	-140(ra) # 80003c58 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cec:	04491703          	lh	a4,68(s2)
    80005cf0:	4785                	li	a5,1
    80005cf2:	f4f712e3          	bne	a4,a5,80005c36 <sys_open+0x60>
    80005cf6:	f4c42783          	lw	a5,-180(s0)
    80005cfa:	dba1                	beqz	a5,80005c4a <sys_open+0x74>
      iunlockput(ip);
    80005cfc:	854a                	mv	a0,s2
    80005cfe:	ffffe097          	auipc	ra,0xffffe
    80005d02:	1bc080e7          	jalr	444(ra) # 80003eba <iunlockput>
      end_op();
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	9a8080e7          	jalr	-1624(ra) # 800046ae <end_op>
      return -1;
    80005d0e:	54fd                	li	s1,-1
    80005d10:	b76d                	j	80005cba <sys_open+0xe4>
      end_op();
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	99c080e7          	jalr	-1636(ra) # 800046ae <end_op>
      return -1;
    80005d1a:	54fd                	li	s1,-1
    80005d1c:	bf79                	j	80005cba <sys_open+0xe4>
    iunlockput(ip);
    80005d1e:	854a                	mv	a0,s2
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	19a080e7          	jalr	410(ra) # 80003eba <iunlockput>
    end_op();
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	986080e7          	jalr	-1658(ra) # 800046ae <end_op>
    return -1;
    80005d30:	54fd                	li	s1,-1
    80005d32:	b761                	j	80005cba <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d34:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d38:	04691783          	lh	a5,70(s2)
    80005d3c:	02f99223          	sh	a5,36(s3)
    80005d40:	bf2d                	j	80005c7a <sys_open+0xa4>
    itrunc(ip);
    80005d42:	854a                	mv	a0,s2
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	022080e7          	jalr	34(ra) # 80003d66 <itrunc>
    80005d4c:	bfb1                	j	80005ca8 <sys_open+0xd2>
      fileclose(f);
    80005d4e:	854e                	mv	a0,s3
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	daa080e7          	jalr	-598(ra) # 80004afa <fileclose>
    iunlockput(ip);
    80005d58:	854a                	mv	a0,s2
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	160080e7          	jalr	352(ra) # 80003eba <iunlockput>
    end_op();
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	94c080e7          	jalr	-1716(ra) # 800046ae <end_op>
    return -1;
    80005d6a:	54fd                	li	s1,-1
    80005d6c:	b7b9                	j	80005cba <sys_open+0xe4>

0000000080005d6e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d6e:	7175                	addi	sp,sp,-144
    80005d70:	e506                	sd	ra,136(sp)
    80005d72:	e122                	sd	s0,128(sp)
    80005d74:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	8b8080e7          	jalr	-1864(ra) # 8000462e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d7e:	08000613          	li	a2,128
    80005d82:	f7040593          	addi	a1,s0,-144
    80005d86:	4501                	li	a0,0
    80005d88:	ffffd097          	auipc	ra,0xffffd
    80005d8c:	212080e7          	jalr	530(ra) # 80002f9a <argstr>
    80005d90:	02054963          	bltz	a0,80005dc2 <sys_mkdir+0x54>
    80005d94:	4681                	li	a3,0
    80005d96:	4601                	li	a2,0
    80005d98:	4585                	li	a1,1
    80005d9a:	f7040513          	addi	a0,s0,-144
    80005d9e:	00000097          	auipc	ra,0x0
    80005da2:	800080e7          	jalr	-2048(ra) # 8000559e <create>
    80005da6:	cd11                	beqz	a0,80005dc2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005da8:	ffffe097          	auipc	ra,0xffffe
    80005dac:	112080e7          	jalr	274(ra) # 80003eba <iunlockput>
  end_op();
    80005db0:	fffff097          	auipc	ra,0xfffff
    80005db4:	8fe080e7          	jalr	-1794(ra) # 800046ae <end_op>
  return 0;
    80005db8:	4501                	li	a0,0
}
    80005dba:	60aa                	ld	ra,136(sp)
    80005dbc:	640a                	ld	s0,128(sp)
    80005dbe:	6149                	addi	sp,sp,144
    80005dc0:	8082                	ret
    end_op();
    80005dc2:	fffff097          	auipc	ra,0xfffff
    80005dc6:	8ec080e7          	jalr	-1812(ra) # 800046ae <end_op>
    return -1;
    80005dca:	557d                	li	a0,-1
    80005dcc:	b7fd                	j	80005dba <sys_mkdir+0x4c>

0000000080005dce <sys_mknod>:

uint64
sys_mknod(void)
{
    80005dce:	7135                	addi	sp,sp,-160
    80005dd0:	ed06                	sd	ra,152(sp)
    80005dd2:	e922                	sd	s0,144(sp)
    80005dd4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	858080e7          	jalr	-1960(ra) # 8000462e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dde:	08000613          	li	a2,128
    80005de2:	f7040593          	addi	a1,s0,-144
    80005de6:	4501                	li	a0,0
    80005de8:	ffffd097          	auipc	ra,0xffffd
    80005dec:	1b2080e7          	jalr	434(ra) # 80002f9a <argstr>
    80005df0:	04054a63          	bltz	a0,80005e44 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005df4:	f6c40593          	addi	a1,s0,-148
    80005df8:	4505                	li	a0,1
    80005dfa:	ffffd097          	auipc	ra,0xffffd
    80005dfe:	15c080e7          	jalr	348(ra) # 80002f56 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e02:	04054163          	bltz	a0,80005e44 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e06:	f6840593          	addi	a1,s0,-152
    80005e0a:	4509                	li	a0,2
    80005e0c:	ffffd097          	auipc	ra,0xffffd
    80005e10:	14a080e7          	jalr	330(ra) # 80002f56 <argint>
     argint(1, &major) < 0 ||
    80005e14:	02054863          	bltz	a0,80005e44 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e18:	f6841683          	lh	a3,-152(s0)
    80005e1c:	f6c41603          	lh	a2,-148(s0)
    80005e20:	458d                	li	a1,3
    80005e22:	f7040513          	addi	a0,s0,-144
    80005e26:	fffff097          	auipc	ra,0xfffff
    80005e2a:	778080e7          	jalr	1912(ra) # 8000559e <create>
     argint(2, &minor) < 0 ||
    80005e2e:	c919                	beqz	a0,80005e44 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e30:	ffffe097          	auipc	ra,0xffffe
    80005e34:	08a080e7          	jalr	138(ra) # 80003eba <iunlockput>
  end_op();
    80005e38:	fffff097          	auipc	ra,0xfffff
    80005e3c:	876080e7          	jalr	-1930(ra) # 800046ae <end_op>
  return 0;
    80005e40:	4501                	li	a0,0
    80005e42:	a031                	j	80005e4e <sys_mknod+0x80>
    end_op();
    80005e44:	fffff097          	auipc	ra,0xfffff
    80005e48:	86a080e7          	jalr	-1942(ra) # 800046ae <end_op>
    return -1;
    80005e4c:	557d                	li	a0,-1
}
    80005e4e:	60ea                	ld	ra,152(sp)
    80005e50:	644a                	ld	s0,144(sp)
    80005e52:	610d                	addi	sp,sp,160
    80005e54:	8082                	ret

0000000080005e56 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e56:	7135                	addi	sp,sp,-160
    80005e58:	ed06                	sd	ra,152(sp)
    80005e5a:	e922                	sd	s0,144(sp)
    80005e5c:	e526                	sd	s1,136(sp)
    80005e5e:	e14a                	sd	s2,128(sp)
    80005e60:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e62:	ffffc097          	auipc	ra,0xffffc
    80005e66:	b1c080e7          	jalr	-1252(ra) # 8000197e <myproc>
    80005e6a:	892a                	mv	s2,a0
  
  begin_op();
    80005e6c:	ffffe097          	auipc	ra,0xffffe
    80005e70:	7c2080e7          	jalr	1986(ra) # 8000462e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e74:	08000613          	li	a2,128
    80005e78:	f6040593          	addi	a1,s0,-160
    80005e7c:	4501                	li	a0,0
    80005e7e:	ffffd097          	auipc	ra,0xffffd
    80005e82:	11c080e7          	jalr	284(ra) # 80002f9a <argstr>
    80005e86:	04054b63          	bltz	a0,80005edc <sys_chdir+0x86>
    80005e8a:	f6040513          	addi	a0,s0,-160
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	580080e7          	jalr	1408(ra) # 8000440e <namei>
    80005e96:	84aa                	mv	s1,a0
    80005e98:	c131                	beqz	a0,80005edc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e9a:	ffffe097          	auipc	ra,0xffffe
    80005e9e:	dbe080e7          	jalr	-578(ra) # 80003c58 <ilock>
  if(ip->type != T_DIR){
    80005ea2:	04449703          	lh	a4,68(s1)
    80005ea6:	4785                	li	a5,1
    80005ea8:	04f71063          	bne	a4,a5,80005ee8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005eac:	8526                	mv	a0,s1
    80005eae:	ffffe097          	auipc	ra,0xffffe
    80005eb2:	e6c080e7          	jalr	-404(ra) # 80003d1a <iunlock>
  iput(p->cwd);
    80005eb6:	15093503          	ld	a0,336(s2)
    80005eba:	ffffe097          	auipc	ra,0xffffe
    80005ebe:	f58080e7          	jalr	-168(ra) # 80003e12 <iput>
  end_op();
    80005ec2:	ffffe097          	auipc	ra,0xffffe
    80005ec6:	7ec080e7          	jalr	2028(ra) # 800046ae <end_op>
  p->cwd = ip;
    80005eca:	14993823          	sd	s1,336(s2)
  return 0;
    80005ece:	4501                	li	a0,0
}
    80005ed0:	60ea                	ld	ra,152(sp)
    80005ed2:	644a                	ld	s0,144(sp)
    80005ed4:	64aa                	ld	s1,136(sp)
    80005ed6:	690a                	ld	s2,128(sp)
    80005ed8:	610d                	addi	sp,sp,160
    80005eda:	8082                	ret
    end_op();
    80005edc:	ffffe097          	auipc	ra,0xffffe
    80005ee0:	7d2080e7          	jalr	2002(ra) # 800046ae <end_op>
    return -1;
    80005ee4:	557d                	li	a0,-1
    80005ee6:	b7ed                	j	80005ed0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ee8:	8526                	mv	a0,s1
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	fd0080e7          	jalr	-48(ra) # 80003eba <iunlockput>
    end_op();
    80005ef2:	ffffe097          	auipc	ra,0xffffe
    80005ef6:	7bc080e7          	jalr	1980(ra) # 800046ae <end_op>
    return -1;
    80005efa:	557d                	li	a0,-1
    80005efc:	bfd1                	j	80005ed0 <sys_chdir+0x7a>

0000000080005efe <sys_exec>:

uint64
sys_exec(void)
{
    80005efe:	7145                	addi	sp,sp,-464
    80005f00:	e786                	sd	ra,456(sp)
    80005f02:	e3a2                	sd	s0,448(sp)
    80005f04:	ff26                	sd	s1,440(sp)
    80005f06:	fb4a                	sd	s2,432(sp)
    80005f08:	f74e                	sd	s3,424(sp)
    80005f0a:	f352                	sd	s4,416(sp)
    80005f0c:	ef56                	sd	s5,408(sp)
    80005f0e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f10:	08000613          	li	a2,128
    80005f14:	f4040593          	addi	a1,s0,-192
    80005f18:	4501                	li	a0,0
    80005f1a:	ffffd097          	auipc	ra,0xffffd
    80005f1e:	080080e7          	jalr	128(ra) # 80002f9a <argstr>
    return -1;
    80005f22:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f24:	0c054a63          	bltz	a0,80005ff8 <sys_exec+0xfa>
    80005f28:	e3840593          	addi	a1,s0,-456
    80005f2c:	4505                	li	a0,1
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	04a080e7          	jalr	74(ra) # 80002f78 <argaddr>
    80005f36:	0c054163          	bltz	a0,80005ff8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f3a:	10000613          	li	a2,256
    80005f3e:	4581                	li	a1,0
    80005f40:	e4040513          	addi	a0,s0,-448
    80005f44:	ffffb097          	auipc	ra,0xffffb
    80005f48:	d7a080e7          	jalr	-646(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f4c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f50:	89a6                	mv	s3,s1
    80005f52:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f54:	02000a13          	li	s4,32
    80005f58:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f5c:	00391793          	slli	a5,s2,0x3
    80005f60:	e3040593          	addi	a1,s0,-464
    80005f64:	e3843503          	ld	a0,-456(s0)
    80005f68:	953e                	add	a0,a0,a5
    80005f6a:	ffffd097          	auipc	ra,0xffffd
    80005f6e:	f52080e7          	jalr	-174(ra) # 80002ebc <fetchaddr>
    80005f72:	02054a63          	bltz	a0,80005fa6 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005f76:	e3043783          	ld	a5,-464(s0)
    80005f7a:	c3b9                	beqz	a5,80005fc0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f7c:	ffffb097          	auipc	ra,0xffffb
    80005f80:	b56080e7          	jalr	-1194(ra) # 80000ad2 <kalloc>
    80005f84:	85aa                	mv	a1,a0
    80005f86:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f8a:	cd11                	beqz	a0,80005fa6 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f8c:	6605                	lui	a2,0x1
    80005f8e:	e3043503          	ld	a0,-464(s0)
    80005f92:	ffffd097          	auipc	ra,0xffffd
    80005f96:	f7c080e7          	jalr	-132(ra) # 80002f0e <fetchstr>
    80005f9a:	00054663          	bltz	a0,80005fa6 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005f9e:	0905                	addi	s2,s2,1
    80005fa0:	09a1                	addi	s3,s3,8
    80005fa2:	fb491be3          	bne	s2,s4,80005f58 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fa6:	10048913          	addi	s2,s1,256
    80005faa:	6088                	ld	a0,0(s1)
    80005fac:	c529                	beqz	a0,80005ff6 <sys_exec+0xf8>
    kfree(argv[i]);
    80005fae:	ffffb097          	auipc	ra,0xffffb
    80005fb2:	a28080e7          	jalr	-1496(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fb6:	04a1                	addi	s1,s1,8
    80005fb8:	ff2499e3          	bne	s1,s2,80005faa <sys_exec+0xac>
  return -1;
    80005fbc:	597d                	li	s2,-1
    80005fbe:	a82d                	j	80005ff8 <sys_exec+0xfa>
      argv[i] = 0;
    80005fc0:	0a8e                	slli	s5,s5,0x3
    80005fc2:	fc040793          	addi	a5,s0,-64
    80005fc6:	9abe                	add	s5,s5,a5
    80005fc8:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005fcc:	e4040593          	addi	a1,s0,-448
    80005fd0:	f4040513          	addi	a0,s0,-192
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	178080e7          	jalr	376(ra) # 8000514c <exec>
    80005fdc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fde:	10048993          	addi	s3,s1,256
    80005fe2:	6088                	ld	a0,0(s1)
    80005fe4:	c911                	beqz	a0,80005ff8 <sys_exec+0xfa>
    kfree(argv[i]);
    80005fe6:	ffffb097          	auipc	ra,0xffffb
    80005fea:	9f0080e7          	jalr	-1552(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fee:	04a1                	addi	s1,s1,8
    80005ff0:	ff3499e3          	bne	s1,s3,80005fe2 <sys_exec+0xe4>
    80005ff4:	a011                	j	80005ff8 <sys_exec+0xfa>
  return -1;
    80005ff6:	597d                	li	s2,-1
}
    80005ff8:	854a                	mv	a0,s2
    80005ffa:	60be                	ld	ra,456(sp)
    80005ffc:	641e                	ld	s0,448(sp)
    80005ffe:	74fa                	ld	s1,440(sp)
    80006000:	795a                	ld	s2,432(sp)
    80006002:	79ba                	ld	s3,424(sp)
    80006004:	7a1a                	ld	s4,416(sp)
    80006006:	6afa                	ld	s5,408(sp)
    80006008:	6179                	addi	sp,sp,464
    8000600a:	8082                	ret

000000008000600c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000600c:	7139                	addi	sp,sp,-64
    8000600e:	fc06                	sd	ra,56(sp)
    80006010:	f822                	sd	s0,48(sp)
    80006012:	f426                	sd	s1,40(sp)
    80006014:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006016:	ffffc097          	auipc	ra,0xffffc
    8000601a:	968080e7          	jalr	-1688(ra) # 8000197e <myproc>
    8000601e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006020:	fd840593          	addi	a1,s0,-40
    80006024:	4501                	li	a0,0
    80006026:	ffffd097          	auipc	ra,0xffffd
    8000602a:	f52080e7          	jalr	-174(ra) # 80002f78 <argaddr>
    return -1;
    8000602e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006030:	0e054063          	bltz	a0,80006110 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006034:	fc840593          	addi	a1,s0,-56
    80006038:	fd040513          	addi	a0,s0,-48
    8000603c:	fffff097          	auipc	ra,0xfffff
    80006040:	dee080e7          	jalr	-530(ra) # 80004e2a <pipealloc>
    return -1;
    80006044:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006046:	0c054563          	bltz	a0,80006110 <sys_pipe+0x104>
  fd0 = -1;
    8000604a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000604e:	fd043503          	ld	a0,-48(s0)
    80006052:	fffff097          	auipc	ra,0xfffff
    80006056:	50a080e7          	jalr	1290(ra) # 8000555c <fdalloc>
    8000605a:	fca42223          	sw	a0,-60(s0)
    8000605e:	08054c63          	bltz	a0,800060f6 <sys_pipe+0xea>
    80006062:	fc843503          	ld	a0,-56(s0)
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	4f6080e7          	jalr	1270(ra) # 8000555c <fdalloc>
    8000606e:	fca42023          	sw	a0,-64(s0)
    80006072:	06054863          	bltz	a0,800060e2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006076:	4691                	li	a3,4
    80006078:	fc440613          	addi	a2,s0,-60
    8000607c:	fd843583          	ld	a1,-40(s0)
    80006080:	68a8                	ld	a0,80(s1)
    80006082:	ffffb097          	auipc	ra,0xffffb
    80006086:	5bc080e7          	jalr	1468(ra) # 8000163e <copyout>
    8000608a:	02054063          	bltz	a0,800060aa <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000608e:	4691                	li	a3,4
    80006090:	fc040613          	addi	a2,s0,-64
    80006094:	fd843583          	ld	a1,-40(s0)
    80006098:	0591                	addi	a1,a1,4
    8000609a:	68a8                	ld	a0,80(s1)
    8000609c:	ffffb097          	auipc	ra,0xffffb
    800060a0:	5a2080e7          	jalr	1442(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060a4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060a6:	06055563          	bgez	a0,80006110 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800060aa:	fc442783          	lw	a5,-60(s0)
    800060ae:	07e9                	addi	a5,a5,26
    800060b0:	078e                	slli	a5,a5,0x3
    800060b2:	97a6                	add	a5,a5,s1
    800060b4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060b8:	fc042503          	lw	a0,-64(s0)
    800060bc:	0569                	addi	a0,a0,26
    800060be:	050e                	slli	a0,a0,0x3
    800060c0:	9526                	add	a0,a0,s1
    800060c2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800060c6:	fd043503          	ld	a0,-48(s0)
    800060ca:	fffff097          	auipc	ra,0xfffff
    800060ce:	a30080e7          	jalr	-1488(ra) # 80004afa <fileclose>
    fileclose(wf);
    800060d2:	fc843503          	ld	a0,-56(s0)
    800060d6:	fffff097          	auipc	ra,0xfffff
    800060da:	a24080e7          	jalr	-1500(ra) # 80004afa <fileclose>
    return -1;
    800060de:	57fd                	li	a5,-1
    800060e0:	a805                	j	80006110 <sys_pipe+0x104>
    if(fd0 >= 0)
    800060e2:	fc442783          	lw	a5,-60(s0)
    800060e6:	0007c863          	bltz	a5,800060f6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800060ea:	01a78513          	addi	a0,a5,26
    800060ee:	050e                	slli	a0,a0,0x3
    800060f0:	9526                	add	a0,a0,s1
    800060f2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800060f6:	fd043503          	ld	a0,-48(s0)
    800060fa:	fffff097          	auipc	ra,0xfffff
    800060fe:	a00080e7          	jalr	-1536(ra) # 80004afa <fileclose>
    fileclose(wf);
    80006102:	fc843503          	ld	a0,-56(s0)
    80006106:	fffff097          	auipc	ra,0xfffff
    8000610a:	9f4080e7          	jalr	-1548(ra) # 80004afa <fileclose>
    return -1;
    8000610e:	57fd                	li	a5,-1
}
    80006110:	853e                	mv	a0,a5
    80006112:	70e2                	ld	ra,56(sp)
    80006114:	7442                	ld	s0,48(sp)
    80006116:	74a2                	ld	s1,40(sp)
    80006118:	6121                	addi	sp,sp,64
    8000611a:	8082                	ret
    8000611c:	0000                	unimp
	...

0000000080006120 <kernelvec>:
    80006120:	7111                	addi	sp,sp,-256
    80006122:	e006                	sd	ra,0(sp)
    80006124:	e40a                	sd	sp,8(sp)
    80006126:	e80e                	sd	gp,16(sp)
    80006128:	ec12                	sd	tp,24(sp)
    8000612a:	f016                	sd	t0,32(sp)
    8000612c:	f41a                	sd	t1,40(sp)
    8000612e:	f81e                	sd	t2,48(sp)
    80006130:	fc22                	sd	s0,56(sp)
    80006132:	e0a6                	sd	s1,64(sp)
    80006134:	e4aa                	sd	a0,72(sp)
    80006136:	e8ae                	sd	a1,80(sp)
    80006138:	ecb2                	sd	a2,88(sp)
    8000613a:	f0b6                	sd	a3,96(sp)
    8000613c:	f4ba                	sd	a4,104(sp)
    8000613e:	f8be                	sd	a5,112(sp)
    80006140:	fcc2                	sd	a6,120(sp)
    80006142:	e146                	sd	a7,128(sp)
    80006144:	e54a                	sd	s2,136(sp)
    80006146:	e94e                	sd	s3,144(sp)
    80006148:	ed52                	sd	s4,152(sp)
    8000614a:	f156                	sd	s5,160(sp)
    8000614c:	f55a                	sd	s6,168(sp)
    8000614e:	f95e                	sd	s7,176(sp)
    80006150:	fd62                	sd	s8,184(sp)
    80006152:	e1e6                	sd	s9,192(sp)
    80006154:	e5ea                	sd	s10,200(sp)
    80006156:	e9ee                	sd	s11,208(sp)
    80006158:	edf2                	sd	t3,216(sp)
    8000615a:	f1f6                	sd	t4,224(sp)
    8000615c:	f5fa                	sd	t5,232(sp)
    8000615e:	f9fe                	sd	t6,240(sp)
    80006160:	c29fc0ef          	jal	ra,80002d88 <kerneltrap>
    80006164:	6082                	ld	ra,0(sp)
    80006166:	6122                	ld	sp,8(sp)
    80006168:	61c2                	ld	gp,16(sp)
    8000616a:	7282                	ld	t0,32(sp)
    8000616c:	7322                	ld	t1,40(sp)
    8000616e:	73c2                	ld	t2,48(sp)
    80006170:	7462                	ld	s0,56(sp)
    80006172:	6486                	ld	s1,64(sp)
    80006174:	6526                	ld	a0,72(sp)
    80006176:	65c6                	ld	a1,80(sp)
    80006178:	6666                	ld	a2,88(sp)
    8000617a:	7686                	ld	a3,96(sp)
    8000617c:	7726                	ld	a4,104(sp)
    8000617e:	77c6                	ld	a5,112(sp)
    80006180:	7866                	ld	a6,120(sp)
    80006182:	688a                	ld	a7,128(sp)
    80006184:	692a                	ld	s2,136(sp)
    80006186:	69ca                	ld	s3,144(sp)
    80006188:	6a6a                	ld	s4,152(sp)
    8000618a:	7a8a                	ld	s5,160(sp)
    8000618c:	7b2a                	ld	s6,168(sp)
    8000618e:	7bca                	ld	s7,176(sp)
    80006190:	7c6a                	ld	s8,184(sp)
    80006192:	6c8e                	ld	s9,192(sp)
    80006194:	6d2e                	ld	s10,200(sp)
    80006196:	6dce                	ld	s11,208(sp)
    80006198:	6e6e                	ld	t3,216(sp)
    8000619a:	7e8e                	ld	t4,224(sp)
    8000619c:	7f2e                	ld	t5,232(sp)
    8000619e:	7fce                	ld	t6,240(sp)
    800061a0:	6111                	addi	sp,sp,256
    800061a2:	10200073          	sret
    800061a6:	00000013          	nop
    800061aa:	00000013          	nop
    800061ae:	0001                	nop

00000000800061b0 <timervec>:
    800061b0:	34051573          	csrrw	a0,mscratch,a0
    800061b4:	e10c                	sd	a1,0(a0)
    800061b6:	e510                	sd	a2,8(a0)
    800061b8:	e914                	sd	a3,16(a0)
    800061ba:	6d0c                	ld	a1,24(a0)
    800061bc:	7110                	ld	a2,32(a0)
    800061be:	6194                	ld	a3,0(a1)
    800061c0:	96b2                	add	a3,a3,a2
    800061c2:	e194                	sd	a3,0(a1)
    800061c4:	4589                	li	a1,2
    800061c6:	14459073          	csrw	sip,a1
    800061ca:	6914                	ld	a3,16(a0)
    800061cc:	6510                	ld	a2,8(a0)
    800061ce:	610c                	ld	a1,0(a0)
    800061d0:	34051573          	csrrw	a0,mscratch,a0
    800061d4:	30200073          	mret
	...

00000000800061da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061da:	1141                	addi	sp,sp,-16
    800061dc:	e422                	sd	s0,8(sp)
    800061de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061e0:	0c0007b7          	lui	a5,0xc000
    800061e4:	4705                	li	a4,1
    800061e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061e8:	c3d8                	sw	a4,4(a5)
}
    800061ea:	6422                	ld	s0,8(sp)
    800061ec:	0141                	addi	sp,sp,16
    800061ee:	8082                	ret

00000000800061f0 <plicinithart>:

void
plicinithart(void)
{
    800061f0:	1141                	addi	sp,sp,-16
    800061f2:	e406                	sd	ra,8(sp)
    800061f4:	e022                	sd	s0,0(sp)
    800061f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061f8:	ffffb097          	auipc	ra,0xffffb
    800061fc:	75a080e7          	jalr	1882(ra) # 80001952 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006200:	0085171b          	slliw	a4,a0,0x8
    80006204:	0c0027b7          	lui	a5,0xc002
    80006208:	97ba                	add	a5,a5,a4
    8000620a:	40200713          	li	a4,1026
    8000620e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006212:	00d5151b          	slliw	a0,a0,0xd
    80006216:	0c2017b7          	lui	a5,0xc201
    8000621a:	953e                	add	a0,a0,a5
    8000621c:	00052023          	sw	zero,0(a0)
}
    80006220:	60a2                	ld	ra,8(sp)
    80006222:	6402                	ld	s0,0(sp)
    80006224:	0141                	addi	sp,sp,16
    80006226:	8082                	ret

0000000080006228 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006228:	1141                	addi	sp,sp,-16
    8000622a:	e406                	sd	ra,8(sp)
    8000622c:	e022                	sd	s0,0(sp)
    8000622e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006230:	ffffb097          	auipc	ra,0xffffb
    80006234:	722080e7          	jalr	1826(ra) # 80001952 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006238:	00d5179b          	slliw	a5,a0,0xd
    8000623c:	0c201537          	lui	a0,0xc201
    80006240:	953e                	add	a0,a0,a5
  return irq;
}
    80006242:	4148                	lw	a0,4(a0)
    80006244:	60a2                	ld	ra,8(sp)
    80006246:	6402                	ld	s0,0(sp)
    80006248:	0141                	addi	sp,sp,16
    8000624a:	8082                	ret

000000008000624c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000624c:	1101                	addi	sp,sp,-32
    8000624e:	ec06                	sd	ra,24(sp)
    80006250:	e822                	sd	s0,16(sp)
    80006252:	e426                	sd	s1,8(sp)
    80006254:	1000                	addi	s0,sp,32
    80006256:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006258:	ffffb097          	auipc	ra,0xffffb
    8000625c:	6fa080e7          	jalr	1786(ra) # 80001952 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006260:	00d5151b          	slliw	a0,a0,0xd
    80006264:	0c2017b7          	lui	a5,0xc201
    80006268:	97aa                	add	a5,a5,a0
    8000626a:	c3c4                	sw	s1,4(a5)
}
    8000626c:	60e2                	ld	ra,24(sp)
    8000626e:	6442                	ld	s0,16(sp)
    80006270:	64a2                	ld	s1,8(sp)
    80006272:	6105                	addi	sp,sp,32
    80006274:	8082                	ret

0000000080006276 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006276:	1141                	addi	sp,sp,-16
    80006278:	e406                	sd	ra,8(sp)
    8000627a:	e022                	sd	s0,0(sp)
    8000627c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000627e:	479d                	li	a5,7
    80006280:	06a7c963          	blt	a5,a0,800062f2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006284:	0001d797          	auipc	a5,0x1d
    80006288:	d7c78793          	addi	a5,a5,-644 # 80023000 <disk>
    8000628c:	00a78733          	add	a4,a5,a0
    80006290:	6789                	lui	a5,0x2
    80006292:	97ba                	add	a5,a5,a4
    80006294:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006298:	e7ad                	bnez	a5,80006302 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000629a:	00451793          	slli	a5,a0,0x4
    8000629e:	0001f717          	auipc	a4,0x1f
    800062a2:	d6270713          	addi	a4,a4,-670 # 80025000 <disk+0x2000>
    800062a6:	6314                	ld	a3,0(a4)
    800062a8:	96be                	add	a3,a3,a5
    800062aa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062ae:	6314                	ld	a3,0(a4)
    800062b0:	96be                	add	a3,a3,a5
    800062b2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800062b6:	6314                	ld	a3,0(a4)
    800062b8:	96be                	add	a3,a3,a5
    800062ba:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800062be:	6318                	ld	a4,0(a4)
    800062c0:	97ba                	add	a5,a5,a4
    800062c2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800062c6:	0001d797          	auipc	a5,0x1d
    800062ca:	d3a78793          	addi	a5,a5,-710 # 80023000 <disk>
    800062ce:	97aa                	add	a5,a5,a0
    800062d0:	6509                	lui	a0,0x2
    800062d2:	953e                	add	a0,a0,a5
    800062d4:	4785                	li	a5,1
    800062d6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800062da:	0001f517          	auipc	a0,0x1f
    800062de:	d3e50513          	addi	a0,a0,-706 # 80025018 <disk+0x2018>
    800062e2:	ffffc097          	auipc	ra,0xffffc
    800062e6:	12a080e7          	jalr	298(ra) # 8000240c <wakeup>
}
    800062ea:	60a2                	ld	ra,8(sp)
    800062ec:	6402                	ld	s0,0(sp)
    800062ee:	0141                	addi	sp,sp,16
    800062f0:	8082                	ret
    panic("free_desc 1");
    800062f2:	00002517          	auipc	a0,0x2
    800062f6:	4e650513          	addi	a0,a0,1254 # 800087d8 <syscalls+0x338>
    800062fa:	ffffa097          	auipc	ra,0xffffa
    800062fe:	230080e7          	jalr	560(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006302:	00002517          	auipc	a0,0x2
    80006306:	4e650513          	addi	a0,a0,1254 # 800087e8 <syscalls+0x348>
    8000630a:	ffffa097          	auipc	ra,0xffffa
    8000630e:	220080e7          	jalr	544(ra) # 8000052a <panic>

0000000080006312 <virtio_disk_init>:
{
    80006312:	1101                	addi	sp,sp,-32
    80006314:	ec06                	sd	ra,24(sp)
    80006316:	e822                	sd	s0,16(sp)
    80006318:	e426                	sd	s1,8(sp)
    8000631a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000631c:	00002597          	auipc	a1,0x2
    80006320:	4dc58593          	addi	a1,a1,1244 # 800087f8 <syscalls+0x358>
    80006324:	0001f517          	auipc	a0,0x1f
    80006328:	e0450513          	addi	a0,a0,-508 # 80025128 <disk+0x2128>
    8000632c:	ffffb097          	auipc	ra,0xffffb
    80006330:	806080e7          	jalr	-2042(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006334:	100017b7          	lui	a5,0x10001
    80006338:	4398                	lw	a4,0(a5)
    8000633a:	2701                	sext.w	a4,a4
    8000633c:	747277b7          	lui	a5,0x74727
    80006340:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006344:	0ef71163          	bne	a4,a5,80006426 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006348:	100017b7          	lui	a5,0x10001
    8000634c:	43dc                	lw	a5,4(a5)
    8000634e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006350:	4705                	li	a4,1
    80006352:	0ce79a63          	bne	a5,a4,80006426 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006356:	100017b7          	lui	a5,0x10001
    8000635a:	479c                	lw	a5,8(a5)
    8000635c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000635e:	4709                	li	a4,2
    80006360:	0ce79363          	bne	a5,a4,80006426 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006364:	100017b7          	lui	a5,0x10001
    80006368:	47d8                	lw	a4,12(a5)
    8000636a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000636c:	554d47b7          	lui	a5,0x554d4
    80006370:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006374:	0af71963          	bne	a4,a5,80006426 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006378:	100017b7          	lui	a5,0x10001
    8000637c:	4705                	li	a4,1
    8000637e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006380:	470d                	li	a4,3
    80006382:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006384:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006386:	c7ffe737          	lui	a4,0xc7ffe
    8000638a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000638e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006390:	2701                	sext.w	a4,a4
    80006392:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006394:	472d                	li	a4,11
    80006396:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006398:	473d                	li	a4,15
    8000639a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000639c:	6705                	lui	a4,0x1
    8000639e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063a0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063a4:	5bdc                	lw	a5,52(a5)
    800063a6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063a8:	c7d9                	beqz	a5,80006436 <virtio_disk_init+0x124>
  if(max < NUM)
    800063aa:	471d                	li	a4,7
    800063ac:	08f77d63          	bgeu	a4,a5,80006446 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063b0:	100014b7          	lui	s1,0x10001
    800063b4:	47a1                	li	a5,8
    800063b6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800063b8:	6609                	lui	a2,0x2
    800063ba:	4581                	li	a1,0
    800063bc:	0001d517          	auipc	a0,0x1d
    800063c0:	c4450513          	addi	a0,a0,-956 # 80023000 <disk>
    800063c4:	ffffb097          	auipc	ra,0xffffb
    800063c8:	8fa080e7          	jalr	-1798(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800063cc:	0001d717          	auipc	a4,0x1d
    800063d0:	c3470713          	addi	a4,a4,-972 # 80023000 <disk>
    800063d4:	00c75793          	srli	a5,a4,0xc
    800063d8:	2781                	sext.w	a5,a5
    800063da:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800063dc:	0001f797          	auipc	a5,0x1f
    800063e0:	c2478793          	addi	a5,a5,-988 # 80025000 <disk+0x2000>
    800063e4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800063e6:	0001d717          	auipc	a4,0x1d
    800063ea:	c9a70713          	addi	a4,a4,-870 # 80023080 <disk+0x80>
    800063ee:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800063f0:	0001e717          	auipc	a4,0x1e
    800063f4:	c1070713          	addi	a4,a4,-1008 # 80024000 <disk+0x1000>
    800063f8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800063fa:	4705                	li	a4,1
    800063fc:	00e78c23          	sb	a4,24(a5)
    80006400:	00e78ca3          	sb	a4,25(a5)
    80006404:	00e78d23          	sb	a4,26(a5)
    80006408:	00e78da3          	sb	a4,27(a5)
    8000640c:	00e78e23          	sb	a4,28(a5)
    80006410:	00e78ea3          	sb	a4,29(a5)
    80006414:	00e78f23          	sb	a4,30(a5)
    80006418:	00e78fa3          	sb	a4,31(a5)
}
    8000641c:	60e2                	ld	ra,24(sp)
    8000641e:	6442                	ld	s0,16(sp)
    80006420:	64a2                	ld	s1,8(sp)
    80006422:	6105                	addi	sp,sp,32
    80006424:	8082                	ret
    panic("could not find virtio disk");
    80006426:	00002517          	auipc	a0,0x2
    8000642a:	3e250513          	addi	a0,a0,994 # 80008808 <syscalls+0x368>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	0fc080e7          	jalr	252(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006436:	00002517          	auipc	a0,0x2
    8000643a:	3f250513          	addi	a0,a0,1010 # 80008828 <syscalls+0x388>
    8000643e:	ffffa097          	auipc	ra,0xffffa
    80006442:	0ec080e7          	jalr	236(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006446:	00002517          	auipc	a0,0x2
    8000644a:	40250513          	addi	a0,a0,1026 # 80008848 <syscalls+0x3a8>
    8000644e:	ffffa097          	auipc	ra,0xffffa
    80006452:	0dc080e7          	jalr	220(ra) # 8000052a <panic>

0000000080006456 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006456:	7119                	addi	sp,sp,-128
    80006458:	fc86                	sd	ra,120(sp)
    8000645a:	f8a2                	sd	s0,112(sp)
    8000645c:	f4a6                	sd	s1,104(sp)
    8000645e:	f0ca                	sd	s2,96(sp)
    80006460:	ecce                	sd	s3,88(sp)
    80006462:	e8d2                	sd	s4,80(sp)
    80006464:	e4d6                	sd	s5,72(sp)
    80006466:	e0da                	sd	s6,64(sp)
    80006468:	fc5e                	sd	s7,56(sp)
    8000646a:	f862                	sd	s8,48(sp)
    8000646c:	f466                	sd	s9,40(sp)
    8000646e:	f06a                	sd	s10,32(sp)
    80006470:	ec6e                	sd	s11,24(sp)
    80006472:	0100                	addi	s0,sp,128
    80006474:	8aaa                	mv	s5,a0
    80006476:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006478:	00c52c83          	lw	s9,12(a0)
    8000647c:	001c9c9b          	slliw	s9,s9,0x1
    80006480:	1c82                	slli	s9,s9,0x20
    80006482:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006486:	0001f517          	auipc	a0,0x1f
    8000648a:	ca250513          	addi	a0,a0,-862 # 80025128 <disk+0x2128>
    8000648e:	ffffa097          	auipc	ra,0xffffa
    80006492:	734080e7          	jalr	1844(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006496:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006498:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000649a:	0001dc17          	auipc	s8,0x1d
    8000649e:	b66c0c13          	addi	s8,s8,-1178 # 80023000 <disk>
    800064a2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800064a4:	4b0d                	li	s6,3
    800064a6:	a0ad                	j	80006510 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800064a8:	00fc0733          	add	a4,s8,a5
    800064ac:	975e                	add	a4,a4,s7
    800064ae:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064b2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064b4:	0207c563          	bltz	a5,800064de <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800064b8:	2905                	addiw	s2,s2,1
    800064ba:	0611                	addi	a2,a2,4
    800064bc:	19690d63          	beq	s2,s6,80006656 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800064c0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064c2:	0001f717          	auipc	a4,0x1f
    800064c6:	b5670713          	addi	a4,a4,-1194 # 80025018 <disk+0x2018>
    800064ca:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064cc:	00074683          	lbu	a3,0(a4)
    800064d0:	fee1                	bnez	a3,800064a8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800064d2:	2785                	addiw	a5,a5,1
    800064d4:	0705                	addi	a4,a4,1
    800064d6:	fe979be3          	bne	a5,s1,800064cc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800064da:	57fd                	li	a5,-1
    800064dc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800064de:	01205d63          	blez	s2,800064f8 <virtio_disk_rw+0xa2>
    800064e2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064e4:	000a2503          	lw	a0,0(s4)
    800064e8:	00000097          	auipc	ra,0x0
    800064ec:	d8e080e7          	jalr	-626(ra) # 80006276 <free_desc>
      for(int j = 0; j < i; j++)
    800064f0:	2d85                	addiw	s11,s11,1
    800064f2:	0a11                	addi	s4,s4,4
    800064f4:	ffb918e3          	bne	s2,s11,800064e4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064f8:	0001f597          	auipc	a1,0x1f
    800064fc:	c3058593          	addi	a1,a1,-976 # 80025128 <disk+0x2128>
    80006500:	0001f517          	auipc	a0,0x1f
    80006504:	b1850513          	addi	a0,a0,-1256 # 80025018 <disk+0x2018>
    80006508:	ffffc097          	auipc	ra,0xffffc
    8000650c:	d78080e7          	jalr	-648(ra) # 80002280 <sleep>
  for(int i = 0; i < 3; i++){
    80006510:	f8040a13          	addi	s4,s0,-128
{
    80006514:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006516:	894e                	mv	s2,s3
    80006518:	b765                	j	800064c0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000651a:	0001f697          	auipc	a3,0x1f
    8000651e:	ae66b683          	ld	a3,-1306(a3) # 80025000 <disk+0x2000>
    80006522:	96ba                	add	a3,a3,a4
    80006524:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006528:	0001d817          	auipc	a6,0x1d
    8000652c:	ad880813          	addi	a6,a6,-1320 # 80023000 <disk>
    80006530:	0001f697          	auipc	a3,0x1f
    80006534:	ad068693          	addi	a3,a3,-1328 # 80025000 <disk+0x2000>
    80006538:	6290                	ld	a2,0(a3)
    8000653a:	963a                	add	a2,a2,a4
    8000653c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006540:	0015e593          	ori	a1,a1,1
    80006544:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006548:	f8842603          	lw	a2,-120(s0)
    8000654c:	628c                	ld	a1,0(a3)
    8000654e:	972e                	add	a4,a4,a1
    80006550:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006554:	20050593          	addi	a1,a0,512
    80006558:	0592                	slli	a1,a1,0x4
    8000655a:	95c2                	add	a1,a1,a6
    8000655c:	577d                	li	a4,-1
    8000655e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006562:	00461713          	slli	a4,a2,0x4
    80006566:	6290                	ld	a2,0(a3)
    80006568:	963a                	add	a2,a2,a4
    8000656a:	03078793          	addi	a5,a5,48
    8000656e:	97c2                	add	a5,a5,a6
    80006570:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006572:	629c                	ld	a5,0(a3)
    80006574:	97ba                	add	a5,a5,a4
    80006576:	4605                	li	a2,1
    80006578:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000657a:	629c                	ld	a5,0(a3)
    8000657c:	97ba                	add	a5,a5,a4
    8000657e:	4809                	li	a6,2
    80006580:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006584:	629c                	ld	a5,0(a3)
    80006586:	973e                	add	a4,a4,a5
    80006588:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000658c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006590:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006594:	6698                	ld	a4,8(a3)
    80006596:	00275783          	lhu	a5,2(a4)
    8000659a:	8b9d                	andi	a5,a5,7
    8000659c:	0786                	slli	a5,a5,0x1
    8000659e:	97ba                	add	a5,a5,a4
    800065a0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800065a4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065a8:	6698                	ld	a4,8(a3)
    800065aa:	00275783          	lhu	a5,2(a4)
    800065ae:	2785                	addiw	a5,a5,1
    800065b0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065b4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065b8:	100017b7          	lui	a5,0x10001
    800065bc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065c0:	004aa783          	lw	a5,4(s5)
    800065c4:	02c79163          	bne	a5,a2,800065e6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800065c8:	0001f917          	auipc	s2,0x1f
    800065cc:	b6090913          	addi	s2,s2,-1184 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800065d0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065d2:	85ca                	mv	a1,s2
    800065d4:	8556                	mv	a0,s5
    800065d6:	ffffc097          	auipc	ra,0xffffc
    800065da:	caa080e7          	jalr	-854(ra) # 80002280 <sleep>
  while(b->disk == 1) {
    800065de:	004aa783          	lw	a5,4(s5)
    800065e2:	fe9788e3          	beq	a5,s1,800065d2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800065e6:	f8042903          	lw	s2,-128(s0)
    800065ea:	20090793          	addi	a5,s2,512
    800065ee:	00479713          	slli	a4,a5,0x4
    800065f2:	0001d797          	auipc	a5,0x1d
    800065f6:	a0e78793          	addi	a5,a5,-1522 # 80023000 <disk>
    800065fa:	97ba                	add	a5,a5,a4
    800065fc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006600:	0001f997          	auipc	s3,0x1f
    80006604:	a0098993          	addi	s3,s3,-1536 # 80025000 <disk+0x2000>
    80006608:	00491713          	slli	a4,s2,0x4
    8000660c:	0009b783          	ld	a5,0(s3)
    80006610:	97ba                	add	a5,a5,a4
    80006612:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006616:	854a                	mv	a0,s2
    80006618:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000661c:	00000097          	auipc	ra,0x0
    80006620:	c5a080e7          	jalr	-934(ra) # 80006276 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006624:	8885                	andi	s1,s1,1
    80006626:	f0ed                	bnez	s1,80006608 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006628:	0001f517          	auipc	a0,0x1f
    8000662c:	b0050513          	addi	a0,a0,-1280 # 80025128 <disk+0x2128>
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	646080e7          	jalr	1606(ra) # 80000c76 <release>
}
    80006638:	70e6                	ld	ra,120(sp)
    8000663a:	7446                	ld	s0,112(sp)
    8000663c:	74a6                	ld	s1,104(sp)
    8000663e:	7906                	ld	s2,96(sp)
    80006640:	69e6                	ld	s3,88(sp)
    80006642:	6a46                	ld	s4,80(sp)
    80006644:	6aa6                	ld	s5,72(sp)
    80006646:	6b06                	ld	s6,64(sp)
    80006648:	7be2                	ld	s7,56(sp)
    8000664a:	7c42                	ld	s8,48(sp)
    8000664c:	7ca2                	ld	s9,40(sp)
    8000664e:	7d02                	ld	s10,32(sp)
    80006650:	6de2                	ld	s11,24(sp)
    80006652:	6109                	addi	sp,sp,128
    80006654:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006656:	f8042503          	lw	a0,-128(s0)
    8000665a:	20050793          	addi	a5,a0,512
    8000665e:	0792                	slli	a5,a5,0x4
  if(write)
    80006660:	0001d817          	auipc	a6,0x1d
    80006664:	9a080813          	addi	a6,a6,-1632 # 80023000 <disk>
    80006668:	00f80733          	add	a4,a6,a5
    8000666c:	01a036b3          	snez	a3,s10
    80006670:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006674:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006678:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000667c:	7679                	lui	a2,0xffffe
    8000667e:	963e                	add	a2,a2,a5
    80006680:	0001f697          	auipc	a3,0x1f
    80006684:	98068693          	addi	a3,a3,-1664 # 80025000 <disk+0x2000>
    80006688:	6298                	ld	a4,0(a3)
    8000668a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000668c:	0a878593          	addi	a1,a5,168
    80006690:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006692:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006694:	6298                	ld	a4,0(a3)
    80006696:	9732                	add	a4,a4,a2
    80006698:	45c1                	li	a1,16
    8000669a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000669c:	6298                	ld	a4,0(a3)
    8000669e:	9732                	add	a4,a4,a2
    800066a0:	4585                	li	a1,1
    800066a2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800066a6:	f8442703          	lw	a4,-124(s0)
    800066aa:	628c                	ld	a1,0(a3)
    800066ac:	962e                	add	a2,a2,a1
    800066ae:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800066b2:	0712                	slli	a4,a4,0x4
    800066b4:	6290                	ld	a2,0(a3)
    800066b6:	963a                	add	a2,a2,a4
    800066b8:	058a8593          	addi	a1,s5,88
    800066bc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066be:	6294                	ld	a3,0(a3)
    800066c0:	96ba                	add	a3,a3,a4
    800066c2:	40000613          	li	a2,1024
    800066c6:	c690                	sw	a2,8(a3)
  if(write)
    800066c8:	e40d19e3          	bnez	s10,8000651a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066cc:	0001f697          	auipc	a3,0x1f
    800066d0:	9346b683          	ld	a3,-1740(a3) # 80025000 <disk+0x2000>
    800066d4:	96ba                	add	a3,a3,a4
    800066d6:	4609                	li	a2,2
    800066d8:	00c69623          	sh	a2,12(a3)
    800066dc:	b5b1                	j	80006528 <virtio_disk_rw+0xd2>

00000000800066de <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066de:	1101                	addi	sp,sp,-32
    800066e0:	ec06                	sd	ra,24(sp)
    800066e2:	e822                	sd	s0,16(sp)
    800066e4:	e426                	sd	s1,8(sp)
    800066e6:	e04a                	sd	s2,0(sp)
    800066e8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066ea:	0001f517          	auipc	a0,0x1f
    800066ee:	a3e50513          	addi	a0,a0,-1474 # 80025128 <disk+0x2128>
    800066f2:	ffffa097          	auipc	ra,0xffffa
    800066f6:	4d0080e7          	jalr	1232(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066fa:	10001737          	lui	a4,0x10001
    800066fe:	533c                	lw	a5,96(a4)
    80006700:	8b8d                	andi	a5,a5,3
    80006702:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006704:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006708:	0001f797          	auipc	a5,0x1f
    8000670c:	8f878793          	addi	a5,a5,-1800 # 80025000 <disk+0x2000>
    80006710:	6b94                	ld	a3,16(a5)
    80006712:	0207d703          	lhu	a4,32(a5)
    80006716:	0026d783          	lhu	a5,2(a3)
    8000671a:	06f70163          	beq	a4,a5,8000677c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000671e:	0001d917          	auipc	s2,0x1d
    80006722:	8e290913          	addi	s2,s2,-1822 # 80023000 <disk>
    80006726:	0001f497          	auipc	s1,0x1f
    8000672a:	8da48493          	addi	s1,s1,-1830 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000672e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006732:	6898                	ld	a4,16(s1)
    80006734:	0204d783          	lhu	a5,32(s1)
    80006738:	8b9d                	andi	a5,a5,7
    8000673a:	078e                	slli	a5,a5,0x3
    8000673c:	97ba                	add	a5,a5,a4
    8000673e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006740:	20078713          	addi	a4,a5,512
    80006744:	0712                	slli	a4,a4,0x4
    80006746:	974a                	add	a4,a4,s2
    80006748:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000674c:	e731                	bnez	a4,80006798 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000674e:	20078793          	addi	a5,a5,512
    80006752:	0792                	slli	a5,a5,0x4
    80006754:	97ca                	add	a5,a5,s2
    80006756:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006758:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000675c:	ffffc097          	auipc	ra,0xffffc
    80006760:	cb0080e7          	jalr	-848(ra) # 8000240c <wakeup>

    disk.used_idx += 1;
    80006764:	0204d783          	lhu	a5,32(s1)
    80006768:	2785                	addiw	a5,a5,1
    8000676a:	17c2                	slli	a5,a5,0x30
    8000676c:	93c1                	srli	a5,a5,0x30
    8000676e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006772:	6898                	ld	a4,16(s1)
    80006774:	00275703          	lhu	a4,2(a4)
    80006778:	faf71be3          	bne	a4,a5,8000672e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000677c:	0001f517          	auipc	a0,0x1f
    80006780:	9ac50513          	addi	a0,a0,-1620 # 80025128 <disk+0x2128>
    80006784:	ffffa097          	auipc	ra,0xffffa
    80006788:	4f2080e7          	jalr	1266(ra) # 80000c76 <release>
}
    8000678c:	60e2                	ld	ra,24(sp)
    8000678e:	6442                	ld	s0,16(sp)
    80006790:	64a2                	ld	s1,8(sp)
    80006792:	6902                	ld	s2,0(sp)
    80006794:	6105                	addi	sp,sp,32
    80006796:	8082                	ret
      panic("virtio_disk_intr status");
    80006798:	00002517          	auipc	a0,0x2
    8000679c:	0d050513          	addi	a0,a0,208 # 80008868 <syscalls+0x3c8>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	d8a080e7          	jalr	-630(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
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
	...
