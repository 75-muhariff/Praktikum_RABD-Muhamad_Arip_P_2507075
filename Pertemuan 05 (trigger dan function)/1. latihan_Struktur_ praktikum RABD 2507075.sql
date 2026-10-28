-- latihan Struktur 
-- Muhamad Arip Purnama
-- 2507075
-- Praktikum RABD Pertemuan 05

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
    CONSTRAINT fk_penjualan_produk
        FOREIGN KEY (id_produk)
        REFERENCES produk(id_produk),
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

INSERT INTO produk (nama_produk, harga, stok)
VALUES
    ('Laptop', 7500000, 10),
    ('Mouse', 150000, 25),
    ('Keyboard', 350000, 15),
    ('Monitor', 1800000, 8);

SELECT * FROM produk;

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

DELIMITER ;

SELECT hitung_total(150000, 3) AS total_harga;

SELECT
    1500000 AS total_transaksi,
    hitung_diskon(1500000) AS diskon,
    1500000 - hitung_diskon(1500000) AS total_bayar;

SELECT
    hitung_total(350000, 4) AS total_transaksi,
    hitung_diskon(hitung_total(350000, 4)) AS diskon,
    hitung_total(350000, 4)
        - hitung_diskon(hitung_total(350000, 4)) AS total_bayar;

DELIMITER //

CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT DEFAULT NULL;
    DECLARE v_ada INT DEFAULT 0;

    IF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Jumlah pembelian harus lebih dari nol';
    END IF;

    IF NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Harga satuan harus lebih dari nol';
    END IF;

    SELECT COUNT(*)
    INTO v_ada
    FROM produk
    WHERE id_produk = NEW.id_produk;

    IF v_ada = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Produk tidak ditemukan';
    END IF;

    SELECT stok
    INTO v_stok
    FROM produk
    WHERE id_produk = NEW.id_produk
    FOR UPDATE;

    IF NEW.jumlah > v_stok THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stok produk tidak mencukupi';
    END IF;

    SET NEW.total =
        hitung_total(NEW.harga_satuan, NEW.jumlah);
END //

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok_awal INT;
    DECLARE v_stok_akhir INT;

    SELECT stok
    INTO v_stok_awal
    FROM produk
    WHERE id_produk = NEW.id_produk;

    SET v_stok_akhir = v_stok_awal - NEW.jumlah;

    UPDATE produk
    SET stok = v_stok_akhir
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (
        id_produk,
        stok_awal,
        stok_akhir,
        keterangan
    )
    VALUES (
        NEW.id_produk,
        v_stok_awal,
        v_stok_akhir,
        'Pengurangan stok karena penjualan'
    );
END //

DELIMITER ;

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (2, 2, 150000, 0);

SELECT * FROM penjualan;

SELECT nama_produk, stok
FROM produk
WHERE id_produk = 2;

SELECT * FROM log_stok;

SHOW FUNCTION STATUS
WHERE Db = 'praktikum_function_trigger';

SHOW TRIGGERS
FROM praktikum_function_trigger;


-- TUGAS 1: Function Perhitungan Total
SELECT hitung_total(250000, 4) AS total_transaksi;


-- TUGAS 2: Function Diskon
SELECT
    800000 AS total_transaksi,
    hitung_diskon(800000) AS diskon,
    800000 - hitung_diskon(800000) AS total_bayar
UNION ALL
SELECT
    1500000,
    hitung_diskon(1500000),
    1500000 - hitung_diskon(1500000) AS total_bayar;


-- TUGAS 3: Validasi Transaksi Penjualan
INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (2, 1, 150000, 0);

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (2, 100, 150000, 0);

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (2, 0, 150000, 0);


-- TUGAS 4: Pembaruan dan Pencatatan Stok
INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (3, 3, 350000, 0);

SELECT nama_produk, stok
FROM produk
WHERE id_produk = 3;

SELECT
    l.id_log,
    p.nama_produk,
    l.stok_awal,
    l.stok_akhir,
    l.keterangan,
    l.waktu_log
FROM log_stok AS l
JOIN produk AS p
    ON p.id_produk = l.id_produk
WHERE l.id_produk = 3
ORDER BY l.id_log DESC;


-- TUGAS 5: Integrasi Function dan Trigger
SELECT nama_produk, stok AS stok_sebelum
FROM produk
WHERE id_produk = 1;

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (1, 2, 7500000, 0);

SELECT
    j.id_penjualan,
    p.nama_produk,
    j.jumlah,
    j.total AS total_transaksi,
    hitung_diskon(j.total) AS diskon,
    j.total - hitung_diskon(j.total) AS total_bayar
FROM penjualan AS j
JOIN produk AS p
    ON p.id_produk = j.id_produk
WHERE j.id_produk = 1
ORDER BY j.id_penjualan DESC
LIMIT 1;

SELECT nama_produk, stok AS stok_sesudah
FROM produk
WHERE id_produk = 1;

SELECT
    l.id_log,
    p.nama_produk,
    l.stok_awal,
    l.stok_akhir,
    l.keterangan,
    l.waktu_log
FROM log_stok AS l
JOIN produk AS p
    ON p.id_produk = l.id_produk
WHERE l.id_produk = 1
ORDER BY l.id_log DESC;

SELECT * FROM produk;
SELECT * FROM penjualan;
SELECT * FROM log_stok;
