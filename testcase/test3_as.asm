#test 3
_start:
    # Step 1: Enable global machine interrupts (MIE bit in mstatus)
    addi x3, x0, 8                  # MIE = 1 (Enable global interrupts) (MIE = 3)
    csrrw x0, mstatus, x3           # Write to mstatus

    # Step 2: Enable the DMA interrupt (Machine External Interrupt - MEIE)
    slli x3, x3, 8                  # Enable external interrupt (MEIE bit)
    csrrw x0, mie, x3

    # Step 3: Set the machine trap vector to our interrupt handler
    addi x3, x0, interrupt_handler
    slli x3, x3, 2
    addi x3, x3, 1
    csrrw x0, mtvec, x3

    # Step 4: Config PLIC and aes
    lui x2, 0x10000                 #base address for AES
    lui x3, 0x20000                 #base address for DMA
    lui x4, 0x30000                 #base address for PLIC
    addi x8, x0, 0x1                #id irq of aes
    addi x9, x0, 0x2                #id irq of dma  
    #config aes
    addi x1, x0, 15
    sw x1, 0(x2)
    sw x1, 4(x2)    
    #Config plic
    addi x1, x0, 1
    sw x1, 0(x4)  # Set priority for AES interrupt
    addi x1, x0, 2
    sw x1, 4(x4)  # Set priority for DMA interrupt
    addi x1, x0, 0xe
    sw x1, 12(x4) # Set enable for PLIC
    
    #config dma 
    #send block and key from block ram to aes by dma
    addi x5,x0, 512
    slli x5,x5,2
    sw x5, 0(x3)
    addi x5, x2, 16
    sw x5, 4(x3)
    addi x5, x0, 1
    slli x5,x5,11
    addi x5,x5, 0x21f
    sw x5, 8(x3)
    #start dma
    addi x5, x0, 1
    sw x5, 12(x3)

main_loop:
    addi x15,x15,1
    jal x0, main_loop 
done:
    addi x17, x0,1
    jal x0, done
error:
    addi x16, x16, 1
    jal x0, error
# ---------------------
# Interrupt Service Routine (ISR)
# ---------------------
interrupt_handler:
    csrrw x1, mcause, x0
    addi x5, x0, 11                     # external Interrupt ID (Assumed)
    lui x6, 0x80000
    add x6, x5, x6
    bne x6, x1, error                   # Branch if it's not a external interrupt
    lw x5, 20(x4)                       # Read the interrupt cause

    beq x5, x8, aes_interrupt_handler   # Branch if aes interrupt       
    beq x5, x9, dma_interrupt_handler   # Branch if DMA interrupt
    mret

# ---------------------
# DMA Interrupt Handler
# ---------------------
dma_interrupt_handler:
    sw x0, 16(x3)                       # Clear the DMA interrupt
    addi x11,x11,1
    beq x11, x8, dma_first_handle
    beq x11, x9, dma_second_handle
    beq x11, x10, dma_third_handle
dma_first_handle:
    #start aes
    sw x8, 12(x2)                       # Start AES operation
    mret
dma_second_handle:
    jal x0, done
dma_third_handle:
    jal x0, error

aes_interrupt_handler:
    sw x0, 4(x2)                        # Clear the AES interrupt
    addi x1, x2, 0x90 
    sw x1, 0(x3)                        # set src addr of dma
    addi x5,x0, 544
    slli x5,x5,2
    sw x5, 4(x3)                        # set dst addr of dma
    addi x5, x0, 1
    slli x5,x5,11
    addi x5,x5, 0x20f   
    sw x5, 8(x3)
    addi x5, x0, 1
    sw x5, 12(x3)
    mret
    
    
    
    
    
    
