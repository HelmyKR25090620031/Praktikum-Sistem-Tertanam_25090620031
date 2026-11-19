# =====================================================
# TANTANGAN 2 (Bagian C) - Floating Point 16 bit (IEEE 754 half)
# Simulator : RARS (RV32IMF)
# Catatan   : Instruksi FP16 asli ada di ekstensi "Zfh", tetapi RARS
#             dan Ripes BELUM mendukungnya. Maka FP16 DIEMULASIKAN:
#             1) nilai disimpan sebagai pola 16 bit di register integer
#             2) untuk dihitung, FP16 -> FP32 (fungsi h2f)
#             3) operasi dilakukan dengan instruksi FP32 (fadd.s, dst.)
#             4) hasil dibulatkan kembali FP32 -> FP16 (fungsi f2h)
# Penyederhanaan: bilangan subnormal dibulatkan ke 0 (flush-to-zero).
# Pembulatan    : round to nearest, ties to even (sama dengan IEEE 754).
# =====================================================
.data
va:   .float 3.1
vb:   .float -1.3
vbig: .float 300.0
v2k:  .float 2048.0
v1:   .float 1.0

s_a:  .string "a (FP16)  = "
s_b:  .string "b (FP16)  = "
msg1: .string "a + b     = "
msg2: .string "a - b     = "
msg3: .string "a * b     = "
msg4: .string "a / b     = "
msg5: .string "300 * 300 = "
msg6: .string "2048 + 1  = "
s_hx: .string "  pola FP16 = "
NL:   .string "\n"

.text
main:
    # --- ubah konstanta FP32 menjadi FP16 (disimpan di s0, s1)
    la   t0, va
    lw   a0, 0(t0)                   # pola bit FP32 dari 3.14159
    jal  ra, f2h
    mv   s0, a0                      # s0 = a dalam FP16

    la   t0, vb
    lw   a0, 0(t0)
    jal  ra, f2h
    mv   s1, a0                      # s1 = b dalam FP16

    la   a0, s_a
    mv   a1, s0
    jal  ra, cetak_h

    la   a0, s_b
    mv   a1, s1
    jal  ra, cetak_h

    # --- operasi: FP16 -> FP32, hitung, FP32 -> FP16
    mv      a0, s0
    jal     ra, h2f
    fmv.w.x fs0, a0                  # fs0 = a (FP32)

    mv      a0, s1
    jal     ra, h2f
    fmv.w.x fs1, a0                  # fs1 = b (FP32)

    fadd.s ft0, fs0, fs1
    la     a0, msg1
    jal    ra, hasil

    fsub.s ft0, fs0, fs1
    la     a0, msg2
    jal    ra, hasil

    fmul.s ft0, fs0, fs1
    la     a0, msg3
    jal    ra, hasil

    fdiv.s ft0, fs0, fs1
    la     a0, msg4
    jal    ra, hasil

    # --- overflow: nilai maks FP16 = 65504
    la     t0, vbig
    flw    ft1, 0(t0)
    fmul.s ft0, ft1, ft1             # 90000 -> terlalu besar untuk FP16
    la     a0, msg5
    jal    ra, hasil

    # --- presisi: mantissa FP16 hanya 11 bit
    la     t0, v2k
    flw    ft1, 0(t0)
    la     t0, v1
    flw    ft2, 0(t0)
    fadd.s ft0, ft1, ft2             # 2049 tidak bisa disimpan di FP16
    la     a0, msg6
    jal    ra, hasil

    li   a7, 10
    ecall

# hasil(a0 = teks, ft0 = hasil FP32): bulatkan ke FP16 lalu cetak
hasil:
    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      a0, 0(sp)
    fmv.x.w a0, ft0
    jal     ra, f2h                  # a0 = hasil dalam FP16
    mv      a1, a0
    lw      a0, 0(sp)
    jal     ra, cetak_h
    lw      ra, 4(sp)
    addi    sp, sp, 8
    ret

# cetak_h(a0 = teks, a1 = pola FP16): cetak nilai desimal + pola hex
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
    ecall                            # PrintFloat
    la      a0, s_hx
    li      a7, 4
    ecall
    lw      a0, 0(sp)
    li      a7, 34
    ecall                            # PrintIntHex
    la      a0, NL
    li      a7, 4
    ecall
    lw      ra, 4(sp)
    addi    sp, sp, 8
    ret

# f2h: a0 = pola FP32 -> a0 = pola FP16
#      FP32: [S:1][E:8 bias 127][M:23]
#      FP16: [S:1][E:5 bias 15][M:10]
f2h:
    srli t0, a0, 16
    li   t6, 0x8000
    and  t0, t0, t6                  # t0 = bit tanda pada posisi 15
    srli t1, a0, 23
    andi t1, t1, 0xFF                # t1 = eksponen FP32
    li   t6, 0x7FFFFF
    and  t2, a0, t6                  # t2 = mantissa FP32 (23 bit)

    li   t6, 0xFF
    beq  t1, t6, f2h_infnan          # eksponen 255 -> Inf atau NaN
    addi t1, t1, -112                # e16 = e32 - 127 + 15
    blez t1, f2h_nol                 # terlalu kecil -> 0 (flush to zero)
    li   t6, 31
    bge  t1, t6, f2h_inf             # terlalu besar -> Infinity

    slli t1, t1, 10
    or   t0, t0, t1                  # pasang eksponen
    srli t3, t2, 13                  # ambil 10 bit teratas mantissa
    or   t0, t0, t3

    # pembulatan "round to nearest, ties to even" (standar IEEE)
    li   t6, 0x1000
    and  t3, t2, t6                  # t3 = bit pembulatan (bit 12)
    beqz t3, f2h_out                 # bit 12 == 0 -> buang saja (bulat ke bawah)
    li   t6, 0xFFF
    and  t4, t2, t6                  # t4 = bit sisa (bit 11..0)
    bnez t4, f2h_naik                # sisa > 0 -> lebih dari setengah -> naik
    andi t4, t0, 1                   # tepat setengah: lihat bit terendah hasil
    beqz t4, f2h_out                 # sudah genap -> tetap
f2h_naik:
    addi t0, t0, 1                   # bulatkan ke atas (carry boleh ke eksponen)
    j    f2h_out

f2h_infnan:
    beqz t2, f2h_inf
    li   t6, 0x7E00
    or   t0, t0, t6                  # NaN
    j    f2h_out
f2h_inf:
    li   t6, 0x7C00
    or   t0, t0, t6                  # Infinity
f2h_nol:
f2h_out:
    mv   a0, t0
    ret

# h2f: a0 = pola FP16 -> a0 = pola FP32
h2f:
    li   t6, 0x8000
    and  t0, a0, t6
    slli t0, t0, 16                  # tanda ke bit 31
    srli t1, a0, 10
    andi t1, t1, 0x1F                # eksponen FP16
    andi t2, a0, 0x3FF               # mantissa FP16

    beqz t1, h2f_out                 # eksponen 0 -> nol (subnormal diabaikan)
    li   t6, 31
    beq  t1, t6, h2f_infnan

    addi t1, t1, 112                 # e32 = e16 - 15 + 127
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