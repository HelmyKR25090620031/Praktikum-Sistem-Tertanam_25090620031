# =====================================================
# Percobaan 2C - Jump, Pemanggilan Fungsi, dan Stack
# Program: hitung 1^2 + 2^2 + ... + 5^2
# Simulator: Ripes (RV32IM)
# =====================================================
.text
main:
    li   a0, 5                  # argumen n = 5
    jal  ra, jumlah_kuadrat     # panggil fungsi, ra = alamat kembali
    mv   s0, a0                 # s0 = hasil
    li   a7, 10
    ecall

# -----------------------------------------------------
# Fungsi jumlah_kuadrat(n) -> a0 = 1^2 + ... + n^2
# Memanggil fungsi lain (kuadrat) sehingga ra HARUS disimpan di stack
# -----------------------------------------------------
jumlah_kuadrat:
    addi sp, sp, -16            # siapkan 16 byte di stack
    sw   ra, 12(sp)             # simpan alamat kembali
    sw   s1, 8(sp)              # simpan s1 (callee-saved)
    sw   s2, 4(sp)              # simpan s2 (callee-saved)

    mv   s1, a0                 # s1 = n (penghitung mundur)
    li   s2, 0                  # s2 = akumulator
ulang:
    beqz s1, keluar             # jika s1 == 0 selesai
    mv   a0, s1                 # argumen untuk kuadrat
    jal  ra, kuadrat            # a0 = s1 * s1
    add  s2, s2, a0             # akumulasi
    addi s1, s1, -1             # s1 = s1 - 1
    j    ulang
keluar:
    mv   a0, s2                 # nilai kembali
    lw   s2, 4(sp)              # pulihkan register
    lw   s1, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16             # bebaskan stack
    ret                         # pseudo: jalr x0, 0(ra)

# -----------------------------------------------------
# Fungsi kuadrat(x) -> a0 = x * x (fungsi daun / leaf)
# -----------------------------------------------------
kuadrat:
    mul  a0, a0, a0
    ret