#test aes
#block: 00112233445566778899AABBCCDDEEFF
#key:   00001111222233334444555566667777
#result: 69C4E0D86A7B0430D8CDB78070B4C55A
_start:
    # Step 1: Enable global machine interrupts (MIE bit in mstatus)
    addi x3, x0, 8    # MIE = 1 (Enable global interrupts) (MIE = 3)
    csrrw x0, mstatus, x3  # Write to mstatus

    # Step 2: Enable the DMA interrupt (Machine External Interrupt - MEIE)
    slli x3, x3, 8   # Enable external interrupt for DMA (MEIE bit)
    csrrw x0, mie, x3

    # Step 3: Set the machine trap vector to our interrupt handler
    addi x3, x0, interrupt_handler
    slli x3, x3, 2
    addi x3, x3, 1
    csrrw x0, mtvec, x3

    # Step 4: Start AES processing using DMA
    addi x1, x0, 15
    aes_cfg x1
    aes_ctrl x1
    addi x1, x0, 0
    addi x2, x0, 3
    aes_block x1, x2
    addi x1,x1, 64   
    aes_key x1, x2
    addi x1, x1, 64
    aes_res x1, x2
    aes_status x2
    aes_start
main_loop:
    jal x0, main_loop 
done:
    jal x0, done

# ---------------------
# Interrupt Service Routine (ISR)
# ---------------------
interrupt_handler:
    csrrw x1, mcause, x0
    addi x2, x0, 11                     # DMA Interrupt ID (Assumed)
    lui x3, 0x80000
    add x3, x2, x3
    beq x3, x1, dma_interrupt_handler   # Branch if it's a DMA interrupt
    mret  

# ---------------------
# DMA Interrupt Handler
# ---------------------
dma_interrupt_handler:
    lw x1, 128(x0)  
    lw x2, 132(x0)  
    lw x3, 136(x0)  
    lw x4, 140(x0)  
    mret
