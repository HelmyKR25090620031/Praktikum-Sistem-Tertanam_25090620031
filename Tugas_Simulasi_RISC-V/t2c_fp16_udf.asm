# =====================================================
# TANTANGAN 2 (Level Lanjut - Bagian C) - Tambahan Operasi Underflow FP16
# Uji Underflow: 0.001 * 0.01 = 0.00001 (< 6.1e-5) -> dibulatkan ke 0
# Simulator    : RARS (RV32IMF)
# =====================================================
.data
v_kecil1: .float 0.001
v_kecil2: .float 0.01
msg_udf:  .string "0.001 * 0.01 (underflow) = "
s_hx:     .string "  pola FP16 = "
NL:       .string "\n"

.text
main:
    la     t0, v_kecil1
    flw    ft1, 0(t0)                # ft1 = 0.001 (FP32)
    la     t0, v_kecil2
    flw    ft2, 0(t0)                # ft2 = 0.01 (FP32)

    fmul.s ft0, ft1, ft2             # ft0 = 0.00001 (1.0E-5 < 6.1E-5)
    la     a0, msg_udf
    jal    ra, hasil

    li   a7, 10
    ecall

hasil:
    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      a0, 0(sp)
    fmv.x.w a0, ft0
    jal     ra, f2h
    mv      a1, a0
    lw      a0, 0(sp)
    jal     ra, cetak_h
    lw      ra, 4(sp)
    addi    sp, sp, 8
    ret

cetak_h:
    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      a1, 0(sp)
    li      a7, 4
    ecall
    mv      a0, a1
    jal     ra, h2f
    fmv.w.x fa0, a0
    li      a7, 2
    ecall
    la      a0, s_hx
    li      a7, 4
    ecall
    lw      a0, 0(sp)
    li      a7, 34
    ecall
    la      a0, NL
    li      a7, 4
    ecall
    lw      ra, 4(sp)
    addi    sp, sp, 8
    ret

f2h:
    srli t0, a0, 16
    li   t6, 0x8000
    and  t0, t0, t6
    srli t1, a0, 23
    andi t1, t1, 0xFF                # untuk 1e-5, eksponen FP32 = 110
    li   t6, 0x7FFFFF
    and  t2, a0, t6

    li   t6, 0xFF
    beq  t1, t6, f2h_infnan
    addi t1, t1, -112                # e16 = 110 - 112 = -2 (<= 0 -> underflow!)
    blez t1, f2h_nol                 # lompat ke f2h_nol (flush-to-zero)
    li   t6, 31
    bge  t1, t6, f2h_inf

    slli t1, t1, 10
    or   t0, t0, t1
    srli t3, t2, 13
    or   t0, t0, t3
    j    f2h_out
f2h_infnan:
    beqz t2, f2h_inf
    li   t6, 0x7E00
    or   t0, t0, t6
    j    f2h_out
f2h_inf:
    li   t6, 0x7C00
    or   t0, t0, t6
f2h_nol:
f2h_out:
    mv   a0, t0
    ret

h2f:
    li   t6, 0x8000
    and  t0, a0, t6
    slli t0, t0, 16
    srli t1, a0, 10
    andi t1, t1, 0x1F
    andi t2, a0, 0x3FF
    beqz t1, h2f_out
    li   t6, 31
    beq  t1, t6, h2f_infnan
    addi t1, t1, 112
    slli t1, t1, 23
    or   t0, t0, t1
    slli t2, t2, 13
    or   t0, t0, t2
    j    h2f_out
h2f_infnan:
    li   t6, 0x7F800000
    or   t0, t0, t6
    slli t2, t2, 13
    or   t0, t0, t2
h2f_out:
    mv   a0, t0
    ret