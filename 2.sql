-- Data prasyarat (tidak dihitung dari 9 baris)
INSERT INTO Area_Parkir (ID_Area, Nama_Area, Lokasi) VALUES
(1, 'Parkir Gedung A', 'Depan Gedung Rektorat');

INSERT INTO Pengguna (ID_Pengguna, Nama_Pengguna) VALUES
(1, 'Vicky Aditya Surya Samudra'),
(2, 'Budi Santoso'),
(3, 'Siti Rahma');

-- Tabel Induk 1: Kendaraan (3 baris)
INSERT INTO Kendaraan (ID_Kendaraan, ID_Pengguna, Nomor_Plat, Jenis_Kendaraan, UID_RFID) VALUES
(1, 1, 'AE 1234 AB', 'Motor', 'RFID-0001'),
(2, 2, 'AE 5678 CD', 'Mobil', 'RFID-0002'),
(3, 3, 'AE 9012 EF', 'Motor', 'RFID-0003');

-- Tabel Induk 2: Slot_Parkir (3 baris)
INSERT INTO Slot_Parkir (ID_Slot, ID_Area, Nomor_Slot, Posisi) VALUES
(1, 1, 'A-01', 'Barat'),
(2, 1, 'A-02', 'Barat'),
(3, 1, 'A-03', 'Timur');

-- Tabel Transaksi: Parkir (3 baris)
INSERT INTO Parkir (No_Log, ID_Kendaraan, ID_Slot, Waktu_Masuk, Waktu_Keluar) VALUES
(1, 1, 1, '2026-10-12 07:00:00', '2026-10-12 09:30:00'),
(2, 2, 2, '2026-10-12 07:05:00', '2026-10-12 08:00:00'),
(3, 3, 3, '2026-10-12 08:15:00', NULL);

-- Menampilkan tabel induk/READ
SELECT * FROM Kendaraan;

-- Ubah data / UPDATE
UPDATE Parkir
SET Waktu_Keluar = '2026-10-12 10:15:00'
WHERE No_Log = 3;

-- Cek hasil update data/UPDATE
SELECT * FROM Parkir;

-- Hapus data / DELETE
DELETE FROM Parkir
WHERE No_Log = 2;

-- cek hasil Hapus data / DELETE
SELECT * FROM Parkir;
