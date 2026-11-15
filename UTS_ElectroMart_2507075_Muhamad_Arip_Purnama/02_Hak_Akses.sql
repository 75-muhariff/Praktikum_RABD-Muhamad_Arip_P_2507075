-- ElectroMart - Sistem Informasi Penjualan dan Persediaan | Hak akses

-- Nama        : Muhamad Arip Purnama
-- NIM         : 2507075
-- Kelas       : Sistem Informasi B
-- Mata Kuliah : Praktikum Rekayasa dan Perancangan Database
-- Script      : 02 Hak Akses
-- ============================================================


USE electromart;


-- awal pembersihan 
DROP USER IF EXISTS
    'user_andi_admin'@'%',
    'user_maya_sales'@'%',
    'user_eko_gudang'@'%',
    'user_hendra_manajer'@'%';

DROP ROLE IF EXISTS
    'role_admin',
    'role_penjualan',
    'role_gudang',
    'role_manajer';
-- akhir pembersihan


-- awal pembuatan role
CREATE ROLE 'role_admin';
CREATE ROLE 'role_penjualan';
CREATE ROLE 'role_gudang';
CREATE ROLE 'role_manajer';
-- akhir pembuatan role


-- awal pemberian hak akses (GRANT)
-- ------------------------------------------------------------
-- 1. role_admin : mengelola seluruh objek dan data basis data
GRANT ALL PRIVILEGES ON electromart.* TO 'role_admin';

-- ------------------------------------------------------------
-- 2. role_penjualan : melihat produk & pelanggan, menginput transaksi
GRANT SELECT ON electromart.produk    TO 'role_penjualan';
GRANT SELECT ON electromart.pelanggan TO 'role_penjualan';
-- diberikan penuh lebih dulu, lalu dipersempit dengan REVOKE di bawah
GRANT SELECT, INSERT, UPDATE, DELETE ON electromart.penjualan        TO 'role_penjualan';
GRANT SELECT, INSERT, UPDATE, DELETE ON electromart.detail_penjualan TO 'role_penjualan';

-- ------------------------------------------------------------
-- 3. role_gudang : melihat produk dan memperbarui stok
GRANT SELECT, UPDATE ON electromart.produk TO 'role_gudang';
-- setiap perubahan stok manual harus bisa dicatat ke log_stok
GRANT SELECT, INSERT ON electromart.log_stok TO 'role_gudang';

-- ------------------------------------------------------------
-- 4. role_manajer : melihat informasi produk dan laporan penjualan (read-only)
GRANT SELECT ON electromart.produk           TO 'role_manajer';
GRANT SELECT ON electromart.penjualan        TO 'role_manajer';
GRANT SELECT ON electromart.detail_penjualan TO 'role_manajer';
-- akhir pemberian hak akses (GRANT)


-- awal pencabutan hak akses (REVOKE)
-- Pegawai penjualan hanya boleh MENAMBAH transaksi, tidak boleh mengubah atau menghapus transaksi yang sudah tercatat.
REVOKE UPDATE, DELETE ON electromart.penjualan        FROM 'role_penjualan';
REVOKE UPDATE, DELETE ON electromart.detail_penjualan FROM 'role_penjualan';

-- Pegawai gudang tidak boleh mengubah seluruh kolom produk. UPDATE tingkat tabel dicabut, lalu hanya kolom stok yang diberikan kembali.
REVOKE UPDATE ON electromart.produk FROM 'role_gudang';
GRANT  UPDATE (stok) ON electromart.produk TO 'role_gudang';
-- akhir pencabutan hak akses (REVOKE)


-- awal pembuatan user dan penghubungan user dengan role
CREATE USER 'user_andi_admin'@'%'     IDENTIFIED BY 'Admin@2507075';
CREATE USER 'user_maya_sales'@'%'     IDENTIFIED BY 'Sales@2507075';
CREATE USER 'user_eko_gudang'@'%'     IDENTIFIED BY 'Gudang@2507075';
CREATE USER 'user_hendra_manajer'@'%' IDENTIFIED BY 'Manajer@2507075';

-- hubungkan user dengan role yang sesuai (sesuai kolom peran pada tabel pegawai)
GRANT 'role_admin'     TO 'user_andi_admin'@'%';       -- PGW001 Andi Wijaya
GRANT 'role_penjualan' TO 'user_maya_sales'@'%';       -- PGW002 Maya Putri
GRANT 'role_gudang'    TO 'user_eko_gudang'@'%';       -- PGW003 Eko Prasetyo
GRANT 'role_manajer'   TO 'user_hendra_manajer'@'%';   -- PGW004 Hendra Gunawan

-- aktifkan role secara otomatis saat user login (wajib di MySQL 8)
SET DEFAULT ROLE 'role_admin'     TO 'user_andi_admin'@'%';
SET DEFAULT ROLE 'role_penjualan' TO 'user_maya_sales'@'%';
SET DEFAULT ROLE 'role_gudang'    TO 'user_eko_gudang'@'%';
SET DEFAULT ROLE 'role_manajer'   TO 'user_hendra_manajer'@'%';

FLUSH PRIVILEGES;
-- akhir pembuatan user dan penghubungan user dengan role


-- menampilkan role dan user
SELECT user AS nama_akun, host
FROM mysql.user
WHERE user LIKE 'role\_%' OR user LIKE 'user\_%'
ORDER BY user;

-- menampilkan hubungan user dengan role
SELECT from_user AS role_name, to_user AS nama_user
FROM mysql.role_edges
WHERE from_user LIKE 'role\_%'
ORDER BY from_user;

-- menampilkan hak akses setiap role
SHOW GRANTS FOR 'role_admin';
SHOW GRANTS FOR 'role_penjualan';
SHOW GRANTS FOR 'role_gudang';
SHOW GRANTS FOR 'role_manajer';

-- menampilkan hak akses efektif setiap user (setelah role diaktifkan)
SHOW GRANTS FOR 'user_andi_admin'@'%'     USING 'role_admin';
SHOW GRANTS FOR 'user_maya_sales'@'%'     USING 'role_penjualan';
SHOW GRANTS FOR 'user_eko_gudang'@'%'     USING 'role_gudang';
SHOW GRANTS FOR 'user_hendra_manajer'@'%' USING 'role_manajer';
