# Sales Dashboard - APEX Build Guide

## Architecture Overview

```
Page 1: Dashboard (Summary)
  ├── KPI Cards (Revenue, Orders, Customers, AOV)
  ├── Line Chart: Monthly Revenue Trend
  ├── Bar Chart: Top 10 Products  → drill-down → Page 4
  ├── Pie Chart: Revenue by Region → drill-down → Page 2
  └── Donut Chart: Orders by Status → drill-down → Page 2

Page 2: Order List (Filtered by region/status/month)
  └── Each row → click Order ID → Page 3

Page 3: Order Line Detail (single order)

Page 4: Product Detail (monthly trend for one product)
```

---

## STEP 1 — Run SQL Scripts

1. Log into APEX → **SQL Workshop → SQL Commands**
2. Run `01_create_tables.sql` — creates all 4 tables + 4 views
3. Run `02_sample_data.sql` — inserts 200 orders of realistic data
4. Verify: the final SELECT at the end should return row counts

---

## STEP 2 — Create the APEX Application

1. Go to **App Builder → Create**
2. Choose **New Application**
3. Name: `Sales Dashboard`
4. Theme Style: **Vita - Slate** (dark, looks great for dashboards)
5. Add a blank home page — we will configure it manually
6. Click **Create Application**

---

## STEP 3 — Page 1: Dashboard

### 3.1 Page Settings
- Page: `1`, Name: `Dashboard`
- Template: **Minimal (No Navigation)**
- Check ✅ **Page is the Home Page**

### 3.2 KPI Cards
Create 4 regions side-by-side (Grid Column = 3 each in a 12-col grid):

| Card | SQL Column |
|------|------------|
| Total Revenue | `TOTAL_REVENUE` |
| Total Orders | `TOTAL_ORDERS` |
| Customers | `TOTAL_CUSTOMERS` |
| Avg Order Value | `AVG_ORDER_VALUE` |

Use SQL from `03_apex_queries.sql` → *KPI Cards* section.

### 3.3 Revenue Trend — Line Chart
1. Add Region → **Chart** → Type: **Line**
2. Title: `Monthly Revenue Trend`
3. Add 3 series: Revenue / Cost / Gross Profit
4. SQL from `03_apex_queries.sql` → *Revenue Trend*
5. Label Column: `LABEL`; Value columns per series
6. Drill-down → set `P2_MONTH = &LABEL.` → redirect to Page 2

### 3.4 Top 10 Products — Horizontal Bar Chart
1. Add Region → **Chart** → Type: **Bar (Horizontal)**
2. SQL from `03_apex_queries.sql` → *Top 10 Products*
3. Link → Redirect to Page 4, set `P4_PRODUCT_ID = #PRODUCT_ID#`

### 3.5 Revenue by Region — Pie Chart
1. Add Region → **Chart** → Type: **Pie**
2. SQL from `03_apex_queries.sql` → *Revenue by Region*
3. Link → Redirect to Page 2, set `P2_REGION = #LABEL#`

### 3.6 Orders by Status — Donut Chart
1. Add Region → **Chart** → Type: **Donut**
2. SQL from `03_apex_queries.sql` → *Orders by Status*
3. Link → Redirect to Page 2, set `P2_STATUS = #LABEL#`

---

## STEP 4 — Page 2: Order List

1. Create Page → Blank, Number `2`, Name: `Orders`
2. Add hidden items: `P2_STATUS`, `P2_REGION`, `P2_MONTH`
3. Add Back Button → Page 1
4. Add **Interactive Report** using SQL from `03_apex_queries.sql` → *Page 2*
5. Make `ORDER_ID` a link → Page 3, set `P3_ORDER_ID = #ORDER_ID#`

---

## STEP 5 — Page 3: Order Line Detail

1. Create Page → Blank, Number `3`, Name: `Order Detail`
2. Add hidden item: `P3_ORDER_ID`
3. Add Back Button → Page 2
4. Add **Classic Report** using SQL from `03_apex_queries.sql` → *Page 3*
5. Format monetary columns: `$#,##0.00`

---

## STEP 6 — Page 4: Product Trend

1. Create Page → Blank, Number `4`, Name: `Product Trend`
2. Add hidden item: `P4_PRODUCT_ID`
3. Add Back Button → Page 1
4. Add page title query:
   ```sql
   SELECT product_name || ' — ' || category AS heading
   FROM   sd_products WHERE product_id = :P4_PRODUCT_ID
   ```
5. Add **Chart** (Bar) using SQL from `03_apex_queries.sql` → *Page 4*

---

## STEP 7 — Global Date Filter (Page 0)

Add on Page 0 so it applies everywhere:
- Items: `P0_DATE_FROM`, `P0_DATE_TO` (Date Picker)
- Add to all chart queries:
  ```sql
  AND ( :P0_DATE_FROM IS NULL OR o.order_date >= TO_DATE(:P0_DATE_FROM,'YYYY-MM-DD') )
  AND ( :P0_DATE_TO   IS NULL OR o.order_date <= TO_DATE(:P0_DATE_TO,  'YYYY-MM-DD') )
  ```
- Dynamic Action on date change → Refresh all chart regions

---

## STEP 8 — Styling Tips

| Goal | Setting |
|------|---------|
| Card colour | Template Options → Alternative Background |
| Chart palette | Appearance → Color Scheme → `Alta` |
| Responsive spacing | Page CSS: `.t-Region{margin-bottom:16px}` |
| Number format | Format Mask: `$999G999G990D00` |
| KPI icons | Font APEX: `fa-dollar`, `fa-shopping-cart` |
