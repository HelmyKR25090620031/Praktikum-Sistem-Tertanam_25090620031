# =====================================================
# TANTANGAN 2 (Level Lanjut - Bagian A) - Deteksi Overflow 16-bit
# Prinsip   : Bandingkan hasil asli 32-bit dengan hasil terpotong 16-bit.
#             Jika berbeda (hasil32 != hasil16), cetak "OVERFLOW".
# Simulator : RARS (RV32IM)
# =====================================================
.data
h2:      .string "\n== Uji Deteksi Overflow 16 bit ==\n"
n1:      .string "u16: 60000 + 10000  = "
n2:      .string "s16: 30000 + 10000  = "
n3:      .string "s16: 300 * 200      = "
n4:      .string "u16: 300 * 200      = "
n5:      .string "s16: -20000 - 20000 = "
txt_ovf: .string " -> OVERFLOW"
NL:      .string "\n"

.text
main:
    la   a0, h2
    li   a7, 4
    ecall

    # 1. unsigned 16: 60000 + 10000 = 70000 (melebihi 65535 -> OVERFLOW)
    li   t0, 60000
    li   t1, 10000
    add  s3, t0, t1                  # s3 = hasil penuh 32-bit (70000)
    slli t2, s3, 16
    srli a1, t2, 16                  # a1 = hasil terpotong u16 (4464)
    la   a0, n1
    jal  ra, cetak_u16_ovf

    # 2. signed 16: 30000 + 10000 = 40000 (melebihi 32767 -> OVERFLOW)
    li   t0, 30000
    li   t1, 10000
    add  s3, t0, t1                  # s3 = 40000
    slli t2, s3, 16
    srai a1, t2, 16                  # a1 = -25536
    la   a0, n2
    jal  ra, cetak_s16_ovf

    # 3. signed 16: 300 * 200 = 60000 (melebihi 32767 -> OVERFLOW)
    li   t0, 300
    li   t1, 200
    mul  s3, t0, t1                  # s3 = 60000
    slli t2, s3, 16
    srai a1, t2, 16                  # a1 = -5536
    la   a0, n3
    jal  ra, cetak_s16_ovf

    # 4. unsigned 16: 300 * 200 = 60000 (muat di 0..65535 -> TIDAK overflow)
    mul  s3, t0, t1                  # s3 = 60000
    slli t2, s3, 16
    srli a1, t2, 16                  # a1 = 60000
    la   a0, n4
    jal  ra, cetak_u16_ovf

    # 5. signed 16: -20000 - 20000 = -40000 (kurang dari -32768 -> OVERFLOW)
    li   t0, -20000
    li   t1, 20000
    sub  s3, t0, t1                  # s3 = -40000
    slli t2, s3, 16
    srai a1, t2, 16                  # a1 = 25536
    la   a0, n5
    jal  ra, cetak_s16_ovf

    li   a7, 10
    ecall

cetak_s16_ovf:
    li   a7, 4
    ecall
    mv   a0, a1
    li   a7, 1
    ecall
    j    cek_ovf_akhir

cetak_u16_ovf:
    li   a7, 4
    ecall
    mv   a0, a1
    li   a7, 36
    ecall

cek_ovf_akhir:
    li   a0, 32
    li   a7, 11
    ecall
    li   a0, 40
    li   a7, 11
    ecall
    mv   a0, a1
    li   a7, 34
    ecall
    li   a0, 41
    li   a7, 11
    ecall

    beq  s3, a1, tanpa_ovf           # jika hasil32 == hasil16, aman
    la   a0, txt_ovf                 # jika berbeda, cetak OVERFLOW
    li   a7, 4
    ecall
tanpa_ovf:
    la   a0, NL
    li   a7, 4
    ecall
    ret