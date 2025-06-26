#test2
addi x1, x0, 111
addi x2, x0, 222
addi x3, x0, 333
addi x4, x0, 444
addi x5, x0, 555
addi x6, x0, 666
addi x7, x0, 777
addi x8, x0, 888
addi x9,x9,0x50
sw x1, 0(x9) 
sw x2, 256(x9) 
sw x3, 512(x9) 
sw x4, 768(x9) 
lw x11, 0(x9)
add x11, x11, x1
sw x11, 0(x9) 
sw x8, 256(x9) 
lw x10, 768(x9) 