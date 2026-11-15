-- ElectroMart - Sistem Informasi Penjualan dan Persediaan | Transaksi

-- ============================================================
-- Nama        : Muhamad Arip Purnama
-- NIM         : 2507075
-- Kelas       : Sistem Informasi B
-- Mata Kuliah : Praktikum Rekayasa dan Perancangan Database
-- Script      : 03 Transaksi


USE electromart;


-- menampilkan kondisi awal sebelum transaksi
SELECT id_produk, nama_produk, harga, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002', 'PRD006', 'PRD008', 'PRD009', 'PRD010');

SELECT id_penjualan, tanggal, id_pelanggan, total_harga, diskon, total_bayar
FROM penjualan ORDER BY id_penjualan;


-- ============================================================
-- SKENARIO A : TRANSAKSI PENJUALAN BERHASIL (COMMIT)
-- Pelanggan PLG005 membeli 1 unit Laptop (PRD001) dan 2 unit Mouse (PRD002)
-- Total  = 14.500.000 + (2 x 250.000) = 15.000.000
-- Diskon = 10% x 15.000.000           =  1.500.000
-- Bayar  = 15.000.000 - 1.500.000     = 13.500.000
-- ============================================================

-- awal skenario A
START TRANSACTION;

-- 1) catat header transaksi
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX005', NOW(), 'PLG005', 'PGW002', 15000000.00, 1500000.00, 13500000.00);

-- 2) catat rincian produk yang dibeli
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal) VALUES
('TRX005', 'PRD001', 1, 14500000.00, 14500000.00),
('TRX005', 'PRD002', 2,   250000.00,   500000.00);

-- 3) kurangi stok produk
UPDATE produk SET stok = stok - 1 WHERE id_produk = 'PRD001';
UPDATE produk SET stok = stok - 2 WHERE id_produk = 'PRD002';

-- 4) catat perubahan stok ke log_stok
INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan) VALUES
('PRD001', -1, 'KELUAR', 'Pengurangan stok dari TRX005'),
('PRD002', -2, 'KELUAR', 'Pengurangan stok dari TRX005');

-- simpan permanen seluruh perubahan di atas
COMMIT;
-- akhir skenario A

-- menampilkan bukti skenario A (transaksi berhasil)
SELECT * FROM penjualan WHERE id_penjualan = 'TRX005';
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX005';
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD001', 'PRD002');
SELECT * FROM log_stok WHERE keterangan LIKE '%TRX005%';


-- ============================================================
-- SKENARIO B : TRANSAKSI GAGAL (ROLLBACK)
-- Pelanggan PLG004 membeli 5 unit Smart TV (PRD006), padahal stok hanya 2.
-- Perubahan yang belum di-COMMIT dibatalkan dengan ROLLBACK.
-- ============================================================

-- awal skenario B
-- cek stok tersedia lebih dulu (stok = 2 < jumlah dibeli = 5)
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk = 'PRD006';

START TRANSACTION;

INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX006', NOW(), 'PLG004', 'PGW002', 42500000.00, 4250000.00, 38250000.00);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD006', 5, 8500000.00, 42500000.00);

UPDATE produk SET stok = stok - 5 WHERE id_produk = 'PRD006';

-- bukti ketidaksesuaian: stok menjadi NEGATIF (tidak valid) sebelum dibatalkan
SELECT id_produk, nama_produk, stok AS stok_tidak_valid FROM produk WHERE id_produk = 'PRD006';
SELECT * FROM penjualan WHERE id_penjualan = 'TRX006';

-- stok tidak mencukupi -> batalkan SELURUH perubahan yang belum disimpan
ROLLBACK;
-- akhir skenario B

-- menampilkan bukti skenario B (transaksi dibatalkan)
-- stok PRD006 kembali 2, dan TRX006 tidak ada (hasil kosong)
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk = 'PRD006';
SELECT * FROM penjualan WHERE id_penjualan = 'TRX006';
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX006';
-- Catatan: nilai AUTO_INCREMENT (id_detail) yang sudah terpakai tidak
-- dikembalikan oleh ROLLBACK, sehingga nomor id_detail bisa melompat.
-- Hal ini normal pada InnoDB.


-- ============================================================
-- SKENARIO C : PEMBATALAN SEBAGIAN TRANSAKSI (SAVEPOINT)
-- Pelanggan PLG003 membeli 3 Flashdisk, 2 Webcam, lalu 1 Printer.
-- Pelanggan membatalkan Printer -> hanya item Printer yang dibatalkan
-- (ROLLBACK TO SAVEPOINT), transaksi lain tetap dilanjutkan dan di-COMMIT.
-- ============================================================

