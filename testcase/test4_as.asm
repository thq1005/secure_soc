//for board demo
_start:
    # Step 1: Enable global machine interrupts (MIE bit in mstatus)
    addi x3, x0, 8    # MIE = 1 (Enable global interrupts) (MIE = 3)
    csrrw x0, mstatus, x3  # Write to mstatus

    # Step 2: Enable the DMA interrupt (Machine External Interrupt - MEIE)
    slli x3, x3, 8   # Enable external interrupt (MEIE bit)
    csrrw x0, mie, x3

    # Step 3: Set the machine trap vector to our interrupt handler
    addi x3, x0, interrupt_handler
    slli x3, x3, 2
    addi x3, x3, 1
    csrrw x0, mtvec, x3

    # Step 4: Config PLIC and aes
    lui x2, 0x10000 #base address for AES
    lui x3, 0x20000 #base address for DMA
    lui x4, 0x30000 #base address for PLIC
    lui x18, 0x40000 #base address for SDIO
    addi x8, x0, 0x1  #id irq of aes
    addi x9, x0, 0x2  #id irq of dma  
    addi x10, x0, 0x3 #id irq of sd
    #config aes
    addi x1, x0, 15
    sw x1, 0(x2)
    sw x1, 4(x2)    
    #Config plic
    addi x1, x0, 1
    sw x1, 0(x4)  # Set priority for AES interrupt
    addi x1, x0, 2
    sw x1, 4(x4)  # Set priority for DMA interrupt
    addi x1, x0, 3
    sw x1, 8(x4)  # Set priority for SD interrupt
    addi x1, x0, 0xe
    sw x1, 12(x4) # Set enable for PLIC
    
    #config dma 
    #send block and key from block ram to aes by dma
    sw x0, 0(x3)
    addi x5, x2, 16
    sw x5, 4(x3)
    addi x5, x0, 1
    slli x5,x5,11
    addi x5,x5, 0x21f
    sw x5, 8(x3)


    ## sdio
    lw x1, 0(x18) # Read SDIO status

main_loop:
    addi x15,x15,1
    jal x0, main_loop

interrupt_handler:
    mret


























































