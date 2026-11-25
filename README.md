# ApexMart Retail — Sales & Profitability Analysis

An end-to-end retail data analytics project analyzing **9,993 transaction records** across **5,009 orders** (2014–2017) to evaluate revenue growth, regional performance, customer segment contributions, and the impact of discounting strategies on net profit.

**Tech Stack:** `Microsoft Excel` • `PostgreSQL (pgAdmin 4)` • `Power BI Desktop (Power Query & DAX)`

---

## 1. Business Problem & Objectives
While ApexMart achieved consistent top-line revenue growth over four years, overall profit margins showed signs of compression. This project addresses four core business questions:
1. **Annual Performance:** How have total sales, net profit, and profit margins evolved from 2014 to 2017?
2. **Regional & Segment Drivers:** Which regions and customer segments generate the highest revenue and profitability?
3. **Discount Impact:** At what discount threshold do transactions shift from profitable to net losses?
4. **Product Leakage:** Which specific product sub-categories are eroding company-wide profitability?

---

## 2. Data Pipeline & Methodology
* **Data Auditing & Cleaning (Excel & Power Query):** Standardized data types across 24 columns (preserving leading zeros on `postal_code` as text), verified zero duplicate records, and engineered a custom `discount_tier` column (`No Discount (0%)`, `Low Discount (10%–20%)`, `High Discount (30%–50%)`, `Extreme Discount (>50%)`).
* **Exploratory Analysis & Validation (PostgreSQL):** Wrote SQL queries using aggregations, `CASE` statements, and CTEs to answer business questions and establish ground-truth KPI benchmarks.
* **Data Modeling & DAX (Power BI):** Built 7 dynamic DAX measures (`Total Sales`, `Total Profit`, `Profit Margin %`, `Total Orders`, `Total Transactions`, `Avg Discount %`, and `High Discount Tx %`) cross-validated 100% against SQL query outputs.

---

## 3. Executive Dashboard Preview

### Page 1: Executive Performance Overview
![Executive Overview](assets/page1_executive_overview.png)

### Page 2: Discount & Profitability Analysis
![Discount and Profitability](assets/page2_discount_profitability.png)

---

## 4. Key Business Insights
* **Top-Line Growth vs. Margin Compression:** Total revenue reached **$2.30M** with **$286.41K** in net profit (**12.47%** overall margin). Although revenue peaked in 2017 (~$0.73M), profit margin declined from ~13.4% in 2016 to ~12.7% in 2017 due to heavier discounting.
* **The 30% Discount Loss Threshold:** Average discount across all transactions stood at **15.62%**, with **13.93%** of transactions receiving high discounts ($\ge 30\%$). Orders with `0%` and `10%–20%` discounts remained profitable, whereas `30%–50%` (*High*) and `>50%` (*Extreme*) tiers resulted in net operating losses.
* **Regional Efficiency Gap (Central Region):** **West** and **East** led both sales and profit generation. However, **Central** generated higher revenue than **South** (~$0.50M vs. ~$0.39M) yet delivered lower total profit due to significantly higher average discount rates.
* **Segment Concentration:** **Consumer** ($1.16M / **50.56%**) and **Corporate** ($0.71M / **30.74%**) accounted for **81.30%** of total company revenue, followed by **Home Office** ($0.43M / **18.69%**).
* **Sub-Category Profit Leakage:** Technology items (**Copiers**, **Phones**, **Accessories**) drove the highest profits, while **Tables** (largest loss), **Bookcases**, and **Supplies** were the only 3 sub-categories out of 17 recording net losses.

---

## 5. Strategic Recommendations
1. **Enforce a 20% Standard Discount Cap:** Eliminate routine promotions $\ge 30\%$ and require managerial approval for discounts exceeding 20% to prevent margin erosion.
2. **Restructure Furniture Pricing & Bundling:** Audit shipping costs and supplier pricing for **Tables** and **Bookcases**, and shift from standalone price cuts to product bundling with high-margin furniture items like **Chairs** and **Furnishings**.
3. **Standardize Central Region Discount Policies:** Align promotional guardrails in the **Central** region with **West** and **East** benchmarks to recover lost profit margin without sacrificing sales volume.
4. **Target High-Margin Cross-Selling:** Focus retention campaigns on **Consumer** and **Corporate** segments by bundling top-performing technology accessories alongside core office purchases.

---

## 6. Repository Structure
```text
├── assets/
│   ├── page1_executive_overview.png
│   └── page2_discount_profitability.png
├── data/
│   └── apexmart_sales_cleaned.csv
├── powerbi/
│   ├── ApexMart_Retail_Dashboard.pbix
│   └── ApexMart_Retail_Dashboard.pdf
├── sql/
│   └── apexmart_exploratory_analysis.sql
└── README.md
