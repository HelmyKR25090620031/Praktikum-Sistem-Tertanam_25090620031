# =====================================================
# Percobaan 1 - Format Instruksi, Opcode, dan Register
# Simulator: Ripes (prosesor RV32IM 5-stage)
# =====================================================
.text
main:
    addi x5, x0, 10         # (1) I-type: x5 = 0 + 10
    addi x6, x0, 3          # (2) I-type: x6 = 0 + 3
    add  x7, x5, x6         # (3) R-type: x7 = x5 + x6
    sub  x8, x5, x6         # (4) R-type: x8 = x5 - x6
    lui  x9, 0x10000        # (5) U-type: x9 = 0x10000000 (alamat RAM data)
    sw   x7, 0(x9)          # (6) S-type: simpan x7 ke memori [x9+0]
    lw   x10, 0(x9)         # (7) I-type: x10 = memori [x9+0]
    beq  x7, x10, sama      # (8) B-type: jika x7 == x10 lompat ke 'sama'
    addi x11, x0, -1        # (9) dilewati jika cabang diambil
sama:
    jal  x1, akhir          # (10) J-type: lompat ke 'akhir', x1 = alamat kembali
    addi x12, x0, 99        # (11) tidak pernah dieksekusi
akhir:
    addi x12, x0, 1         # (12) x12 = 1 tanda program selesai
    addi x17, x0, 10        # (13) a7 = 10 -> layanan "exit"
    ecall                   # (14) panggil layanan sistem