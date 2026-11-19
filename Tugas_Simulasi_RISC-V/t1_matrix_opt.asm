# =====================================================
# TANTANGAN 1 (Level Lanjut) - Optimasi Perkalian Matriks Tanpa MUL di mm_k
# Optimasi  : Pointer baris A ditambah 4 byte, pointer kolom X ditambah 40 byte
# Simulator : RARS (RV32IM)
# =====================================================
.data
.align 2
A:       .space 400
X:       .space 400
Y:       .space 400
s_iter:  .string "Iterasi "
s_cek:   .string ": checksum = "
s_final: .string "\nMatriks X setelah 20 iterasi (Teroptimasi):\n"
NL:      .string "\n"

.text
main:
    la   s0, A                       # s0 = basis A
    la   s1, X                       # s1 = basis X
    la   s2, Y                       # s2 = basis Y
    li   s7, 10                      # s7 = N = 10
    li   s8, 1000                    # s8 = modulus

    # --- Inisialisasi A dan X
    li   s4, 0
init_i:
    li   s5, 0
init_j:
    mul  t0, s4, s7
    add  t0, t0, s5
    slli t1, t0, 2
    add  t2, s0, t1
    add  t3, s4, s5
    li   t4, 3
    remu t3, t3, t4
    sw   t3, 0(t2)
    add  t2, s1, t1
    sw   t0, 0(t2)
    addi s5, s5, 1
    blt  s5, s7, init_j
    addi s4, s4, 1
    blt  s4, s7, init_i

    # --- Loop utama 20 iterasi (teroptimasi pointer)
    li   s3, 1
iter_loop:
    li   s4, 0                       # i = 0
    mv   a2, s0                      # a2 = pointer awal baris A[i][0]
    mv   a3, s2                      # a3 = pointer awal baris Y[i][0]
mm_i:
    li   s5, 0                       # j = 0
mm_j:
    li   t5, 0                       # sum = 0
    li   s6, 0                       # k = 0
    mv   t0, a2                      # t0 = pointer A[i][0]
    slli t2, s5, 2
    add  t2, s1, t2                  # t2 = pointer X[0][j]

mm_k:
    lw   t1, 0(t0)                   # ambil A[i][k] langsung dari pointer
    lw   t3, 0(t2)                   # ambil X[k][j] langsung dari pointer
    mul  t4, t1, t3                  # hanya 1x mul untuk perkalian elemen
    add  t5, t5, t4                  # sum += A[i][k] * X[k][j]

    addi t0, t0, 4                   # geser pointer A ke kolom berikutnya (+4 byte)
    addi t2, t2, 40                  # geser pointer X ke baris berikutnya (+40 byte)
    addi s6, s6, 1
    blt  s6, s7, mm_k

    remu t5, t5, s8                  # sum mod 1000
    slli t0, s5, 2
    add  t0, a3, t0                  # alamat Y[i][j] = basis_baris_Y + j*4
    sw   t5, 0(t0)

    addi s5, s5, 1
    blt  s5, s7, mm_j

    addi a2, a2, 40                  # pindah ke baris A berikutnya (+40 byte)
    addi a3, a3, 40                  # pindah ke baris Y berikutnya (+40 byte)
    addi s4, s4, 1
    blt  s4, s7, mm_i

    # --- Salin Y -> X dan hitung checksum
    li   t0, 0
    li   t6, 0
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

    # --- Cetak checksum
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
    li   a0, 9
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