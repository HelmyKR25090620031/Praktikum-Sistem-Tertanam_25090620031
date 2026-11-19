# =====================================================
# Percobaan 2B - Percabangan (Branch) dan Perulangan (Loop)
# Program: (a) jumlah 1+2+...+10
#          (b) cari nilai maksimum pada array
# Simulator: Ripes (RV32IM)
# =====================================================
.data
array: .word 7, 23, -4, 15, -42, 8, 0, 19
N:     .word 8

.text
main:
    # --- (a) Jumlah 1 s.d. 10
    li   t0, 1              # t0 = i = 1
    li   t1, 10             # t1 = batas = 10
    li   s0, 0              # s0 = jumlah = 0
loop_jumlah:
    add  s0, s0, t0         # jumlah = jumlah + i
    addi t0, t0, 1          # i = i + 1
    ble  t0, t1, loop_jumlah # jika i <= 10 ulangi (pseudo: bge t1, t0)

    # --- (b) Nilai maksimum array
    la   t2, array          # t2 = alamat elemen pertama
    lw   t3, N              # t3 = banyak elemen (8)
    lw   s1, 0(t2)          # s1 = maks = array[0]
    li   t4, 1              # t4 = indeks k = 1
loop_maks:
    bge  t4, t3, selesai    # jika k >= N keluar loop
    slli t5, t4, 2          # t5 = k * 4 (1 word = 4 byte)
    add  t5, t2, t5         # t5 = alamat array[k]
    lw   t6, 0(t5)          # t6 = array[k]
    blt  t6, s1, lewati     # jika array[k] < maks, lewati
    mv   s1, t6             # maks = array[k]
lewati:
    addi t4, t4, 1          # k = k + 1
    j    loop_maks          # kembali ke awal loop (pseudo: jal x0)
selesai:
    li   a7, 10
    ecall