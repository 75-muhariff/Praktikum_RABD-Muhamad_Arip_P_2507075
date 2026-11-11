-- =====================================================================
-- PRAKTIKUM 1 : KONFIGURASI INDEX PADA POSTGRESQL
-- Database    : Praktikum_PrakR&ADB_Pertemuan 01
-- Nama        : Muhammad Arip purnama
-- NIM         : 2507075
-- ==================================================================

SELECT current_database();
SELECT version();

-- Membuat tabel (Mulai dari sini)
CREATE TABLE products (
    product_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    stock_quantity INT NOT NULL
);

CREATE TABLE customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
-- (membuat tabel) berakhir


-- Mulai dari sini mengisi tabel products, customers, dan orders dengan data dummy
-- Data products (40 baris) 
INSERT INTO products (name, category, price, stock_quantity)
VALUES
('Laptop ASUS Vivobook', 'Elektronik', 8500000, 12),
('Laptop Lenovo IdeaPad', 'Elektronik', 7800000, 8),
('Laptop Acer Aspire', 'Elektronik', 7200000, 15),
('Laptop HP 14', 'Elektronik', 6900000, 10),
('Monitor Samsung 24', 'Elektronik', 2500000, 20),
('Monitor LG 24', 'Elektronik', 2300000, 17),
('Keyboard Logitech K120', 'Aksesoris', 180000, 35),
('Keyboard Mechanical RGB', 'Aksesoris', 650000, 14),
('Mouse Logitech M170', 'Aksesoris', 175000, 30),
('Mouse Wireless Gaming', 'Aksesoris', 450000, 18),
('Flashdisk Sandisk 32GB', 'Penyimpanan', 85000, 40),
('Flashdisk Sandisk 64GB', 'Penyimpanan', 125000, 25),
('SSD Kingston 480GB', 'Penyimpanan', 650000, 16),
('SSD Samsung 500GB', 'Penyimpanan', 850000, 12),
('Harddisk Seagate 1TB', 'Penyimpanan', 900000, 10),
('Harddisk WD 1TB', 'Penyimpanan', 875000, 11),
('Printer Epson L3210', 'Printer', 2500000, 9),
('Printer Canon G2010', 'Printer', 2300000, 7),
('Printer HP 107A', 'Printer', 1700000, 13),
('Printer Epson L3250', 'Printer', 2900000, 6),
('Kamera Canon EOS 2000D', 'Kamera', 6500000, 5),
('Kamera Nikon D3500', 'Kamera', 6800000, 4),
('Webcam Logitech C270', 'Kamera', 750000, 16),
('Webcam Logitech C920', 'Kamera', 1500000, 8),
('Smartphone Samsung A15', 'Smartphone', 2500000, 14),
('Smartphone Xiaomi Redmi Note', 'Smartphone', 2800000, 18),
('Smartphone Oppo A58', 'Smartphone', 2700000, 13),
('Smartphone Vivo Y27', 'Smartphone', 3000000, 10),
('Tablet Samsung A9', 'Tablet', 3200000, 9),
('Tablet Xiaomi Redmi Pad', 'Tablet', 2900000, 11),
('Tablet Lenovo M10', 'Tablet', 2500000, 7),
('Headset Logitech H111', 'Aksesoris', 150000, 28),
('Headset Gaming HyperX', 'Aksesoris', 850000, 10),
('Speaker JBL Go', 'Audio', 650000, 15),
('Speaker Logitech Z120', 'Audio', 350000, 20),
('Powerbank Anker 10000mAh', 'Aksesoris', 450000, 22),
('Powerbank Xiaomi 20000mAh', 'Aksesoris', 550000, 19),
('Router TP-Link Archer', 'Jaringan', 750000, 12),
('Router Tenda AC10', 'Jaringan', 650000, 14),
('Router Tenda AC12', 'Jaringan', 950000, 15);

