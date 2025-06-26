#haz1
addi x1, x0, 5       # x1 = 5
add  x2, x1, x1      # x2 = x1 + x1
add  x3, x2, x1      # x3 = x2 + x1
addi x9, x0, 20      # x4 = x3 + 10
#haz2
haz2:
addi x7, x0, 24      # x7 = 20
sw   x3, 0(x7)       
lw   x4, 8(x7)       
add  x5, x4, x1

#haz3
addi x8, x8,4
addi x3, x3, 
jal x10, haz2
