-- ElectroMart - Sistem Informasi Penjualan dan Persediaan | indexing

-- Nama        : Muhamad Arip Purnama
-- NIM         : 2507075
-- Kelas       : Sistem Informasi B
-- Mata Kuliah : Praktikum Rekayasa dan Perancangan Database
-- Script      : 01 Indexing
-- ============================================================



-- MEMBUAT DATABASE

DROP DATABASE IF EXISTS electromart;
CREATE DATABASE electromart
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
USE electromart;


-- awal pembuatan tabel

-- 1. tabel pegawai
CREATE TABLE pegawai (
    id_pegawai   VARCHAR(10)  NOT NULL,
    nama_pegawai VARCHAR(100) NOT NULL,
    peran        VARCHAR(30)  NOT NULL,
    email        VARCHAR(100) NOT NULL,
    no_hp        VARCHAR(20)  NULL,
    PRIMARY KEY (id_pegawai),
    UNIQUE KEY uq_pegawai_email (email)
) ENGINE = InnoDB;

-- 2. tabel pelanggan
CREATE TABLE pelanggan (
    id_pelanggan   VARCHAR(10)  NOT NULL,
    nama_pelanggan VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    no_hp          VARCHAR(20)  NULL,
    alamat         TEXT         NULL,
    PRIMARY KEY (id_pelanggan),
    UNIQUE KEY uq_pelanggan_email (email)
) ENGINE = InnoDB;

-- 3. Tabel produk
CREATE TABLE produk (
    id_produk   VARCHAR(10)   NOT NULL,
    nama_produk VARCHAR(100)  NOT NULL,
    kategori    VARCHAR(50)   NOT NULL,
    harga       DECIMAL(12,2) NOT NULL,
    stok        INT           NOT NULL DEFAULT 0,
    PRIMARY KEY (id_produk)
) ENGINE = InnoDB;

-- 4. Tabel penjualan 
CREATE TABLE penjualan (
    id_penjualan VARCHAR(10)   NOT NULL,
    tanggal      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_pelanggan VARCHAR(10)   NULL,
    id_pegawai   VARCHAR(10)   NULL,
    total_harga  DECIMAL(12,2) NOT NULL DEFAULT 0,
    diskon       DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_bayar  DECIMAL(12,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_penjualan),
    CONSTRAINT fk_penjualan_pelanggan
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id_pelanggan),
    CONSTRAINT fk_penjualan_pegawai
        FOREIGN KEY (id_pegawai) REFERENCES pegawai (id_pegawai)
) ENGINE = InnoDB;

-- 5. Tabel detail penjualan 
CREATE TABLE detail_penjualan (
    id_detail    INT           NOT NULL AUTO_INCREMENT,
    id_penjualan VARCHAR(10)   NULL,
    id_produk    VARCHAR(10)   NULL,
    jumlah       INT           NOT NULL,
    harga_satuan DECIMAL(12,2) NOT NULL,
    subtotal     DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_detail),
    CONSTRAINT fk_detail_penjualan
        FOREIGN KEY (id_penjualan) REFERENCES penjualan (id_penjualan),
    CONSTRAINT fk_detail_produk
        FOREIGN KEY (id_produk) REFERENCES produk (id_produk)
) ENGINE = InnoDB;

-- 6. Tabel log stok 
CREATE TABLE log_stok (
    id_log           INT          NOT NULL AUTO_INCREMENT,
    id_produk        VARCHAR(10)  NULL,
    jumlah_perubahan INT          NOT NULL,
    tipe_transaksi   VARCHAR(20)  NOT NULL,
    keterangan       VARCHAR(255) NULL,
    tanggal          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_log),
    CONSTRAINT fk_log_produk
        FOREIGN KEY (id_produk) REFERENCES produk (id_produk)
) ENGINE = InnoDB;

-- akhir pembuatan tabel


-- awal pengisian dataset

