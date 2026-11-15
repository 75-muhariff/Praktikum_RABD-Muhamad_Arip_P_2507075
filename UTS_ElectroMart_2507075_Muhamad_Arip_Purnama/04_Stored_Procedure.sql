-- ElectroMart - Sistem Informasi Penjualan dan Persediaan | Stored Procedure

-- ============================================================
-- Nama        : Muhamad Arip Purnama
-- NIM         : 2507075
-- Kelas       : Sistem Informasi B
-- Mata Kuliah : Praktikum Rekayasa dan Perancangan Database
-- Script      : 04 Stored Procedure

USE electromart;

-- awal pembersihan (agar script dapat dijalankan ulang)
DROP PROCEDURE IF EXISTS SP_Tampil_Produk;
DROP PROCEDURE IF EXISTS SP_Tambah_Produk;
DROP PROCEDURE IF EXISTS SP_Ubah_Harga;
DROP PROCEDURE IF EXISTS SP_Cari_Produk_Kategori;
DROP PROCEDURE IF EXISTS SP_Tambah_Penjualan;
DROP PROCEDURE IF EXISTS SP_Tambah_Detail_Penjualan;
-- akhir pembersihan


-- awal pembuatan stored procedure
DELIMITER $$

-- ------------------------------------------------------------
-- 1. SP_Tampil_Produk : menampilkan seluruh data produk
CREATE PROCEDURE SP_Tampil_Produk()
BEGIN
    SELECT id_produk, nama_produk, kategori, harga, stok
    FROM produk
    ORDER BY id_produk;
END$$

-- ------------------------------------------------------------
-- 2. SP_Tambah_Produk : menambah produk baru memakai parameter
CREATE PROCEDURE SP_Tambah_Produk(
    IN p_id_produk   VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_kategori    VARCHAR(50),
    IN p_harga       DECIMAL(12,2),
    IN p_stok        INT
)
BEGIN
    -- validasi sederhana sebelum data disimpan
    IF p_harga IS NULL OR p_harga <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Gagal: harga produk harus lebih dari 0';
    END IF;

    IF p_stok IS NULL OR p_stok < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Gagal: stok produk tidak boleh negatif';
    END IF;

    INSERT INTO produk (id_produk, nama_produk, kategori, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_kategori, p_harga, p_stok);

    SELECT CONCAT('Produk ', p_id_produk, ' berhasil ditambahkan') AS pesan;
END$$

-- ------------------------------------------------------------
-- 3. SP_Ubah_Harga : mengubah harga berdasarkan ID produk dan harga baru
CREATE PROCEDURE SP_Ubah_Harga(
    IN p_id_produk   VARCHAR(10),
    IN p_harga_baru  DECIMAL(12,2)
)
BEGIN
    IF p_harga_baru IS NULL OR p_harga_baru <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Gagal: harga baru harus lebih dari 0';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM produk WHERE id_produk = p_id_produk) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Gagal: produk tidak ditemukan';
    END IF;

    UPDATE produk
    SET harga = p_harga_baru
    WHERE id_produk = p_id_produk;

    -- tampilkan data hasil perubahan sebagai bukti
    SELECT id_produk, nama_produk, harga AS harga_terbaru
    FROM produk
    WHERE id_produk = p_id_produk;
END$$

-- ------------------------------------------------------------
-- 4. SP_Cari_Produk_Kategori : procedure tambahan
CREATE PROCEDURE SP_Cari_Produk_Kategori(IN p_kategori VARCHAR(50))
BEGIN
    SELECT id_produk, nama_produk, kategori, harga, stok
    FROM produk
    WHERE kategori = p_kategori
    ORDER BY nama_produk;
END$$

-- ------------------------------------------------------------
-- 5. SP_Tambah_Penjualan : membuat header transaksi baru
CREATE PROCEDURE SP_Tambah_Penjualan(
    IN p_id_penjualan VARCHAR(10),
    IN p_id_pelanggan VARCHAR(10),
    IN p_id_pegawai   VARCHAR(10)
)
BEGIN
    INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
    VALUES (p_id_penjualan, NOW(), p_id_pelanggan, p_id_pegawai);
END$$

