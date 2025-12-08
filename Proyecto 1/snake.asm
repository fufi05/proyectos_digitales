
snake.elf:     file format elf32-littleriscv


Disassembly of section .text:

00010054 <_start>:
   10054:	40000537          	lui	a0,0x40000
   10058:	00c00593          	li	a1,12
   1005c:	00c00613          	li	a2,12
   10060:	0032d6b7          	lui	a3,0x32d
   10064:	d3268693          	addi	a3,a3,-718 # 32cd32 <__global_pointer$+0x31b29a>
   10068:	00000713          	li	a4,0
   1006c:	00000793          	li	a5,0
   10070:	00000813          	li	a6,0
   10074:	00000893          	li	a7,0
   10078:	10010bb7          	lui	s7,0x10010
   1007c:	00000c13          	li	s8,0
   10080:	00000c93          	li	s9,0
   10084:	00300d13          	li	s10,3
   10088:	09400d93          	li	s11,148
   1008c:	000ba023          	sw	zero,0(s7) # 10010000 <__global_pointer$+0xfffe568>
   10090:	000ba223          	sw	zero,4(s7)
   10094:	000ba423          	sw	zero,8(s7)
   10098:	00300c93          	li	s9,3
   1009c:	00d52023          	sw	a3,0(a0) # 40000000 <LED_MATRIX_0_BASE>
   100a0:	00000413          	li	s0,0
   100a4:	f0000337          	lui	t1,0xf0000
   100a8:	f00003b7          	lui	t2,0xf0000
   100ac:	00438393          	addi	t2,t2,4 # f0000004 <LED_MATRIX_0_BASE+0xb0000004>
   100b0:	f0000e37          	lui	t3,0xf0000
   100b4:	008e0e13          	addi	t3,t3,8 # f0000008 <LED_MATRIX_0_BASE+0xb0000008>
   100b8:	f0000eb7          	lui	t4,0xf0000
   100bc:	00ce8e93          	addi	t4,t4,12 # f000000c <LED_MATRIX_0_BASE+0xb000000c>
   100c0:	00ff09b7          	lui	s3,0xff0
   100c4:	11200a13          	li	s4,274
   100c8:	00d00a93          	li	s5,13
   100cc:	09000b13          	li	s6,144

000100d0 <Generate_apple>:
   100d0:	00aa0f33          	add	t5,s4,a0
   100d4:	000f2f83          	lw	t6,0(t5)
   100d8:	000f8463          	beqz	t6,100e0 <Apple_Position_ok>
   100dc:	00c0006f          	j	100e8 <RNG>

000100e0 <Apple_Position_ok>:
   100e0:	013f2023          	sw	s3,0(t5)
   100e4:	0180006f          	j	100fc <Dpad_check>

000100e8 <RNG>:
   100e8:	035a0a33          	mul	s4,s4,s5
   100ec:	001a0a13          	addi	s4,s4,1
   100f0:	036a6a33          	rem	s4,s4,s6
   100f4:	002a1a13          	slli	s4,s4,0x2
   100f8:	fd9ff06f          	j	100d0 <Generate_apple>

000100fc <Dpad_check>:
   100fc:	00032283          	lw	t0,0(t1) # f0000000 <LED_MATRIX_0_BASE+0xb0000000>
   10100:	0a029c63          	bnez	t0,101b8 <up>
   10104:	0003a283          	lw	t0,0(t2)
   10108:	0c029263          	bnez	t0,101cc <down>
   1010c:	000e2283          	lw	t0,0(t3)
   10110:	0c029863          	bnez	t0,101e0 <left>
   10114:	000ea283          	lw	t0,0(t4)
   10118:	08029663          	bnez	t0,101a4 <right>
   1011c:	0d80006f          	j	101f4 <No_Input>

00010120 <Snake_Head>:
   10120:	0e07cc63          	bltz	a5,10218 <Animation_Initialize>
   10124:	0eb7da63          	ble	a1,a5,10218 <Animation_Initialize>
   10128:	0e074863          	bltz	a4,10218 <Animation_Initialize>
   1012c:	0ec75663          	ble	a2,a4,10218 <Animation_Initialize>
   10130:	02b70833          	mul	a6,a4,a1
   10134:	00f808b3          	add	a7,a6,a5
   10138:	00289893          	slli	a7,a7,0x2
   1013c:	011504b3          	add	s1,a0,a7
   10140:	0004af03          	lw	t5,0(s1)
   10144:	053f0063          	beq	t5,s3,10184 <Eat_Apple>
   10148:	0cdf0863          	beq	t5,a3,10218 <Animation_Initialize>
   1014c:	002c9f93          	slli	t6,s9,0x2
   10150:	017f8fb3          	add	t6,t6,s7
   10154:	011fa023          	sw	a7,0(t6)
   10158:	001c8c93          	addi	s9,s9,1
   1015c:	03bcecb3          	rem	s9,s9,s11
   10160:	00d4a023          	sw	a3,0(s1)
   10164:	002c1f93          	slli	t6,s8,0x2
   10168:	017f8fb3          	add	t6,t6,s7
   1016c:	000faf83          	lw	t6,0(t6)
   10170:	00af8fb3          	add	t6,t6,a0
   10174:	000fa023          	sw	zero,0(t6)
   10178:	001c0c13          	addi	s8,s8,1
   1017c:	03bc6c33          	rem	s8,s8,s11
   10180:	f7dff06f          	j	100fc <Dpad_check>

