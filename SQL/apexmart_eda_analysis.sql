/*
===============================================================================
PROYEK   : ApexMart Retail Sales & Profitability Analysis
PENULIS  : Rangga Setiawan
TOOLS    : PostgreSQL (pgAdmin 4)
DATASET  : sales_data (9.993 baris bersih, 2014–2017)
TUJUAN   : Validasi KPI lintas-alat (Excel vs SQL), analisis performa bisnis
           inti (BQ #1–#5), dan investigasi akar kebocoran margin (Deep-Dive).
===============================================================================
*/


-- ============================================================================
-- BAGIAN 1: AUDIT PASCA-IMPOR & PEMBERSIHAN DATA (DATA CLEANING)
-- ============================================================================

-- 1.1 Deteksi baris kosong (NULL) yang terbawa dari proses ekspor CSV Excel
SELECT *
FROM sales_data
WHERE order_id IS NULL
   OR sales IS NULL;

-- 1.2 Hapus baris kosong (ditemukan 1 baris NULL; aman dijalankan ulang)
DELETE FROM sales_data
WHERE order_id IS NULL;

-- 1.3 Validasi Global KPI (Cross-check terhadap baseline Excel)
SELECT
    COUNT(*) AS total_rows,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data;


-- ============================================================================
-- BAGIAN 2: ANALISIS PERTANYAAN BISNIS INTI (BQ #1 – BQ #5)
-- ============================================================================

-- BQ #1: Tren Penjualan, Profit, Margin, dan Jumlah Order Unik Tahunan
SELECT
    order_year,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data
GROUP BY order_year
ORDER BY order_year ASC;

-- BQ #2: Evaluasi Profitabilitas Kategori & Sub-Kategori (Urutan Rugi Terbesar)
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data
GROUP BY category, sub_category
ORDER BY total_profit ASC;

-- BQ #3: Performa & Efisiensi Profitabilitas per Wilayah (Region)
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data
GROUP BY region
ORDER BY profit_margin_pct ASC;

-- BQ #4: Kontribusi Penjualan & Profit berdasarkan Segmen Pelanggan
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data
GROUP BY segment
ORDER BY total_profit DESC;

-- BQ #5: Pengelompokan Dampak Tingkat Diskon terhadap Profitabilitas (CASE WHEN)
SELECT
    CASE
        WHEN discount = 0 THEN '1. No Discount (0%)'
        WHEN discount <= 0.20 THEN '2. Low Discount (10% - 20%)'
        WHEN discount <= 0.50 THEN '3. High Discount (30% - 50%)'
        ELSE '4. Extreme Discount (> 50%)'
    END AS discount_tier,
    COUNT(*) AS total_transactions,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data
GROUP BY discount_tier
ORDER BY discount_tier ASC;


-- ============================================================================
-- BAGIAN 3: DEEP-DIVE ROOT CAUSE ANALYSIS (CTE, WINDOW FUNCTION, HAVING)
-- ============================================================================

-- Deep-Dive #1 (BQ #3 + BQ #5): Audit Proporsi Diskon Tinggi (>20%) per Wilayah
WITH regional_audit AS (
    SELECT
        region,
        COUNT(*) AS total_tx,
        COUNT(*) FILTER (WHERE discount > 0.20) AS high_discount_tx,
        ROUND(AVG(discount) * 100, 2) AS avg_discount_pct,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM sales_data
    GROUP BY region
)
SELECT
    region,
    total_tx,
    high_discount_tx,
    ROUND((high_discount_tx::NUMERIC / total_tx) * 100, 2) AS pct_high_discount_tx,
    avg_discount_pct,
    total_sales,
    total_profit,
    ROUND((total_profit / total_sales) * 100, 2) AS profit_margin_pct
FROM regional_audit
ORDER BY profit_margin_pct ASC;

-- Deep-Dive #2 (BQ #2 + BQ #3 + BQ #5): Top 3 Sub-Kategori Profit Terendah per Wilayah
WITH subcat_region AS (
    SELECT
        region,
        category,
        sub_category,
        ROUND(AVG(discount) * 100, 2) AS avg_discount_pct,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM sales_data
    GROUP BY region, category, sub_category
),
ranked_subcat AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY region ORDER BY total_profit ASC) AS loss_rank
    FROM subcat_region
)
SELECT
    region,
    loss_rank,
    category,
    sub_category,
    avg_discount_pct,
    total_sales,
    total_profit
FROM ranked_subcat
WHERE loss_rank <= 3
ORDER BY region, loss_rank;

-- Deep-Dive #3 (BQ #3 + BQ #5): Top 5 Negara Bagian (State) Penyumbang Kerugian Terbesar
SELECT
    region,
    state,
    COUNT(*) AS total_tx,
    ROUND(AVG(discount) * 100, 2) AS avg_discount_pct,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM sales_data
GROUP BY region, state
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 5;