# =====================================================
# TANTANGAN 2 (Bagian B) - Floating Point 32 bit (IEEE 754 single)
# Simulator : RARS (RV32IMF) - Ripes TIDAK mendukung ekstensi F
# Ekstensi  : F (register f0..f31, instruksi *.s)
# =====================================================
.data
va:     .float 3.1
vb:     .float -1.3
vbesar: .float 16777216.0
vsatu:  .float 1.0
vnol:   .float 0.0

txt_a:  .string "a            = "
txt_b:  .string "b            = "
txt1:   .string "a + b        = "
txt2:   .string "a - b        = "
txt3:   .string "a * b        = "
txt4:   .string "a / b        = "
txt5:   .string "16777216 + 1 = "
txt6:   .string "a / 0.0      = "
txt7:   .string "0.0 / 0.0    = "
k1:     .string "\n-- Konversi signed vs unsigned --\n"
k2:     .string "fcvt.w.s  (b -> int signed)       = "
k3:     .string "fcvt.wu.s (b -> int unsigned)     = "
k4:     .string "fcvt.s.w  (0xFFFFFFFF signed)     = "
k5:     .string "fcvt.s.wu (0xFFFFFFFF unsigned)   = "
bit:    .string "  bit IEEE754 = "
NL:     .string "\n"

.text
main:
    la    t0, va
    flw   fs0, 0(t0)                 # fs0 = a = 7.5
    la    t0, vb
    flw   fs1, 0(t0)                 # fs1 = b = -2.25

    la    a0, txt_a
    fmv.s fa0, fs0
    jal   ra, cetak_float

    la    a0, txt_b
    fmv.s fa0, fs1
    jal   ra, cetak_float

    la     a0, txt1
    fadd.s fa0, fs0, fs1             # penjumlahan
    jal    ra, cetak_float

    la     a0, txt2
    fsub.s fa0, fs0, fs1             # pengurangan
    jal    ra, cetak_float

    la     a0, txt3
    fmul.s fa0, fs0, fs1             # perkalian
    jal    ra, cetak_float

    la     a0, txt4
    fdiv.s fa0, fs0, fs1             # pembagian
    jal    ra, cetak_float

    # Presisi terbatas: mantissa hanya 24 bit, 2^24 + 1 tidak bisa disimpan
    la     t0, vbesar
    flw    ft0, 0(t0)
    la     t0, vsatu
    flw    ft1, 0(t0)
    la     a0, txt5
    fadd.s fa0, ft0, ft1
    jal    ra, cetak_float

    # Kasus istimewa: Infinity dan NaN
    la     t0, vnol
    flw    ft2, 0(t0)
    la     a0, txt6
    fdiv.s fa0, fs0, ft2             # 7.5 / 0 -> +Infinity
    jal    ra, cetak_float

    la     a0, txt7
    fdiv.s fa0, ft2, ft2             # 0 / 0 -> NaN
    jal    ra, cetak_float

    # --- signed vs unsigned pada KONVERSI float <-> integer
    la   a0, k1
    li   a7, 4
    ecall

    la       a0, k2
    li       a7, 4
    ecall
    fcvt.w.s a0, fs1, rtz            # -2.25 -> -2
    li       a7, 1
    ecall
    la       a0, NL
    li       a7, 4
    ecall

    la        a0, k3
    li        a7, 4
    ecall
    fcvt.wu.s a0, fs1, rtz           # -2.25 -> 0 (unsigned tidak bisa negatif)
    li        a7, 36
    ecall
    la        a0, NL
    li        a7, 4
    ecall

    li       t1, -1                  # 0xFFFFFFFF
    la       a0, k4
    fcvt.s.w fa0, t1                 # dibaca signed -> -1.0
    jal      ra, cetak_float

    la        a0, k5
    fcvt.s.wu fa0, t1                # dibaca unsigned -> 4294967295 -> 4.2949673E9
    jal       ra, cetak_float

    li   a7, 10
    ecall

# cetak_float(a0 = alamat teks, fa0 = nilai): cetak nilai + pola bit
cetak_float:
    li      a7, 4
    ecall
    li      a7, 2
    ecall                            # PrintFloat (fa0)
    la      a0, bit
    li      a7, 4
    ecall
    fmv.x.w a0, fa0                  # salin pola bit float ke register integer
    li      a7, 34
    ecall                            # PrintIntHex
    la      a0, NL
    li      a7, 4
    ecall
    ret