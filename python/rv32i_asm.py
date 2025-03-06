import sys
import argparse
import re

'''
    Step 1: Xóa các dòng trống và command. -> Nên dùng file script csh (pre-process) để xử lý trước
    Step 2: Tìm địa chỉ của label. Nếu có các lệnh nhảy thì phải thay thể label bằng offset. (Nếu ko có label thì bỏ qua bước này) (process)
    Step 3: Chuyển đổi các số integer sang dạng nhị phân. Nếu số âm thì chuyển sang dạng bù 2. Nếu đã là mã hex thì chuyển sang nhị phân. (process)
    Step 4: Xác định các lệnh và chuyển đổi chúng sang mã máy sẽ gồm 3 thành phần chính opcode, funct3, funct7(Tùy lệnh) (process)
    Step 5: Sau khi hoàn thành thì thêm bước check lại mã lệnh đó. (post-process)
    Step 6: Thêm input file và output file. (pre-process)
'''

# Bảng tra cứu cho các lệnh RISC-V
opcode_table = {
    'add': '0110011', 'sub': '0110011', 'xor': '0110011', 'or': '0110011', 'and': '0110011', 'sll': '0110011', 'srl': '0110011', 'sra': '0110011', 'slt': '0110011', 'sltu': '0110011', # R-type
    'addi': '0010011', 'xori': '0010011', 'andi': '0010011', 'ori': '0010011', 'slli': '0010011', 'srli': '0010011', 'srai': '0010011', 'slti': '0010011', 'sltiu': '0010011', # I-type
    'lb': '0000011', 'lh': '0000011', 'lw': '0000011', 'lbu': '0000011', 'lhu': '0000011', 'aes_read_result': '0101011', 'aes_read_status': '0101011', # I-type
    'sb': '0100011', 'sh': '0100011', 'sw': '0100011', 'aes_write_block': '0100111', 'aes_write_key': '0100111', 'aes_write_config': '0100111', 'aes_write_ctrl': '0100111', # S-type
    'beq': '1100011', 'bne': '1100011', 'blt': '1100011', 'bge': '1100011', 'bltu': '1100011', 'bgeu': '1100011', # SB-type
    'jalr': '1100111', # I-type
    'jal': '1101111', # UJ-type
    'lui': '0110111', 'auipc': '0010111', # U-type 
    'csrrs': '1110011' , 'csrrsi': '1110011', 'csrrw': '1110011', 'csrrwi': '1110011', 'csrrc': '1110011', 'csrrci': '1110011' # I-type
}

funct3_table = {
    'add': '000', 'sub': '000', 'xor': '100', 'or': '110', 'and': '111', 'sll': '001', 'srl': '101', 'sra': '101', 'slt': '010', 'sltu': '011', # R-type
    'addi': '000', 'xori': '100', 'andi': '111', 'ori': '110', 'slli': '001', 'srli': '101', 'srai': '101', 'slti': '010', 'sltiu': '011', # I-type
    'lb': '000', 'lh': '001', 'lw': '010', 'lbu': '100', 'lhu': '101', # I-type
    'aes_read_result': '001', 'aes_read_status': '000',
    'aes_write_block': '000', 'aes_write_key': '001', 'aes_write_ctrl': '010', 'aes_write_config': '011',
    'sb': '000', 'sh': '001', 'sw': '010', # S-type
    'beq': '000', 'bne': '001', 'blt': '100', 'bge': '101', 'bltu': '110', 'bgeu': '111', # SB-type
    'jalr': '000', # I-type
    'jal': '000', # UJ-type
    'lui': '011', 'auipc': '001', # U-type
    'csrrw': '001', 'csrrwi': '101', 'csrrs': '010', 'csrrsi': '110', 'csrrc': '011', 'csrrw': '111'  
    }

funct7_table = {
    'add': '0000000', 'sub': '0100000', 'xor': '0000000', 'or': '0000000', 'and': '0000000', 'sll': '0000000', 'srl': '0000000', 'sra': '0100000', 'slt': '0000000', 'sltu': '0000000', # R-type
    'addi': '0000000', 'xori': '0000000', 'andi': '0000000', 'ori': '0000000', 'slli': '0000000', 'srli': '0000000', 'srai': '0100000', 'slti': '0000000', 'sltiu': '0000000', # I-type
    'lb': '000', 'lh': '001', 'lw': '010', 'lbu': '100', 'lhu': '101', # I-type
    'sb': '000', 'sh': '001', 'sw': '010', # S-type
    'beq': '000', 'bne': '001', 'blt': '100', 'bge': '101', 'bltu': '110', 'bgeu': '111', # SB-type
    'jalr': '0000000', # I-type
    'jal': '0000000', # UJ-type
    'lui': '0000000', 'auipc': '0000000' # U-type
}

