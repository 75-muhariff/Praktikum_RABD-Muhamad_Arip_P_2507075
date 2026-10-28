-- Tugas Mandiri 
-- Muhamad Arip Purnama
-- 2507075
-- Praktikum RABD Pertemuan 05


-- Tugas Mandiri Stored Function dan Trigger

DROP DATABASE IF EXISTS praktikum_function_trigger;
CREATE DATABASE praktikum_function_trigger;
USE praktikum_function_trigger;

CREATE TABLE produk (
    id_produk INT AUTO_INCREMENT PRIMARY KEY,
    nama_produk VARCHAR(100) NOT NULL,
    harga DECIMAL(12,2) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    CHECK (harga > 0),
    CHECK (stok >= 0)
) ENGINE = InnoDB;

CREATE TABLE penjualan (
    id_penjualan INT AUTO_INCREMENT PRIMARY KEY,
    id_produk INT NOT NULL,
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(12,2) NOT NULL,
    total DECIMAL(14,2) NOT NULL DEFAULT 0,
    tanggal_transaksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produk) REFERENCES produk(id_produk),
    CHECK (jumlah > 0),
    CHECK (harga_satuan > 0),
    CHECK (total >= 0)
) ENGINE = InnoDB;

CREATE TABLE log_stok (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_produk INT NOT NULL,
    stok_awal INT NOT NULL,
    stok_akhir INT NOT NULL,
    keterangan VARCHAR(100) NOT NULL,
    waktu_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO produk (nama_produk, harga, stok) VALUES
('Laptop', 7500000, 10),
('Mouse', 150000, 25),
('Keyboard', 350000, 15),
('Monitor', 1800000, 8);

DELIMITER //

CREATE FUNCTION hitung_total(
    p_harga DECIMAL(12,2),
    p_jumlah INT
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_harga * p_jumlah;
END //

CREATE FUNCTION hitung_diskon(
    p_total DECIMAL(14,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_total >= 1000000 THEN
        RETURN p_total * 0.10;
    ELSE
        RETURN 0;
    END IF;
END //

CREATE FUNCTION hitung_pajak(
    p_total DECIMAL(14,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_total * 0.11;
END //

CREATE FUNCTION hitung_total_akhir(
    p_total DECIMAL(14,2),
    p_diskon DECIMAL(5,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_total - (p_total * p_diskon / 100);
END //

CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT;

    IF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Jumlah pembelian harus lebih dari nol';
    END IF;

    IF NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Harga satuan harus lebih dari nol';
    END IF;

    SELECT stok INTO v_stok
    FROM produk
    WHERE id_produk = NEW.id_produk
    FOR UPDATE;

    IF NEW.jumlah > v_stok THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stok produk tidak mencukupi';
    END IF;

    SET NEW.total = hitung_total(NEW.harga_satuan, NEW.jumlah);
END //

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok_awal INT;

    SELECT stok INTO v_stok_awal
    FROM produk
    WHERE id_produk = NEW.id_produk;

    UPDATE produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (
        id_produk, stok_awal, stok_akhir, keterangan
    )
    VALUES (
        NEW.id_produk,
        v_stok_awal,
        v_stok_awal - NEW.jumlah,
        'Pengurangan stok karena penjualan'
    );
END //

CREATE TRIGGER catat_perubahan_stok
AFTER UPDATE ON produk
FOR EACH ROW
BEGIN
    IF OLD.stok <> NEW.stok THEN
        INSERT INTO log_stok (
            id_produk, stok_awal, stok_akhir, keterangan
        )
        VALUES (
            NEW.id_produk,
            OLD.stok,
            NEW.stok,
            'Perubahan stok produk'
        );
    END IF;
END //

CREATE TRIGGER validasi_harga_produk
BEFORE UPDATE ON produk
FOR EACH ROW
BEGIN
    IF NEW.harga <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Harga produk harus lebih dari nol';
    END IF;
END //

DELIMITER ;

SELECT hitung_total(2000000, 1) AS total_transaksi;
SELECT hitung_diskon(2000000) AS diskon_transaksi;
SELECT hitung_pajak(2000000) AS pajak_transaksi;
SELECT hitung_total_akhir(3000000, 15) AS total_setelah_diskon;

INSERT INTO penjualan (id_produk, jumlah, harga_satuan)
VALUES (2, 2, 150000);

UPDATE produk
SET stok = 30
WHERE id_produk = 2;

UPDATE produk
SET harga = 200000
WHERE id_produk = 2;

SELECT * FROM produk;
SELECT * FROM penjualan;
SELECT * FROM log_stok;

SELECT
    pj.id_penjualan,
    pr.nama_produk,
    pj.jumlah,
    pj.harga_satuan,
    pj.total,
    hitung_diskon(pj.total) AS diskon,
    hitung_pajak(pj.total) AS pajak,
    hitung_total_akhir(pj.total, 15) AS total_setelah_diskon,
    pj.tanggal_transaksi
FROM penjualan pj
JOIN produk pr ON pj.id_produk = pr.id_produk;