-- Data customers (30 baris)
INSERT INTO customers (first_name, last_name, city)
VALUES
('Andi', 'Pratama', 'Jakarta'),
('Budi', 'Santoso', 'Bandung'),
('Citra', 'Lestari', 'Jakarta'),
('Deni', 'Kurniawan', 'Bogor'),
('Eka', 'Saputra', 'Bandung'),
('Fajar', 'Hidayat', 'Garut'),
('Gita', 'Permata', 'Jakarta'),
('Hendra', 'Wijaya', 'Bekasi'),
('Indah', 'Sari', 'Bandung'),
('Joko', 'Setiawan', 'Garut'),
('Kiki', 'Ramadhan', 'Bogor'),
('Lina', 'Marlina', 'Jakarta'),
('Maman', 'Suryana', 'Garut'),
('Nina', 'Anggraini', 'Bandung'),
('Oki', 'Firmansyah', 'Bekasi'),
('Putri', 'Amelia', 'Jakarta'),
('Rian', 'Maulana', 'Bogor'),
('Sinta', 'Nuraini', 'Bandung'),
('Tono', 'Hermawan', 'Garut'),
('Umi', 'Khasanah', 'Jakarta'),
('Vina', 'Oktavia', 'Bandung'),
('Wahyu', 'Ramdan', 'Bogor'),
('Yani', 'Puspita', 'Bekasi'),
('Zaki', 'Akbar', 'Jakarta'),
('Agus', 'Setiawan', 'Garut'),
('Bella', 'Safitri', 'Bandung'),
('Dimas', 'Nugraha', 'Jakarta'),
('Elsa', 'Fitriani', 'Bogor'),
('Galih', 'Permana', 'Garut'),
('Hana', 'Rahmawati', 'Bandung');

-- Data orders (60 baris)
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES
(1, '2023-06-01', 8500000), (2, '2023-06-02', 2500000),
(3, '2023-06-03', 7800000), (4, '2023-06-04', 650000),
(5, '2023-06-05', 2900000), (6, '2023-06-06', 1700000),
(7, '2023-06-07', 450000), (8, '2023-06-08', 6500000),
(9, '2023-06-09', 2300000), (10, '2023-06-10', 850000),
(11, '2023-06-11', 3200000), (12, '2023-06-12', 2500000),
(13, '2023-06-13', 6900000), (14, '2023-06-14', 450000),
(15, '2023-06-15', 900000), (16, '2023-06-16', 2700000),
(17, '2023-06-17', 1500000), (18, '2023-06-18', 850000),
(19, '2023-06-19', 3000000), (20, '2023-06-20', 650000),
(21, '2023-06-21', 750000), (22, '2023-06-22', 2500000),
(23, '2023-06-23', 2900000), (24, '2023-06-24', 550000),
(25, '2023-06-25', 6500000), (26, '2023-06-26', 2300000),
(27, '2023-06-27', 8500000), (28, '2023-06-28', 1700000),
(29, '2023-06-29', 900000), (30, '2023-06-30', 2800000),
(1, '2023-07-01', 1250000), (2, '2023-07-02', 450000),
(3, '2023-07-03', 850000), (4, '2023-07-04', 2500000),
(5, '2023-07-05', 6500000), (6, '2023-07-06', 350000),
(7, '2023-07-07', 2900000), (8, '2023-07-08', 750000),
(9, '2023-07-09', 3200000), (10, '2023-07-10', 1700000),
(11, '2023-07-11', 850000), (12, '2023-07-12', 2700000),
(13, '2023-07-13', 650000), (14, '2023-07-14', 2300000),
(15, '2023-07-15', 8500000), (16, '2023-07-16', 450000),
(17, '2023-07-17', 2900000), (18, '2023-07-18', 650000),
(19, '2023-07-19', 1500000), (20, '2023-07-20', 3000000),
(21, '2023-07-21', 850000), (22, '2023-07-22', 2500000),
(23, '2023-07-23', 6500000), (24, '2023-07-24', 550000),
(25, '2023-07-25', 7800000), (26, '2023-07-26', 1700000),
(27, '2023-07-27', 900000), (28, '2023-07-28', 2800000),
(29, '2023-07-29', 1250000), (30, '2023-07-30', 350000);
-- berakhir mengisi tabel products, customers, dan orders dengan data dummy


-- Verifikasi dataset (hasil: products 40, customers 30, orders 60)
SELECT 'products' AS tabel, COUNT(*) AS jumlah FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;
-- berakhir verifikasi dataset


-- Karakteristik harga produk
SELECT
    MIN(price) AS harga_minimum,
    MAX(price) AS harga_maksimum,
    AVG(price) AS harga_rata_rata
FROM products;


-- Membuat index
-- Single-column index
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_products_stock ON products(stock_quantity);

-- Composite index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);


-- Memeriksa index (jalankan satu per satu agar hasil tampil di tab terpisah)
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'products';
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'customers';
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'orders';

