-- PRASYARAT
CREATE TABLE Area_Parkir (
ID_Area    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
Nama_Area  VARCHAR(50)   NOT NULL,
Lokasi     VARCHAR(100)  NOT NULL,
CONSTRAINT pk_area_parkir PRIMARY KEY (ID_Area)
)ENGINE=InnoDB;

CREATE TABLE Pengguna (
ID_Pengguna    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
Nama_Pengguna  VARCHAR(100)  NOT NULL,
CONSTRAINT pk_pengguna PRIMARY KEY (ID_Pengguna)
)ENGINE=InnoDB;

-- ===== 3 TABEL JAWABAN =====
-- Tabel Induk 1
CREATE TABLE Kendaraan (
ID_Kendaraan    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
ID_Pengguna     INT UNSIGNED  NOT NULL,
Nomor_Plat      VARCHAR(12)   NOT NULL,
Jenis_Kendaraan ENUM('Motor','Mobil') NOT NULL,
UID_RFID        VARCHAR(20)   NOT NULL,
CONSTRAINT pk_kendaraan PRIMARY KEY (ID_Kendaraan),
CONSTRAINT uq_kendaraan_rfid UNIQUE (UID_RFID),
CONSTRAINT fk_kendaraan_pengguna FOREIGN KEY (ID_Pengguna)
REFERENCES Pengguna (ID_Pengguna)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Induk 2
CREATE TABLE Slot_Parkir (
ID_Slot     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
ID_Area     INT UNSIGNED  NOT NULL,
Nomor_Slot  VARCHAR(10)   NOT NULL,
Posisi      VARCHAR(50)   NULL,
CONSTRAINT pk_slot_parkir PRIMARY KEY (ID_Slot),
CONSTRAINT uq_slot_area_nomor UNIQUE (ID_Area, Nomor_Slot),
CONSTRAINT fk_slot_area FOREIGN KEY (ID_Area)
    REFERENCES Area_Parkir (ID_Area)
    ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=InnoDB;

-- Tabel Transaksi (Anak)
CREATE TABLE Parkir (
No_Log         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
ID_Kendaraan   INT UNSIGNED    NOT NULL,
ID_Slot        INT UNSIGNED    NOT NULL,
Waktu_Masuk    DATETIME        NOT NULL,
Waktu_Keluar   DATETIME        NULL,
Durasi_Jam     DECIMAL(6,2) GENERATED ALWAYS AS
                (TIMESTAMPDIFF(MINUTE, Waktu_Masuk, Waktu_Keluar) / 60) STORED,
    Status_Parkir  VARCHAR(10) GENERATED ALWAYS AS
                (IF(Waktu_Keluar IS NULL, 'Aktif', 'Selesai')) STORED,
CONSTRAINT pk_parkir PRIMARY KEY (No_Log),
CONSTRAINT ck_parkir_waktu CHECK (Waktu_Keluar IS NULL OR Waktu_Keluar >= Waktu_Masuk),
CONSTRAINT fk_parkir_kendaraan FOREIGN KEY (ID_Kendaraan)
    REFERENCES Kendaraan (ID_Kendaraan)
    ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT fk_parkir_slot FOREIGN KEY (ID_Slot)
    REFERENCES Slot_Parkir (ID_Slot)
    ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=InnoDB;
