# =====================================================
# TANTANGAN 2 (Bagian A) - Bilangan BULAT 16 & 32 bit, signed vs unsigned
# Simulator : RARS (RV32IM)
# Catatan   : RISC-V 32-bit tidak punya ALU 16 bit. Operasi 16 bit
#             dilakukan di 32 bit lalu DIPOTONG (truncate) ke 16 bit:
#               signed   -> slli 16 lalu srai 16 (perluasan tanda)
#               unsigned -> slli 16 lalu srli 16 (perluasan nol)
# =====================================================
.data
h1: .string "\n== 32 bit ==\n"
h2: .string "\n== 16 bit ==\n"
m1: .string "a + b (signed)        = "
m2: .string "a - b (signed)        = "
m3: .string "a * b (signed)        = "
m4: .string "a / b div  (signed)   = "
m5: .string "a % b rem  (signed)   = "
m6: .string "a / b divu (unsign)   = "
m7: .string "a % b remu (unsign)   = "
m8: .string "a sebagai unsigned    = "
n1: .string "u16: 60000 + 10000    = "
n2: .string "s16: 30000 + 10000    = "
n3: .string "s16: 300 * 200        = "
n4: .string "u16: 300 * 200        = "
n5: .string "s16: -20000 - 20000   = "
NL: .string "\n"

.text
main:
    # ================= 32 BIT =================
    la   a0, h1
    li   a7, 4
    ecall

    li   s0, -20                     # a = -20 (0xFFFFFFEC)
    li   s1, 3                       # b = 3

    la   a0, m1
    add  a1, s0, s1
    jal  ra, cetak_signed

    la   a0, m2
    sub  a1, s0, s1
    jal  ra, cetak_signed

    la   a0, m3
    mul  a1, s0, s1
    jal  ra, cetak_signed

    la   a0, m4
    div  a1, s0, s1
    jal  ra, cetak_signed

    la   a0, m5
    rem  a1, s0, s1
    jal  ra, cetak_signed

    la   a0, m6
    divu a1, s0, s1
    jal  ra, cetak_unsigned

    la   a0, m7
    remu a1, s0, s1
    jal  ra, cetak_unsigned

    la   a0, m8
    mv   a1, s0
    jal  ra, cetak_unsigned

    # ================= 16 BIT =================
    la   a0, h2
    li   a7, 4
    ecall

    # unsigned 16: 60000 + 10000 = 70000 -> melebihi 65535 (overflow)
    li   t0, 60000
    li   t1, 10000
    add  t2, t0, t1
    slli t2, t2, 16
    srli a1, t2, 16                  # potong ke 16 bit tak bertanda
    la   a0, n1
    jal  ra, cetak_unsigned

    # signed 16: 30000 + 10000 = 40000 -> melebihi 32767 (overflow)
    li   t0, 30000
    li   t1, 10000
    add  t2, t0, t1
    slli t2, t2, 16
    srai a1, t2, 16                  # potong ke 16 bit bertanda
    la   a0, n2
    jal  ra, cetak_signed

    # signed 16: 300 * 200 = 60000
    li   t0, 300
    li   t1, 200
    mul  t2, t0, t1
    slli t2, t2, 16
    srai a1, t2, 16
    la   a0, n3
    jal  ra, cetak_signed

    # unsigned 16: 300 * 200 = 60000 (masih muat)
    mul  t2, t0, t1
    slli t2, t2, 16
    srli a1, t2, 16
    la   a0, n4
    jal  ra, cetak_unsigned

    # signed 16: -20000 - 20000 = -40000 -> underflow
    li   t0, -20000
    li   t1, 20000
    sub  t2, t0, t1
    slli t2, t2, 16
    srai a1, t2, 16
    la   a0, n5
    jal  ra, cetak_signed

    li   a7, 10
    ecall

# cetak_signed(a0 = alamat teks, a1 = nilai)
cetak_signed:
    li   a7, 4
    ecall                            # cetak teks
    mv   a0, a1
    li   a7, 1
    ecall                            # PrintInt (bertanda)
    j    cetak_hex

# cetak_unsigned(a0 = alamat teks, a1 = nilai)
cetak_unsigned:
    li   a7, 4
    ecall
    mv   a0, a1
    li   a7, 36
    ecall                            # PrintIntUnsigned

cetak_hex:
    li   a0, 32                      # spasi
    li   a7, 11
    ecall
    li   a0, 40                      # '('
    li   a7, 11
    ecall
    mv   a0, a1
    li   a7, 34
    ecall                            # PrintIntHex
    li   a0, 41                      # ')'
    li   a7, 11
    ecall
    la   a0, NL
    li   a7, 4
    ecall
    ret