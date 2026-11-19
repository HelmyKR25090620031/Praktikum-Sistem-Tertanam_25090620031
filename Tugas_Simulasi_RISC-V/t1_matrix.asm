# =====================================================
# TANTANGAN 1 - Contoh Kode: Simulasi Matriks 10x10, 20 Iterasi
# Model     : X(k+1) = (A * X(k)) mod 1000
# Simulator : RARS (RV32IM)
# Ekstensi  : RV32I + M (mul, remu)
# =====================================================
.data
A:       .space 400                  # 10 x 10 word (4 byte) = 400 byte
X:       .space 400
Y:       .space 400
s_iter:  .string "Iterasi "
s_cek:   .string ": checksum = "
s_final: .string "\nMatriks X setelah 20 iterasi:\n"
NL:      .string "\n"

.text
main:
    la   s0, A                       # s0 = alamat A
    la   s1, X                       # s1 = alamat X
    la   s2, Y                       # s2 = alamat Y
    li   s7, 10                      # s7 = N = 10
    li   s8, 1000                    # s8 = modulus

    # --- Inisialisasi: A[i][j] = (i+j) mod 3, X[i][j] = i*10 + j
    li   s4, 0                       # i = 0
init_i:
    li   s5, 0                       # j = 0
init_j:
    mul  t0, s4, s7                  # t0 = i*N
    add  t0, t0, s5                  # t0 = i*N + j (indeks linear)
    slli t1, t0, 2                   # t1 = offset byte = indeks*4
    add  t2, s0, t1
    add  t3, s4, s5
    li   t4, 3
    remu t3, t3, t4                  # (i+j) mod 3
    sw   t3, 0(t2)                   # A[i][j]
    add  t2, s1, t1
    sw   t0, 0(t2)                   # X[i][j] = i*10 + j
    addi s5, s5, 1
    blt  s5, s7, init_j
    addi s4, s4, 1
    blt  s4, s7, init_i

    # --- Loop utama 20 iterasi
    li   s3, 1                       # iterasi = 1
iter_loop:
    li   s4, 0                       # i = 0
mm_i:
    li   s5, 0                       # j = 0
mm_j:
    li   t5, 0                       # sum = 0
    li   s6, 0                       # k = 0
mm_k:
    mul  t0, s4, s7                  # alamat A[i][k]
    add  t0, t0, s6
    slli t0, t0, 2
    add  t0, s0, t0
    lw   t1, 0(t0)

    mul  t2, s6, s7                  # alamat X[k][j]
    add  t2, t2, s5
    slli t2, t2, 2
    add  t2, s1, t2
    lw   t3, 0(t2)

    mul  t4, t1, t3                  # A[i][k] * X[k][j]
    add  t5, t5, t4                  # sum += ...
    addi s6, s6, 1
    blt  s6, s7, mm_k

    remu t5, t5, s8                  # sum mod 1000
    mul  t0, s4, s7                  # alamat Y[i][j]
    add  t0, t0, s5
    slli t0, t0, 2
    add  t0, s2, t0
    sw   t5, 0(t0)

    addi s5, s5, 1
    blt  s5, s7, mm_j
    addi s4, s4, 1
    blt  s4, s7, mm_i

    # --- Salin Y -> X sekaligus hitung checksum (jumlah semua elemen)
    li   t0, 0                       # indeks 0..99
    li   t6, 0                       # checksum
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

    # --- Cetak "Iterasi k: checksum = c"
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

    # --- Cetak matriks akhir
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
    li   a0, 9                       # karakter TAB
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