#test cache
addi x1, x0, 111
addi x2, x0, 222
addi x3, x0, 333
addi x4, x0, 444
addi x5, x0, 555
addi x6, x0, 666
addi x7, x0, 777
addi x8, x0, 888
addi x9, x0, 999

sw x1, 0(x0) #0/0
sw x2, 256(x0) #0/1
sw x3, 512(x0) #0/2
sw x4, 768(x0) #0/3
sw x5, 1024(x0) #0/4
sw x6, 2048(x0) #0/5

sw x7, 0(x0) #0/0
sw x8, 256(x0) #0/1

lw x10, 0(x0) 
