#test aes
#block: 00112233445566778899AABBCCDDEEFF
#key:   00001111222233334444555566667777
#result: 69C4E0D86A7B0430D8CDB78070B4C55A
_start:
    # Step 1: Enable global machine interrupts (MIE bit in mstatus)
    addi t0, x0, 8    # MIE = 1 (Enable global interrupts) (MIE = 3)
    csrrw x0, mstatus, t0  # Write to mstatus

    # Step 2: Enable the DMA interrupt (Machine External Interrupt - MEIE)
    slli t0, t0, 8   # Enable external interrupt for DMA (MEIE bit)
    csrw x0, mie, t0

    # Step 3: Set the machine trap vector to our interrupt handler
    addi t0, x0, interrupt_handler
    csrw x0, mtvec, t0

    # Step 4: Start AES processing using DMA
    addi x1, x0, 1
    aes_cfg x1
    addi x1,x0, 16
    aes_key x1
    addi x1, x0, 0
    aes_blk x1
    addi x1, x0, 32
    aes_res x1
    aes_start
main_loop:
    j main_loop  # Keep running indefinitely

# ---------------------
# Interrupt Service Routine (ISR)
# ---------------------
interrupt_handler:
    csrrw x1, mcause, x0
    addi x2, x0, 11          # DMA Interrupt ID (Assumed)
    beq t0, t1, dma_interrupt_handler  # Branch if it's a DMA interrupt
    mret  # Return if it's an unknown interrupt

# ---------------------
# DMA Interrupt Handler
# ---------------------
dma_interrupt_handler:
    lw x1, 32(x0)  
    lw x2, 36(x0)  
    lw x3, 40(x0)  
    lw x4, 44(x0)  
    mret
