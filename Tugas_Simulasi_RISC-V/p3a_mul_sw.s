# =====================================================
# Percobaan 3 Kasus A (versi 2) - Perkalian & pembagian
# TANPA ekstensi "M" (hanya RV32I): diganti PERANGKAT LUNAK
# perkalian metode geser-dan-jumlah (shift-and-add)
# pembagian metode pengurangan bertingkat (restoring division)
# Berjalan pada RV32I maupun RV32IM
# =====================================================
.text
main:
    li   a0, 123
    li   a1, 45
    jal  ra, kali_sw        # a0 = 123 * 45
    mv   s0, a0

    mv   a0, s0
    li   a1, 45
    jal  ra, bagi_sw        # a0 = s0 / 45, a1 = s0 % 45
    mv   s1, a0

    mv   a0, s0
    li   a1, 7
    jal  ra, bagi_sw        # a1 = s0 % 7
    mv   s2, a1

    li   a7, 10
    ecall

# kali_sw(a0, a1) -> a0 = a0 * a1 (bilangan tak bertanda)
kali_sw:
    li   t0, 0              # t0 = hasil
kali_loop:
    beqz a1, kali_end       # pengali habis -> selesai
    andi t1, a1, 1          # cek bit terendah pengali
    beqz t1, kali_geser
    add  t0, t0, a0         # bit = 1 -> tambahkan multiplicand
kali_geser:
    slli a0, a0, 1          # multiplicand << 1
    srli a1, a1, 1          # pengali >> 1
    j    kali_loop
kali_end:
    mv   a0, t0
    ret

# bagi_sw(a0, a1) -> a0 = a0 / a1, a1 = a0 % a1 (tak bertanda, 32 bit)
bagi_sw:
    li   t0, 0              # t0 = hasil bagi (quotient)
    li   t1, 0              # t1 = sisa (remainder)
    li   t2, 31             # t2 = indeks bit, mulai dari bit 31
bagi_loop:
    bltz t2, bagi_end
    slli t1, t1, 1          # sisa << 1
    srl  t3, a0, t2         # ambil bit ke-t2 dari pembilang
    andi t3, t3, 1
    or   t1, t1, t3         # masukkan ke sisa
    bltu t1, a1, bagi_next  # jika sisa < pembagi, bit hasil = 0
    sub  t1, t1, a1         # sisa = sisa - pembagi
    li   t4, 1
    sll  t4, t4, t2
    or   t0, t0, t4         # set bit hasil ke-t2
bagi_next:
    addi t2, t2, -1
    j    bagi_loop
bagi_end:
    mv   a0, t0
    mv   a1, t1
    ret