reg_table = {
    'x0': '00000', 'x1': '00001', 'x2': '00010', 'x3': '00011', 'x4': '00100', 'x5': '00101', 'x6': '00110', 'x7': '00111',
    'x8': '01000', 'x9': '01001', 'x10': '01010', 'x11': '01011', 'x12': '01100', 'x13': '01101', 'x14': '01110', 'x15': '01111',
    'x16': '10000', 'x17': '10001', 'x18': '10010', 'x19': '10011', 'x20': '10100', 'x21': '10101', 'x22': '10110', 'x23': '10111',
    'x24': '11000', 'x25': '11001', 'x26': '11010', 'x27': '11011', 'x28': '11100', 'x29': '11101', 'x30': '11110', 'x31': '11111'
}

csr_table = {
    'mstatus': '001100000000',
    'mie'    : '001100000100',
    'mtvec'  : '001100000101',
    'mepc'   : '001101000001',
    'mcause' : '001101000010',
    'mip'    : '001101000100'
}

# Conver hex to binary
def hex_to_bin(hex_str):
    # Chuyển đổi chuỗi thập lục phân sang số nguyên
    decimal_value = int(hex_str, 16)
    # Chuyển đổi số nguyên sang chuỗi nhị phân và loại bỏ tiền tố '0b'
    bin_str = bin(decimal_value)[2:]
    # Đảm bảo chuỗi nhị phân có độ dài là bội số của 4
    bin_str = bin_str.zfill((len(bin_str) + 3) // 4 * 4)
    return bin_str

def hex_to_int(hex_str):
    return int(hex_str, 16)


def add_space_after_comma(code):
    processed_code = []
    for line in code:
        # Sử dụng regex để tìm dấu phẩy không được theo sau bởi khoảng trắng
        # và thay thế bằng dấu phẩy + khoảng trắng
        new_line = re.sub(r',(?=\S)', ', ', line)
        processed_code.append(new_line)
    return processed_code

# Get a list of addresses
def get_addr(cleaned_code):

    addr = {}
    current_address = 0

    for line in cleaned_code:
        if line.endswith(":"):
            # Nếu là nhãn, lưu địa chỉ của nhãn
            addr[line] = current_address
        else:
            # Nếu là lệnh, lưu địa chỉ của lệnh và tăng địa chỉ hiện tại lên 4 byte
            addr[line] = current_address
            current_address += 4

    return addr

# Change the label to the offset
def change_label_to_offset(code):

    list_addr = get_addr(code)
    for i, line in enumerate(code):
        if line.endswith(":"):
            continue
        parts = line.split()
        if parts[0] in ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu', 'jal','jalr']:
            label = parts[-1]
            if label.isdigit():
                continue
            current_address = list_addr[line]
            target_address = list_addr[label + ":"]
            offset = (target_address - current_address)
            code[i] = ' '.join(parts[:-1]) + f" {offset}"

    return code

# Pre-process: "Clean" the assembly code
def pre_process(code):
    """
    Làm sạch mã Assembly và loại bỏ các chỉ thị (directive), comment và khoảng trắng dư thừa và đổi label sang offset tương ứng
    :param code: List chứa mã Assembly thô (mỗi dòng là một phần tử)
    :return: List mã Assembly đã được làm sạch, không chứa hiển thị
    """
    cleaned_code = []

    for line in code:
        # Xóa các khoảng trắng ở đầu và cuối dòng
        line = line.strip()
        # Bỏ qua các dòng trống và các dòng chứa comment
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        # Xử lý các dòng có comment ở cuối
        if "#" in line:
            line = line.split("#")[0].strip()
        elif "//" in line:
            line = line.split("//")[0].strip()

        # Loại bỏ chỉ thị (bắt đầu bằng dấu '.')
        if line.startswith("."):
            continue

        # Tách nhãn ra dòng riêng nếu cần
        if ":" in line:
            parts = line.split(":")
            label = parts[0].strip() + ":"
            if len(parts) > 1 and parts[1].strip():  # Nếu sau nhãn có lệnh
                instruction = parts[1].strip()
                cleaned_code.append(label)
                cleaned_code.append(' '.join(instruction.split()))  # Làm sạch khoảng trắng thừa
            else:  # Nếu chỉ có nhãn
                cleaned_code.append(label)
        else:
            # Giữ lại lệnh Assembly và làm sạch khoảng trắng thừa
            cleaned_code.append(' '.join(line.split()))

    # Thay thế nhãn bằng offset tương ứng
    cleaned_code = change_label_to_offset(cleaned_code)

    return cleaned_code

# Hàm chuyển đổi immediate sang dạng nhị phân
def imm_to_bin(value, bits):
    if value < 0:
        value = (1 << bits) + value
    return format(value, f'0{bits}b')

# Hàm chuyển đổi lệnh assembly sang mã máy
def asm_to_bin(instruction):
    parts = instruction.split()
    opcode = parts[0]
    if opcode in opcode_table:
        if opcode in ['add', 'sub', 'xor', 'or', 'and', 'sll', 'srl', 'sra', 'slt', 'sltu']:
            rd = reg_table[parts[1][:-1]]
            rs1 = reg_table[parts[2].strip(',')]
            rs2 = reg_table[parts[3]]
            funct7 = funct7_table[opcode]
            funct3 = funct3_table[opcode]
            return f"{funct7}{rs2}{rs1}{funct3}{rd}{opcode_table[opcode]}"
        
        elif opcode in ['addi', 'xori', 'andi', 'ori', 'slti', 'sltiu', 'slli', 'srli', 'srai']:
            rd = reg_table[parts[1].strip(',')]
            rs1 = reg_table[parts[2].strip(',')]
            if (parts[3].startswith("0x")):
                imm = hex_to_int(parts[3])
            else:
                imm = int(parts[3])

            imm_bin = imm_to_bin(imm, 12)
            funct3 = funct3_table[opcode]
            return f"{imm_bin}{rs1}{funct3}{rd}{opcode_table[opcode]}"
        
        elif opcode in ['lb', 'lh', 'lw', 'lbu', 'lhu']:
            # I-type (load)
            rd = reg_table[parts[1][:-1]]
            # imm_t = parts[2].split('(')[0]
            # if (imm_t.startswith("0x")):
            #     imm = hex_to_int(imm_t)
            # else:
            #     imm = int(imm_t)
            # imm = imm_to_bin(imm, 12)
            imm = imm_to_bin(int(parts[2].split('(')[0]), 12)
            rs1 = reg_table[parts[2].split('(')[1][:-1]]
            funct3 = funct3_table[opcode]
            return f"{imm}{rs1}{funct3}{rd}{opcode_table[opcode]}"
        
        elif opcode in ['sb', 'sh', 'sw']:
            funct3 = funct3_table[opcode]
            rs2 = reg_table[parts[1][:-1]]
            # imm_t = parts[2].split('(')[0]
            # if (imm_t.startswith("0x")):
            #     imm = hex_to_int(imm_t)
            # else:
            #     imm = int(imm_t)
            # imm = imm_to_bin(imm, 12)
            imm = imm_to_bin(int(parts[2].split('(')[0]), 12)
            rs1 = reg_table[parts[2].split('(')[1][:-1]]
            return f"{imm[:7]}{rs2}{rs1}{funct3}{imm[7:]}{opcode_table[opcode]}"
        
        elif opcode in ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']:
            # B-type (branch)
            funct3 = funct3_table[opcode]
            rs1 = reg_table[parts[1].strip(',')]
            rs2 = reg_table[parts[2].strip(',')]
            imm = int(parts[3])
            imm_bin = imm_to_bin(imm, 13)
            return f"{imm_bin[0]}{imm_bin[2:8]}{rs2}{rs1}{funct3}{imm_bin[8:12]}{imm_bin[1]}{opcode_table[opcode]}"
        
        elif opcode == 'jalr':
            rd = reg_table[parts[1][:-1]]
            rs1 = reg_table[parts[2].strip(',')]
            imm = imm_to_bin(int(parts[3]), 12)
            funct3 = funct3_table[opcode]
            return f"{imm}{rs1}{funct3}{rd}{opcode_table[opcode]}"

        elif opcode == 'jal':
            # UJ-type (jal)
            rd = reg_table[parts[1][:-1]]
            imm = int(parts[2])
            imm_bin = imm_to_bin(imm, 21)
            return f"{imm_bin[0]}{imm_bin[10:20]}{imm_bin[9]}{imm_bin[1:9]}{rd}{opcode_table[opcode]}"
        
        elif opcode in ['lui', 'auipc']:
            rd = reg_table[parts[1][:-1]]
            if (parts[2].startswith("0x")):
                imm = hex_to_int(parts[2])
            else:
                imm = int(parts[2])

            imm_bin = imm_to_bin(imm, 20)
            return f"{imm_bin}{rd}{opcode_table[opcode]}"
        elif opcode in ['aes_read_status', 'aes_read_result']:
            imm = "000000000000"
            rd  = reg_table[parts[1][:-1]]
            rs1 = reg_table[parts[2]]
            funct3 = funct3_table[opcode]
            return f"{imm}{rs1}{funct3}{rd}{opcode_table[opcode]}"
        elif opcode in ['aes_write_block', 'aes_write_key', 'aes_write_config', 'aes_write_ctrl']:
            funct3 = funct3_table[opcode]
            rs2 = reg_table[parts[1][:-1]]
            imm = "000000000000"
            rs1 = reg_table[parts[2]]
            return f"{imm[:7]}{rs2}{rs1}{funct3}{imm[7:]}{opcode_table[opcode]}"
        elif opcode in ['csrrw', 'csrrwi', 'csrrc', 'csrrci', 'csrrs', 'csrrsi']:
            funct3 = funct3_table[opcode]
            rs1 = reg_table[parts[3]]
            rd  = reg_table[parts[-1]]
            imm = csr_table[parts[2][:-1]]
            return f"{imm}{rs1}{funct3}{rd}{opcode_table[opcode]}"
    else:
        raise ValueError(f"Unknown opcode: {opcode}")

# Process
def process(code):
    binary_code = []

    for line in code:
        if line.endswith(":"):
            continue 
        try:
            instr_bin = asm_to_bin(line)
            print(instr_bin)
            if instr_bin is None:
                print(f"Warning: asm_to_bin returned None for line: {line}")
            binary_code.append(instr_bin)
        except ValueError as e:
            print(f"Error: {e} for line: {line}")
            binary_code.append(None)
        
    return binary_code

def bin_to_hex(binary_str):

    # Chuyển đổi chuỗi nhị phân sang số nguyên
    decimal_value = int(binary_str, 2)
    # Chuyển đổi số nguyên sang chuỗi thập lục phân và loại bỏ tiền tố '0x'
    hex_str = hex(decimal_value)[2:]
    # Đảm bảo chuỗi thập lục phân có độ dài là 8 ký tự (32 bit)
    hex_str = hex_str.zfill(8)
    return hex_str

def read_file(file):
    with open(file, 'r') as f:
        return f.readlines()

def main(input_file, output_file, bin2hex):
    # Đọc nội dung file và lưu vào một mảng
    code = read_file(input_file)
    # Làm sạch mã assembly
    cleaned_code = add_space_after_comma(code)
    cleaned_code = pre_process(cleaned_code)

    # Xử lý mã assembly và chuyển đổi sang mã máy
    binary_code = process(cleaned_code)
    # Ghi mã máy ra file
    print("Writing binary output to file...")
    with open(output_file, 'w') as outfile:
        for instr in binary_code:
            if instr is not None:
                # Chuyển đổi chuỗi nhị phân thành bytes và ghi vào file
                outfile.write(instr + '\n')
    
    if bin2hex:
        print("Converting binary output to hexadecimal...")
        for code in binary_code:
            print(bin_to_hex(code.strip()))
        
        with open(output_file, 'r') as f:
            binary_code = f.readlines()
        with open(output_file, 'w') as f:
            for line in binary_code:
                hex_str = bin_to_hex(line.strip())
                f.write(hex_str + '\n')
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="RISC-V RV32I Assembler")
    parser.add_argument("input_file", help="Path to the input assembly file")
    parser.add_argument("output_file", help="Path to the output binary file")
    parser.add_argument("-bin2hex", action="store_true", help="Convert binary output to hexadecimal")
    args = parser.parse_args()

    main(args.input_file, args.output_file, args.bin2hex)