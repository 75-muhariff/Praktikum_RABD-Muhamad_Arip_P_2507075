-- nama 		: Muhamad Arip Purnama
-- NIM  		: 2507075
-- mata kuliah  : Praktikum Rekayasa dan Arsitektur DataBase 

-- Create Database 
CREATE DATABASE perpustakaan; 
USE perpustakaan; -- 1. Tabel Anggota 
CREATE TABLE Anggota ( 
id_anggota VARCHAR(7) PRIMARY KEY, 
nama_anggota VARCHAR(25) NOT NULL, 
alamat_anggota VARCHAR(50) NOT NULL, 
kota_anggota VARCHAR(15) NOT NULL, 
telp_anggota VARCHAR(15) NULL 
); -- 2. Tabel Penulis 
CREATE TABLE Penulis ( 
id_penulis VARCHAR(5) PRIMARY KEY, 
nama_penulis VARCHAR(15) NOT NULL, 
alamat_penulis VARCHAR(50) NOT NULL, 
kota_penulis VARCHAR(15) NULL, 
email VARCHAR(50) NULL 
); 
 -- 3. Tabel Buku 
CREATE TABLE Buku ( 
    id_buku VARCHAR(7) PRIMARY KEY, 
    judul_buku VARCHAR(30) NOT NULL, 
    penerbit_buku VARCHAR(15) NOT NULL, 
    tahun_terbit YEAR(4) NULL, 
    id_penulis VARCHAR(5) NOT NULL, 
    FOREIGN KEY (id_penulis) REFERENCES Penulis(id_penulis) 
); 
 -- 4. Tabel Detail_Buku 
CREATE TABLE Detail_Buku ( 
    id_buku VARCHAR(7) PRIMARY KEY, 
    kategori_buku VARCHAR(25) NOT NULL, 
    jumlah_buku INT NOT NULL, 
    harga_sewa INT NOT NULL, 
    FOREIGN KEY (id_buku) REFERENCES Buku(id_buku) 
); 
 -- 5. Tabel Peminjaman 
CREATE TABLE Peminjaman ( 
    id_peminjaman VARCHAR(6) PRIMARY KEY, 
    tanggal_peminjaman DATE NOT NULL, 
    id_anggota VARCHAR(7) NOT NULL, 
    FOREIGN KEY (id_anggota) REFERENCES Anggota(id_anggota) 
); 
 -- 6. Tabel Detail_Peminjaman 
CREATE TABLE Detail_Peminjaman ( 
    id_peminjaman VARCHAR(6) NOT NULL, 
    id_buku VARCHAR(7) NOT NULL, 
    status_peminjaman VARCHAR(10) NOT NULL, 
    PRIMARY KEY (id_peminjaman, id_buku), 
    FOREIGN KEY (id_peminjaman) REFERENCES Peminjaman(id_peminjaman), 
    FOREIGN KEY (id_buku) REFERENCES Buku(id_buku) 
);

-- Insert Tabel Anggota 
INSERT INTO Anggota VALUES 
('A.1.001', 'Budi Santoso', 'Jl. Merdeka No.10', 'Bandung', '0812345678'), 
('A.1.002', 'Siti Rahma', 'Jl. Sunda No.15', 'Bandung', '0821987654'), 
('A.1.003', 'Rian Hidayat', 'Jl. Pemuda No.45', 'Jakarta', '0838112233'), 
('A.1.004', 'Dewi Lestari', 'Jl. Asia Afrika No.8', 'Bandung', '0856778899'), 
('A.1.005', 'Eko Prasetyo', 'Jl. Gajah Mada No.12', 'Surabaya', '0878554433'); 
 -- Insert Tabel Penulis 
INSERT INTO Penulis VALUES 
('P.001', 'Ahmad Fuadi', 'Jl. Padang No.5', 'Padang', 'fuadi@writer.com'), 
('P.002', 'Tere Liye', 'Jl. Senayan No.88', 'Jakarta', 'tereliye@book.com'), 
('P.003', 'Andrea Hirata', 'Jl. Belitung No.3', 'Belitung', 'andrea@hirata.com'), 
('P.004', 'Dee Lestari', 'Jl. Dago No.100', 'Bandung', 'dee@supernova.com'); 
 -- Insert Tabel Buku 