-- awal skenario C
START TRANSACTION;

-- header dibuat dengan total 0, dihitung ulang setelah item final diketahui
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX007', NOW(), 'PLG003', 'PGW002', 0, 0, 0);

-- item 1: Flashdisk 3 x 85.000 = 255.000
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD008', 3, 85000.00, 255000.00);
UPDATE produk SET stok = stok - 3 WHERE id_produk = 'PRD008';
INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD008', -3, 'KELUAR', 'Pengurangan stok dari TRX007');
SAVEPOINT sp_item1;

-- item 2: Webcam 2 x 950.000 = 1.900.000
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD010', 2, 950000.00, 1900000.00);
UPDATE produk SET stok = stok - 2 WHERE id_produk = 'PRD010';
INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD010', -2, 'KELUAR', 'Pengurangan stok dari TRX007');
SAVEPOINT sp_item2;

-- item 3: Printer 1 x 2.400.000 (nantinya dibatalkan pelanggan)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD009', 1, 2400000.00, 2400000.00);
UPDATE produk SET stok = stok - 1 WHERE id_produk = 'PRD009';
INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD009', -1, 'KELUAR', 'Pengurangan stok dari TRX007');

-- bukti sebelum pembatalan sebagian: 3 item, stok Printer berkurang jadi 3
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX007';
SELECT id_produk, stok FROM produk WHERE id_produk = 'PRD009';

-- pelanggan batal membeli Printer -> kembali ke kondisi sp_item2
-- (item 1 dan 2 TETAP ada, hanya item 3 yang dibatalkan)
ROLLBACK TO SAVEPOINT sp_item2;

-- bukti setelah ROLLBACK TO SAVEPOINT: tinggal 2 item, stok Printer kembali 4
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX007';
SELECT id_produk, stok FROM produk WHERE id_produk = 'PRD009';

-- hitung ulang header berdasarkan item yang tersisa
-- total = 255.000 + 1.900.000 = 2.155.000 | diskon 10% = 215.500 | bayar = 1.939.500
SET @total  = (SELECT SUM(subtotal) FROM detail_penjualan WHERE id_penjualan = 'TRX007');
SET @diskon = IF(@total >= 1000000, @total * 0.10, 0);
UPDATE penjualan
SET total_harga = @total,
    diskon      = @diskon,
    total_bayar = @total - @diskon
WHERE id_penjualan = 'TRX007';

-- savepoint tidak diperlukan lagi -> dilepas dengan RELEASE SAVEPOINT
-- (dilepas dari yang terbaru: melepas sp_item1 lebih dulu akan ikut
--  menghapus sp_item2, sehingga perintah kedua menjadi error 1305)
RELEASE SAVEPOINT sp_item2;
RELEASE SAVEPOINT sp_item1;
-- (setelah RELEASE, perintah ROLLBACK TO SAVEPOINT sp_item1 akan menghasilkan
--  ERROR 1305: SAVEPOINT sp_item1 does not exist)

-- simpan transaksi (item Printer tidak ikut tersimpan)
COMMIT;
-- akhir skenario C

-- menampilkan bukti skenario C
SELECT * FROM penjualan WHERE id_penjualan = 'TRX007';
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX007';
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD008', 'PRD009', 'PRD010');
SELECT * FROM log_stok WHERE keterangan LIKE '%TRX007%';


-- ============================================================
-- HASIL AKHIR (pembuktian dengan SELECT)
-- ============================================================

-- menampilkan seluruh transaksi penjualan
SELECT * FROM penjualan ORDER BY id_penjualan;

-- menampilkan seluruh detail penjualan
SELECT * FROM detail_penjualan ORDER BY id_detail;

-- menampilkan stok akhir produk
SELECT id_produk, nama_produk, stok FROM produk ORDER BY id_produk;

-- menampilkan log stok
SELECT * FROM log_stok ORDER BY id_log;

-- pemeriksaan konsistensi: header = jumlah subtotal rincian (semua baris harus 'SESUAI')
SELECT p.id_penjualan,
       p.total_harga               AS total_header,
       COALESCE(SUM(d.subtotal),0) AS total_rincian,
       IF(p.total_harga = COALESCE(SUM(d.subtotal),0), 'SESUAI', 'TIDAK SESUAI') AS status
FROM penjualan p
LEFT JOIN detail_penjualan d ON d.id_penjualan = p.id_penjualan
GROUP BY p.id_penjualan, p.total_harga
ORDER BY p.id_penjualan;