00010184 <Eat_Apple>:
   10184:	002c9f93          	slli	t6,s9,0x2
   10188:	017f8fb3          	add	t6,t6,s7
   1018c:	011fa023          	sw	a7,0(t6)
   10190:	001c8c93          	addi	s9,s9,1
   10194:	03bcecb3          	rem	s9,s9,s11
   10198:	00d4a023          	sw	a3,0(s1)
   1019c:	001d0d13          	addi	s10,s10,1
   101a0:	f31ff06f          	j	100d0 <Generate_apple>

000101a4 <right>:
   101a4:	00300913          	li	s2,3
   101a8:	05240663          	beq	s0,s2,101f4 <No_Input>
   101ac:	00000413          	li	s0,0
   101b0:	00178793          	addi	a5,a5,1
   101b4:	f6dff06f          	j	10120 <Snake_Head>

000101b8 <up>:
   101b8:	00200913          	li	s2,2
   101bc:	03240c63          	beq	s0,s2,101f4 <No_Input>
   101c0:	00100413          	li	s0,1
   101c4:	fff70713          	addi	a4,a4,-1
   101c8:	f59ff06f          	j	10120 <Snake_Head>

000101cc <down>:
   101cc:	00100913          	li	s2,1
   101d0:	03240263          	beq	s0,s2,101f4 <No_Input>
   101d4:	00200413          	li	s0,2
   101d8:	00170713          	addi	a4,a4,1
   101dc:	f45ff06f          	j	10120 <Snake_Head>

000101e0 <left>:
   101e0:	00000913          	li	s2,0
   101e4:	01240863          	beq	s0,s2,101f4 <No_Input>
   101e8:	00300413          	li	s0,3
   101ec:	fff78793          	addi	a5,a5,-1
   101f0:	f31ff06f          	j	10120 <Snake_Head>

000101f4 <No_Input>:
   101f4:	00000293          	li	t0,0
   101f8:	fa5406e3          	beq	s0,t0,101a4 <right>
   101fc:	00100293          	li	t0,1
   10200:	fa540ce3          	beq	s0,t0,101b8 <up>
   10204:	00200293          	li	t0,2
   10208:	fc5402e3          	beq	s0,t0,101cc <down>
   1020c:	00300293          	li	t0,3
   10210:	fc5408e3          	beq	s0,t0,101e0 <left>
   10214:	ee9ff06f          	j	100fc <Dpad_check>

00010218 <Animation_Initialize>:
   10218:	00000293          	li	t0,0
   1021c:	00000313          	li	t1,0
   10220:	00000393          	li	t2,0
   10224:	00000e13          	li	t3,0
   10228:	00000e93          	li	t4,0
   1022c:	00ffff37          	lui	t5,0xfff
   10230:	ca1f0f13          	addi	t5,t5,-863 # ffeca1 <__global_pointer$+0xfed209>
   10234:	24000f93          	li	t6,576
   10238:	0040006f          	j	1023c <Animation>

0001023c <Animation>:
   1023c:	02b283b3          	mul	t2,t0,a1
   10240:	00638e33          	add	t3,t2,t1
   10244:	002e1e13          	slli	t3,t3,0x2
   10248:	01c50eb3          	add	t4,a0,t3
   1024c:	01eea023          	sw	t5,0(t4)
   10250:	00130313          	addi	t1,t1,1
   10254:	00128293          	addi	t0,t0,1
   10258:	fffe42e3          	blt	t3,t6,1023c <Animation>
   1025c:	00000f93          	li	t6,0
   10260:	00000e93          	li	t4,0
   10264:	0040006f          	j	10268 <Game_Over>

00010268 <Game_Over>:
   10268:	00000313          	li	t1,0
   1026c:	24000393          	li	t2,576
   10270:	00000e13          	li	t3,0
   10274:	0040006f          	j	10278 <Restart>

00010278 <Restart>:
   10278:	00650fb3          	add	t6,a0,t1
   1027c:	01dfa023          	sw	t4,0(t6)
   10280:	00430313          	addi	t1,t1,4
   10284:	fe734ae3          	blt	t1,t2,10278 <Restart>
   10288:	00000e93          	li	t4,0
   1028c:	00000f13          	li	t5,0
   10290:	00000f93          	li	t6,0
   10294:	00008067          	ret
