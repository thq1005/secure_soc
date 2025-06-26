/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include <xuartlite_l.h>
#include <xil_io.h>
#include <sleep.h>
#include "subsystem.h"

#define core_0				0x0
#define core_1				0x1

#define reset  				0x00
#define	enable				0x04
#define m0_reg_rd_en		0x08
#define m0_reg_addr			0x0c
#define m0_reg_data			0x10
#define m1_reg_rd_en		0x14
#define m1_reg_addr			0x18
#define m1_reg_data			0x1c
#define m_wr_mem_en			0x20
#define m_wr_mem_addr		0x24
#define m_wr_mem_data		0x28

#define printf           xil_printf

uint32_t addr_inst_0;
uint32_t addr_inst_1;


void Reset_SoC ()
{
    u32 baseaddr;
    baseaddr = (u32) XPAR_SUBSYSTEM_0_S00_AXI_BASEADDR;

    SUBSYSTEM_mWriteReg (baseaddr, reset, 0x1);
    SUBSYSTEM_mWriteReg (baseaddr, enable, 0x0);
    usleep(1);
    SUBSYSTEM_mWriteReg (baseaddr, reset, 0x0);
}

void Enable_SoC (uint32_t period)
{
    u32 baseaddr;
    baseaddr = (u32) XPAR_SUBSYSTEM_0_S00_AXI_BASEADDR;

    SUBSYSTEM_mWriteReg (baseaddr, enable, 0x1);
	usleep(period);
	SUBSYSTEM_mWriteReg (baseaddr, enable, 0x0);
	usleep(period);
}

void Load_Instr(uint8_t core_id, uint32_t *addr_inst, uint32_t data_inst)
{
    u32 baseaddr;
    baseaddr = (u32) XPAR_SUBSYSTEM_0_S00_AXI_BASEADDR;

    SUBSYSTEM_mWriteReg (baseaddr, m_wr_mem_addr, *addr_inst + core_id * 256 * 4);
    SUBSYSTEM_mWriteReg (baseaddr, m_wr_mem_data, data_inst);
    SUBSYSTEM_mWriteReg (baseaddr, m_wr_mem_en, 0x1);
    SUBSYSTEM_mWriteReg (baseaddr, m_wr_mem_en, 0x0);
    *addr_inst = *addr_inst + 4;
}

void Read_Reg(uint8_t core_id, uint8_t reg_addr)
{
    u32 baseaddr;
    baseaddr = (u32) XPAR_SUBSYSTEM_0_S00_AXI_BASEADDR;

    if (core_id == 0) {
    	SUBSYSTEM_mWriteReg (baseaddr, m0_reg_addr , reg_addr);
    	SUBSYSTEM_mWriteReg (baseaddr, m0_reg_rd_en, 0x1);
    	printf("x%d = %x\n", reg_addr, SUBSYSTEM_mReadReg  (baseaddr, m0_reg_data));
    	SUBSYSTEM_mWriteReg (baseaddr, m0_reg_rd_en, 0x0);
    }
    else {
    	SUBSYSTEM_mWriteReg (baseaddr, m1_reg_addr , reg_addr);
		SUBSYSTEM_mWriteReg (baseaddr, m1_reg_rd_en, 0x1);
		printf("x%d = %x\n", reg_addr, SUBSYSTEM_mReadReg  (baseaddr, m1_reg_data));
		SUBSYSTEM_mWriteReg (baseaddr, m1_reg_rd_en, 0x0);
    }
}

void Display_RegFile (uint32_t core_id)
{
	printf("Register File of Core_%d\n", core_id);
	for (int i=0; i<=31; i=i+1)
    {
		Read_Reg(core_id, i);
    }
}

// function to read testcase .bin file
unsigned int* read_hex_file(const char* filename, size_t* out_size) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        perror("Failed to open file");
        return NULL;
    }

    // Determine file size
    fseek(file, 0, SEEK_END);
    long filesize = ftell(file);
    rewind(file);

    // Check if file size is divisible by sizeof(unsigned int)
    if (filesize % sizeof(unsigned int) != 0) {
        fprintf(stderr, "File size is not aligned with unsigned int size.\n");
        fclose(file);
        return NULL;
    }

    // Calculate number of unsigned ints
    size_t num_elements = filesize / sizeof(unsigned int);
    *out_size = num_elements;

    // Allocate array
    unsigned int* array = (unsigned int*)malloc(filesize);
    if (!array) {
        perror("Memory allocation failed");
        fclose(file);
        return NULL;
    }

    // Read data
    size_t read_count = fread(array, sizeof(unsigned int), num_elements, file);
    if (read_count != num_elements) {
        fprintf(stderr, "Failed to read entire file\n");
        free(array);
        fclose(file);
        return NULL;
    }

    fclose(file);
    return array;
}


