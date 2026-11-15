-- ElectroMart - Sistem Informasi Penjualan dan Persediaan | Function Trigger

-- ============================================================
-- Nama        : Muhamad Arip Purnama
-- NIM         : 2507075
-- Kelas       : Sistem Informasi B
-- Mata Kuliah : Praktikum Rekayasa dan Perancangan Database
-- Script      : 05 Function Trigger

USE electromart;

-- awal pembersihan (agar script dapat dijalankan ulang)
DROP TRIGGER  IF EXISTS update_total_penjualan;
DROP TRIGGER  IF EXISTS update_stok_penjualan;
DROP TRIGGER  IF EXISTS validasi_penjualan;
DROP FUNCTION IF EXISTS hitung_diskon;
DROP FUNCTION IF EXISTS hitung_total;
-- akhir pembersihan


-- awal pembuatan stored function
DELIMITER $$

-- ------------------------------------------------------------
-- hitung_total() : Total = Harga Satuan x Jumlah
CREATE FUNCTION hitung_total(p_harga_satuan DECIMAL(12,2), p_jumlah INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN p_harga_satuan * p_jumlah;
END$$

-- ------------------------------------------------------------
-- hitung_diskon() : diskon 10% jika total transaksi >= Rp1.000.000
CREATE FUNCTION hitung_diskon(p_total DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    IF p_total >= 1000000 THEN
        RETURN ROUND(p_total * 0.10, 2);
    END IF;
    RETURN 0;
END$$

DELIMITER ;
-- akhir pembuatan stored function


-- awal pembuatan trigger
DELIMITER $$

-- ------------------------------------------------------------
-- TRIGGER 1 : validasi_penjualan

CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_ada   INT           DEFAULT 0;
    DECLARE v_harga DECIMAL(12,2) DEFAULT 0;
    DECLARE v_stok  INT           DEFAULT 0;

    -- 1) jumlah pembelian harus lebih dari 0
    IF NEW.jumlah IS NULL OR NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validasi gagal: jumlah pembelian harus lebih dari 0';
    END IF;

    -- 2) produk harus terdaftar
    SELECT COUNT(*) INTO v_ada FROM produk WHERE id_produk = NEW.id_produk;
    IF v_ada = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validasi gagal: produk tidak terdaftar';
    END IF;

    SELECT harga, stok INTO v_harga, v_stok
    FROM produk WHERE id_produk = NEW.id_produk;

    -- 3) harga satuan harus valid dan sesuai harga produk
    IF NEW.harga_satuan IS NULL OR NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validasi gagal: harga satuan harus lebih dari 0';
    END IF;

    IF NEW.harga_satuan <> v_harga THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validasi gagal: harga satuan tidak sesuai dengan harga produk';
    END IF;

    -- 4) stok harus mencukupi
    IF NEW.jumlah > v_stok THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validasi gagal: stok tidak mencukupi';
    END IF;

    -- 5) subtotal selalu dihitung ulang memakai function hitung_total()
    SET NEW.subtotal = hitung_total(NEW.harga_satuan, NEW.jumlah);
END$$

-- ------------------------------------------------------------
-- TRIGGER 2 : update_stok_penjualan

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    UPDATE produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan, tanggal)
    VALUES (NEW.id_produk, -NEW.jumlah, 'KELUAR',
            CONCAT('Pengurangan stok dari ', NEW.id_penjualan), NOW());
END$$

-- ------------------------------------------------------------
-- TRIGGER 3 : update_total_penjualan

CREATE TRIGGER update_total_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
FOLLOWS update_stok_penjualan
BEGIN
    DECLARE v_total  DECIMAL(12,2) DEFAULT 0;
    DECLARE v_diskon DECIMAL(12,2) DEFAULT 0;

    SELECT COALESCE(SUM(subtotal), 0) INTO v_total
    FROM detail_penjualan
    WHERE id_penjualan = NEW.id_penjualan;

    SET v_diskon = hitung_diskon(v_total);

    UPDATE penjualan
    SET total_harga = v_total,
        diskon      = v_diskon,
        total_bayar = v_total - v_diskon
    WHERE id_penjualan = NEW.id_penjualan;
END$$

DELIMITER ;
-- akhir pembuatan trigger


-- menampilkan function dan trigger
SHOW FUNCTION STATUS WHERE Db = 'electromart';
SHOW TRIGGERS FROM electromart;


-- ============================================================
-- PENGUJIAN FUNCTION (berdiri sendiri)
-- ============================================================

-- pengujian hitung_total() dan hitung_diskon()
SELECT hitung_total(250000, 2)       AS total_2_mouse,         
       hitung_diskon(500000)         AS diskon_di_bawah_batas,  
       hitung_diskon(999999)         AS diskon_999999,          
       hitung_diskon(1000000)        AS diskon_tepat_batas,     
       hitung_diskon(15000000)       AS diskon_15jt;          

-- pengujian function pada seluruh produk (simulasi beli 2 unit tiap produk)
SELECT id_produk, nama_produk, harga,
       hitung_total(harga, 2)                                        AS total,
       hitung_diskon(hitung_total(harga, 2))                         AS diskon,
       hitung_total(harga, 2) - hitung_diskon(hitung_total(harga, 2)) AS total_bayar
FROM produk
ORDER BY id_produk;


-- ============================================================
-- PENGUJIAN SISTEM (function + trigger)


-- menampilkan kondisi stok SEBELUM pengujian
SELECT id_produk, nama_produk, harga, stok AS stok_sebelum
FROM produk
WHERE id_produk IN ('PRD002', 'PRD004', 'PRD008')
ORDER BY id_produk;

