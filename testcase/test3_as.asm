#test aes
#block: 00112233445566778899AABBCCDDEEFF
#key:   00001111222233334444555566667777
#result: 69C4E0D86A7B0430D8CDB78070B4C55A
_start:
    # Step 1: Enable global machine interrupts (MIE bit in mstatus)
    li t0, (1 << 3)   # MIE = 1 (Enable global interrupts)
    csrw mstatus, t0  # Write to mstatus

    # Step 2: Enable the DMA interrupt (Machine External Interrupt - MEIE)
    li t0, (1 << 11)  # Enable external interrupt for DMA (MEIE bit)
    csrw mie, t0

    # Step 3: Set the machine trap vector to our interrupt handler
    la t0, interrupt_handler
    csrw mtvec, t0

    # Step 4: Start AES processing using DMA
    li t0, 0x40000000  # Address of AES DMA control register
    li t1, 1           # Start DMA transfer to AES
    sw t1, 0(t0)       # Trigger DMA

    # Step 5: Main execution loop (CPU is free while DMA runs)
main_loop:
    wfi  # CPU sleeps until an interrupt occurs
    j main_loop  # Keep running indefinitely

# ---------------------
# Interrupt Service Routine (ISR)
# ---------------------
interrupt_handler:
    # Step 6: Read mcause to determine the interrupt source
    csrr t0, mcause
    li t1, 11          # DMA Interrupt ID (Assumed)
    beq t0, t1, dma_interrupt_handler  # Branch if it's a DMA interrupt

    mret  # Return if it's an unknown interrupt

# ---------------------
# DMA Interrupt Handler
# ---------------------
dma_interrupt_handler:
    # Step 7: Clear the DMA interrupt flag
    li t0, 0x50000000  # Address of DMA status register
    lw t1, 0(t0)       # Read DMA status
    sw zero, 0(t0)     # Clear the DMA interrupt flag

    # Step 8: Read AES result from memory
    li t0, 0x60000000  # Address of AES result register
    lw t1, 0(t0)       # Read encrypted data

    # Step 9: Store the result to memory
    li t0, 0x70000000  # Address where encrypted data should be saved
    sw t1, 0(t0)       # Store AES result

    # Step 10: Return from the interrupt
    mret
