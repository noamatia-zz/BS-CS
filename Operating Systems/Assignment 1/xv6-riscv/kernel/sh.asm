
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <findexec>:
struct cmd *parsecmd(char*);

// Find the program and execute it.
void
findexec(struct execcmd *ecmd)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	f852                	sd	s4,48(sp)
       e:	f456                	sd	s5,40(sp)
      10:	f05a                	sd	s6,32(sp)
      12:	ec5e                	sd	s7,24(sp)
      14:	1080                	addi	s0,sp,96
      16:	84010113          	addi	sp,sp,-1984
      1a:	89aa                	mv	s3,a0
  int i, start, end, nbytes, fd;
  char buf[MAXLENGTH], path[MAXLENGTH];

  exec(ecmd->argv[0], ecmd->argv);
      1c:	00850b13          	addi	s6,a0,8
      20:	85da                	mv	a1,s6
      22:	6508                	ld	a0,8(a0)
      24:	00001097          	auipc	ra,0x1
      28:	ef0080e7          	jalr	-272(ra) # f14 <exec>
  fd = open("/path", O_RDONLY);
      2c:	4581                	li	a1,0
      2e:	00001517          	auipc	a0,0x1
      32:	3e250513          	addi	a0,a0,994 # 1410 <malloc+0xe6>
      36:	00001097          	auipc	ra,0x1
      3a:	ee6080e7          	jalr	-282(ra) # f1c <open>
  if(fd < 0 || (nbytes = read(fd, buf, sizeof(buf))) < 0)
      3e:	0c054363          	bltz	a0,104 <findexec+0x104>
      42:	84aa                	mv	s1,a0
      44:	3e700613          	li	a2,999
      48:	bc840593          	addi	a1,s0,-1080
      4c:	00001097          	auipc	ra,0x1
      50:	ea8080e7          	jalr	-344(ra) # ef4 <read>
      54:	8a2a                	mv	s4,a0
      56:	0a054763          	bltz	a0,104 <findexec+0x104>
    return;
  close(fd);
      5a:	8526                	mv	a0,s1
      5c:	00001097          	auipc	ra,0x1
      60:	ea8080e7          	jalr	-344(ra) # f04 <close>
  start = 0;
  end = 0;
  while(end < nbytes)
      64:	0b405063          	blez	s4,104 <findexec+0x104>
      68:	bc840913          	addi	s2,s0,-1080
      6c:	4485                	li	s1,1
  start = 0;
      6e:	4801                	li	a6,0
  {
    if(buf[end] ==':')
      70:	03a00a93          	li	s5,58
    {
      for(i=0; ecmd->argv[0][i] != '\0'; i++)
      74:	4b81                	li	s7,0
      76:	a09d                	j	dc <findexec+0xdc>
      78:	0089b503          	ld	a0,8(s3)
      7c:	00054603          	lbu	a2,0(a0)
      80:	c241                	beqz	a2,100 <findexec+0x100>
      82:	4705                	li	a4,1
        {
          path[end-start+i] = ecmd->argv[0][i];
      84:	410585bb          	subw	a1,a1,a6
      88:	00e586b3          	add	a3,a1,a4
      8c:	78fd                	lui	a7,0xfffff
      8e:	7e088893          	addi	a7,a7,2016 # fffffffffffff7e0 <__global_pointer$+0xffffffffffffda6f>
      92:	98a2                	add	a7,a7,s0
      94:	96c6                	add	a3,a3,a7
      96:	fec68fa3          	sb	a2,-1(a3)
      for(i=0; ecmd->argv[0][i] != '\0'; i++)
      9a:	0007089b          	sext.w	a7,a4
      9e:	0705                	addi	a4,a4,1
      a0:	00e506b3          	add	a3,a0,a4
      a4:	fff6c603          	lbu	a2,-1(a3)
      a8:	f265                	bnez	a2,88 <findexec+0x88>
        }
      path[end-start+i] = '\0';
      aa:	410787bb          	subw	a5,a5,a6
      ae:	011787bb          	addw	a5,a5,a7
      b2:	fb040713          	addi	a4,s0,-80
      b6:	97ba                	add	a5,a5,a4
      b8:	82078823          	sb	zero,-2000(a5)
      exec(path, ecmd->argv);
      bc:	85da                	mv	a1,s6
      be:	77fd                	lui	a5,0xfffff
      c0:	7e078513          	addi	a0,a5,2016 # fffffffffffff7e0 <__global_pointer$+0xffffffffffffda6f>
      c4:	9522                	add	a0,a0,s0
      c6:	00001097          	auipc	ra,0x1
      ca:	e4e080e7          	jalr	-434(ra) # f14 <exec>
      end++;
      ce:	0004881b          	sext.w	a6,s1
      d2:	8742                	mv	a4,a6
  while(end < nbytes)
      d4:	0905                	addi	s2,s2,1
      d6:	2485                	addiw	s1,s1,1
      d8:	03475663          	bge	a4,s4,104 <findexec+0x104>
      dc:	fff4879b          	addiw	a5,s1,-1
      e0:	0007859b          	sext.w	a1,a5
    if(buf[end] ==':')
      e4:	00094703          	lbu	a4,0(s2)
      e8:	f95708e3          	beq	a4,s5,78 <findexec+0x78>
      start = end;
    }
    else
    {
      path[end-start] = buf[end];
      ec:	410787bb          	subw	a5,a5,a6
      f0:	fb040693          	addi	a3,s0,-80
      f4:	97b6                	add	a5,a5,a3
      f6:	82e78823          	sb	a4,-2000(a5)
      end++;
      fa:	0004871b          	sext.w	a4,s1
      fe:	bfd9                	j	d4 <findexec+0xd4>
      for(i=0; ecmd->argv[0][i] != '\0'; i++)
     100:	88de                	mv	a7,s7
     102:	b765                	j	aa <findexec+0xaa>
    }
  }
}
     104:	7c010113          	addi	sp,sp,1984
     108:	60e6                	ld	ra,88(sp)
     10a:	6446                	ld	s0,80(sp)
     10c:	64a6                	ld	s1,72(sp)
     10e:	6906                	ld	s2,64(sp)
     110:	79e2                	ld	s3,56(sp)
     112:	7a42                	ld	s4,48(sp)
     114:	7aa2                	ld	s5,40(sp)
     116:	7b02                	ld	s6,32(sp)
     118:	6be2                	ld	s7,24(sp)
     11a:	6125                	addi	sp,sp,96
     11c:	8082                	ret

000000000000011e <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
     11e:	1101                	addi	sp,sp,-32
     120:	ec06                	sd	ra,24(sp)
     122:	e822                	sd	s0,16(sp)
     124:	e426                	sd	s1,8(sp)
     126:	e04a                	sd	s2,0(sp)
     128:	1000                	addi	s0,sp,32
     12a:	84aa                	mv	s1,a0
     12c:	892e                	mv	s2,a1
  fprintf(2, "$ ");
     12e:	00001597          	auipc	a1,0x1
     132:	2ea58593          	addi	a1,a1,746 # 1418 <malloc+0xee>
     136:	4509                	li	a0,2
     138:	00001097          	auipc	ra,0x1
     13c:	106080e7          	jalr	262(ra) # 123e <fprintf>
  memset(buf, 0, nbuf);
     140:	864a                	mv	a2,s2
     142:	4581                	li	a1,0
     144:	8526                	mv	a0,s1
     146:	00001097          	auipc	ra,0x1
     14a:	b9a080e7          	jalr	-1126(ra) # ce0 <memset>
  gets(buf, nbuf);
     14e:	85ca                	mv	a1,s2
     150:	8526                	mv	a0,s1
     152:	00001097          	auipc	ra,0x1
     156:	bd4080e7          	jalr	-1068(ra) # d26 <gets>
  if(buf[0] == 0) // EOF
     15a:	0004c503          	lbu	a0,0(s1)
     15e:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
     162:	40a00533          	neg	a0,a0
     166:	60e2                	ld	ra,24(sp)
     168:	6442                	ld	s0,16(sp)
     16a:	64a2                	ld	s1,8(sp)
     16c:	6902                	ld	s2,0(sp)
     16e:	6105                	addi	sp,sp,32
     170:	8082                	ret

0000000000000172 <panic>:
  exit(0);
}

void
panic(char *s)
{
     172:	1141                	addi	sp,sp,-16
     174:	e406                	sd	ra,8(sp)
     176:	e022                	sd	s0,0(sp)
     178:	0800                	addi	s0,sp,16
     17a:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
     17c:	00001597          	auipc	a1,0x1
     180:	2a458593          	addi	a1,a1,676 # 1420 <malloc+0xf6>
     184:	4509                	li	a0,2
     186:	00001097          	auipc	ra,0x1
     18a:	0b8080e7          	jalr	184(ra) # 123e <fprintf>
  exit(1);
     18e:	4505                	li	a0,1
     190:	00001097          	auipc	ra,0x1
     194:	d4c080e7          	jalr	-692(ra) # edc <exit>

0000000000000198 <fork1>:
}

int
fork1(void)
{
     198:	1141                	addi	sp,sp,-16
     19a:	e406                	sd	ra,8(sp)
     19c:	e022                	sd	s0,0(sp)
     19e:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
     1a0:	00001097          	auipc	ra,0x1
     1a4:	d34080e7          	jalr	-716(ra) # ed4 <fork>
  if(pid == -1)
     1a8:	57fd                	li	a5,-1
     1aa:	00f50663          	beq	a0,a5,1b6 <fork1+0x1e>
    panic("fork");
  return pid;
}
     1ae:	60a2                	ld	ra,8(sp)
     1b0:	6402                	ld	s0,0(sp)
     1b2:	0141                	addi	sp,sp,16
     1b4:	8082                	ret
    panic("fork");
     1b6:	00001517          	auipc	a0,0x1
     1ba:	27250513          	addi	a0,a0,626 # 1428 <malloc+0xfe>
     1be:	00000097          	auipc	ra,0x0
     1c2:	fb4080e7          	jalr	-76(ra) # 172 <panic>

