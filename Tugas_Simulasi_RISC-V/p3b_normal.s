# =====================================================
# Percobaan 3 Kasus B (pembanding) - Program yang SAMA
# ditulis dengan instruksi 32 bit biasa (RV32I)
# =====================================================
.text
main:
    addi a0, x0, 5
    addi a1, x0, 7
    add  a0, a0, a1
    addi a0, a0, 3
    add  a2, x0, a0
    and  a2, a2, a1
    addi a3, a0, 100
    li   a7, 10
    ecall