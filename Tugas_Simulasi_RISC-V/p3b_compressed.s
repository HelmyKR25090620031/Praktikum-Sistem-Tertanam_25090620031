# =====================================================
# Percobaan 3 Kasus B - Ekstensi "C" (Compressed, 16 bit)
# Wajib: Ekstensi C DIPASANG (RV32IC atau RV32IMC)
# Perhatikan kolom alamat: instruksi c.* hanya 2 byte!
# =====================================================
.text
main:
    c.li   a0, 5            # 16 bit: a0 = 5
    c.li   a1, 7            # 16 bit: a1 = 7
    c.add  a0, a1           # 16 bit: a0 = a0 + a1
    c.addi a0, 3            # 16 bit: a0 = a0 + 3
    c.mv   a2, a0           # 16 bit: a2 = a0
    c.and  a2, a1           # 16 bit: a2 = a2 AND a1 (hanya x8..x15!)
    addi   a3, a0, 100      # 32 bit: instruksi biasa
    li     a7, 10           # 32 bit
    ecall                   # 32 bit