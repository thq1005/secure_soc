`ifndef INC_PACKET_SV
`define INC_PACKET_SV
class Packet;
string name;
logic [31:0] instruction;
rand bit [6:0] opcode;
rand bit [4:0] rs1,rs2,rd;
rand bit [11:0] imm_0; //i s sb
rand bit [19:0] imm_1;
rand bit [2:0] funct3;
rand bit [6:0] funct7;
constraint opcode_limit{
    opcode inside {7'h03,7'h13,7'h17,7'h23,7'h33,7'h37,7'h63,7'h67,7'h6F};
}
constraint reg_limit{
    rd != 0;
}
constraint imm_limit{
    (opcode == 7'h03) -> imm_0 inside {[0:1023]};
    (opcode == 7'h23) -> imm_0 inside {[0:1023]};
}
constraint funct_limit{
    (opcode == 7'h03) -> funct3 inside {0,1,2,4,5};
    (opcode == 7'h13) -> funct3 inside {[0:7]};
    (opcode == 7'h23) -> funct3 inside {[0:2]};
    (opcode == 7'h33) -> funct3 inside {[0:7]};
    (opcode == 7'h63) -> funct3 inside {0,1,4,5,6,7};
    funct7 inside {7'h00,7'h20};
}
extern function new(string name = "Packet");
extern function gen();
extern function void display(string prefix = "NOTE");
endclass:Packet

function Packet:: new(string name);
    this.name = name;
endfunction:new

function Packet::gen();
    if (opcode == 7'h03 | opcode == 7'h13 | opcode == 7'h67)
        instruction <= {imm_0,rs1,funct3,rd,opcode};
    else if (opcode == 7'h17 | opcode == 7'h37)
        instruction <= {imm_1,rd,opcode}; 
    else if (opcode == 7'h23)
        instruction <= {imm_0[11:5],rs2,rs1,funct3,imm_0[4:0],opcode}; 
    else if (opcode == 7'h33)
        instruction <= {funct7,rs2,rs1,funct3,rd,opcode}; 
    else if (opcode == 7'h63)
        instruction <= {imm_0[11],imm_0[9:4],rs2,rs1,funct3,imm_0[3:0],imm_0[10],opcode}; 
    else if (opcode == 7'h6F)
        instruction <= {imm_1[19],imm_1[9:0],imm_1[11],imm_1[18:11],rd,opcode}; 
endfunction:gen

function Packet:: display(string prefix = "NOTE");
    $display("---%s---",prefix);
    if (opcode == 7'h03) begin
        if (funct3 == 0)
            $display ("lb R%d,M[R%d + %d]",rd,rs1,imm_0);
        else if (funct3 == 1)
            $display ("lh R%d,M[R%d + %d]",rd,rs1,imm_0);
        else if (funct3 == 2)
            $display ("lw R%d,M[R%d + %d]",rd,rs1,imm_0);
        else if (funct3 == 4)
            $display ("lbu R%d,M[R%d + %d]",rd,rs1,imm_0);
        else if (funct3 == 5)
            $display ("lhu R%d,M[R%d + %d]",rd,rs1,imm_0);
    end
    else if (opcode == 7'h13) begin
        if (funct3 == 0)
            $display ("addi R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 1)
            $display ("slli R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 2)
            $display ("slti R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 3)
            $display ("sltiu R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 4)
            $display ("xori R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 5)
            if (funct7 == 7'h00)
                $display ("srli R%d, R%d, %d",rd,rs1,imm_0);
            else
                $display ("srai R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 6)
            $display ("ori R%d, R%d, %d",rd,rs1,imm_0);
        else if (funct3 == 7)
            $display ("andi R%d, R%d, %d",rd,rs1,imm_0);
    end
    else if (opcode == 7'h17) begin
        $display ("auipc R%d, %d",rd,imm_1);
    end
    else if (opcode == 7'h23) begin
        if (funct3 == 0)    
           $display ("sb M[R%d + %d],R%d",rs1,imm_0,rs2);
        else if (funct3 == 1)    
           $display ("sh M[R%d + %d],R%d",rs1,imm_0,rs2);
        else if (funct3 == 2)    
           $display ("sw M[R%d + %d],R%d",rs1,imm_0,rs2);
    end
    else if (opcode == 7'h33) begin
        if (funct3 == 0)
            if (funct7 == 7'h00)
                $display ("add R%d, R%d, R%d",rd,rs1,rs2);
            else
                $display ("sub R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 1)
            $display ("sll R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 2)
            $display ("slt R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 3)
            $display ("sltu R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 4)
            $display ("xor R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 5)
            if (funct7 == 7'h00)
                $display ("srl R%d, R%d, R%d",rd,rs1,rs2);
            else
                $display ("sra R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 6)
            $display ("or R%d, R%d, R%d",rd,rs1,rs2);
        else if (funct3 == 7)
            $display ("and R%d, R%d, R%d",rd,rs1,rs2);
    end
    else if (opcode == 7'h37) begin
        $display ("lui R%d, %d",rd,imm_1);
    end
    else if (opcode == 7'h63) begin
        if (funct3 == 0)    
           $display ("beq R%d, R%d, %d",rs1,rs2,imm_0);
        else if (funct3 == 1)    
           $display ("bne R%d, R%d, %d",rs1,rs2,imm_0);
        else if (funct3 == 4)    
           $display ("blt R%d, R%d, %d",rs1,rs2,imm_0);
        else if (funct3 == 5)    
           $display ("bge R%d, R%d, %d",rs1,rs2,imm_0);
        else if (funct3 == 6)    
           $display ("bltu R%d, R%d, %d",rs1,rs2,imm_0);
        else if (funct3 == 7)    
           $display ("bgeu R%d, R%d, %d",rs1,rs2,imm_0); 
    end
    else if (opcode == 7'h67) begin
        $display ("jalr R%d, R%d, %d",rd,rs1,imm_0); 
    end
    else if (opcode == 7'h6F) begin
        $display ("jal R%d, %d",rd,imm_1); 
    end
endfunction:display
`endif