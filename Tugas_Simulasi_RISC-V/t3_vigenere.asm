# =====================================================
# TANTANGAN 3 (Level Menengah) - Vigenere Cipher
# Aturan    : Huruf digeser sejauh nilai huruf kunci (A=0..Z=25), kunci berulang,
#             karakter non-huruf disalin apa adanya. Kunci uji: EMBEDDED
# Simulator : RARS (RV32IM)
# =====================================================
.data
pesan:   .string "Sistem Tertanam UNY 2026"
kunci:   .string "EMBEDDED"
buf_enc: .space 64
buf_dec: .space 64

h_asli:  .string "Pesan asli       : "
h_v_enc: .string "Vigenere encode  : "
h_v_dec: .string "Vigenere decode  : "
NL:      .string "\n"

.text
main:
    la   a0, h_asli
    la   a1, pesan
    jal  ra, cetak_str

    # --- Enkripsi Vigenere
    la   a0, pesan
    la   a1, buf_enc
    la   a2, kunci
    jal  ra, vigenere_enc

    la   a0, h_v_enc
    la   a1, buf_enc
    jal  ra, cetak_str

    # --- Dekripsi Vigenere
    la   a0, buf_enc
    la   a1, buf_dec
    la   a2, kunci
    jal  ra, vigenere_dec

    la   a0, h_v_dec
    la   a1, buf_dec
    jal  ra, cetak_str

    li   a7, 10
    ecall

# vigenere_enc(a0 = sumber, a1 = tujuan, a2 = kunci)
vigenere_enc:
    li   t5, 26
    mv   t4, a2                      # t4 = pointer huruf kunci
ve_loop:
    lbu  t0, 0(a0)                   # ambil karakter plaintext
    beqz t0, ve_end

    li   t1, 'A'
    li   t2, 'Z'
    blt  t0, t1, ve_cek_kecil
    bgt  t0, t2, ve_cek_kecil
    j    ve_ambil_kunci              # huruf besar, basis t1 = 'A'

ve_cek_kecil:
    li   t1, 'a'
    li   t2, 'z'
    blt  t0, t1, ve_simpan           # non-huruf: salin apa adanya tanpa geser kunci
    bgt  t0, t2, ve_simpan

ve_ambil_kunci:
    lbu  t3, 0(t4)
    bnez t3, ve_hitung_shift
    mv   t4, a2                      # kunci habis -> ulang dari awal
    lbu  t3, 0(t4)
ve_hitung_shift:
    li   t6, 'a'
    blt  t3, t6, ve_kunci_besar
    sub  t3, t3, t6                  # kunci huruf kecil -> 0..25
    j    ve_geser
ve_kunci_besar:
    addi t3, t3, -65                 # kunci huruf besar ('A'=65) -> 0..25
ve_geser:
    sub  t0, t0, t1                  # p - basis
    add  t0, t0, t3                  # + shift kunci
    remu t0, t0, t5                  # mod 26
    add  t0, t0, t1                  # kembali ke ASCII
    addi t4, t4, 1                   # maju ke huruf kunci berikutnya

ve_simpan:
    sb   t0, 0(a1)
    addi a0, a0, 1
    addi a1, a1, 1
    j    ve_loop
ve_end:
    sb   zero, 0(a1)
    ret

# vigenere_dec(a0 = cipher, a1 = tujuan, a2 = kunci)
vigenere_dec:
    li   t5, 26
    mv   t4, a2
vd_loop:
    lbu  t0, 0(a0)
    beqz t0, vd_end

    li   t1, 'A'
    li   t2, 'Z'
    blt  t0, t1, vd_cek_kecil
    bgt  t0, t2, vd_cek_kecil
    j    vd_ambil_kunci

vd_cek_kecil:
    li   t1, 'a'
    li   t2, 'z'
    blt  t0, t1, vd_simpan
    bgt  t0, t2, vd_simpan

vd_ambil_kunci:
    lbu  t3, 0(t4)
    bnez t3, vd_hitung_shift
    mv   t4, a2
    lbu  t3, 0(t4)
vd_hitung_shift:
    li   t6, 'a'
    blt  t3, t6, vd_kunci_besar
    sub  t3, t3, t6
    j    vd_geser
vd_kunci_besar:
    addi t3, t3, -65
vd_geser:
    sub  t0, t0, t1                  # c - basis
    addi t0, t0, 26                  # + 26 agar tidak negatif
    sub  t0, t0, t3                  # - shift kunci
    remu t0, t0, t5                  # mod 26
    add  t0, t0, t1
    addi t4, t4, 1

vd_simpan:
    sb   t0, 0(a1)
    addi a0, a0, 1
    addi a1, a1, 1
    j    vd_loop
vd_end:
    sb   zero, 0(a1)
    ret

cetak_str:
    li   a7, 4
    ecall
    mv   a0, a1
    ecall
    la   a0, NL
    ecall
    ret