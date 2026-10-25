-- ---------------------------------------------------------------------
-- A. ALASAN BISNIS
-- ---------------------------------------------------------------------
-- Saat jam sibuk atau acara kampus, slot cepat penuh. Pengguna perlu
-- memesan slot untuk rentang waktu tertentu. Agar tidak terjadi dua
-- pemesanan pada slot dan waktu yang sama, aturan dijaga langsung oleh
-- database: waktu selesai > waktu mulai, durasi maksimal 4 jam, dan
-- tidak boleh ada rentang waktu yang tumpang tindih pada slot yang sama.

-- ---------------------------------------------------------------------
-- B. ANALISIS NORMALISASI
-- ---------------------------------------------------------------------
-- Tabel awal (belum dinormalisasi):
--   reservasi(id_reservasi, id_kendaraan, nomor_plat, id_slot,
--             nomor_slot, nama_area, waktu_mulai, waktu_selesai, status)
--
-- 1NF : Semua atribut atomik, baris dikenali oleh id_reservasi. TERPENUHI.
--
-- 2NF : Primary key tunggal (id_reservasi), tidak ada ketergantungan
--       parsial. TERPENUHI.
--
-- 3NF : TIDAK terpenuhi. Ada ketergantungan transitif:
--         id_reservasi -> id_kendaraan -> nomor_plat
--         id_reservasi -> id_slot      -> nomor_slot, nama_area
--       Plat, nomor slot, dan nama area ditentukan oleh kendaraan/slot,
--       bukan oleh reservasinya, sehingga tertulis berulang di setiap
--       reservasi (rawan anomali update).
--
-- Solusi: reservasi hanya menyimpan FK ke tabel yang sudah ada.
--   reservasi_slot(id_reservasi, id_kendaraan*, id_slot*, waktu_mulai,
--                  waktu_selesai, status_reservasi)
--   durasi_jam dibuat generated column (atribut turunan, tidak redundan).
--
-- Hasil: 3NF TERPENUHI.
-- Relasi: KENDARAAN (1) ---- (N) RESERVASI_SLOT (N) ---- (1) SLOT_PARKIR

-- ---------------------------------------------------------------------
-- C. DDL
-- ---------------------------------------------------------------------

CREATE TABLE Reservasi_Slot (
    ID_Reservasi     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ID_Kendaraan     INT UNSIGNED    NOT NULL,
    ID_Slot          INT UNSIGNED    NOT NULL,
    Waktu_Mulai      DATETIME        NOT NULL,
    Waktu_Selesai    DATETIME        NOT NULL,
    Status_Reservasi ENUM('Dipesan','Digunakan','Selesai','Dibatalkan')
                     NOT NULL DEFAULT 'Dipesan',
    Durasi_Jam       DECIMAL(5,2) GENERATED ALWAYS AS
                     (TIMESTAMPDIFF(MINUTE, Waktu_Mulai, Waktu_Selesai) / 60) STORED,
    CONSTRAINT pk_reservasi PRIMARY KEY (ID_Reservasi),
    CONSTRAINT ck_reservasi_waktu CHECK (
        Waktu_Selesai > Waktu_Mulai
        AND TIMESTAMPDIFF(MINUTE, Waktu_Mulai, Waktu_Selesai) <= 240),
    CONSTRAINT fk_reservasi_kendaraan FOREIGN KEY (ID_Kendaraan)
        REFERENCES Kendaraan (ID_Kendaraan) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reservasi_slot FOREIGN KEY (ID_Slot)
        REFERENCES Slot_Parkir (ID_Slot) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Trigger: tolak reservasi aktif yang waktunya tumpang tindih di slot sama
DELIMITER $$
CREATE TRIGGER trg_reservasi_bi BEFORE INSERT ON Reservasi_Slot
FOR EACH ROW
BEGIN
    IF NEW.Status_Reservasi IN ('Dipesan','Digunakan')
       AND EXISTS (SELECT 1 FROM Reservasi_Slot r
                    WHERE r.ID_Slot = NEW.ID_Slot
                      AND r.Status_Reservasi IN ('Dipesan','Digunakan')
                      AND NEW.Waktu_Mulai   < r.Waktu_Selesai
                      AND NEW.Waktu_Selesai > r.Waktu_Mulai) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Slot sudah dipesan pada rentang waktu tersebut';
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- D. DATA & BUKTI
-- ---------------------------------------------------------------------

INSERT INTO Reservasi_Slot (ID_Kendaraan, ID_Slot, Waktu_Mulai, Waktu_Selesai) VALUES
(1, 4, '2026-10-26 08:00:00', '2026-10-26 10:00:00'),
(2, 6, '2026-10-26 09:00:00', '2026-10-26 12:00:00'),
(3, 4, '2026-10-26 10:00:00', '2026-10-26 11:30:00'); -- mulai saat #1 selesai: BOLEH

-- Daftar reservasi
SELECT r.ID_Reservasi, p.Nama_Pengguna, k.Nomor_Plat, s.Nomor_Slot,
       r.Waktu_Mulai, r.Waktu_Selesai, r.Durasi_Jam, r.Status_Reservasi
  FROM Reservasi_Slot r
  JOIN Kendaraan   k ON k.ID_Kendaraan = r.ID_Kendaraan
  JOIN Pengguna    p ON p.ID_Pengguna  = k.ID_Pengguna
  JOIN Slot_Parkir s ON s.ID_Slot      = r.ID_Slot
 ORDER BY r.Waktu_Mulai;

-- Bukti constraint: setiap perintah di bawah HARUS GAGAL
INSERT INTO Reservasi_Slot (ID_Kendaraan, ID_Slot, Waktu_Mulai, Waktu_Selesai)
VALUES (3, 4, '2026-10-26 09:00:00', '2026-10-26 09:30:00'); -- bentrok jam
INSERT INTO Reservasi_Slot (ID_Kendaraan, ID_Slot, Waktu_Mulai, Waktu_Selesai)
VALUES (3, 7, '2026-10-27 08:00:00', '2026-10-27 13:00:00'); -- lebih dari 4 jam
INSERT INTO Reservasi_Slot (ID_Kendaraan, ID_Slot, Waktu_Mulai, Waktu_Selesai)
VALUES (3, 7, '2026-10-27 10:00:00', '2026-10-27 09:00:00'); -- waktu terbalik
INSERT INTO Reservasi_Slot (ID_Kendaraan, ID_Slot, Waktu_Mulai, Waktu_Selesai)
VALUES (99, 7, '2026-10-27 08:00:00', '2026-10-27 09:00:00'); -- kendaraan tidak ada
