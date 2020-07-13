ori $1,$0,0xfc01
#初始化SR
mtc0 $1,$12
mfc0 $2,$15
#保存输入、输出设备的地址
ori $20,$0,0x7f00        # 0 ctrl，4 preset
ori $21,$0,0x7f14
ori $22,$0,0x7f20        # 地址
#初始化输入、输出设备
lw $10,0($22)
sw $10,4($21)   # 输出

#初始化TC ctrl
ori $10,$0,0x0008  # CTRL 初始化
sw $10,0($20)      # 赋值初值寄存器

#初始化TC present
ori $10,$10,0x000A  # 随便赋值
sw $10,4($20)       # 
lop:
j lop