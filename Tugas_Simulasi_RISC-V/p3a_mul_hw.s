# =====================================================
# Percobaan 3 Kasus A (versi 1) - Perkalian & pembagian
# memakai instruksi PERANGKAT KERAS dari ekstensi "M"
# Wajib: Ekstensi M DIPASANG (RV32IM)
# =====================================================
.text
main:
    li   a0, 123
    li   a1, 45
    mul  s0, a0, a1         # s0 = 123 * 45
    div  s1, s0, a1         # s1 = s0 / 45 (hasil bagi)
    li   t0, 7
    rem  s2, s0, t0         # s2 = s0 % 7 (sisa bagi)
    li   a7, 10
    ecall