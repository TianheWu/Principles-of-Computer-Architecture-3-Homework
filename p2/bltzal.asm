lui $15,0xffff
ori $15,$15,0x1234
bltzal $15, jump
ori $13,$13,0x1234

jump:
addi $14,$14,1
jr $31