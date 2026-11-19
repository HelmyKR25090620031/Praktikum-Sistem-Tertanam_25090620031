# =====================================================
# Percobaan 2A - Operasi ALU (Aritmetika, Logika, Geser, Banding)
# Simulator: Ripes (RV32IM)
# =====================================================
.text
main:
    li   t0, 12             # t0 = 12 = 0b1100
    li   t1, 10             # t1 = 10 = 0b1010
    li   t2, -8             # t2 = -8 = 0xFFFFFFF8

    # --- Aritmetika
    add  s0, t0, t1         # s0 = 12 + 10
    sub  s1, t0, t1         # s1 = 12 - 10

    # --- Logika bitwise
    and  s2, t0, t1         # s2 = 1100 AND 1010
    or   s3, t0, t1         # s3 = 1100 OR 1010
    xor  s4, t0, t1         # s4 = 1100 XOR 1010

    # --- Geser (shift)
    slli s5, t0, 2          # s5 = 12 << 2 (geser kiri logika)
    srli s6, t2, 1          # s6 = -8 >> 1 (geser kanan LOGIKA, isi 0)
    srai s7, t2, 1          # s7 = -8 >> 1 (geser kanan ARITMETIKA, isi bit tanda)

    # --- Perbandingan
    slt  s8, t2, t0         # s8 = 1 jika -8 < 12 (bertanda / signed)
    sltu s9, t2, t0         # s9 = 1 jika 0xFFFFFFF8 < 12 (tak bertanda / unsigned)

    # --- Selesai
    li   a7, 10
    ecall