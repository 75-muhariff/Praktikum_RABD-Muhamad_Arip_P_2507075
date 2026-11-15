-- ElectroMart - Sistem Informasi Penjualan dan Persediaan | View

-- ============================================================
-- Nama        : Muhamad Arip Purnama
-- NIM         : 2507075
-- Kelas       : Sistem Informasi B
-- Mata Kuliah : Praktikum Rekayasa dan Perancangan Database
-- Script      : 06 View


USE electromart;


-- awal pembersihan (agar script dapat dijalankan ulang)
DROP VIEW IF EXISTS View_Produk;
DROP VIEW IF EXISTS View_Transaksi;
DROP VIEW IF EXISTS View_Laporan_Penjualan;
DROP VIEW IF EXISTS View_Stok_Rendah;
DROP VIEW IF EXISTS View_Produk_Aksesoris;
DROP VIEW IF EXISTS View_Produk_Mahal;
-- akhir pembersihan


-- awal pembuatan view

-- ------------------------------------------------------------
-- 1. View_Produk  (VIEW DARI SATU TABEL)

CREATE VIEW View_Produk AS
SELECT id_produk,
       nama_produk,
       kategori,
       harga,
       CASE
           WHEN stok = 0 THEN 'Habis'
           WHEN stok < 5 THEN 'Menipis'
           ELSE 'Tersedia'
       END AS status_stok
FROM produk;

-- ------------------------------------------------------------
-- 2. View_Transaksi  (VIEW DENGAN JOIN BEBERAPA TABEL)
--    Informasi transaksi beserta nama pelanggan dan nama kasir.

CREATE VIEW View_Transaksi AS
SELECT p.id_penjualan,
       p.tanggal,
       p.id_pelanggan,
       pl.nama_pelanggan,
       pg.nama_pegawai AS nama_kasir,
       p.total_harga,
       p.diskon,
       p.total_bayar
FROM penjualan p
JOIN pelanggan pl ON pl.id_pelanggan = p.id_pelanggan
JOIN pegawai   pg ON pg.id_pegawai   = p.id_pegawai;

-- ------------------------------------------------------------
-- 3. View_Laporan_Penjualan  (VIEW AGREGASI: COUNT, SUM, GROUP BY)
--    Jumlah transaksi dan total penjualan per periode (bulan) dan kategori.

CREATE VIEW View_Laporan_Penjualan AS
SELECT DATE_FORMAT(p.tanggal, '%Y-%m')   AS periode,
       pr.kategori                       AS kategori,
       COUNT(DISTINCT p.id_penjualan)    AS jumlah_transaksi,
       SUM(d.jumlah)                     AS total_unit_terjual,
       SUM(d.subtotal)                   AS total_penjualan
FROM penjualan p
JOIN detail_penjualan d ON d.id_penjualan = p.id_penjualan
JOIN produk pr          ON pr.id_produk   = d.id_produk
GROUP BY DATE_FORMAT(p.tanggal, '%Y-%m'), pr.kategori;

-- ------------------------------------------------------------
-- 4. View_Stok_Rendah  (produk dengan stok di bawah batas = 5 unit)

CREATE VIEW View_Stok_Rendah AS
SELECT id_produk,
       nama_produk,
       kategori,
       stok,
       CASE
           WHEN stok = 0 THEN 'Habis'
           WHEN stok <= 2 THEN 'Kritis'
           ELSE 'Rendah'
       END AS tingkat_stok
FROM produk
WHERE stok < 5;

-- ------------------------------------------------------------
-- 5. View_Produk_Aksesoris  (VIEW UPDATABLE + WITH CHECK OPTION)
--    Hanya boleh memuat / menerima data produk berkategori 'Aksesoris'.

CREATE VIEW View_Produk_Aksesoris AS
SELECT id_produk, nama_produk, kategori, harga, stok
FROM produk
WHERE kategori = 'Aksesoris'
WITH CHECK OPTION;

-- ------------------------------------------------------------
-- 6. View_Produk_Mahal  (view contoh yang akan dihapus dengan DROP VIEW)

CREATE VIEW View_Produk_Mahal AS
SELECT id_produk, nama_produk, kategori, harga
FROM produk
WHERE harga >= 5000000;

-- akhir pembuatan view


-- menampilkan daftar view
SHOW FULL TABLES IN electromart WHERE Table_type = 'VIEW';


-- ============================================================
-- PENGUJIAN VIEW MENGGUNAKAN SELECT

-- menampilkan View_Produk (satu tabel)
SELECT * FROM View_Produk;
SELECT * FROM View_Produk WHERE kategori = 'Aksesoris';

-- menampilkan View_Transaksi (bukti hasil JOIN)
SELECT * FROM View_Transaksi ORDER BY tanggal;
SELECT * FROM View_Transaksi WHERE nama_pelanggan LIKE 'Budi%';

-- menampilkan View_Laporan_Penjualan (bukti hasil agregasi)
SELECT * FROM View_Laporan_Penjualan ORDER BY periode, kategori;
-- laporan berdasarkan periode tertentu
SELECT * FROM View_Laporan_Penjualan WHERE periode = '2026-11' ORDER BY total_penjualan DESC;
-- laporan berdasarkan kategori tertentu
SELECT * FROM View_Laporan_Penjualan WHERE kategori = 'Aksesoris';
-- ringkasan total penjualan per periode
SELECT periode, SUM(total_unit_terjual) AS total_unit, SUM(total_penjualan) AS total_penjualan
FROM View_Laporan_Penjualan
GROUP BY periode;

-- menampilkan View_Stok_Rendah
SELECT * FROM View_Stok_Rendah ORDER BY stok;