-- dataset tabel pegawai
INSERT INTO pegawai (id_pegawai, nama_pegawai, peran, email, no_hp) VALUES
('PGW001', 'Andi Wijaya',     'role_admin',     'andi.admin@electromart.com',      '081234567890'),
('PGW002', 'Maya Putri',      'role_penjualan', 'maya.sales@electromart.com',      '081234567891'),
('PGW003', 'Eko Prasetyo',    'role_gudang',    'eko.gudang@electromart.com',      '081234567892'),
('PGW004', 'Hendra Gunawan',  'role_manajer',   'hendra.manager@electromart.com',  '081234567893');

-- dataset tabel pelanggan
INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, email, no_hp, alamat) VALUES
('PLG001', 'Budi Santoso', 'budi.santoso@email.com', '085611223344', 'Jl. Merdeka No. 12, Jakarta'),
('PLG002', 'Siti Aminah',  'siti.aminah@email.com',  '085622334455', 'Jl. Mawar No. 5, Bandung'),
('PLG003', 'Rian Hidayat', 'rian.hidayat@email.com', '085633445566', 'Jl. Pemuda No. 88, Surabaya'),
('PLG004', 'Dewi Lestari', 'dewi.lestari@email.com', '085644556677', 'Jl. Diponegoro No. 45, Semarang'),
('PLG005', 'Ahmad Fauzi',  'ahmad.fauzi@email.com',  '085655667788', 'Jl. Gajah Mada No. 20, Yogyakarta');

-- Dataset tabel produk
INSERT INTO produk (id_produk, nama_produk, kategori, harga, stok) VALUES
('PRD001', 'Laptop Asus ZenBook 14',        'Laptop',     14500000.00,  15),
('PRD002', 'Mouse Wireless Logitech M330',  'Aksesoris',    250000.00,  50),
('PRD003', 'Keyboard Mekanikal Keychron K2','Aksesoris',   1200000.00,   3),
('PRD004', 'Monitor LG 27 Inch IPS',        'Monitor',     3200000.00,   8),
('PRD005', 'Smartphone Samsung Galaxy S23', 'Smartphone', 12999000.00,  10),
('PRD006', 'Smart TV Sony 55 Inch 4K',      'TV',          8500000.00,   2),
('PRD007', 'Headphone Sony WH-1000XM5',     'Audio',       4499000.00,  12),
('PRD008', 'Flashdisk SanDisk 64GB',        'Aksesoris',     85000.00, 100),
('PRD009', 'Printer Epson EcoTank L3210',   'Periferal',   2400000.00,   4),
('PRD010', 'Webcam Logitech C920',          'Aksesoris',    950000.00,  25);

-- Dataset tabel penjualan
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar) VALUES
('TRX001', '2026-11-01 10:15:00', 'PLG001', 'PGW002', 15000000.00, 1500000.00, 13500000.00),
('TRX002', '2026-11-03 14:30:00', 'PLG002', 'PGW002',   850000.00,       0.00,   850000.00),
('TRX003', '2026-11-05 11:00:00', 'PLG003', 'PGW002',  4400000.00,  440000.00,  3960000.00),
('TRX004', '2026-11-08 16:45:00', 'PLG004', 'PGW002', 12999000.00, 1299900.00, 11699100.00);

-- Dataset tabel detail_penjualan
INSERT INTO detail_penjualan (id_detail, id_penjualan, id_produk, jumlah, harga_satuan, subtotal) VALUES
(1, 'TRX001', 'PRD001',  1, 14500000.00, 14500000.00),
(2, 'TRX001', 'PRD002',  2,   250000.00,   500000.00),
(3, 'TRX002', 'PRD008', 10,    85000.00,   850000.00),
(4, 'TRX003', 'PRD003',  1,  1200000.00,  1200000.00),
(5, 'TRX003', 'PRD004',  1,  3200000.00,  3200000.00),
(6, 'TRX004', 'PRD005',  1, 12999000.00, 12999000.00);

