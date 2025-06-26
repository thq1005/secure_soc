#test cpu
lui x2,0xA
addi x2,x2,0x550
addi x2,x2,0x550
lui x4,0xAAAA0
lui x3,0x0
ori x3,x3,0x10
loop:
addi x3,x3,0x04
addi x2,x2,0x01
sw x2,512(x3)
lw x1,512(x3)
slli x5,x1,16
bne x5,x4,loop
done:
jal x4,done
