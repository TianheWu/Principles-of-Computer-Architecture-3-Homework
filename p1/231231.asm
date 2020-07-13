lui $10,0xffff
ori $17, $17,0x1111
bgezal $17,giao
add $1,$2,$2

giao:
ori $20,$0,0xabcd
end:
ori $20,$0,0x1234
bgezal $10,end