-- ------------------------------------------------------------
-- 6. SP_Tambah_Detail_Penjualan 
CREATE PROCEDURE SP_Tambah_Detail_Penjualan(
    IN p_id_penjualan VARCHAR(10),
    IN p_id_produk    VARCHAR(10),
    IN p_jumlah       INT
)
BEGIN
    DECLARE v_harga DECIMAL(12,2) DEFAULT 0;

    SELECT harga INTO v_harga FROM produk WHERE id_produk = p_id_produk;

    INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
    VALUES (p_id_penjualan, p_id_produk, p_jumlah, v_harga, v_harga * p_jumlah);
END$$

DELIMITER ;
-- akhir pembuatan stored procedure


-- awal pemberian hak EXECUTE ke role (kelanjutan Tugas 2)
-- Procedure berjalan dengan hak pembuatnya (SQL SECURITY DEFINER), sehingga
-- EXECUTE hanya diberikan kepada role yang memang berwenang.
GRANT EXECUTE ON PROCEDURE electromart.SP_Tampil_Produk
    TO 'role_penjualan', 'role_gudang', 'role_manajer';
GRANT EXECUTE ON PROCEDURE electromart.SP_Tambah_Penjualan
    TO 'role_penjualan';
GRANT EXECUTE ON PROCEDURE electromart.SP_Tambah_Detail_Penjualan
    TO 'role_penjualan';
-- SP_Tambah_Produk dan SP_Ubah_Harga hanya untuk role_admin (sudah ALL PRIVILEGES)
-- akhir pemberian hak EXECUTE


-- menampilkan daftar stored procedure
SHOW PROCEDURE STATUS WHERE Db = 'electromart';


-- ============================================================
-- PENGUJIAN STORED PROCEDURE

-- pengujian SP_Tampil_Produk
CALL SP_Tampil_Produk();

-- pengujian SP_Tambah_Produk (data berbeda: produk 1)
CALL SP_Tambah_Produk('PRD011', 'Speaker Bluetooth JBL Flip 6', 'Audio', 1800000, 20);
-- pengujian SP_Tambah_Produk (data berbeda: produk 2)
CALL SP_Tambah_Produk('PRD012', 'Kabel HDMI 2 Meter', 'Aksesoris', 75000, 60);

-- menampilkan bukti produk baru bertambah
CALL SP_Tampil_Produk();

-- pengujian SP_Ubah_Harga (data berbeda: produk 1)
CALL SP_Ubah_Harga('PRD011', 1750000);
-- pengujian SP_Ubah_Harga (data berbeda: produk 2)
CALL SP_Ubah_Harga('PRD012', 89000);

-- menampilkan bukti perubahan harga
SELECT id_produk, nama_produk, harga FROM produk WHERE id_produk IN ('PRD011', 'PRD012');

-- pengujian procedure tambahan dengan kategori berbeda
CALL SP_Cari_Produk_Kategori('Aksesoris');
CALL SP_Cari_Produk_Kategori('Audio');


-- ============================================================
-- BUKTI PENGHAPUSAN PROCEDURE (DROP PROCEDURE)

-- sebelum dihapus: SP_Cari_Produk_Kategori masih terdaftar
SHOW PROCEDURE STATUS WHERE Db = 'electromart' AND Name = 'SP_Cari_Produk_Kategori';

-- menghapus procedure
DROP PROCEDURE SP_Cari_Produk_Kategori;

-- sesudah dihapus: hasil kosong (procedure sudah tidak ada)
SHOW PROCEDURE STATUS WHERE Db = 'electromart' AND Name = 'SP_Cari_Produk_Kategori';

-- menampilkan procedure yang tersisa
SHOW PROCEDURE STATUS WHERE Db = 'electromart';


-- ============================================================
-- PENGUJIAN ERROR (SENGAJA) - jalankan satu per satu

-- harga baru tidak valid  -> ERROR 1644: Gagal: harga baru harus lebih dari 0
CALL SP_Ubah_Harga('PRD011', -5000);

-- produk tidak ada        -> ERROR 1644: Gagal: produk tidak ditemukan
CALL SP_Ubah_Harga('PRD999', 100000);

-- harga produk nol        -> ERROR 1644: Gagal: harga produk harus lebih dari 0
CALL SP_Tambah_Produk('PRD013', 'Produk Uji', 'Aksesoris', 0, 5);

-- ID produk duplikat      -> ERROR 1062: Duplicate entry 'PRD001' for key 'produk.PRIMARY'
CALL SP_Tambah_Produk('PRD001', 'Produk Duplikat', 'Laptop', 5000000, 5);

-- procedure yang sudah di-DROP dipanggil -> ERROR 1305: PROCEDURE ... does not exist
CALL SP_Cari_Produk_Kategori('Audio');