-- ------------------------------------------------------------
-- UJI 1 : pembelian dengan jumlah tersedia + TIDAK memenuhi syarat diskon
-- Flashdisk (PRD008) x 11 = 935.000 (< 1.000.000) -> diskon 0, bayar 935.000
-- ------------------------------------------------------------
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX008', NOW(), 'PLG001', 'PGW002');

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX008', 'PRD008', 11, 85000.00, 935000.00);

-- ------------------------------------------------------------
-- UJI 2 : transaksi yang MEMENUHI syarat diskon (2 item)
-- Monitor (PRD004) x 1 = 3.200.000 ; Mouse (PRD002) x 2 = 500.000
-- Total 3.700.000 -> diskon 370.000 -> bayar 3.330.000
-- ------------------------------------------------------------
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX009', NOW(), 'PLG002', 'PGW002');

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal) VALUES
('TRX009', 'PRD004', 1, 3200000.00, 3200000.00),
('TRX009', 'PRD002', 2,  250000.00,  500000.00);

-- ------------------------------------------------------------
-- UJI 3 : batas tepat Rp1.000.000 (>= berlaku)
-- Mouse (PRD002) x 4 = 1.000.000 -> diskon 100.000 -> bayar 900.000
-- ------------------------------------------------------------
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX010', NOW(), 'PLG005', 'PGW002');

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX010', 'PRD002', 4, 250000.00, 1000000.00);

-- menampilkan bukti: total & diskon terhitung otomatis oleh function
SELECT id_penjualan, total_harga, diskon, total_bayar
FROM penjualan
WHERE id_penjualan IN ('TRX008', 'TRX009', 'TRX010')
ORDER BY id_penjualan;

SELECT * FROM detail_penjualan
WHERE id_penjualan IN ('TRX008', 'TRX009', 'TRX010')
ORDER BY id_detail;

-- menampilkan bukti: stok berkurang otomatis (bandingkan dengan stok_sebelum)
--   PRD008 turun 11 | PRD004 turun 1 | PRD002 turun 2 + 4 = 6
SELECT id_produk, nama_produk, stok AS stok_sesudah
FROM produk
WHERE id_produk IN ('PRD002', 'PRD004', 'PRD008')
ORDER BY id_produk;

-- menampilkan bukti: perubahan stok tercatat otomatis di log_stok
SELECT * FROM log_stok
WHERE keterangan IN ('Pengurangan stok dari TRX008',
                     'Pengurangan stok dari TRX009',
                     'Pengurangan stok dari TRX010')
ORDER BY id_log;


-- ============================================================
-- PENGUJIAN TRANSAKSI TIDAK VALID (SENGAJA DITOLAK TRIGGER)
-- Jalankan satu per satu dan ambil screenshot pesan errornya.
-- ============================================================

-- header uji (akan dihapus kembali setelah pengujian)
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX011', NOW(), 'PLG004', 'PGW002');

-- UJI 4 : jumlah melebihi stok (stok Smart TV = 2, dibeli 5)
--   -> ERROR 1644: Validasi gagal: stok tidak mencukupi
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX011', 'PRD006', 5, 8500000.00, 42500000.00);

-- UJI 5a : jumlah pembelian nol
--   -> ERROR 1644: Validasi gagal: jumlah pembelian harus lebih dari 0
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX011', 'PRD001', 0, 14500000.00, 0);

-- UJI 5b : jumlah pembelian negatif
--   -> ERROR 1644: Validasi gagal: jumlah pembelian harus lebih dari 0
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX011', 'PRD001', -3, 14500000.00, -43500000.00);

-- UJI 6 : produk tidak terdaftar
--   -> ERROR 1644: Validasi gagal: produk tidak terdaftar
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX011', 'PRD999', 1, 1000000.00, 1000000.00);

-- UJI 7 : harga satuan tidak sesuai harga produk
--   -> ERROR 1644: Validasi gagal: harga satuan tidak sesuai dengan harga produk
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX011', 'PRD001', 1, 1000.00, 1000.00);

-- bukti: seluruh transaksi tidak valid di atas TIDAK tersimpan
-- (detail kosong, stok PRD006 & PRD001 tidak berubah, log_stok tidak bertambah)
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX011';
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD001', 'PRD006');
SELECT COUNT(*) AS jumlah_log_stok FROM log_stok;

-- membersihkan header uji
DELETE FROM penjualan WHERE id_penjualan = 'TRX011';


-- ============================================================
-- HASIL AKHIR
-- ============================================================

-- menampilkan seluruh penjualan
SELECT * FROM penjualan ORDER BY id_penjualan;

-- menampilkan stok akhir seluruh produk
SELECT id_produk, nama_produk, stok FROM produk ORDER BY id_produk;

-- pemeriksaan integritas: header = jumlah subtotal rincian (semua harus 'SESUAI')
SELECT p.id_penjualan,
       p.total_harga               AS total_header,
       COALESCE(SUM(d.subtotal),0) AS total_rincian,
       IF(p.total_harga = COALESCE(SUM(d.subtotal),0), 'SESUAI', 'TIDAK SESUAI') AS status
FROM penjualan p
LEFT JOIN detail_penjualan d ON d.id_penjualan = p.id_penjualan
GROUP BY p.id_penjualan, p.total_harga
ORDER BY p.id_penjualan;

-- pemeriksaan integritas: stok tidak boleh negatif (hasil harus kosong)
SELECT id_produk, nama_produk, stok FROM produk WHERE stok < 0;