00000000000001c6 <runcmd>:
{
     1c6:	7179                	addi	sp,sp,-48
     1c8:	f406                	sd	ra,40(sp)
     1ca:	f022                	sd	s0,32(sp)
     1cc:	ec26                	sd	s1,24(sp)
     1ce:	1800                	addi	s0,sp,48
  if(cmd == 0)
     1d0:	c10d                	beqz	a0,1f2 <runcmd+0x2c>
     1d2:	84aa                	mv	s1,a0
  switch(cmd->type){
     1d4:	4118                	lw	a4,0(a0)
     1d6:	4795                	li	a5,5
     1d8:	02e7e263          	bltu	a5,a4,1fc <runcmd+0x36>
     1dc:	00056783          	lwu	a5,0(a0)
     1e0:	078a                	slli	a5,a5,0x2
     1e2:	00001717          	auipc	a4,0x1
     1e6:	34670713          	addi	a4,a4,838 # 1528 <malloc+0x1fe>
     1ea:	97ba                	add	a5,a5,a4
     1ec:	439c                	lw	a5,0(a5)
     1ee:	97ba                	add	a5,a5,a4
     1f0:	8782                	jr	a5
    exit(1);
     1f2:	4505                	li	a0,1
     1f4:	00001097          	auipc	ra,0x1
     1f8:	ce8080e7          	jalr	-792(ra) # edc <exit>
    panic("runcmd");
     1fc:	00001517          	auipc	a0,0x1
     200:	23450513          	addi	a0,a0,564 # 1430 <malloc+0x106>
     204:	00000097          	auipc	ra,0x0
     208:	f6e080e7          	jalr	-146(ra) # 172 <panic>
    if(ecmd->argv[0] == 0)
     20c:	651c                	ld	a5,8(a0)
     20e:	c785                	beqz	a5,236 <runcmd+0x70>
    findexec(ecmd);
     210:	00000097          	auipc	ra,0x0
     214:	df0080e7          	jalr	-528(ra) # 0 <findexec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     218:	6490                	ld	a2,8(s1)
     21a:	00001597          	auipc	a1,0x1
     21e:	21e58593          	addi	a1,a1,542 # 1438 <malloc+0x10e>
     222:	4509                	li	a0,2
     224:	00001097          	auipc	ra,0x1
     228:	01a080e7          	jalr	26(ra) # 123e <fprintf>
  exit(0);
     22c:	4501                	li	a0,0
     22e:	00001097          	auipc	ra,0x1
     232:	cae080e7          	jalr	-850(ra) # edc <exit>
      exit(1);
     236:	4505                	li	a0,1
     238:	00001097          	auipc	ra,0x1
     23c:	ca4080e7          	jalr	-860(ra) # edc <exit>
    close(rcmd->fd);
     240:	5148                	lw	a0,36(a0)
     242:	00001097          	auipc	ra,0x1
     246:	cc2080e7          	jalr	-830(ra) # f04 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     24a:	508c                	lw	a1,32(s1)
     24c:	6888                	ld	a0,16(s1)
     24e:	00001097          	auipc	ra,0x1
     252:	cce080e7          	jalr	-818(ra) # f1c <open>
     256:	00054763          	bltz	a0,264 <runcmd+0x9e>
    runcmd(rcmd->cmd);
     25a:	6488                	ld	a0,8(s1)
     25c:	00000097          	auipc	ra,0x0
     260:	f6a080e7          	jalr	-150(ra) # 1c6 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     264:	6890                	ld	a2,16(s1)
     266:	00001597          	auipc	a1,0x1
     26a:	1e258593          	addi	a1,a1,482 # 1448 <malloc+0x11e>
     26e:	4509                	li	a0,2
     270:	00001097          	auipc	ra,0x1
     274:	fce080e7          	jalr	-50(ra) # 123e <fprintf>
      exit(1);
     278:	4505                	li	a0,1
     27a:	00001097          	auipc	ra,0x1
     27e:	c62080e7          	jalr	-926(ra) # edc <exit>
    if(fork1() == 0)
     282:	00000097          	auipc	ra,0x0
     286:	f16080e7          	jalr	-234(ra) # 198 <fork1>
     28a:	c919                	beqz	a0,2a0 <runcmd+0xda>
    wait(0);
     28c:	4501                	li	a0,0
     28e:	00001097          	auipc	ra,0x1
     292:	c56080e7          	jalr	-938(ra) # ee4 <wait>
    runcmd(lcmd->right);
     296:	6888                	ld	a0,16(s1)
     298:	00000097          	auipc	ra,0x0
     29c:	f2e080e7          	jalr	-210(ra) # 1c6 <runcmd>
      runcmd(lcmd->left);
     2a0:	6488                	ld	a0,8(s1)
     2a2:	00000097          	auipc	ra,0x0
     2a6:	f24080e7          	jalr	-220(ra) # 1c6 <runcmd>
    if(pipe(p) < 0)
     2aa:	fd840513          	addi	a0,s0,-40
     2ae:	00001097          	auipc	ra,0x1
     2b2:	c3e080e7          	jalr	-962(ra) # eec <pipe>
     2b6:	04054363          	bltz	a0,2fc <runcmd+0x136>
    if(fork1() == 0){
     2ba:	00000097          	auipc	ra,0x0
     2be:	ede080e7          	jalr	-290(ra) # 198 <fork1>
     2c2:	c529                	beqz	a0,30c <runcmd+0x146>
    if(fork1() == 0){
     2c4:	00000097          	auipc	ra,0x0
     2c8:	ed4080e7          	jalr	-300(ra) # 198 <fork1>
     2cc:	cd25                	beqz	a0,344 <runcmd+0x17e>
    close(p[0]);
     2ce:	fd842503          	lw	a0,-40(s0)
     2d2:	00001097          	auipc	ra,0x1
     2d6:	c32080e7          	jalr	-974(ra) # f04 <close>
    close(p[1]);
     2da:	fdc42503          	lw	a0,-36(s0)
     2de:	00001097          	auipc	ra,0x1
     2e2:	c26080e7          	jalr	-986(ra) # f04 <close>
    wait(0);
     2e6:	4501                	li	a0,0
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bfc080e7          	jalr	-1028(ra) # ee4 <wait>
    wait(0);
     2f0:	4501                	li	a0,0
     2f2:	00001097          	auipc	ra,0x1
     2f6:	bf2080e7          	jalr	-1038(ra) # ee4 <wait>
    break;
     2fa:	bf0d                	j	22c <runcmd+0x66>
      panic("pipe");
     2fc:	00001517          	auipc	a0,0x1
     300:	15c50513          	addi	a0,a0,348 # 1458 <malloc+0x12e>
     304:	00000097          	auipc	ra,0x0
     308:	e6e080e7          	jalr	-402(ra) # 172 <panic>
      close(1);
     30c:	4505                	li	a0,1
     30e:	00001097          	auipc	ra,0x1
     312:	bf6080e7          	jalr	-1034(ra) # f04 <close>
      dup(p[1]);
     316:	fdc42503          	lw	a0,-36(s0)
     31a:	00001097          	auipc	ra,0x1
     31e:	c3a080e7          	jalr	-966(ra) # f54 <dup>
      close(p[0]);
     322:	fd842503          	lw	a0,-40(s0)
     326:	00001097          	auipc	ra,0x1
     32a:	bde080e7          	jalr	-1058(ra) # f04 <close>
      close(p[1]);
     32e:	fdc42503          	lw	a0,-36(s0)
     332:	00001097          	auipc	ra,0x1
     336:	bd2080e7          	jalr	-1070(ra) # f04 <close>
      runcmd(pcmd->left);
     33a:	6488                	ld	a0,8(s1)
     33c:	00000097          	auipc	ra,0x0
     340:	e8a080e7          	jalr	-374(ra) # 1c6 <runcmd>
      close(0);
     344:	00001097          	auipc	ra,0x1
     348:	bc0080e7          	jalr	-1088(ra) # f04 <close>
      dup(p[0]);
     34c:	fd842503          	lw	a0,-40(s0)
     350:	00001097          	auipc	ra,0x1
     354:	c04080e7          	jalr	-1020(ra) # f54 <dup>
      close(p[0]);
     358:	fd842503          	lw	a0,-40(s0)
     35c:	00001097          	auipc	ra,0x1
     360:	ba8080e7          	jalr	-1112(ra) # f04 <close>
      close(p[1]);
     364:	fdc42503          	lw	a0,-36(s0)
     368:	00001097          	auipc	ra,0x1
     36c:	b9c080e7          	jalr	-1124(ra) # f04 <close>
      runcmd(pcmd->right);
     370:	6888                	ld	a0,16(s1)
     372:	00000097          	auipc	ra,0x0
     376:	e54080e7          	jalr	-428(ra) # 1c6 <runcmd>
    if(fork1() == 0)
     37a:	00000097          	auipc	ra,0x0
     37e:	e1e080e7          	jalr	-482(ra) # 198 <fork1>
     382:	ea0515e3          	bnez	a0,22c <runcmd+0x66>
      runcmd(bcmd->cmd);
     386:	6488                	ld	a0,8(s1)
     388:	00000097          	auipc	ra,0x0
     38c:	e3e080e7          	jalr	-450(ra) # 1c6 <runcmd>

0000000000000390 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     390:	1101                	addi	sp,sp,-32
     392:	ec06                	sd	ra,24(sp)
     394:	e822                	sd	s0,16(sp)
     396:	e426                	sd	s1,8(sp)
     398:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     39a:	0a800513          	li	a0,168
     39e:	00001097          	auipc	ra,0x1
     3a2:	f8c080e7          	jalr	-116(ra) # 132a <malloc>
     3a6:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3a8:	0a800613          	li	a2,168
     3ac:	4581                	li	a1,0
     3ae:	00001097          	auipc	ra,0x1
     3b2:	932080e7          	jalr	-1742(ra) # ce0 <memset>
  cmd->type = EXEC;
     3b6:	4785                	li	a5,1
     3b8:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     3ba:	8526                	mv	a0,s1
     3bc:	60e2                	ld	ra,24(sp)
     3be:	6442                	ld	s0,16(sp)
     3c0:	64a2                	ld	s1,8(sp)
     3c2:	6105                	addi	sp,sp,32
     3c4:	8082                	ret

00000000000003c6 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     3c6:	7139                	addi	sp,sp,-64
     3c8:	fc06                	sd	ra,56(sp)
     3ca:	f822                	sd	s0,48(sp)
     3cc:	f426                	sd	s1,40(sp)
     3ce:	f04a                	sd	s2,32(sp)
     3d0:	ec4e                	sd	s3,24(sp)
     3d2:	e852                	sd	s4,16(sp)
     3d4:	e456                	sd	s5,8(sp)
     3d6:	e05a                	sd	s6,0(sp)
     3d8:	0080                	addi	s0,sp,64
     3da:	8b2a                	mv	s6,a0
     3dc:	8aae                	mv	s5,a1
     3de:	8a32                	mv	s4,a2
     3e0:	89b6                	mv	s3,a3
     3e2:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3e4:	02800513          	li	a0,40
     3e8:	00001097          	auipc	ra,0x1
     3ec:	f42080e7          	jalr	-190(ra) # 132a <malloc>
     3f0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3f2:	02800613          	li	a2,40
     3f6:	4581                	li	a1,0
     3f8:	00001097          	auipc	ra,0x1
     3fc:	8e8080e7          	jalr	-1816(ra) # ce0 <memset>
  cmd->type = REDIR;
     400:	4789                	li	a5,2
     402:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     404:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     408:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     40c:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     410:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     414:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     418:	8526                	mv	a0,s1
     41a:	70e2                	ld	ra,56(sp)
     41c:	7442                	ld	s0,48(sp)
     41e:	74a2                	ld	s1,40(sp)
     420:	7902                	ld	s2,32(sp)
     422:	69e2                	ld	s3,24(sp)
     424:	6a42                	ld	s4,16(sp)
     426:	6aa2                	ld	s5,8(sp)
     428:	6b02                	ld	s6,0(sp)
     42a:	6121                	addi	sp,sp,64
     42c:	8082                	ret

000000000000042e <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     42e:	7179                	addi	sp,sp,-48
     430:	f406                	sd	ra,40(sp)
     432:	f022                	sd	s0,32(sp)
     434:	ec26                	sd	s1,24(sp)
     436:	e84a                	sd	s2,16(sp)
     438:	e44e                	sd	s3,8(sp)
     43a:	1800                	addi	s0,sp,48
     43c:	89aa                	mv	s3,a0
     43e:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     440:	4561                	li	a0,24
     442:	00001097          	auipc	ra,0x1
     446:	ee8080e7          	jalr	-280(ra) # 132a <malloc>
     44a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     44c:	4661                	li	a2,24
     44e:	4581                	li	a1,0
     450:	00001097          	auipc	ra,0x1
     454:	890080e7          	jalr	-1904(ra) # ce0 <memset>
  cmd->type = PIPE;
     458:	478d                	li	a5,3
     45a:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     45c:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     460:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     464:	8526                	mv	a0,s1
     466:	70a2                	ld	ra,40(sp)
     468:	7402                	ld	s0,32(sp)
     46a:	64e2                	ld	s1,24(sp)
     46c:	6942                	ld	s2,16(sp)
     46e:	69a2                	ld	s3,8(sp)
     470:	6145                	addi	sp,sp,48
     472:	8082                	ret

0000000000000474 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     474:	7179                	addi	sp,sp,-48
     476:	f406                	sd	ra,40(sp)
     478:	f022                	sd	s0,32(sp)
     47a:	ec26                	sd	s1,24(sp)
     47c:	e84a                	sd	s2,16(sp)
     47e:	e44e                	sd	s3,8(sp)
     480:	1800                	addi	s0,sp,48
     482:	89aa                	mv	s3,a0
     484:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     486:	4561                	li	a0,24
     488:	00001097          	auipc	ra,0x1
     48c:	ea2080e7          	jalr	-350(ra) # 132a <malloc>
     490:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     492:	4661                	li	a2,24
     494:	4581                	li	a1,0
     496:	00001097          	auipc	ra,0x1
     49a:	84a080e7          	jalr	-1974(ra) # ce0 <memset>
  cmd->type = LIST;
     49e:	4791                	li	a5,4
     4a0:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     4a2:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     4a6:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     4aa:	8526                	mv	a0,s1
     4ac:	70a2                	ld	ra,40(sp)
     4ae:	7402                	ld	s0,32(sp)
     4b0:	64e2                	ld	s1,24(sp)
     4b2:	6942                	ld	s2,16(sp)
     4b4:	69a2                	ld	s3,8(sp)
     4b6:	6145                	addi	sp,sp,48
     4b8:	8082                	ret

00000000000004ba <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     4ba:	1101                	addi	sp,sp,-32
     4bc:	ec06                	sd	ra,24(sp)
     4be:	e822                	sd	s0,16(sp)
     4c0:	e426                	sd	s1,8(sp)
     4c2:	e04a                	sd	s2,0(sp)
     4c4:	1000                	addi	s0,sp,32
     4c6:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4c8:	4541                	li	a0,16
     4ca:	00001097          	auipc	ra,0x1
     4ce:	e60080e7          	jalr	-416(ra) # 132a <malloc>
     4d2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4d4:	4641                	li	a2,16
     4d6:	4581                	li	a1,0
     4d8:	00001097          	auipc	ra,0x1
     4dc:	808080e7          	jalr	-2040(ra) # ce0 <memset>
  cmd->type = BACK;
     4e0:	4795                	li	a5,5
     4e2:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     4e4:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     4e8:	8526                	mv	a0,s1
     4ea:	60e2                	ld	ra,24(sp)
     4ec:	6442                	ld	s0,16(sp)
     4ee:	64a2                	ld	s1,8(sp)
     4f0:	6902                	ld	s2,0(sp)
     4f2:	6105                	addi	sp,sp,32
     4f4:	8082                	ret

00000000000004f6 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     4f6:	7139                	addi	sp,sp,-64
     4f8:	fc06                	sd	ra,56(sp)
     4fa:	f822                	sd	s0,48(sp)
     4fc:	f426                	sd	s1,40(sp)
     4fe:	f04a                	sd	s2,32(sp)
     500:	ec4e                	sd	s3,24(sp)
     502:	e852                	sd	s4,16(sp)
     504:	e456                	sd	s5,8(sp)
     506:	e05a                	sd	s6,0(sp)
     508:	0080                	addi	s0,sp,64
     50a:	8a2a                	mv	s4,a0
     50c:	892e                	mv	s2,a1
     50e:	8ab2                	mv	s5,a2
     510:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     512:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     514:	00001997          	auipc	s3,0x1
     518:	06c98993          	addi	s3,s3,108 # 1580 <whitespace>
     51c:	00b4fd63          	bgeu	s1,a1,536 <gettoken+0x40>
     520:	0004c583          	lbu	a1,0(s1)
     524:	854e                	mv	a0,s3
     526:	00000097          	auipc	ra,0x0
     52a:	7dc080e7          	jalr	2012(ra) # d02 <strchr>
     52e:	c501                	beqz	a0,536 <gettoken+0x40>
    s++;
     530:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     532:	fe9917e3          	bne	s2,s1,520 <gettoken+0x2a>
  if(q)
     536:	000a8463          	beqz	s5,53e <gettoken+0x48>
    *q = s;
     53a:	009ab023          	sd	s1,0(s5)
  ret = *s;
     53e:	0004c783          	lbu	a5,0(s1)
     542:	00078a9b          	sext.w	s5,a5
  switch(*s){
     546:	03c00713          	li	a4,60
     54a:	06f76563          	bltu	a4,a5,5b4 <gettoken+0xbe>
     54e:	03a00713          	li	a4,58
     552:	00f76e63          	bltu	a4,a5,56e <gettoken+0x78>
     556:	cf89                	beqz	a5,570 <gettoken+0x7a>
     558:	02600713          	li	a4,38
     55c:	00e78963          	beq	a5,a4,56e <gettoken+0x78>
     560:	fd87879b          	addiw	a5,a5,-40
     564:	0ff7f793          	andi	a5,a5,255
     568:	4705                	li	a4,1
     56a:	06f76c63          	bltu	a4,a5,5e2 <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     56e:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     570:	000b0463          	beqz	s6,578 <gettoken+0x82>
    *eq = s;
     574:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     578:	00001997          	auipc	s3,0x1
     57c:	00898993          	addi	s3,s3,8 # 1580 <whitespace>
     580:	0124fd63          	bgeu	s1,s2,59a <gettoken+0xa4>
     584:	0004c583          	lbu	a1,0(s1)
     588:	854e                	mv	a0,s3
     58a:	00000097          	auipc	ra,0x0
     58e:	778080e7          	jalr	1912(ra) # d02 <strchr>
     592:	c501                	beqz	a0,59a <gettoken+0xa4>
    s++;
     594:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     596:	fe9917e3          	bne	s2,s1,584 <gettoken+0x8e>
  *ps = s;
     59a:	009a3023          	sd	s1,0(s4)
  return ret;
}
     59e:	8556                	mv	a0,s5
     5a0:	70e2                	ld	ra,56(sp)
     5a2:	7442                	ld	s0,48(sp)
     5a4:	74a2                	ld	s1,40(sp)
     5a6:	7902                	ld	s2,32(sp)
     5a8:	69e2                	ld	s3,24(sp)
     5aa:	6a42                	ld	s4,16(sp)
     5ac:	6aa2                	ld	s5,8(sp)
     5ae:	6b02                	ld	s6,0(sp)
     5b0:	6121                	addi	sp,sp,64
     5b2:	8082                	ret
  switch(*s){
     5b4:	03e00713          	li	a4,62
     5b8:	02e79163          	bne	a5,a4,5da <gettoken+0xe4>
    s++;
     5bc:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     5c0:	0014c703          	lbu	a4,1(s1)
     5c4:	03e00793          	li	a5,62
      s++;
     5c8:	0489                	addi	s1,s1,2
      ret = '+';
     5ca:	02b00a93          	li	s5,43
    if(*s == '>'){
     5ce:	faf701e3          	beq	a4,a5,570 <gettoken+0x7a>
    s++;
     5d2:	84b6                	mv	s1,a3
  ret = *s;
     5d4:	03e00a93          	li	s5,62
     5d8:	bf61                	j	570 <gettoken+0x7a>
  switch(*s){
     5da:	07c00713          	li	a4,124
     5de:	f8e788e3          	beq	a5,a4,56e <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5e2:	00001997          	auipc	s3,0x1
     5e6:	f9e98993          	addi	s3,s3,-98 # 1580 <whitespace>
     5ea:	00001a97          	auipc	s5,0x1
     5ee:	f8ea8a93          	addi	s5,s5,-114 # 1578 <symbols>
     5f2:	0324f563          	bgeu	s1,s2,61c <gettoken+0x126>
     5f6:	0004c583          	lbu	a1,0(s1)
     5fa:	854e                	mv	a0,s3
     5fc:	00000097          	auipc	ra,0x0
     600:	706080e7          	jalr	1798(ra) # d02 <strchr>
     604:	e505                	bnez	a0,62c <gettoken+0x136>
     606:	0004c583          	lbu	a1,0(s1)
     60a:	8556                	mv	a0,s5
     60c:	00000097          	auipc	ra,0x0
     610:	6f6080e7          	jalr	1782(ra) # d02 <strchr>
     614:	e909                	bnez	a0,626 <gettoken+0x130>
      s++;
     616:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     618:	fc991fe3          	bne	s2,s1,5f6 <gettoken+0x100>
  if(eq)
     61c:	06100a93          	li	s5,97
     620:	f40b1ae3          	bnez	s6,574 <gettoken+0x7e>
     624:	bf9d                	j	59a <gettoken+0xa4>
    ret = 'a';
     626:	06100a93          	li	s5,97
     62a:	b799                	j	570 <gettoken+0x7a>
     62c:	06100a93          	li	s5,97
     630:	b781                	j	570 <gettoken+0x7a>

0000000000000632 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     632:	7139                	addi	sp,sp,-64
     634:	fc06                	sd	ra,56(sp)
     636:	f822                	sd	s0,48(sp)
     638:	f426                	sd	s1,40(sp)
     63a:	f04a                	sd	s2,32(sp)
     63c:	ec4e                	sd	s3,24(sp)
     63e:	e852                	sd	s4,16(sp)
     640:	e456                	sd	s5,8(sp)
     642:	0080                	addi	s0,sp,64
     644:	8a2a                	mv	s4,a0
     646:	892e                	mv	s2,a1
     648:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     64a:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     64c:	00001997          	auipc	s3,0x1
     650:	f3498993          	addi	s3,s3,-204 # 1580 <whitespace>
     654:	00b4fd63          	bgeu	s1,a1,66e <peek+0x3c>
     658:	0004c583          	lbu	a1,0(s1)
     65c:	854e                	mv	a0,s3
     65e:	00000097          	auipc	ra,0x0
     662:	6a4080e7          	jalr	1700(ra) # d02 <strchr>
     666:	c501                	beqz	a0,66e <peek+0x3c>
    s++;
     668:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     66a:	fe9917e3          	bne	s2,s1,658 <peek+0x26>
  *ps = s;
     66e:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     672:	0004c583          	lbu	a1,0(s1)
     676:	4501                	li	a0,0
     678:	e991                	bnez	a1,68c <peek+0x5a>
}
     67a:	70e2                	ld	ra,56(sp)
     67c:	7442                	ld	s0,48(sp)
     67e:	74a2                	ld	s1,40(sp)
     680:	7902                	ld	s2,32(sp)
     682:	69e2                	ld	s3,24(sp)
     684:	6a42                	ld	s4,16(sp)
     686:	6aa2                	ld	s5,8(sp)
     688:	6121                	addi	sp,sp,64
     68a:	8082                	ret
  return *s && strchr(toks, *s);
     68c:	8556                	mv	a0,s5
     68e:	00000097          	auipc	ra,0x0
     692:	674080e7          	jalr	1652(ra) # d02 <strchr>
     696:	00a03533          	snez	a0,a0
     69a:	b7c5                	j	67a <peek+0x48>

000000000000069c <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     69c:	7159                	addi	sp,sp,-112
     69e:	f486                	sd	ra,104(sp)
     6a0:	f0a2                	sd	s0,96(sp)
     6a2:	eca6                	sd	s1,88(sp)
     6a4:	e8ca                	sd	s2,80(sp)
     6a6:	e4ce                	sd	s3,72(sp)
     6a8:	e0d2                	sd	s4,64(sp)
     6aa:	fc56                	sd	s5,56(sp)
     6ac:	f85a                	sd	s6,48(sp)
     6ae:	f45e                	sd	s7,40(sp)
     6b0:	f062                	sd	s8,32(sp)
     6b2:	ec66                	sd	s9,24(sp)
     6b4:	1880                	addi	s0,sp,112
     6b6:	8a2a                	mv	s4,a0
     6b8:	89ae                	mv	s3,a1
     6ba:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     6bc:	00001b97          	auipc	s7,0x1
     6c0:	dc4b8b93          	addi	s7,s7,-572 # 1480 <malloc+0x156>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     6c4:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     6c8:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     6cc:	a02d                	j	6f6 <parseredirs+0x5a>
      panic("missing file for redirection");
     6ce:	00001517          	auipc	a0,0x1
     6d2:	d9250513          	addi	a0,a0,-622 # 1460 <malloc+0x136>
     6d6:	00000097          	auipc	ra,0x0
     6da:	a9c080e7          	jalr	-1380(ra) # 172 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     6de:	4701                	li	a4,0
     6e0:	4681                	li	a3,0
     6e2:	f9043603          	ld	a2,-112(s0)
     6e6:	f9843583          	ld	a1,-104(s0)
     6ea:	8552                	mv	a0,s4
     6ec:	00000097          	auipc	ra,0x0
     6f0:	cda080e7          	jalr	-806(ra) # 3c6 <redircmd>
     6f4:	8a2a                	mv	s4,a0
    switch(tok){
     6f6:	03e00b13          	li	s6,62
     6fa:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     6fe:	865e                	mv	a2,s7
     700:	85ca                	mv	a1,s2
     702:	854e                	mv	a0,s3
     704:	00000097          	auipc	ra,0x0
     708:	f2e080e7          	jalr	-210(ra) # 632 <peek>
     70c:	c925                	beqz	a0,77c <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     70e:	4681                	li	a3,0
     710:	4601                	li	a2,0
     712:	85ca                	mv	a1,s2
     714:	854e                	mv	a0,s3
     716:	00000097          	auipc	ra,0x0
     71a:	de0080e7          	jalr	-544(ra) # 4f6 <gettoken>
     71e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     720:	f9040693          	addi	a3,s0,-112
     724:	f9840613          	addi	a2,s0,-104
     728:	85ca                	mv	a1,s2
     72a:	854e                	mv	a0,s3
     72c:	00000097          	auipc	ra,0x0
     730:	dca080e7          	jalr	-566(ra) # 4f6 <gettoken>
     734:	f9851de3          	bne	a0,s8,6ce <parseredirs+0x32>
    switch(tok){
     738:	fb9483e3          	beq	s1,s9,6de <parseredirs+0x42>
     73c:	03648263          	beq	s1,s6,760 <parseredirs+0xc4>
     740:	fb549fe3          	bne	s1,s5,6fe <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     744:	4705                	li	a4,1
     746:	20100693          	li	a3,513
     74a:	f9043603          	ld	a2,-112(s0)
     74e:	f9843583          	ld	a1,-104(s0)
     752:	8552                	mv	a0,s4
     754:	00000097          	auipc	ra,0x0
     758:	c72080e7          	jalr	-910(ra) # 3c6 <redircmd>
     75c:	8a2a                	mv	s4,a0
      break;
     75e:	bf61                	j	6f6 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     760:	4705                	li	a4,1
     762:	60100693          	li	a3,1537
     766:	f9043603          	ld	a2,-112(s0)
     76a:	f9843583          	ld	a1,-104(s0)
     76e:	8552                	mv	a0,s4
     770:	00000097          	auipc	ra,0x0
     774:	c56080e7          	jalr	-938(ra) # 3c6 <redircmd>
     778:	8a2a                	mv	s4,a0
      break;
     77a:	bfb5                	j	6f6 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     77c:	8552                	mv	a0,s4
     77e:	70a6                	ld	ra,104(sp)
     780:	7406                	ld	s0,96(sp)
     782:	64e6                	ld	s1,88(sp)
     784:	6946                	ld	s2,80(sp)
     786:	69a6                	ld	s3,72(sp)
     788:	6a06                	ld	s4,64(sp)
     78a:	7ae2                	ld	s5,56(sp)
     78c:	7b42                	ld	s6,48(sp)
     78e:	7ba2                	ld	s7,40(sp)
     790:	7c02                	ld	s8,32(sp)
     792:	6ce2                	ld	s9,24(sp)
     794:	6165                	addi	sp,sp,112
     796:	8082                	ret

0000000000000798 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     798:	7159                	addi	sp,sp,-112
     79a:	f486                	sd	ra,104(sp)
     79c:	f0a2                	sd	s0,96(sp)
     79e:	eca6                	sd	s1,88(sp)
     7a0:	e8ca                	sd	s2,80(sp)
     7a2:	e4ce                	sd	s3,72(sp)
     7a4:	e0d2                	sd	s4,64(sp)
     7a6:	fc56                	sd	s5,56(sp)
     7a8:	f85a                	sd	s6,48(sp)
     7aa:	f45e                	sd	s7,40(sp)
     7ac:	f062                	sd	s8,32(sp)
     7ae:	ec66                	sd	s9,24(sp)
     7b0:	1880                	addi	s0,sp,112
     7b2:	8a2a                	mv	s4,a0
     7b4:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     7b6:	00001617          	auipc	a2,0x1
     7ba:	cd260613          	addi	a2,a2,-814 # 1488 <malloc+0x15e>
     7be:	00000097          	auipc	ra,0x0
     7c2:	e74080e7          	jalr	-396(ra) # 632 <peek>
     7c6:	e905                	bnez	a0,7f6 <parseexec+0x5e>
     7c8:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     7ca:	00000097          	auipc	ra,0x0
     7ce:	bc6080e7          	jalr	-1082(ra) # 390 <execcmd>
     7d2:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     7d4:	8656                	mv	a2,s5
     7d6:	85d2                	mv	a1,s4
     7d8:	00000097          	auipc	ra,0x0
     7dc:	ec4080e7          	jalr	-316(ra) # 69c <parseredirs>
     7e0:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     7e2:	008c0913          	addi	s2,s8,8
     7e6:	00001b17          	auipc	s6,0x1
     7ea:	cc2b0b13          	addi	s6,s6,-830 # 14a8 <malloc+0x17e>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     7ee:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     7f2:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     7f4:	a0b1                	j	840 <parseexec+0xa8>
    return parseblock(ps, es);
     7f6:	85d6                	mv	a1,s5
     7f8:	8552                	mv	a0,s4
     7fa:	00000097          	auipc	ra,0x0
     7fe:	1bc080e7          	jalr	444(ra) # 9b6 <parseblock>
     802:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     804:	8526                	mv	a0,s1
     806:	70a6                	ld	ra,104(sp)
     808:	7406                	ld	s0,96(sp)
     80a:	64e6                	ld	s1,88(sp)
     80c:	6946                	ld	s2,80(sp)
     80e:	69a6                	ld	s3,72(sp)
     810:	6a06                	ld	s4,64(sp)
     812:	7ae2                	ld	s5,56(sp)
     814:	7b42                	ld	s6,48(sp)
     816:	7ba2                	ld	s7,40(sp)
     818:	7c02                	ld	s8,32(sp)
     81a:	6ce2                	ld	s9,24(sp)
     81c:	6165                	addi	sp,sp,112
     81e:	8082                	ret
      panic("syntax");
     820:	00001517          	auipc	a0,0x1
     824:	c7050513          	addi	a0,a0,-912 # 1490 <malloc+0x166>
     828:	00000097          	auipc	ra,0x0
     82c:	94a080e7          	jalr	-1718(ra) # 172 <panic>
    ret = parseredirs(ret, ps, es);
     830:	8656                	mv	a2,s5
     832:	85d2                	mv	a1,s4
     834:	8526                	mv	a0,s1
     836:	00000097          	auipc	ra,0x0
     83a:	e66080e7          	jalr	-410(ra) # 69c <parseredirs>
     83e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     840:	865a                	mv	a2,s6
     842:	85d6                	mv	a1,s5
     844:	8552                	mv	a0,s4
     846:	00000097          	auipc	ra,0x0
     84a:	dec080e7          	jalr	-532(ra) # 632 <peek>
     84e:	e131                	bnez	a0,892 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     850:	f9040693          	addi	a3,s0,-112
     854:	f9840613          	addi	a2,s0,-104
     858:	85d6                	mv	a1,s5
     85a:	8552                	mv	a0,s4
     85c:	00000097          	auipc	ra,0x0
     860:	c9a080e7          	jalr	-870(ra) # 4f6 <gettoken>
     864:	c51d                	beqz	a0,892 <parseexec+0xfa>
    if(tok != 'a')
     866:	fb951de3          	bne	a0,s9,820 <parseexec+0x88>
    cmd->argv[argc] = q;
     86a:	f9843783          	ld	a5,-104(s0)
     86e:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     872:	f9043783          	ld	a5,-112(s0)
     876:	04f93823          	sd	a5,80(s2)
    argc++;
     87a:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     87c:	0921                	addi	s2,s2,8
     87e:	fb7999e3          	bne	s3,s7,830 <parseexec+0x98>
      panic("too many args");
     882:	00001517          	auipc	a0,0x1
     886:	c1650513          	addi	a0,a0,-1002 # 1498 <malloc+0x16e>
     88a:	00000097          	auipc	ra,0x0
     88e:	8e8080e7          	jalr	-1816(ra) # 172 <panic>
  cmd->argv[argc] = 0;
     892:	098e                	slli	s3,s3,0x3
     894:	99e2                	add	s3,s3,s8
     896:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     89a:	0409bc23          	sd	zero,88(s3)
  return ret;
     89e:	b79d                	j	804 <parseexec+0x6c>

00000000000008a0 <parsepipe>:
{
     8a0:	7179                	addi	sp,sp,-48
     8a2:	f406                	sd	ra,40(sp)
     8a4:	f022                	sd	s0,32(sp)
     8a6:	ec26                	sd	s1,24(sp)
     8a8:	e84a                	sd	s2,16(sp)
     8aa:	e44e                	sd	s3,8(sp)
     8ac:	1800                	addi	s0,sp,48
     8ae:	892a                	mv	s2,a0
     8b0:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     8b2:	00000097          	auipc	ra,0x0
     8b6:	ee6080e7          	jalr	-282(ra) # 798 <parseexec>
     8ba:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     8bc:	00001617          	auipc	a2,0x1
     8c0:	bf460613          	addi	a2,a2,-1036 # 14b0 <malloc+0x186>
     8c4:	85ce                	mv	a1,s3
     8c6:	854a                	mv	a0,s2
     8c8:	00000097          	auipc	ra,0x0
     8cc:	d6a080e7          	jalr	-662(ra) # 632 <peek>
     8d0:	e909                	bnez	a0,8e2 <parsepipe+0x42>
}
     8d2:	8526                	mv	a0,s1
     8d4:	70a2                	ld	ra,40(sp)
     8d6:	7402                	ld	s0,32(sp)
     8d8:	64e2                	ld	s1,24(sp)
     8da:	6942                	ld	s2,16(sp)
     8dc:	69a2                	ld	s3,8(sp)
     8de:	6145                	addi	sp,sp,48
     8e0:	8082                	ret
    gettoken(ps, es, 0, 0);
     8e2:	4681                	li	a3,0
     8e4:	4601                	li	a2,0
     8e6:	85ce                	mv	a1,s3
     8e8:	854a                	mv	a0,s2
     8ea:	00000097          	auipc	ra,0x0
     8ee:	c0c080e7          	jalr	-1012(ra) # 4f6 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8f2:	85ce                	mv	a1,s3
     8f4:	854a                	mv	a0,s2
     8f6:	00000097          	auipc	ra,0x0
     8fa:	faa080e7          	jalr	-86(ra) # 8a0 <parsepipe>
     8fe:	85aa                	mv	a1,a0
     900:	8526                	mv	a0,s1
     902:	00000097          	auipc	ra,0x0
     906:	b2c080e7          	jalr	-1236(ra) # 42e <pipecmd>
     90a:	84aa                	mv	s1,a0
  return cmd;
     90c:	b7d9                	j	8d2 <parsepipe+0x32>

000000000000090e <parseline>:
{
     90e:	7179                	addi	sp,sp,-48
     910:	f406                	sd	ra,40(sp)
     912:	f022                	sd	s0,32(sp)
     914:	ec26                	sd	s1,24(sp)
     916:	e84a                	sd	s2,16(sp)
     918:	e44e                	sd	s3,8(sp)
     91a:	e052                	sd	s4,0(sp)
     91c:	1800                	addi	s0,sp,48
     91e:	892a                	mv	s2,a0
     920:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     922:	00000097          	auipc	ra,0x0
     926:	f7e080e7          	jalr	-130(ra) # 8a0 <parsepipe>
     92a:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     92c:	00001a17          	auipc	s4,0x1
     930:	b8ca0a13          	addi	s4,s4,-1140 # 14b8 <malloc+0x18e>
     934:	a839                	j	952 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     936:	4681                	li	a3,0
     938:	4601                	li	a2,0
     93a:	85ce                	mv	a1,s3
     93c:	854a                	mv	a0,s2
     93e:	00000097          	auipc	ra,0x0
     942:	bb8080e7          	jalr	-1096(ra) # 4f6 <gettoken>
    cmd = backcmd(cmd);
     946:	8526                	mv	a0,s1
     948:	00000097          	auipc	ra,0x0
     94c:	b72080e7          	jalr	-1166(ra) # 4ba <backcmd>
     950:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     952:	8652                	mv	a2,s4
     954:	85ce                	mv	a1,s3
     956:	854a                	mv	a0,s2
     958:	00000097          	auipc	ra,0x0
     95c:	cda080e7          	jalr	-806(ra) # 632 <peek>
     960:	f979                	bnez	a0,936 <parseline+0x28>
  if(peek(ps, es, ";")){
     962:	00001617          	auipc	a2,0x1
     966:	b5e60613          	addi	a2,a2,-1186 # 14c0 <malloc+0x196>
     96a:	85ce                	mv	a1,s3
     96c:	854a                	mv	a0,s2
     96e:	00000097          	auipc	ra,0x0
     972:	cc4080e7          	jalr	-828(ra) # 632 <peek>
     976:	e911                	bnez	a0,98a <parseline+0x7c>
}
     978:	8526                	mv	a0,s1
     97a:	70a2                	ld	ra,40(sp)
     97c:	7402                	ld	s0,32(sp)
     97e:	64e2                	ld	s1,24(sp)
     980:	6942                	ld	s2,16(sp)
     982:	69a2                	ld	s3,8(sp)
     984:	6a02                	ld	s4,0(sp)
     986:	6145                	addi	sp,sp,48
     988:	8082                	ret
    gettoken(ps, es, 0, 0);
     98a:	4681                	li	a3,0
     98c:	4601                	li	a2,0
     98e:	85ce                	mv	a1,s3
     990:	854a                	mv	a0,s2
     992:	00000097          	auipc	ra,0x0
     996:	b64080e7          	jalr	-1180(ra) # 4f6 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     99a:	85ce                	mv	a1,s3
     99c:	854a                	mv	a0,s2
     99e:	00000097          	auipc	ra,0x0
     9a2:	f70080e7          	jalr	-144(ra) # 90e <parseline>
     9a6:	85aa                	mv	a1,a0
     9a8:	8526                	mv	a0,s1
     9aa:	00000097          	auipc	ra,0x0
     9ae:	aca080e7          	jalr	-1334(ra) # 474 <listcmd>
     9b2:	84aa                	mv	s1,a0
  return cmd;
     9b4:	b7d1                	j	978 <parseline+0x6a>

00000000000009b6 <parseblock>:
{
     9b6:	7179                	addi	sp,sp,-48
     9b8:	f406                	sd	ra,40(sp)
     9ba:	f022                	sd	s0,32(sp)
     9bc:	ec26                	sd	s1,24(sp)
     9be:	e84a                	sd	s2,16(sp)
     9c0:	e44e                	sd	s3,8(sp)
     9c2:	1800                	addi	s0,sp,48
     9c4:	84aa                	mv	s1,a0
     9c6:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     9c8:	00001617          	auipc	a2,0x1
     9cc:	ac060613          	addi	a2,a2,-1344 # 1488 <malloc+0x15e>
     9d0:	00000097          	auipc	ra,0x0
     9d4:	c62080e7          	jalr	-926(ra) # 632 <peek>
     9d8:	c12d                	beqz	a0,a3a <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     9da:	4681                	li	a3,0
     9dc:	4601                	li	a2,0
     9de:	85ca                	mv	a1,s2
     9e0:	8526                	mv	a0,s1
     9e2:	00000097          	auipc	ra,0x0
     9e6:	b14080e7          	jalr	-1260(ra) # 4f6 <gettoken>
  cmd = parseline(ps, es);
     9ea:	85ca                	mv	a1,s2
     9ec:	8526                	mv	a0,s1
     9ee:	00000097          	auipc	ra,0x0
     9f2:	f20080e7          	jalr	-224(ra) # 90e <parseline>
     9f6:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     9f8:	00001617          	auipc	a2,0x1
     9fc:	ae060613          	addi	a2,a2,-1312 # 14d8 <malloc+0x1ae>
     a00:	85ca                	mv	a1,s2
     a02:	8526                	mv	a0,s1
     a04:	00000097          	auipc	ra,0x0
     a08:	c2e080e7          	jalr	-978(ra) # 632 <peek>
     a0c:	cd1d                	beqz	a0,a4a <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     a0e:	4681                	li	a3,0
     a10:	4601                	li	a2,0
     a12:	85ca                	mv	a1,s2
     a14:	8526                	mv	a0,s1
     a16:	00000097          	auipc	ra,0x0
     a1a:	ae0080e7          	jalr	-1312(ra) # 4f6 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     a1e:	864a                	mv	a2,s2
     a20:	85a6                	mv	a1,s1
     a22:	854e                	mv	a0,s3
     a24:	00000097          	auipc	ra,0x0
     a28:	c78080e7          	jalr	-904(ra) # 69c <parseredirs>
}
     a2c:	70a2                	ld	ra,40(sp)
     a2e:	7402                	ld	s0,32(sp)
     a30:	64e2                	ld	s1,24(sp)
     a32:	6942                	ld	s2,16(sp)
     a34:	69a2                	ld	s3,8(sp)
     a36:	6145                	addi	sp,sp,48
     a38:	8082                	ret
    panic("parseblock");
     a3a:	00001517          	auipc	a0,0x1
     a3e:	a8e50513          	addi	a0,a0,-1394 # 14c8 <malloc+0x19e>
     a42:	fffff097          	auipc	ra,0xfffff
     a46:	730080e7          	jalr	1840(ra) # 172 <panic>
    panic("syntax - missing )");
     a4a:	00001517          	auipc	a0,0x1
     a4e:	a9650513          	addi	a0,a0,-1386 # 14e0 <malloc+0x1b6>
     a52:	fffff097          	auipc	ra,0xfffff
     a56:	720080e7          	jalr	1824(ra) # 172 <panic>

0000000000000a5a <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     a5a:	1101                	addi	sp,sp,-32
     a5c:	ec06                	sd	ra,24(sp)
     a5e:	e822                	sd	s0,16(sp)
     a60:	e426                	sd	s1,8(sp)
     a62:	1000                	addi	s0,sp,32
     a64:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     a66:	c521                	beqz	a0,aae <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     a68:	4118                	lw	a4,0(a0)
     a6a:	4795                	li	a5,5
     a6c:	04e7e163          	bltu	a5,a4,aae <nulterminate+0x54>
     a70:	00056783          	lwu	a5,0(a0)
     a74:	078a                	slli	a5,a5,0x2
     a76:	00001717          	auipc	a4,0x1
     a7a:	aca70713          	addi	a4,a4,-1334 # 1540 <malloc+0x216>
     a7e:	97ba                	add	a5,a5,a4
     a80:	439c                	lw	a5,0(a5)
     a82:	97ba                	add	a5,a5,a4
     a84:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     a86:	651c                	ld	a5,8(a0)
     a88:	c39d                	beqz	a5,aae <nulterminate+0x54>
     a8a:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     a8e:	67b8                	ld	a4,72(a5)
     a90:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     a94:	07a1                	addi	a5,a5,8
     a96:	ff87b703          	ld	a4,-8(a5)
     a9a:	fb75                	bnez	a4,a8e <nulterminate+0x34>
     a9c:	a809                	j	aae <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     a9e:	6508                	ld	a0,8(a0)
     aa0:	00000097          	auipc	ra,0x0
     aa4:	fba080e7          	jalr	-70(ra) # a5a <nulterminate>
    *rcmd->efile = 0;
     aa8:	6c9c                	ld	a5,24(s1)
     aaa:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     aae:	8526                	mv	a0,s1
     ab0:	60e2                	ld	ra,24(sp)
     ab2:	6442                	ld	s0,16(sp)
     ab4:	64a2                	ld	s1,8(sp)
     ab6:	6105                	addi	sp,sp,32
     ab8:	8082                	ret
    nulterminate(pcmd->left);
     aba:	6508                	ld	a0,8(a0)
     abc:	00000097          	auipc	ra,0x0
     ac0:	f9e080e7          	jalr	-98(ra) # a5a <nulterminate>
    nulterminate(pcmd->right);
     ac4:	6888                	ld	a0,16(s1)
     ac6:	00000097          	auipc	ra,0x0
     aca:	f94080e7          	jalr	-108(ra) # a5a <nulterminate>
    break;
     ace:	b7c5                	j	aae <nulterminate+0x54>
    nulterminate(lcmd->left);
     ad0:	6508                	ld	a0,8(a0)
     ad2:	00000097          	auipc	ra,0x0
     ad6:	f88080e7          	jalr	-120(ra) # a5a <nulterminate>
    nulterminate(lcmd->right);
     ada:	6888                	ld	a0,16(s1)
     adc:	00000097          	auipc	ra,0x0
     ae0:	f7e080e7          	jalr	-130(ra) # a5a <nulterminate>
    break;
     ae4:	b7e9                	j	aae <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     ae6:	6508                	ld	a0,8(a0)
     ae8:	00000097          	auipc	ra,0x0
     aec:	f72080e7          	jalr	-142(ra) # a5a <nulterminate>
    break;
     af0:	bf7d                	j	aae <nulterminate+0x54>

0000000000000af2 <parsecmd>:
{
     af2:	7179                	addi	sp,sp,-48
     af4:	f406                	sd	ra,40(sp)
     af6:	f022                	sd	s0,32(sp)
     af8:	ec26                	sd	s1,24(sp)
     afa:	e84a                	sd	s2,16(sp)
     afc:	1800                	addi	s0,sp,48
     afe:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     b02:	84aa                	mv	s1,a0
     b04:	00000097          	auipc	ra,0x0
     b08:	1b2080e7          	jalr	434(ra) # cb6 <strlen>
     b0c:	1502                	slli	a0,a0,0x20
     b0e:	9101                	srli	a0,a0,0x20
     b10:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     b12:	85a6                	mv	a1,s1
     b14:	fd840513          	addi	a0,s0,-40
     b18:	00000097          	auipc	ra,0x0
     b1c:	df6080e7          	jalr	-522(ra) # 90e <parseline>
     b20:	892a                	mv	s2,a0
  peek(&s, es, "");
     b22:	00001617          	auipc	a2,0x1
     b26:	9d660613          	addi	a2,a2,-1578 # 14f8 <malloc+0x1ce>
     b2a:	85a6                	mv	a1,s1
     b2c:	fd840513          	addi	a0,s0,-40
     b30:	00000097          	auipc	ra,0x0
     b34:	b02080e7          	jalr	-1278(ra) # 632 <peek>
  if(s != es){
     b38:	fd843603          	ld	a2,-40(s0)
     b3c:	00961e63          	bne	a2,s1,b58 <parsecmd+0x66>
  nulterminate(cmd);
     b40:	854a                	mv	a0,s2
     b42:	00000097          	auipc	ra,0x0
     b46:	f18080e7          	jalr	-232(ra) # a5a <nulterminate>
}
     b4a:	854a                	mv	a0,s2
     b4c:	70a2                	ld	ra,40(sp)
     b4e:	7402                	ld	s0,32(sp)
     b50:	64e2                	ld	s1,24(sp)
     b52:	6942                	ld	s2,16(sp)
     b54:	6145                	addi	sp,sp,48
     b56:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     b58:	00001597          	auipc	a1,0x1
     b5c:	9a858593          	addi	a1,a1,-1624 # 1500 <malloc+0x1d6>
     b60:	4509                	li	a0,2
     b62:	00000097          	auipc	ra,0x0
     b66:	6dc080e7          	jalr	1756(ra) # 123e <fprintf>
    panic("syntax");
     b6a:	00001517          	auipc	a0,0x1
     b6e:	92650513          	addi	a0,a0,-1754 # 1490 <malloc+0x166>
     b72:	fffff097          	auipc	ra,0xfffff
     b76:	600080e7          	jalr	1536(ra) # 172 <panic>

0000000000000b7a <main>:
{
     b7a:	7139                	addi	sp,sp,-64
     b7c:	fc06                	sd	ra,56(sp)
     b7e:	f822                	sd	s0,48(sp)
     b80:	f426                	sd	s1,40(sp)
     b82:	f04a                	sd	s2,32(sp)
     b84:	ec4e                	sd	s3,24(sp)
     b86:	e852                	sd	s4,16(sp)
     b88:	e456                	sd	s5,8(sp)
     b8a:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     b8c:	00001497          	auipc	s1,0x1
     b90:	98448493          	addi	s1,s1,-1660 # 1510 <malloc+0x1e6>
     b94:	4589                	li	a1,2
     b96:	8526                	mv	a0,s1
     b98:	00000097          	auipc	ra,0x0
     b9c:	384080e7          	jalr	900(ra) # f1c <open>
     ba0:	00054963          	bltz	a0,bb2 <main+0x38>
    if(fd >= 3){
     ba4:	4789                	li	a5,2
     ba6:	fea7d7e3          	bge	a5,a0,b94 <main+0x1a>
      close(fd);
     baa:	00000097          	auipc	ra,0x0
     bae:	35a080e7          	jalr	858(ra) # f04 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     bb2:	00001497          	auipc	s1,0x1
     bb6:	9de48493          	addi	s1,s1,-1570 # 1590 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bba:	06300913          	li	s2,99
     bbe:	02000993          	li	s3,32
      if(chdir(buf+3) < 0)
     bc2:	00001a17          	auipc	s4,0x1
     bc6:	9d1a0a13          	addi	s4,s4,-1583 # 1593 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     bca:	00001a97          	auipc	s5,0x1
     bce:	94ea8a93          	addi	s5,s5,-1714 # 1518 <malloc+0x1ee>
     bd2:	a819                	j	be8 <main+0x6e>
    if(fork1() == 0)
     bd4:	fffff097          	auipc	ra,0xfffff
     bd8:	5c4080e7          	jalr	1476(ra) # 198 <fork1>
     bdc:	c925                	beqz	a0,c4c <main+0xd2>
    wait(0);
     bde:	4501                	li	a0,0
     be0:	00000097          	auipc	ra,0x0
     be4:	304080e7          	jalr	772(ra) # ee4 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     be8:	06400593          	li	a1,100
     bec:	8526                	mv	a0,s1
     bee:	fffff097          	auipc	ra,0xfffff
     bf2:	530080e7          	jalr	1328(ra) # 11e <getcmd>
     bf6:	06054763          	bltz	a0,c64 <main+0xea>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bfa:	0004c783          	lbu	a5,0(s1)
     bfe:	fd279be3          	bne	a5,s2,bd4 <main+0x5a>
     c02:	0014c703          	lbu	a4,1(s1)
     c06:	06400793          	li	a5,100
     c0a:	fcf715e3          	bne	a4,a5,bd4 <main+0x5a>
     c0e:	0024c783          	lbu	a5,2(s1)
     c12:	fd3791e3          	bne	a5,s3,bd4 <main+0x5a>
      buf[strlen(buf)-1] = 0;  // chop \n
     c16:	8526                	mv	a0,s1
     c18:	00000097          	auipc	ra,0x0
     c1c:	09e080e7          	jalr	158(ra) # cb6 <strlen>
     c20:	fff5079b          	addiw	a5,a0,-1
     c24:	1782                	slli	a5,a5,0x20
     c26:	9381                	srli	a5,a5,0x20
     c28:	97a6                	add	a5,a5,s1
     c2a:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     c2e:	8552                	mv	a0,s4
     c30:	00000097          	auipc	ra,0x0
     c34:	31c080e7          	jalr	796(ra) # f4c <chdir>
     c38:	fa0558e3          	bgez	a0,be8 <main+0x6e>
        fprintf(2, "cannot cd %s\n", buf+3);
     c3c:	8652                	mv	a2,s4
     c3e:	85d6                	mv	a1,s5
     c40:	4509                	li	a0,2
     c42:	00000097          	auipc	ra,0x0
     c46:	5fc080e7          	jalr	1532(ra) # 123e <fprintf>
     c4a:	bf79                	j	be8 <main+0x6e>
      runcmd(parsecmd(buf));
     c4c:	00001517          	auipc	a0,0x1
     c50:	94450513          	addi	a0,a0,-1724 # 1590 <buf.0>
     c54:	00000097          	auipc	ra,0x0
     c58:	e9e080e7          	jalr	-354(ra) # af2 <parsecmd>
     c5c:	fffff097          	auipc	ra,0xfffff
     c60:	56a080e7          	jalr	1386(ra) # 1c6 <runcmd>
  exit(0);
     c64:	4501                	li	a0,0
     c66:	00000097          	auipc	ra,0x0
     c6a:	276080e7          	jalr	630(ra) # edc <exit>

0000000000000c6e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     c6e:	1141                	addi	sp,sp,-16
     c70:	e422                	sd	s0,8(sp)
     c72:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c74:	87aa                	mv	a5,a0
     c76:	0585                	addi	a1,a1,1
     c78:	0785                	addi	a5,a5,1
     c7a:	fff5c703          	lbu	a4,-1(a1)
     c7e:	fee78fa3          	sb	a4,-1(a5)
     c82:	fb75                	bnez	a4,c76 <strcpy+0x8>
    ;
  return os;
}
     c84:	6422                	ld	s0,8(sp)
     c86:	0141                	addi	sp,sp,16
     c88:	8082                	ret

0000000000000c8a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c8a:	1141                	addi	sp,sp,-16
     c8c:	e422                	sd	s0,8(sp)
     c8e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c90:	00054783          	lbu	a5,0(a0)
     c94:	cb91                	beqz	a5,ca8 <strcmp+0x1e>
     c96:	0005c703          	lbu	a4,0(a1)
     c9a:	00f71763          	bne	a4,a5,ca8 <strcmp+0x1e>
    p++, q++;
     c9e:	0505                	addi	a0,a0,1
     ca0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     ca2:	00054783          	lbu	a5,0(a0)
     ca6:	fbe5                	bnez	a5,c96 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     ca8:	0005c503          	lbu	a0,0(a1)
}
     cac:	40a7853b          	subw	a0,a5,a0
     cb0:	6422                	ld	s0,8(sp)
     cb2:	0141                	addi	sp,sp,16
     cb4:	8082                	ret

0000000000000cb6 <strlen>:

uint
strlen(const char *s)
{
     cb6:	1141                	addi	sp,sp,-16
     cb8:	e422                	sd	s0,8(sp)
     cba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     cbc:	00054783          	lbu	a5,0(a0)
     cc0:	cf91                	beqz	a5,cdc <strlen+0x26>
     cc2:	0505                	addi	a0,a0,1
     cc4:	87aa                	mv	a5,a0
     cc6:	4685                	li	a3,1
     cc8:	9e89                	subw	a3,a3,a0
     cca:	00f6853b          	addw	a0,a3,a5
     cce:	0785                	addi	a5,a5,1
     cd0:	fff7c703          	lbu	a4,-1(a5)
     cd4:	fb7d                	bnez	a4,cca <strlen+0x14>
    ;
  return n;
}
     cd6:	6422                	ld	s0,8(sp)
     cd8:	0141                	addi	sp,sp,16
     cda:	8082                	ret
  for(n = 0; s[n]; n++)
     cdc:	4501                	li	a0,0
     cde:	bfe5                	j	cd6 <strlen+0x20>

0000000000000ce0 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ce0:	1141                	addi	sp,sp,-16
     ce2:	e422                	sd	s0,8(sp)
     ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ce6:	ca19                	beqz	a2,cfc <memset+0x1c>
     ce8:	87aa                	mv	a5,a0
     cea:	1602                	slli	a2,a2,0x20
     cec:	9201                	srli	a2,a2,0x20
     cee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cf2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cf6:	0785                	addi	a5,a5,1
     cf8:	fee79de3          	bne	a5,a4,cf2 <memset+0x12>
  }
  return dst;
}
     cfc:	6422                	ld	s0,8(sp)
     cfe:	0141                	addi	sp,sp,16
     d00:	8082                	ret

0000000000000d02 <strchr>:

char*
strchr(const char *s, char c)
{
     d02:	1141                	addi	sp,sp,-16
     d04:	e422                	sd	s0,8(sp)
     d06:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d08:	00054783          	lbu	a5,0(a0)
     d0c:	cb99                	beqz	a5,d22 <strchr+0x20>
    if(*s == c)
     d0e:	00f58763          	beq	a1,a5,d1c <strchr+0x1a>
  for(; *s; s++)
     d12:	0505                	addi	a0,a0,1
     d14:	00054783          	lbu	a5,0(a0)
     d18:	fbfd                	bnez	a5,d0e <strchr+0xc>
      return (char*)s;
  return 0;
     d1a:	4501                	li	a0,0
}
     d1c:	6422                	ld	s0,8(sp)
     d1e:	0141                	addi	sp,sp,16
     d20:	8082                	ret
  return 0;
     d22:	4501                	li	a0,0
     d24:	bfe5                	j	d1c <strchr+0x1a>

0000000000000d26 <gets>:

char*
gets(char *buf, int max)
{
     d26:	711d                	addi	sp,sp,-96
     d28:	ec86                	sd	ra,88(sp)
     d2a:	e8a2                	sd	s0,80(sp)
     d2c:	e4a6                	sd	s1,72(sp)
     d2e:	e0ca                	sd	s2,64(sp)
     d30:	fc4e                	sd	s3,56(sp)
     d32:	f852                	sd	s4,48(sp)
     d34:	f456                	sd	s5,40(sp)
     d36:	f05a                	sd	s6,32(sp)
     d38:	ec5e                	sd	s7,24(sp)
     d3a:	1080                	addi	s0,sp,96
     d3c:	8baa                	mv	s7,a0
     d3e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d40:	892a                	mv	s2,a0
     d42:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d44:	4aa9                	li	s5,10
     d46:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d48:	89a6                	mv	s3,s1
     d4a:	2485                	addiw	s1,s1,1
     d4c:	0344d863          	bge	s1,s4,d7c <gets+0x56>
    cc = read(0, &c, 1);
     d50:	4605                	li	a2,1
     d52:	faf40593          	addi	a1,s0,-81
     d56:	4501                	li	a0,0
     d58:	00000097          	auipc	ra,0x0
     d5c:	19c080e7          	jalr	412(ra) # ef4 <read>
    if(cc < 1)
     d60:	00a05e63          	blez	a0,d7c <gets+0x56>
    buf[i++] = c;
     d64:	faf44783          	lbu	a5,-81(s0)
     d68:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d6c:	01578763          	beq	a5,s5,d7a <gets+0x54>
     d70:	0905                	addi	s2,s2,1
     d72:	fd679be3          	bne	a5,s6,d48 <gets+0x22>
  for(i=0; i+1 < max; ){
     d76:	89a6                	mv	s3,s1
     d78:	a011                	j	d7c <gets+0x56>
     d7a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d7c:	99de                	add	s3,s3,s7
     d7e:	00098023          	sb	zero,0(s3)
  return buf;
}
     d82:	855e                	mv	a0,s7
     d84:	60e6                	ld	ra,88(sp)
     d86:	6446                	ld	s0,80(sp)
     d88:	64a6                	ld	s1,72(sp)
     d8a:	6906                	ld	s2,64(sp)
     d8c:	79e2                	ld	s3,56(sp)
     d8e:	7a42                	ld	s4,48(sp)
     d90:	7aa2                	ld	s5,40(sp)
     d92:	7b02                	ld	s6,32(sp)
     d94:	6be2                	ld	s7,24(sp)
     d96:	6125                	addi	sp,sp,96
     d98:	8082                	ret

0000000000000d9a <stat>:

int
stat(const char *n, struct stat *st)
{
     d9a:	1101                	addi	sp,sp,-32
     d9c:	ec06                	sd	ra,24(sp)
     d9e:	e822                	sd	s0,16(sp)
     da0:	e426                	sd	s1,8(sp)
     da2:	e04a                	sd	s2,0(sp)
     da4:	1000                	addi	s0,sp,32
     da6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     da8:	4581                	li	a1,0
     daa:	00000097          	auipc	ra,0x0
     dae:	172080e7          	jalr	370(ra) # f1c <open>
  if(fd < 0)
     db2:	02054563          	bltz	a0,ddc <stat+0x42>
     db6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     db8:	85ca                	mv	a1,s2
     dba:	00000097          	auipc	ra,0x0
     dbe:	17a080e7          	jalr	378(ra) # f34 <fstat>
     dc2:	892a                	mv	s2,a0
  close(fd);
     dc4:	8526                	mv	a0,s1
     dc6:	00000097          	auipc	ra,0x0
     dca:	13e080e7          	jalr	318(ra) # f04 <close>
  return r;
}
     dce:	854a                	mv	a0,s2
     dd0:	60e2                	ld	ra,24(sp)
     dd2:	6442                	ld	s0,16(sp)
     dd4:	64a2                	ld	s1,8(sp)
     dd6:	6902                	ld	s2,0(sp)
     dd8:	6105                	addi	sp,sp,32
     dda:	8082                	ret
    return -1;
     ddc:	597d                	li	s2,-1
     dde:	bfc5                	j	dce <stat+0x34>

0000000000000de0 <atoi>:

int
atoi(const char *s)
{
     de0:	1141                	addi	sp,sp,-16
     de2:	e422                	sd	s0,8(sp)
     de4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     de6:	00054603          	lbu	a2,0(a0)
     dea:	fd06079b          	addiw	a5,a2,-48
     dee:	0ff7f793          	andi	a5,a5,255
     df2:	4725                	li	a4,9
     df4:	02f76963          	bltu	a4,a5,e26 <atoi+0x46>
     df8:	86aa                	mv	a3,a0
  n = 0;
     dfa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     dfc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     dfe:	0685                	addi	a3,a3,1
     e00:	0025179b          	slliw	a5,a0,0x2
     e04:	9fa9                	addw	a5,a5,a0
     e06:	0017979b          	slliw	a5,a5,0x1
     e0a:	9fb1                	addw	a5,a5,a2
     e0c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e10:	0006c603          	lbu	a2,0(a3)
     e14:	fd06071b          	addiw	a4,a2,-48
     e18:	0ff77713          	andi	a4,a4,255
     e1c:	fee5f1e3          	bgeu	a1,a4,dfe <atoi+0x1e>
  return n;
}
     e20:	6422                	ld	s0,8(sp)
     e22:	0141                	addi	sp,sp,16
     e24:	8082                	ret
  n = 0;
     e26:	4501                	li	a0,0
     e28:	bfe5                	j	e20 <atoi+0x40>

0000000000000e2a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e2a:	1141                	addi	sp,sp,-16
     e2c:	e422                	sd	s0,8(sp)
     e2e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e30:	02b57463          	bgeu	a0,a1,e58 <memmove+0x2e>
    while(n-- > 0)
     e34:	00c05f63          	blez	a2,e52 <memmove+0x28>
     e38:	1602                	slli	a2,a2,0x20
     e3a:	9201                	srli	a2,a2,0x20
     e3c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e40:	872a                	mv	a4,a0
      *dst++ = *src++;
     e42:	0585                	addi	a1,a1,1
     e44:	0705                	addi	a4,a4,1
     e46:	fff5c683          	lbu	a3,-1(a1)
     e4a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e4e:	fee79ae3          	bne	a5,a4,e42 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e52:	6422                	ld	s0,8(sp)
     e54:	0141                	addi	sp,sp,16
     e56:	8082                	ret
    dst += n;
     e58:	00c50733          	add	a4,a0,a2
    src += n;
     e5c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e5e:	fec05ae3          	blez	a2,e52 <memmove+0x28>
     e62:	fff6079b          	addiw	a5,a2,-1
     e66:	1782                	slli	a5,a5,0x20
     e68:	9381                	srli	a5,a5,0x20
     e6a:	fff7c793          	not	a5,a5
     e6e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e70:	15fd                	addi	a1,a1,-1
     e72:	177d                	addi	a4,a4,-1
     e74:	0005c683          	lbu	a3,0(a1)
     e78:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e7c:	fee79ae3          	bne	a5,a4,e70 <memmove+0x46>
     e80:	bfc9                	j	e52 <memmove+0x28>

0000000000000e82 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e82:	1141                	addi	sp,sp,-16
     e84:	e422                	sd	s0,8(sp)
     e86:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e88:	ca05                	beqz	a2,eb8 <memcmp+0x36>
     e8a:	fff6069b          	addiw	a3,a2,-1
     e8e:	1682                	slli	a3,a3,0x20
     e90:	9281                	srli	a3,a3,0x20
     e92:	0685                	addi	a3,a3,1
     e94:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e96:	00054783          	lbu	a5,0(a0)
     e9a:	0005c703          	lbu	a4,0(a1)
     e9e:	00e79863          	bne	a5,a4,eae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     ea2:	0505                	addi	a0,a0,1
    p2++;
     ea4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     ea6:	fed518e3          	bne	a0,a3,e96 <memcmp+0x14>
  }
  return 0;
     eaa:	4501                	li	a0,0
     eac:	a019                	j	eb2 <memcmp+0x30>
      return *p1 - *p2;
     eae:	40e7853b          	subw	a0,a5,a4
}
     eb2:	6422                	ld	s0,8(sp)
     eb4:	0141                	addi	sp,sp,16
     eb6:	8082                	ret
  return 0;
     eb8:	4501                	li	a0,0
     eba:	bfe5                	j	eb2 <memcmp+0x30>

0000000000000ebc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     ebc:	1141                	addi	sp,sp,-16
     ebe:	e406                	sd	ra,8(sp)
     ec0:	e022                	sd	s0,0(sp)
     ec2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ec4:	00000097          	auipc	ra,0x0
     ec8:	f66080e7          	jalr	-154(ra) # e2a <memmove>
}
     ecc:	60a2                	ld	ra,8(sp)
     ece:	6402                	ld	s0,0(sp)
     ed0:	0141                	addi	sp,sp,16
     ed2:	8082                	ret

0000000000000ed4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ed4:	4885                	li	a7,1
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <exit>:
.global exit
exit:
 li a7, SYS_exit
     edc:	4889                	li	a7,2
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ee4:	488d                	li	a7,3
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eec:	4891                	li	a7,4
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <read>:
.global read
read:
 li a7, SYS_read
     ef4:	4895                	li	a7,5
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <write>:
.global write
write:
 li a7, SYS_write
     efc:	48c1                	li	a7,16
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <close>:
.global close
close:
 li a7, SYS_close
     f04:	48d5                	li	a7,21
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <kill>:
.global kill
kill:
 li a7, SYS_kill
     f0c:	4899                	li	a7,6
 ecall
     f0e:	00000073          	ecall
 ret
     f12:	8082                	ret

0000000000000f14 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f14:	489d                	li	a7,7
 ecall
     f16:	00000073          	ecall
 ret
     f1a:	8082                	ret

0000000000000f1c <open>:
.global open
open:
 li a7, SYS_open
     f1c:	48bd                	li	a7,15
 ecall
     f1e:	00000073          	ecall
 ret
     f22:	8082                	ret

0000000000000f24 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f24:	48c5                	li	a7,17
 ecall
     f26:	00000073          	ecall
 ret
     f2a:	8082                	ret

0000000000000f2c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f2c:	48c9                	li	a7,18
 ecall
     f2e:	00000073          	ecall
 ret
     f32:	8082                	ret

0000000000000f34 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f34:	48a1                	li	a7,8
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <link>:
.global link
link:
 li a7, SYS_link
     f3c:	48cd                	li	a7,19
 ecall
     f3e:	00000073          	ecall
 ret
     f42:	8082                	ret

0000000000000f44 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f44:	48d1                	li	a7,20
 ecall
     f46:	00000073          	ecall
 ret
     f4a:	8082                	ret

0000000000000f4c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f4c:	48a5                	li	a7,9
 ecall
     f4e:	00000073          	ecall
 ret
     f52:	8082                	ret

0000000000000f54 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f54:	48a9                	li	a7,10
 ecall
     f56:	00000073          	ecall
 ret
     f5a:	8082                	ret

0000000000000f5c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f5c:	48ad                	li	a7,11
 ecall
     f5e:	00000073          	ecall
 ret
     f62:	8082                	ret

0000000000000f64 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f64:	48b1                	li	a7,12
 ecall
     f66:	00000073          	ecall
 ret
     f6a:	8082                	ret

0000000000000f6c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f6c:	48b5                	li	a7,13
 ecall
     f6e:	00000073          	ecall
 ret
     f72:	8082                	ret

0000000000000f74 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f74:	48b9                	li	a7,14
 ecall
     f76:	00000073          	ecall
 ret
     f7a:	8082                	ret

0000000000000f7c <trace>:
.global trace
trace:
 li a7, SYS_trace
     f7c:	48d9                	li	a7,22
 ecall
     f7e:	00000073          	ecall
 ret
     f82:	8082                	ret

0000000000000f84 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
     f84:	48dd                	li	a7,23
 ecall
     f86:	00000073          	ecall
 ret
     f8a:	8082                	ret

0000000000000f8c <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
     f8c:	48e1                	li	a7,24
 ecall
     f8e:	00000073          	ecall
 ret
     f92:	8082                	ret

0000000000000f94 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f94:	1101                	addi	sp,sp,-32
     f96:	ec06                	sd	ra,24(sp)
     f98:	e822                	sd	s0,16(sp)
     f9a:	1000                	addi	s0,sp,32
     f9c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     fa0:	4605                	li	a2,1
     fa2:	fef40593          	addi	a1,s0,-17
     fa6:	00000097          	auipc	ra,0x0
     faa:	f56080e7          	jalr	-170(ra) # efc <write>
}
     fae:	60e2                	ld	ra,24(sp)
     fb0:	6442                	ld	s0,16(sp)
     fb2:	6105                	addi	sp,sp,32
     fb4:	8082                	ret

0000000000000fb6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fb6:	7139                	addi	sp,sp,-64
     fb8:	fc06                	sd	ra,56(sp)
     fba:	f822                	sd	s0,48(sp)
     fbc:	f426                	sd	s1,40(sp)
     fbe:	f04a                	sd	s2,32(sp)
     fc0:	ec4e                	sd	s3,24(sp)
     fc2:	0080                	addi	s0,sp,64
     fc4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fc6:	c299                	beqz	a3,fcc <printint+0x16>
     fc8:	0805c863          	bltz	a1,1058 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fcc:	2581                	sext.w	a1,a1
  neg = 0;
     fce:	4881                	li	a7,0
     fd0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fd4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fd6:	2601                	sext.w	a2,a2
     fd8:	00000517          	auipc	a0,0x0
     fdc:	58850513          	addi	a0,a0,1416 # 1560 <digits>
     fe0:	883a                	mv	a6,a4
     fe2:	2705                	addiw	a4,a4,1
     fe4:	02c5f7bb          	remuw	a5,a1,a2
     fe8:	1782                	slli	a5,a5,0x20
     fea:	9381                	srli	a5,a5,0x20
     fec:	97aa                	add	a5,a5,a0
     fee:	0007c783          	lbu	a5,0(a5)
     ff2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     ff6:	0005879b          	sext.w	a5,a1
     ffa:	02c5d5bb          	divuw	a1,a1,a2
     ffe:	0685                	addi	a3,a3,1
    1000:	fec7f0e3          	bgeu	a5,a2,fe0 <printint+0x2a>
  if(neg)
    1004:	00088b63          	beqz	a7,101a <printint+0x64>
    buf[i++] = '-';
    1008:	fd040793          	addi	a5,s0,-48
    100c:	973e                	add	a4,a4,a5
    100e:	02d00793          	li	a5,45
    1012:	fef70823          	sb	a5,-16(a4)
    1016:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    101a:	02e05863          	blez	a4,104a <printint+0x94>
    101e:	fc040793          	addi	a5,s0,-64
    1022:	00e78933          	add	s2,a5,a4
    1026:	fff78993          	addi	s3,a5,-1
    102a:	99ba                	add	s3,s3,a4
    102c:	377d                	addiw	a4,a4,-1
    102e:	1702                	slli	a4,a4,0x20
    1030:	9301                	srli	a4,a4,0x20
    1032:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1036:	fff94583          	lbu	a1,-1(s2)
    103a:	8526                	mv	a0,s1
    103c:	00000097          	auipc	ra,0x0
    1040:	f58080e7          	jalr	-168(ra) # f94 <putc>
  while(--i >= 0)
    1044:	197d                	addi	s2,s2,-1
    1046:	ff3918e3          	bne	s2,s3,1036 <printint+0x80>
}
    104a:	70e2                	ld	ra,56(sp)
    104c:	7442                	ld	s0,48(sp)
    104e:	74a2                	ld	s1,40(sp)
    1050:	7902                	ld	s2,32(sp)
    1052:	69e2                	ld	s3,24(sp)
    1054:	6121                	addi	sp,sp,64
    1056:	8082                	ret
    x = -xx;
    1058:	40b005bb          	negw	a1,a1
    neg = 1;
    105c:	4885                	li	a7,1
    x = -xx;
    105e:	bf8d                	j	fd0 <printint+0x1a>

0000000000001060 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1060:	7119                	addi	sp,sp,-128
    1062:	fc86                	sd	ra,120(sp)
    1064:	f8a2                	sd	s0,112(sp)
    1066:	f4a6                	sd	s1,104(sp)
    1068:	f0ca                	sd	s2,96(sp)
    106a:	ecce                	sd	s3,88(sp)
    106c:	e8d2                	sd	s4,80(sp)
    106e:	e4d6                	sd	s5,72(sp)
    1070:	e0da                	sd	s6,64(sp)
    1072:	fc5e                	sd	s7,56(sp)
    1074:	f862                	sd	s8,48(sp)
    1076:	f466                	sd	s9,40(sp)
    1078:	f06a                	sd	s10,32(sp)
    107a:	ec6e                	sd	s11,24(sp)
    107c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    107e:	0005c903          	lbu	s2,0(a1)
    1082:	18090f63          	beqz	s2,1220 <vprintf+0x1c0>
    1086:	8aaa                	mv	s5,a0
    1088:	8b32                	mv	s6,a2
    108a:	00158493          	addi	s1,a1,1
  state = 0;
    108e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1090:	02500a13          	li	s4,37
      if(c == 'd'){
    1094:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1098:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    109c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    10a0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10a4:	00000b97          	auipc	s7,0x0
    10a8:	4bcb8b93          	addi	s7,s7,1212 # 1560 <digits>
    10ac:	a839                	j	10ca <vprintf+0x6a>
        putc(fd, c);
    10ae:	85ca                	mv	a1,s2
    10b0:	8556                	mv	a0,s5
    10b2:	00000097          	auipc	ra,0x0
    10b6:	ee2080e7          	jalr	-286(ra) # f94 <putc>
    10ba:	a019                	j	10c0 <vprintf+0x60>
    } else if(state == '%'){
    10bc:	01498f63          	beq	s3,s4,10da <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    10c0:	0485                	addi	s1,s1,1
    10c2:	fff4c903          	lbu	s2,-1(s1)
    10c6:	14090d63          	beqz	s2,1220 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10ca:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10ce:	fe0997e3          	bnez	s3,10bc <vprintf+0x5c>
      if(c == '%'){
    10d2:	fd479ee3          	bne	a5,s4,10ae <vprintf+0x4e>
        state = '%';
    10d6:	89be                	mv	s3,a5
    10d8:	b7e5                	j	10c0 <vprintf+0x60>
      if(c == 'd'){
    10da:	05878063          	beq	a5,s8,111a <vprintf+0xba>
      } else if(c == 'l') {
    10de:	05978c63          	beq	a5,s9,1136 <vprintf+0xd6>
      } else if(c == 'x') {
    10e2:	07a78863          	beq	a5,s10,1152 <vprintf+0xf2>
      } else if(c == 'p') {
    10e6:	09b78463          	beq	a5,s11,116e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10ea:	07300713          	li	a4,115
    10ee:	0ce78663          	beq	a5,a4,11ba <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10f2:	06300713          	li	a4,99
    10f6:	0ee78e63          	beq	a5,a4,11f2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10fa:	11478863          	beq	a5,s4,120a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10fe:	85d2                	mv	a1,s4
    1100:	8556                	mv	a0,s5
    1102:	00000097          	auipc	ra,0x0
    1106:	e92080e7          	jalr	-366(ra) # f94 <putc>
        putc(fd, c);
    110a:	85ca                	mv	a1,s2
    110c:	8556                	mv	a0,s5
    110e:	00000097          	auipc	ra,0x0
    1112:	e86080e7          	jalr	-378(ra) # f94 <putc>
      }
      state = 0;
    1116:	4981                	li	s3,0
    1118:	b765                	j	10c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    111a:	008b0913          	addi	s2,s6,8
    111e:	4685                	li	a3,1
    1120:	4629                	li	a2,10
    1122:	000b2583          	lw	a1,0(s6)
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	e8e080e7          	jalr	-370(ra) # fb6 <printint>
    1130:	8b4a                	mv	s6,s2
      state = 0;
    1132:	4981                	li	s3,0
    1134:	b771                	j	10c0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1136:	008b0913          	addi	s2,s6,8
    113a:	4681                	li	a3,0
    113c:	4629                	li	a2,10
    113e:	000b2583          	lw	a1,0(s6)
    1142:	8556                	mv	a0,s5
    1144:	00000097          	auipc	ra,0x0
    1148:	e72080e7          	jalr	-398(ra) # fb6 <printint>
    114c:	8b4a                	mv	s6,s2
      state = 0;
    114e:	4981                	li	s3,0
    1150:	bf85                	j	10c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1152:	008b0913          	addi	s2,s6,8
    1156:	4681                	li	a3,0
    1158:	4641                	li	a2,16
    115a:	000b2583          	lw	a1,0(s6)
    115e:	8556                	mv	a0,s5
    1160:	00000097          	auipc	ra,0x0
    1164:	e56080e7          	jalr	-426(ra) # fb6 <printint>
    1168:	8b4a                	mv	s6,s2
      state = 0;
    116a:	4981                	li	s3,0
    116c:	bf91                	j	10c0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    116e:	008b0793          	addi	a5,s6,8
    1172:	f8f43423          	sd	a5,-120(s0)
    1176:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    117a:	03000593          	li	a1,48
    117e:	8556                	mv	a0,s5
    1180:	00000097          	auipc	ra,0x0
    1184:	e14080e7          	jalr	-492(ra) # f94 <putc>
  putc(fd, 'x');
    1188:	85ea                	mv	a1,s10
    118a:	8556                	mv	a0,s5
    118c:	00000097          	auipc	ra,0x0
    1190:	e08080e7          	jalr	-504(ra) # f94 <putc>
    1194:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1196:	03c9d793          	srli	a5,s3,0x3c
    119a:	97de                	add	a5,a5,s7
    119c:	0007c583          	lbu	a1,0(a5)
    11a0:	8556                	mv	a0,s5
    11a2:	00000097          	auipc	ra,0x0
    11a6:	df2080e7          	jalr	-526(ra) # f94 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11aa:	0992                	slli	s3,s3,0x4
    11ac:	397d                	addiw	s2,s2,-1
    11ae:	fe0914e3          	bnez	s2,1196 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    11b2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    11b6:	4981                	li	s3,0
    11b8:	b721                	j	10c0 <vprintf+0x60>
        s = va_arg(ap, char*);
    11ba:	008b0993          	addi	s3,s6,8
    11be:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    11c2:	02090163          	beqz	s2,11e4 <vprintf+0x184>
        while(*s != 0){
    11c6:	00094583          	lbu	a1,0(s2)
    11ca:	c9a1                	beqz	a1,121a <vprintf+0x1ba>
          putc(fd, *s);
    11cc:	8556                	mv	a0,s5
    11ce:	00000097          	auipc	ra,0x0
    11d2:	dc6080e7          	jalr	-570(ra) # f94 <putc>
          s++;
    11d6:	0905                	addi	s2,s2,1
        while(*s != 0){
    11d8:	00094583          	lbu	a1,0(s2)
    11dc:	f9e5                	bnez	a1,11cc <vprintf+0x16c>
        s = va_arg(ap, char*);
    11de:	8b4e                	mv	s6,s3
      state = 0;
    11e0:	4981                	li	s3,0
    11e2:	bdf9                	j	10c0 <vprintf+0x60>
          s = "(null)";
    11e4:	00000917          	auipc	s2,0x0
    11e8:	37490913          	addi	s2,s2,884 # 1558 <malloc+0x22e>
        while(*s != 0){
    11ec:	02800593          	li	a1,40
    11f0:	bff1                	j	11cc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11f2:	008b0913          	addi	s2,s6,8
    11f6:	000b4583          	lbu	a1,0(s6)
    11fa:	8556                	mv	a0,s5
    11fc:	00000097          	auipc	ra,0x0
    1200:	d98080e7          	jalr	-616(ra) # f94 <putc>
    1204:	8b4a                	mv	s6,s2
      state = 0;
    1206:	4981                	li	s3,0
    1208:	bd65                	j	10c0 <vprintf+0x60>
        putc(fd, c);
    120a:	85d2                	mv	a1,s4
    120c:	8556                	mv	a0,s5
    120e:	00000097          	auipc	ra,0x0
    1212:	d86080e7          	jalr	-634(ra) # f94 <putc>
      state = 0;
    1216:	4981                	li	s3,0
    1218:	b565                	j	10c0 <vprintf+0x60>
        s = va_arg(ap, char*);
    121a:	8b4e                	mv	s6,s3
      state = 0;
    121c:	4981                	li	s3,0
    121e:	b54d                	j	10c0 <vprintf+0x60>
    }
  }
}
    1220:	70e6                	ld	ra,120(sp)
    1222:	7446                	ld	s0,112(sp)
    1224:	74a6                	ld	s1,104(sp)
    1226:	7906                	ld	s2,96(sp)
    1228:	69e6                	ld	s3,88(sp)
    122a:	6a46                	ld	s4,80(sp)
    122c:	6aa6                	ld	s5,72(sp)
    122e:	6b06                	ld	s6,64(sp)
    1230:	7be2                	ld	s7,56(sp)
    1232:	7c42                	ld	s8,48(sp)
    1234:	7ca2                	ld	s9,40(sp)
    1236:	7d02                	ld	s10,32(sp)
    1238:	6de2                	ld	s11,24(sp)
    123a:	6109                	addi	sp,sp,128
    123c:	8082                	ret

000000000000123e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    123e:	715d                	addi	sp,sp,-80
    1240:	ec06                	sd	ra,24(sp)
    1242:	e822                	sd	s0,16(sp)
    1244:	1000                	addi	s0,sp,32
    1246:	e010                	sd	a2,0(s0)
    1248:	e414                	sd	a3,8(s0)
    124a:	e818                	sd	a4,16(s0)
    124c:	ec1c                	sd	a5,24(s0)
    124e:	03043023          	sd	a6,32(s0)
    1252:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1256:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    125a:	8622                	mv	a2,s0
    125c:	00000097          	auipc	ra,0x0
    1260:	e04080e7          	jalr	-508(ra) # 1060 <vprintf>
}
    1264:	60e2                	ld	ra,24(sp)
    1266:	6442                	ld	s0,16(sp)
    1268:	6161                	addi	sp,sp,80
    126a:	8082                	ret

000000000000126c <printf>:

void
printf(const char *fmt, ...)
{
    126c:	711d                	addi	sp,sp,-96
    126e:	ec06                	sd	ra,24(sp)
    1270:	e822                	sd	s0,16(sp)
    1272:	1000                	addi	s0,sp,32
    1274:	e40c                	sd	a1,8(s0)
    1276:	e810                	sd	a2,16(s0)
    1278:	ec14                	sd	a3,24(s0)
    127a:	f018                	sd	a4,32(s0)
    127c:	f41c                	sd	a5,40(s0)
    127e:	03043823          	sd	a6,48(s0)
    1282:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1286:	00840613          	addi	a2,s0,8
    128a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    128e:	85aa                	mv	a1,a0
    1290:	4505                	li	a0,1
    1292:	00000097          	auipc	ra,0x0
    1296:	dce080e7          	jalr	-562(ra) # 1060 <vprintf>
}
    129a:	60e2                	ld	ra,24(sp)
    129c:	6442                	ld	s0,16(sp)
    129e:	6125                	addi	sp,sp,96
    12a0:	8082                	ret

00000000000012a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12a2:	1141                	addi	sp,sp,-16
    12a4:	e422                	sd	s0,8(sp)
    12a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12ac:	00000797          	auipc	a5,0x0
    12b0:	2dc7b783          	ld	a5,732(a5) # 1588 <freep>
    12b4:	a805                	j	12e4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    12b6:	4618                	lw	a4,8(a2)
    12b8:	9db9                	addw	a1,a1,a4
    12ba:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    12be:	6398                	ld	a4,0(a5)
    12c0:	6318                	ld	a4,0(a4)
    12c2:	fee53823          	sd	a4,-16(a0)
    12c6:	a091                	j	130a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12c8:	ff852703          	lw	a4,-8(a0)
    12cc:	9e39                	addw	a2,a2,a4
    12ce:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12d0:	ff053703          	ld	a4,-16(a0)
    12d4:	e398                	sd	a4,0(a5)
    12d6:	a099                	j	131c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12d8:	6398                	ld	a4,0(a5)
    12da:	00e7e463          	bltu	a5,a4,12e2 <free+0x40>
    12de:	00e6ea63          	bltu	a3,a4,12f2 <free+0x50>
{
    12e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12e4:	fed7fae3          	bgeu	a5,a3,12d8 <free+0x36>
    12e8:	6398                	ld	a4,0(a5)
    12ea:	00e6e463          	bltu	a3,a4,12f2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12ee:	fee7eae3          	bltu	a5,a4,12e2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12f2:	ff852583          	lw	a1,-8(a0)
    12f6:	6390                	ld	a2,0(a5)
    12f8:	02059813          	slli	a6,a1,0x20
    12fc:	01c85713          	srli	a4,a6,0x1c
    1300:	9736                	add	a4,a4,a3
    1302:	fae60ae3          	beq	a2,a4,12b6 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1306:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    130a:	4790                	lw	a2,8(a5)
    130c:	02061593          	slli	a1,a2,0x20
    1310:	01c5d713          	srli	a4,a1,0x1c
    1314:	973e                	add	a4,a4,a5
    1316:	fae689e3          	beq	a3,a4,12c8 <free+0x26>
  } else
    p->s.ptr = bp;
    131a:	e394                	sd	a3,0(a5)
  freep = p;
    131c:	00000717          	auipc	a4,0x0
    1320:	26f73623          	sd	a5,620(a4) # 1588 <freep>
}
    1324:	6422                	ld	s0,8(sp)
    1326:	0141                	addi	sp,sp,16
    1328:	8082                	ret

000000000000132a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    132a:	7139                	addi	sp,sp,-64
    132c:	fc06                	sd	ra,56(sp)
    132e:	f822                	sd	s0,48(sp)
    1330:	f426                	sd	s1,40(sp)
    1332:	f04a                	sd	s2,32(sp)
    1334:	ec4e                	sd	s3,24(sp)
    1336:	e852                	sd	s4,16(sp)
    1338:	e456                	sd	s5,8(sp)
    133a:	e05a                	sd	s6,0(sp)
    133c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    133e:	02051493          	slli	s1,a0,0x20
    1342:	9081                	srli	s1,s1,0x20
    1344:	04bd                	addi	s1,s1,15
    1346:	8091                	srli	s1,s1,0x4
    1348:	0014899b          	addiw	s3,s1,1
    134c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    134e:	00000517          	auipc	a0,0x0
    1352:	23a53503          	ld	a0,570(a0) # 1588 <freep>
    1356:	c515                	beqz	a0,1382 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1358:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    135a:	4798                	lw	a4,8(a5)
    135c:	02977f63          	bgeu	a4,s1,139a <malloc+0x70>
    1360:	8a4e                	mv	s4,s3
    1362:	0009871b          	sext.w	a4,s3
    1366:	6685                	lui	a3,0x1
    1368:	00d77363          	bgeu	a4,a3,136e <malloc+0x44>
    136c:	6a05                	lui	s4,0x1
    136e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1372:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1376:	00000917          	auipc	s2,0x0
    137a:	21290913          	addi	s2,s2,530 # 1588 <freep>
  if(p == (char*)-1)
    137e:	5afd                	li	s5,-1
    1380:	a895                	j	13f4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1382:	00000797          	auipc	a5,0x0
    1386:	27678793          	addi	a5,a5,630 # 15f8 <base>
    138a:	00000717          	auipc	a4,0x0
    138e:	1ef73f23          	sd	a5,510(a4) # 1588 <freep>
    1392:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1394:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1398:	b7e1                	j	1360 <malloc+0x36>
      if(p->s.size == nunits)
    139a:	02e48c63          	beq	s1,a4,13d2 <malloc+0xa8>
        p->s.size -= nunits;
    139e:	4137073b          	subw	a4,a4,s3
    13a2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13a4:	02071693          	slli	a3,a4,0x20
    13a8:	01c6d713          	srli	a4,a3,0x1c
    13ac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13ae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13b2:	00000717          	auipc	a4,0x0
    13b6:	1ca73b23          	sd	a0,470(a4) # 1588 <freep>
      return (void*)(p + 1);
    13ba:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    13be:	70e2                	ld	ra,56(sp)
    13c0:	7442                	ld	s0,48(sp)
    13c2:	74a2                	ld	s1,40(sp)
    13c4:	7902                	ld	s2,32(sp)
    13c6:	69e2                	ld	s3,24(sp)
    13c8:	6a42                	ld	s4,16(sp)
    13ca:	6aa2                	ld	s5,8(sp)
    13cc:	6b02                	ld	s6,0(sp)
    13ce:	6121                	addi	sp,sp,64
    13d0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13d2:	6398                	ld	a4,0(a5)
    13d4:	e118                	sd	a4,0(a0)
    13d6:	bff1                	j	13b2 <malloc+0x88>
  hp->s.size = nu;
    13d8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13dc:	0541                	addi	a0,a0,16
    13de:	00000097          	auipc	ra,0x0
    13e2:	ec4080e7          	jalr	-316(ra) # 12a2 <free>
  return freep;
    13e6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13ea:	d971                	beqz	a0,13be <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13ee:	4798                	lw	a4,8(a5)
    13f0:	fa9775e3          	bgeu	a4,s1,139a <malloc+0x70>
    if(p == freep)
    13f4:	00093703          	ld	a4,0(s2)
    13f8:	853e                	mv	a0,a5
    13fa:	fef719e3          	bne	a4,a5,13ec <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    13fe:	8552                	mv	a0,s4
    1400:	00000097          	auipc	ra,0x0
    1404:	b64080e7          	jalr	-1180(ra) # f64 <sbrk>
  if(p == (char*)-1)
    1408:	fd5518e3          	bne	a0,s5,13d8 <malloc+0xae>
        return 0;
    140c:	4501                	li	a0,0
    140e:	bf45                	j	13be <malloc+0x94>
