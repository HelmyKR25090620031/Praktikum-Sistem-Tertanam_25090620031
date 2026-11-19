# =====================================================
# TANTANGAN 3 - Contoh Kode: Enkripsi (Encode) dan Dekripsi (Decode)
# Metode 1: Caesar Cipher (geser huruf sejauh K, A-Z dan a-z)
# Metode 2: XOR-Rotate Cipher dengan kunci teks (kunci berulang)
#           Encode: c = ROTL8( p XOR kunci[i], 3 )
#           Decode: p = ROTR8( c, 3 ) XOR kunci[i]
# Simulator : RARS (RV32IM)
# =====================================================
.data
pesan:   .string "Helmy Khairi Rauf"
kunci:   .string "25090620031"
buf_enc: .space 64
buf_dec: .space 64

h_asli:  .string "Pesan asli       : "
h_c_enc: .string "Caesar encode K=3: "
h_c_dec: .string "Caesar decode    : "
h_x_enc: .string "XOR-Rot encode   : "
h_x_dec: .string "XOR-Rot decode   : "
NL:      .string "\n"

.text
main:
    la   a0, h_asli
    la   a1, pesan
    jal  ra, cetak_str

    # ============ METODE 1: CAESAR ============
    la   a0, pesan
    la   a1, buf_enc
    li   a2, 3                       # K = 3 (geser maju)
    jal  ra, caesar

    la   a0, h_c_enc
    la   a1, buf_enc
    jal  ra, cetak_str

    la   a0, buf_enc
    la   a1, buf_dec
    li   a2, 23                      # geser mundur 3 = geser maju 26-3
    jal  ra, caesar

    la   a0, h_c_dec
    la   a1, buf_dec
    jal  ra, cetak_str

    # ============ METODE 2: XOR-ROTATE ============
    la   a0, pesan
    la   a1, buf_enc
    la   a2, kunci
    jal  ra, xor_encode              # a0 = panjang pesan
    mv   s0, a0

    la   a0, h_x_enc
    li   a7, 4
    ecall
    la   a0, buf_enc                 # cipher berisi byte acak -> cetak heksadesimal
    mv   a1, s0
    jal  ra, cetak_hex_bytes

    la   a0, buf_enc
    la   a1, buf_dec
    la   a2, kunci
    mv   a3, s0
    jal  ra, xor_decode

    la   a0, h_x_dec
    la   a1, buf_dec
    jal  ra, cetak_str

    li   a7, 10
    ecall

# caesar(a0 = sumber, a1 = tujuan, a2 = K); berhenti di byte 0
caesar:
    li   t5, 26
c_loop:
    lbu  t0, 0(a0)                   # ambil 1 karakter
    beqz t0, c_end                   # akhir string

    li   t1, 'A'
    li   t2, 'Z'
    blt  t0, t1, c_cek_kecil
    bgt  t0, t2, c_cek_kecil
    j    c_geser                     # huruf besar, basis 'A' (t1)

c_cek_kecil:
    li   t1, 'a'
    li   t2, 'z'
    blt  t0, t1, c_simpan            # bukan huruf -> salin apa adanya
    bgt  t0, t2, c_simpan

c_geser:
    sub  t0, t0, t1                  # 0..25
    add  t0, t0, a2                  # + K
    remu t0, t0, t5                  # mod 26 (perlu ekstensi M)
    add  t0, t0, t1                  # kembali ke kode ASCII

c_simpan:
    sb   t0, 0(a1)
    addi a0, a0, 1
    addi a1, a1, 1
    j    c_loop
c_end:
    sb   zero, 0(a1)                 # akhiri string tujuan dengan 0
    ret

# xor_encode(a0 = sumber, a1 = tujuan, a2 = kunci) -> a0 = panjang
xor_encode:
    li   t6, 0                       # i = 0
    mv   t4, a2                      # t4 = penunjuk kunci
xe_loop:
    lbu  t0, 0(a0)
    beqz t0, xe_end

    lbu  t1, 0(t4)
    bnez t1, xe_ok
    mv   t4, a2                      # kunci habis -> ulang dari awal
    lbu  t1, 0(t4)
xe_ok:
    xor  t0, t0, t1                  # p XOR k
    slli t2, t0, 3                   # ROTL8(x,3) = ((x<<3) | (x>>5)) & 0xFF
    srli t3, t0, 5
    or   t0, t2, t3
    andi t0, t0, 0xFF
    sb   t0, 0(a1)

    addi a0, a0, 1
    addi a1, a1, 1
    addi t4, t4, 1
    addi t6, t6, 1
    j    xe_loop
xe_end:
    mv   a0, t6
    ret

# xor_decode(a0 = cipher, a1 = tujuan, a2 = kunci, a3 = panjang)
xor_decode:
    mv   t4, a2
xd_loop:
    beqz a3, xd_end
    lbu  t0, 0(a0)

    lbu  t1, 0(t4)
    bnez t1, xd_ok
    mv   t4, a2
    lbu  t1, 0(t4)
xd_ok:
    srli t2, t0, 3                   # ROTR8(x,3) = ((x>>3) | (x<<5)) & 0xFF
    slli t3, t0, 5
    or   t0, t2, t3
    andi t0, t0, 0xFF
    xor  t0, t0, t1                  # XOR kunci -> plaintext
    sb   t0, 0(a1)

    addi a0, a0, 1
    addi a1, a1, 1
    addi t4, t4, 1
    addi a3, a3, -1
    j    xd_loop
xd_end:
    sb   zero, 0(a1)
    ret

# cetak_str(a0 = judul, a1 = string)
cetak_str:
    li   a7, 4
    ecall
    mv   a0, a1
    ecall
    la   a0, NL
    ecall
    ret

# cetak_hex_bytes(a0 = alamat, a1 = jumlah byte): tiap byte 2 digit hex
cetak_hex_bytes:
    mv   t0, a0
    mv   t1, a1
hb_loop:
    beqz t1, hb_end
    lbu  t2, 0(t0)
    srli t3, t2, 4                   # nibble atas
    jal  t6, hb_digit
    andi t3, t2, 0xF                 # nibble bawah
    jal  t6, hb_digit
    li   a0, 32                      # spasi pemisah antar-byte
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

hb_digit:                            # cetak t3 (0..15) sebagai '0'..'9', 'A'..'F'
    li   t4, 10
    addi a0, t3, '0'
    blt  t3, t4, hb_put
    addi a0, t3, 55                  # 'A' - 10 = 55
hb_put:
    li   a7, 11
    ecall
    jalr x0, 0(t6)