INSERT INTO Buku VALUES 
('B.2.001', 'Basis Data Lanjut', 'Informatika', 2013, 'P.001'), 
('B.2.002', 'Pemrograman Python', 'Andi Offset', 2014, 'P.002'), 
('B.2.003', 'Struktur Data & Algoritma', 'Informatika', 2014, 'P.001'), 
('B.2.004', 'Rekayasa Perangkat Lunak', 'Erlangga', 2015, 'P.003'), 
('B.2.005', 'Kecerdasan Buatan', 'Erlangga', 2015, 'P.004'), 
('B.2.006', 'Jaringan Komputer', 'Andi Offset', 2015, 'P.003'); 
 -- Insert Tabel Detail_Buku 
INSERT INTO Detail_Buku VALUES 
('B.2.001', 'Komputer', 10, 3000), 
('B.2.002', 'Pemrograman', 8, 3500), 
('B.2.003', 'Pemrograman', 6, 3000), 
('B.2.004', 'Teknologi', 5, 4000), 
('B.2.005', 'Komputer', 7, 4500), 
('B.2.006', 'Jaringan', 4, 3500); 
 -- Insert Tabel Peminjaman 
INSERT INTO Peminjaman VALUES 
('T.101', '2026-03-01', 'A.1.001'), 
('T.102', '2026-03-01', 'A.1.002'), 
('T.103', '2026-03-02', 'A.1.003'), 
('T.104', '2026-03-03', 'A.1.004'); 
 -- Insert Tabel Detail_Peminjaman 
INSERT INTO Detail_Peminjaman VALUES 
('T.101', 'B.2.001', 'kembali'), 
('T.101', 'B.2.002', 'pinjam'), 
('T.102', 'B.2.003', 'pinjam'), 
('T.103', 'B.2.004', 'pinjam'), 
('T.104', 'B.2.005', 'pinjam'), 
('T.104', 'B.2.006', 'pinjam'); 


-- soal jawaban no 1
CREATE VIEW v_buku AS
SELECT
    b.id_buku,
    b.judul_buku,
    b.penerbit_buku,
    p.nama_penulis,
    p.email
FROM Buku b
JOIN Penulis p
    ON b.id_penulis = p.id_penulis;

-- soal jawaban no 2
CREATE VIEW v_pinjam AS
SELECT
    a.nama_anggota,
    pm.tanggal_peminjaman,
    b.judul_buku
FROM Peminjaman pm
JOIN Anggota a
    ON pm.id_anggota = a.id_anggota
JOIN Detail_Peminjaman dp
    ON pm.id_peminjaman = dp.id_peminjaman
JOIN Buku b
    ON dp.id_buku = b.id_buku;

-- soal jawaban no 3
CREATE VIEW v_detail AS
SELECT
    p.nama_penulis,
    COUNT(b.id_buku) AS jumlah_total_buku
FROM Penulis p
LEFT JOIN Buku b
    ON p.id_penulis = b.id_penulis
GROUP BY p.id_penulis, p.nama_penulis;

-- soal jawaban  no 4
CREATE VIEW v_pendapatan AS
SELECT
    pm.tanggal_peminjaman,
    SUM(db.harga_sewa) AS total_pendapatan
FROM Peminjaman pm
JOIN Detail_Peminjaman dp
    ON pm.id_peminjaman = dp.id_peminjaman
JOIN Detail_Buku db
    ON dp.id_buku = db.id_buku
GROUP BY pm.tanggal_peminjaman;

-- soal jawaban no 5
CREATE VIEW v_stok_tahun AS
SELECT
    b.tahun_terbit,
    SUM(db.jumlah_buku) AS total_stok_buku
FROM Buku b
JOIN Detail_Buku db
    ON b.id_buku = db.id_buku
WHERE b.tahun_terbit IN (2013, 2014, 2015)
GROUP BY b.tahun_terbit;

-- soal  jawaban no 6
CREATE VIEW v_peminjaman_lengkap AS
SELECT
    pm.id_peminjaman AS id_pinjam,
    pm.tanggal_peminjaman AS tgl_pinjam,
    a.nama_anggota AS peminjam,
    CONCAT(a.alamat_anggota, ', ', a.kota_anggota) AS alamat,
    a.telp_anggota AS telp
FROM Peminjaman pm
JOIN Anggota a
    ON pm.id_anggota = a.id_anggota;

-- soal jawaban no 7 
CREATE VIEW v_demografi AS
SELECT
    kota_anggota,
    COUNT(id_anggota) AS jumlah_anggota
FROM Anggota
GROUP BY kota_anggota;


select * from v_buku; 				-- no 1
select * from v_demografi;  		-- no 2
select * from v_detail; 			-- no 3
select * from v_peminjaman_lengkap; -- no 4
select * from v_pendapatan; 		-- no 5
select * from v_pinjam; 			-- no 6
select * from v_stok_tahun; 		-- no 7