-- Dataset tabel log_stok
INSERT INTO log_stok (id_log, id_produk, jumlah_perubahan, tipe_transaksi, keterangan, tanggal) VALUES
( 1, 'PRD001',  16, 'MASUK',  'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
( 2, 'PRD001',  -1, 'KELUAR', 'Pengurangan stok dari TRX001',            '2026-11-01 10:15:00'),
( 3, 'PRD002',  52, 'MASUK',  'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
( 4, 'PRD002',  -2, 'KELUAR', 'Pengurangan stok dari TRX001',            '2026-11-01 10:15:00'),
( 5, 'PRD008', 110, 'MASUK',  'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
( 6, 'PRD008', -10, 'KELUAR', 'Pengurangan stok dari TRX002',            '2026-11-03 14:30:00'),
( 7, 'PRD003',   4, 'MASUK',  'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
( 8, 'PRD003',  -1, 'KELUAR', 'Pengurangan stok dari TRX003',            '2026-11-05 11:00:00'),
( 9, 'PRD004',   9, 'MASUK',  'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
(10, 'PRD004',  -1, 'KELUAR', 'Pengurangan stok dari TRX003',            '2026-11-05 11:00:00'),
(11, 'PRD005',  11, 'MASUK',  'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
(12, 'PRD005',  -1, 'KELUAR', 'Pengurangan stok dari TRX004',            '2026-11-08 16:45:00');

-- akhir pengisian dataset


-- menampilkan tabel
SHOW TABLES;
SELECT * FROM pegawai;
SELECT * FROM pelanggan;
SELECT * FROM produk;
SELECT * FROM penjualan;
SELECT * FROM detail_penjualan;
SELECT * FROM log_stok;


-- awal pembuatan index

-- A. SINGLE-COLUMN INDEX

-- pencarian produk berdasarkan kategori
CREATE INDEX idx_produk_kategori ON produk (kategori);

-- pencarian produk berdasarkan nama produk.
CREATE INDEX idx_produk_nama ON produk (nama_produk);

-- pencarian transaksi berdasarkan tanggal / rentang tanggal
CREATE INDEX idx_penjualan_tanggal ON penjualan (tanggal);

-- pencarian pelanggan berdasarkan nama.
CREATE INDEX idx_pelanggan_nama ON pelanggan (nama_pelanggan);


-- B. COMPOSITE INDEX

-- pencarian transaksi berdasarkan pelanggan DAN tanggal
CREATE INDEX idx_penjualan_pelanggan_tanggal ON penjualan (id_pelanggan, tanggal);
-- riwayat perubahan stok suatu produk pada rentang waktu tertentu.
CREATE INDEX idx_log_produk_tanggal ON log_stok (id_produk, tanggal);

-- akhir pembuatan index


-- menampilkan index
SHOW INDEX FROM produk;
SHOW INDEX FROM pelanggan;
SHOW INDEX FROM penjualan;
SHOW INDEX FROM detail_penjualan;
SHOW INDEX FROM log_stok;

-- menampilkan index (ringkasan seluruh index di database electromart)
SELECT
    table_name  AS nama_tabel,
    index_name  AS nama_index,
    GROUP_CONCAT(column_name ORDER BY seq_in_index SEPARATOR ', ') AS kolom_index,
    IF(non_unique = 0, 'UNIQUE', 'NON-UNIQUE') AS jenis,
    index_type  AS tipe
FROM information_schema.statistics
WHERE table_schema = 'electromart'
GROUP BY table_name, index_name, non_unique, index_type
ORDER BY table_name, index_name;


-- pengujian 1: pencarian produk berdasarkan kategori
SELECT * FROM produk WHERE kategori = 'Aksesoris';
EXPLAIN SELECT * FROM produk FORCE INDEX (idx_produk_kategori)
WHERE kategori = 'Aksesoris';

-- pengujian 2: pencarian transaksi berdasarkan rentang tanggal
SELECT * FROM penjualan
WHERE tanggal BETWEEN '2026-11-01 00:00:00' AND '2026-11-05 23:59:59';
EXPLAIN SELECT * FROM penjualan FORCE INDEX (idx_penjualan_tanggal)
WHERE tanggal BETWEEN '2026-11-01 00:00:00' AND '2026-11-05 23:59:59';

-- pengujian 3: pencarian transaksi berdasarkan pelanggan dan tanggal (composite)
SELECT * FROM penjualan
WHERE id_pelanggan = 'PLG001'
  AND tanggal BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';
EXPLAIN SELECT * FROM penjualan FORCE INDEX (idx_penjualan_pelanggan_tanggal)
WHERE id_pelanggan = 'PLG001'
  AND tanggal BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';