-- perbandingan penyederhanaan query:
-- TANPA view (pengguna harus menulis JOIN sendiri)
SELECT p.id_penjualan, p.tanggal, pl.nama_pelanggan, pg.nama_pegawai AS nama_kasir,
       p.total_harga, p.diskon, p.total_bayar
FROM penjualan p
JOIN pelanggan pl ON pl.id_pelanggan = p.id_pelanggan
JOIN pegawai   pg ON pg.id_pegawai   = p.id_pegawai
ORDER BY p.tanggal;
-- DENGAN view (cukup satu baris, hasil sama)
SELECT id_penjualan, tanggal, nama_pelanggan, nama_kasir, total_harga, diskon, total_bayar
FROM View_Transaksi ORDER BY tanggal;


-- ============================================================
-- PENGUJIAN WITH CHECK OPTION (View_Produk_Aksesoris)
-- Dibungkus transaksi + ROLLBACK agar data produk tidak berubah.

START TRANSACTION;

-- [BERHASIL] INSERT produk berkategori 'Aksesoris' sesuai kondisi view
INSERT INTO View_Produk_Aksesoris (id_produk, nama_produk, kategori, harga, stok)
VALUES ('PRD013', 'Mousepad Gaming XL', 'Aksesoris', 120000, 30);

-- [BERHASIL] UPDATE harga produk dalam view (kategori tetap 'Aksesoris')
UPDATE View_Produk_Aksesoris SET harga = 130000 WHERE id_produk = 'PRD013';

-- bukti data masuk lewat view dan tersimpan di tabel produk
SELECT * FROM View_Produk_Aksesoris WHERE id_produk = 'PRD013';
SELECT * FROM produk WHERE id_produk = 'PRD013';

-- [DITOLAK] INSERT produk kategori selain 'Aksesoris'
--   -> ERROR 1369: CHECK OPTION failed 'electromart.View_Produk_Aksesoris'
INSERT INTO View_Produk_Aksesoris (id_produk, nama_produk, kategori, harga, stok)
VALUES ('PRD014', 'Monitor Gaming 24 Inch', 'Monitor', 2500000, 5);

-- [DITOLAK] UPDATE yang membuat baris keluar dari kondisi view
--   -> ERROR 1369: CHECK OPTION failed 'electromart.View_Produk_Aksesoris'
UPDATE View_Produk_Aksesoris SET kategori = 'Laptop' WHERE id_produk = 'PRD002';

-- bukti: PRD014 tidak ada, kategori PRD002 tetap 'Aksesoris'
SELECT id_produk, nama_produk, kategori FROM produk WHERE id_produk IN ('PRD002', 'PRD014');

ROLLBACK;

-- bukti setelah ROLLBACK: PRD013 juga tidak tersimpan (hasil kosong)
SELECT * FROM produk WHERE id_produk = 'PRD013';


-- ============================================================
-- BUKTI PENGHAPUSAN VIEW (DROP VIEW)
-- ============================================================

-- sebelum dihapus: View_Produk_Mahal dapat di-SELECT
SELECT * FROM View_Produk_Mahal;

-- menghapus view
DROP VIEW View_Produk_Mahal;

-- menampilkan view yang tersisa (View_Produk_Mahal sudah tidak ada)
SHOW FULL TABLES IN electromart WHERE Table_type = 'VIEW';

-- PENGUJIAN ERROR (SENGAJA): view yang sudah dihapus di-SELECT
--   -> ERROR 1146: Table 'electromart.View_Produk_Mahal' doesn't exist
SELECT * FROM View_Produk_Mahal;


-- ============================================================
-- HAK AKSES VIEW (kelanjutan Tugas 2 - role hanya dibatasi pada view)
-- ============================================================
GRANT SELECT ON electromart.View_Produk
    TO 'role_penjualan', 'role_gudang', 'role_manajer';
GRANT SELECT ON electromart.View_Transaksi          TO 'role_manajer';
GRANT SELECT ON electromart.View_Laporan_Penjualan  TO 'role_manajer';
GRANT SELECT ON electromart.View_Stok_Rendah
    TO 'role_manajer', 'role_gudang';

-- menampilkan hak akses role_manajer setelah ada view
SHOW GRANTS FOR 'role_manajer';

-- ------------------------------------------------------------
-- UJI KEAMANAN VIEW (login di koneksi baru sebagai user_hendra_manajer
-- | password: Manajer@2507075; hapus tanda "-- " lalu jalankan satu per satu)
-- ------------------------------------------------------------
-- [berhasil] manajer membaca laporan lewat view
-- SELECT * FROM electromart.View_Laporan_Penjualan;
-- SELECT * FROM electromart.View_Transaksi;
-- SELECT * FROM electromart.View_Stok_Rendah;
--
-- [DITOLAK] manajer TIDAK punya akses langsung ke tabel pelanggan, tetapi
-- tetap melihat nama pelanggan lewat View_Transaksi (view berjalan dengan
-- hak pembuatnya / SQL SECURITY DEFINER):
--   -> ERROR 1142 (42000): SELECT command denied ... for table 'pelanggan'
-- SELECT * FROM electromart.pelanggan;
--
-- [DITOLAK] view agregasi bersifat read-only:
--   -> ERROR 1288 (HY000): The target table View_Laporan_Penjualan of the UPDATE is not updatable
-- (dijalankan sebagai root / admin)
-- UPDATE electromart.View_Laporan_Penjualan SET total_penjualan = 0;

-- OPSIONAL (penguatan keamanan): setelah semua view tersedia, akses langsung
-- manajer ke tabel dasar dapat dicabut sehingga manajer HANYA melihat data
-- lewat view:
-- REVOKE SELECT ON electromart.penjualan        FROM 'role_manajer';
-- REVOKE SELECT ON electromart.detail_penjualan FROM 'role_manajer';
