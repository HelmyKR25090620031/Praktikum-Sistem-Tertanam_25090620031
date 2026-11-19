# =====================================================
# TANTANGAN 3 (Level Lanjut) - Sandi Blok 32-bit (8 Putaran)
# Encode    : c = ROTL32((p XOR K) + 0x9E3779B9, 7)  [8 putaran]
# Decode    : p = (ROTR32(c, 7) - 0x9E3779B9) XOR K  [8 putaran]
# Kunci K   : 0x52495343 ("RISC")
# Simulator : RARS (RV32I / RV32IM)
# =====================================================
.data
.align 2
pesan:   .string "Sistem Tertanam UNY 2026"
.align 2
buf_in:  .space 64                   # buffer input ter-align word (padding 0)
.align 2
buf_enc: .space 64                   # buffer ciphertext 32-bit
.align 2
buf_dec: .space 64                   # buffer hasil dekripsi

h_asli:  .string "Pesan asli         : "
h_b_enc: .string "Block-32 encode    : "
h_b_dec: .string "Block-32 decode    : "
NL:      .string "\n"

.text
main:
    # --- Salin pesan ke buf_in (yang sudah nol) dan hitung panjangnya
    la   t0, pesan
    la   t1, buf_in
    li   s0, 0                       # s0 = panjang karakter
salin_in:
    lbu  t2, 0(t0)
    beqz t2, hitung_blok
    sb   t2, 0(t1)
    addi t0, t0, 1
    addi t1, t1, 1
    addi s0, s0, 1
    j    salin_in

hitung_blok:
    addi s1, s0, 3
    srli s1, s1, 2                   # s1 = jumlah blok word = ceil(panjang / 4)
    li   s2, 0x52495343              # Kunci 32-bit K = "RISC"

    la   a0, h_asli
    la   a1, buf_in
    jal  ra, cetak_str

    # --- Enkripsi blok 32-bit
    la   a0, buf_in
    la   a1, buf_enc
    mv   a2, s2
    mv   a3, s1
    jal  ra, block32_enc

    la   a0, h_b_enc
    li   a7, 4
    ecall
    la   a0, buf_enc
    slli a1, s1, 2                   # total byte = jumlah_word * 4
    jal  ra, cetak_hex_bytes

    # --- Dekripsi blok 32-bit
    la   a0, buf_enc
    la   a1, buf_dec
    mv   a2, s2
    mv   a3, s1
    jal  ra, block32_dec

    la   a0, h_b_dec
    la   a1, buf_dec
    jal  ra, cetak_str

    li   a7, 10
    ecall

# block32_enc(a0 = src, a1 = dst, a2 = K, a3 = jumlah_word)
block32_enc:
    li   t3, 0x9E3779B9              # konstanta golden ratio 32-bit
    li   t5, 8                       # 8 putaran
be_word_loop:
    beqz a3, be_end
    lw   t0, 0(a0)                   # muat 4 karakter sekaligus (1 word)
    li   t4, 0                       # penghitung putaran = 0
be_round:
    xor  t0, t0, a2                  # p XOR K
    add  t0, t0, t3                  # + 0x9E3779B9
    slli t1, t0, 7                   # ROTL32(x, 7) = (x << 7) | (x >>> 25)
    srli t2, t0, 25
    or   t0, t1, t2
    addi t4, t4, 1
    blt  t4, t5, be_round

    sw   t0, 0(a1)                   # simpan 1 word ciphertext
    addi a0, a0, 4
    addi a1, a1, 4
    addi a3, a3, -1
    j    be_word_loop
be_end:
    ret

# block32_dec(a0 = src, a1 = dst, a2 = K, a3 = jumlah_word)
block32_dec:
    li   t3, 0x9E3779B9
    li   t5, 8
bd_word_loop:
    beqz a3, bd_end
    lw   t0, 0(a0)                   # muat 1 word ciphertext
    li   t4, 0
bd_round:
    srli t1, t0, 7                   # ROTR32(c, 7) = (c >>> 7) | (c << 25)
    slli t2, t0, 25
    or   t0, t1, t2
    sub  t0, t0, t3                  # - 0x9E3779B9
    xor  t0, t0, a2                  # XOR K
    addi t4, t4, 1
    blt  t4, t5, bd_round

    sw   t0, 0(a1)                   # simpan 4 karakter plaintext hasil dekripsi
    addi a0, a0, 4
    addi a1, a1, 4
    addi a3, a3, -1
    j    bd_word_loop
bd_end:
    sw   zero, 0(a1)                 # pastikan akhir string null-terminated
    ret

cetak_str:
    li   a7, 4
    ecall
    mv   a0, a1
    ecall
    la   a0, NL
    ecall
    ret

cetak_hex_bytes:
    mv   t0, a0
    mv   t1, a1
hb_loop:
    beqz t1, hb_end
    lbu  t2, 0(t0)
    srli t3, t2, 4
    jal  t6, hb_digit
    andi t3, t2, 0xF
    jal  t6, hb_digit
    li   a0, 32
    li   a7, 11
    ecall
    addi t0, t0, 1
    addi t1, t1, -1
    j    hb_loop
hb_end:
    la   a0, NL
    li   a7, 4
    ecall
    ret

hb_digit:
    li   t4, 10
    addi a0, t3, '0'
    blt  t3, t4, hb_put
    addi a0, t3, 55
hb_put:
    li   a7, 11
    ecall
    jalr x0, 0(t6)