# =====================================================
# TANTANGAN 1 (Level Menengah) - Simulasi Difusi Panas Pelat 10x10
# Syarat    : Baris 0 = 100 (tetap), tepi lain = 0, sel dalam awal = 0
# Rumus     : suhu_baru = (atas + bawah + kiri + kanan) >> 2 (srli 2)
# Simulator : RARS (RV32IM)
# =====================================================
.data
.align 2
X:       .space 400                  # Buffer suhu saat ini (10 x 10 word)
Y:       .space 400                  # Buffer suhu iterasi berikutnya
s_iter:  .string "Iterasi "
s_cek:   .string ": checksum = "
s_final: .string "\nDistribusi Suhu Pelat X setelah 20 iterasi:\n"
NL:      .string "\n"

.text
main:
    la   s1, X                       # s1 = alamat dasar buffer X
    la   s2, Y                       # s2 = alamat dasar buffer Y
    li   s7, 10                      # s7 = N = 10

    # --- Inisialisasi pelat X dan Y: baris 0 = 100, lainnya = 0
    li   s4, 0                       # i = 0
init_i:
    li   s5, 0                       # j = 0
init_j:
    mul  t0, s4, s7
    add  t0, t0, s5
    slli t1, t0, 2                   # t1 = offset byte = (i*10 + j) * 4

    li   t3, 0                       # suhu default = 0
    bnez s4, simpan_awal             # jika bukan baris 0, tetap 0
    li   t3, 100                     # baris 0 (tepi atas) = 100
simpan_awal:
    add  t2, s1, t1
    sw   t3, 0(t2)                   # X[i][j] = t3
    add  t2, s2, t1
    sw   t3, 0(t2)                   # Y[i][j] = t3 (jaga kondisi batas)

    addi s5, s5, 1
    blt  s5, s7, init_j
    addi s4, s4, 1
    blt  s4, s7, init_i

    # --- Loop utama 20 iterasi difusi panas
    li   s3, 1                       # iterasi = 1
    li   s8, 9                       # batas atas sel dalam (i, j < 9)
iter_loop:
    li   s4, 1                       # mulai dari baris dalam i = 1
heat_i:
    li   s5, 1                       # mulai dari kolom dalam j = 1
heat_j:
    mul  t0, s4, s7
    add  t0, t0, s5
    slli t0, t0, 2                   # t0 = offset byte sel (i, j)
    add  t6, s1, t0                  # t6 = alamat X[i][j]

    lw   t1, -40(t6)                 # atas  = X[i-1][j] (mundur 10 word = 40 byte)
    lw   t2, 40(t6)                  # bawah = X[i+1][j] (maju 10 word = 40 byte)
    lw   t3, -4(t6)                  # kiri  = X[i][j-1] (mundur 1 word = 4 byte)
    lw   t4, 4(t6)                   # kanan = X[i][j+1] (maju 1 word = 4 byte)

    add  t5, t1, t2
    add  t5, t5, t3
    add  t5, t5, t4
    srli t5, t5, 2                   # rata-rata 4 tetangga = jumlah / 4

    add  t6, s2, t0                  # t6 = alamat Y[i][j]
    sw   t5, 0(t6)                   # simpan suhu baru ke Y[i][j]

    addi s5, s5, 1
    blt  s5, s8, heat_j
    addi s4, s4, 1
    blt  s4, s8, heat_i

    # --- Salin Y -> X dan hitung checksum seluruh 100 sel
    li   t0, 0
    li   t6, 0                       # akumulator checksum
    li   t1, 100
copy_loop:
    slli t2, t0, 2
    add  t3, s2, t2
    lw   t4, 0(t3)
    add  t3, s1, t2
    sw   t4, 0(t3)
    add  t6, t6, t4
    addi t0, t0, 1
    blt  t0, t1, copy_loop

    # --- Cetak checksum iterasi ke-s3
    la   a0, s_iter
    li   a7, 4
    ecall
    mv   a0, s3
    li   a7, 1
    ecall
    la   a0, s_cek
    li   a7, 4
    ecall
    mv   a0, t6
    li   a7, 1
    ecall
    la   a0, NL
    li   a7, 4
    ecall

    addi s3, s3, 1
    li   t0, 20
    ble  s3, t0, iter_loop

    # --- Cetak matriks suhu akhir
    la   a0, s_final
    li   a7, 4
    ecall
    li   s4, 0
pr_i:
    li   s5, 0
pr_j:
    mul  t0, s4, s7
    add  t0, t0, s5
    slli t0, t0, 2
    add  t0, s1, t0
    lw   a0, 0(t0)
    li   a7, 1
    ecall
    li   a0, 9                       # TAB
    li   a7, 11
    ecall
    addi s5, s5, 1
    blt  s5, s7, pr_j
    la   a0, NL
    li   a7, 4
    ecall
    addi s4, s4, 1
    blt  s4, s7, pr_i

    li   a7, 10
    ecall