void Init_Testcase (unsigned char tc_id)
{
	unsigned int count_0, count_1;
	unsigned int *instr_mem_0, *instr_mem_1;
	printf("Start initializing of Testcase_%c\n", tc_id);
	switch(tc_id){
		case '1':{
			instr_mem_0 = read_hex_file("D:\\University\\KLTN\\hw_design\\testcase\\assembly\\testcase_A_1.bin", &count_0);
			for (int i=0; i<count_0; i=i+1) {
				Load_Instr (0, &addr_inst_0, instr_mem_0[i]);
			}

			instr_mem_1 = read_hex_file("D:\\University\\KLTN\\hw_design\\testcase\\assembly\\testcase_B_1.bin", &count_1);
			for (int i=0; i<count_1; i=i+1) {
				Load_Instr (1, &addr_inst_1, instr_mem_1[i]);
			}
			/*
			Load_Instr (0, &addr_inst_0, 0x03000093);
			Load_Instr (0, &addr_inst_0, 0x04000113);
			Load_Instr (0, &addr_inst_0, 0x05400193);
			Load_Instr (0, &addr_inst_0, 0x06C00213);
			Load_Instr (0, &addr_inst_0, 0x07800113);
			Load_Instr (0, &addr_inst_0, 0xFFF00193);
			Load_Instr (0, &addr_inst_0, 0x12300213);
			Load_Instr (0, &addr_inst_0, 0x12300293);
			Load_Instr (0, &addr_inst_0, 0x07800313);
			Load_Instr (0, &addr_inst_0, 0x56700393);
			Load_Instr (0, &addr_inst_0, 0x03000093);
			Load_Instr (0, &addr_inst_0, 0x04000113);
			Load_Instr (0, &addr_inst_0, 0x05400193);
			Load_Instr (0, &addr_inst_0, 0x06C00213);
			Load_Instr (0, &addr_inst_0, 0x07800113);
			Load_Instr (0, &addr_inst_0, 0xFFF00193);
			Load_Instr (0, &addr_inst_0, 0x12300213);
			Load_Instr (0, &addr_inst_0, 0x12300293);
			Load_Instr (0, &addr_inst_0, 0x07800313);
			Load_Instr (0, &addr_inst_0, 0x56700393);
			Load_Instr (0, &addr_inst_0, 0x000010B7);
			Load_Instr (0, &addr_inst_0, 0x00008403);

			Load_Instr (1, &addr_inst_1, 0x000010B7);
			Load_Instr (1, &addr_inst_1, 0x12345137);
			Load_Instr (1, &addr_inst_1, 0x67810113);
			Load_Instr (1, &addr_inst_1, 0x00209023);
			*/

			break;
		}
		case '2':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '3':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '4':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '5':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '6':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '7':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '8':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		case '9':{
			printf("Testcase_%c is unsupported!\n", tc_id);
			break;
		}
		default: break;
	}
	printf("End initializing of Testcase_%c\n", tc_id);
}


int main()
{
    init_platform();

    print("Start program\n");

    unsigned char c;
	addr_inst_0 = 0;
	addr_inst_1 = 0;

	printf("Press r to RESET. \n");
	printf("Press a to DISPLAY REGFILE of CORE_0. \n");
	printf("Press b to DISPLAY REGFILE of CORE_0. \n");
	printf("Press 1 to check testcase: .... \n");
	printf("Press 2 to check testcase: .... \n");
	printf("Press 3 to check testcase: .... \n");
	printf("Press 4 to check testcase: .... \n");
	printf("Press 5 to check testcase: .... \n");
	printf("Press 6 to check testcase: .... \n");
	printf("Press 7 to check testcase: .... \n");
	printf("Press 8 to check testcase: .... \n");
	printf("Press 9 to check testcase: .... \n");
	printf("Press e to EXIT. \n");

	while (c != 'e') {
		printf("\nMake your select: ");
		c = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
		XUartLite_SendByte(XPAR_AXI_UARTLITE_0_BASEADDR, c);
		printf("\n");
		switch(c){
			case 'r':{
				addr_inst_0 = 0;
				addr_inst_1 = 0;
				Reset_SoC ();
				printf("Done RESET.\n");
				break;
			}
			case 'a':{
				Display_RegFile (core_0);
				break;
			}
			case 'b':{
				Display_RegFile (core_1);
				break;
			}
			case '1':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '2':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '3':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '4':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '5':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '6':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '7':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '8':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			case '9':{
				printf("Start of Testcase %c.\n", c);
				Init_Testcase (c);
				printf("Running of Testcase %c.\n", c);
				Enable_SoC ((addr_inst_0 > addr_inst_1) ? addr_inst_0 : addr_inst_1);
				printf("End of Testcase %c.\n", c);
				break;
			}
			default: {
				printf("Unsupport selection.\n", c);
				break;
			}
		}
		// used to inorged redundant \r
		c = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
	}
	printf("End program %c.\n");

    cleanup_platform();
    return 0;
}
