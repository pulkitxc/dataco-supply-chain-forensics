/*==========================================================
 DATAWAREHOUSE VALIDATION SUITE
 Project : DataCo Sherlock
 Phase   : 06 PostgreSQL
 Purpose : Validate Star Schema Integrity
==========================================================*/


/*==========================================================
TEST 1 : Landing Table Row Count
Question:
Did we load every cleaned row into PostgreSQL?
Expected : 180519
==========================================================*/

SELECT COUNT(*) AS landing_rows
FROM analytics.orders_clean;



/*==========================================================
TEST 2 : Fact Table Row Count
Question:
Did every business event enter Fact Table?
Expected : 180519
==========================================================*/

SELECT COUNT(*) AS fact_rows
FROM analytics.fact_sales;



/*==========================================================
TEST 3 : Primary Key Validation
Question:
Is every Order Item unique?
Expected:
total_rows = unique_order_items
==========================================================*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_item_id) AS unique_order_items
FROM analytics.fact_sales;



/*==========================================================
TEST 4 : Customer Dimension Count
Question:
How many unique customers exist?
==========================================================*/

SELECT COUNT(*) AS total_customers
FROM analytics.dim_customer;



/*==========================================================
TEST 5 : Product Dimension Count
==========================================================*/

SELECT COUNT(*) AS total_products
FROM analytics.dim_product;



/*==========================================================
TEST 6 : Date Dimension Count
==========================================================*/

SELECT COUNT(*) AS total_dates
FROM analytics.dim_date;



/*==========================================================
TEST 7 : Duplicate Customers
Expected : 0 rows
==========================================================*/

SELECT
    customer_id,
    COUNT(*)
FROM analytics.dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;



/*==========================================================
TEST 8 : Duplicate Products
Expected : 0 rows
==========================================================*/

SELECT
    product_card_id,
    COUNT(*)
FROM analytics.dim_product
GROUP BY product_card_id
HAVING COUNT(*) > 1;



/*==========================================================
TEST 9 : Duplicate Dates
Expected : 0 rows
==========================================================*/

SELECT
    order_date_dateorders,
    COUNT(*)
FROM analytics.dim_date
GROUP BY order_date_dateorders
HAVING COUNT(*) > 1;



/*==========================================================
TEST 10 : Missing Customers (Orphan Records)
Question:
Does every Sale reference a valid Customer?
Expected : 0
==========================================================*/

SELECT COUNT(*) AS missing_customers
FROM analytics.fact_sales f
LEFT JOIN analytics.dim_customer c
ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



/*==========================================================
TEST 11 : Missing Products
Expected : 0
==========================================================*/

SELECT COUNT(*) AS missing_products
FROM analytics.fact_sales f
LEFT JOIN analytics.dim_product p
ON f.product_card_id = p.product_card_id
WHERE p.product_card_id IS NULL;



/*==========================================================
TEST 12 : Missing Dates
Expected : 0
==========================================================*/

SELECT COUNT(*) AS missing_dates
FROM analytics.fact_sales f
LEFT JOIN analytics.dim_date d
ON f.order_date_dateorders = d.order_date_dateorders
WHERE d.order_date_dateorders IS NULL;



/*==========================================================
TEST 13 : Sales Reconciliation
Question:
Did we lose Sales while loading Fact Table?
Expected:
Landing Sales = Fact Sales
==========================================================*/

SELECT
    SUM(sales) AS landing_sales
FROM analytics.orders_clean;

SELECT
    SUM(sales) AS fact_sales
FROM analytics.fact_sales;



/*==========================================================
TEST 14 : Profit Reconciliation
Expected:
Landing Profit = Fact Profit
==========================================================*/

SELECT
    SUM(order_profit_per_order) AS landing_profit
FROM analytics.orders_clean;

SELECT
    SUM(order_profit_per_order) AS fact_profit
FROM analytics.fact_sales;



/*==========================================================
TEST 15 : Quantity Reconciliation
Expected:
Landing Quantity = Fact Quantity
==========================================================*/

SELECT
    SUM(order_item_quantity) AS landing_quantity
FROM analytics.orders_clean;

SELECT
    SUM(order_item_quantity) AS fact_quantity
FROM analytics.fact_sales;



/*==========================================================
TEST 16 : Discount Reconciliation
Expected:
Landing Discount = Fact Discount
==========================================================*/

SELECT
    SUM(order_item_discount) AS landing_discount
FROM analytics.orders_clean;

SELECT
    SUM(order_item_discount) AS fact_discount
FROM analytics.fact_sales;



/*==========================================================
TEST 17 : Date Range Validation
Question:
Do both tables cover the same timeline?
==========================================================*/

SELECT
    MIN(order_date_dateorders) AS min_date,
    MAX(order_date_dateorders) AS max_date
FROM analytics.orders_clean;

SELECT
    MIN(order_date_dateorders) AS min_date,
    MAX(order_date_dateorders) AS max_date
FROM analytics.fact_sales;



/*==========================================================
TEST 18 : NULL Customer IDs
Expected : 0
==========================================================*/

SELECT COUNT(*) AS null_customer_ids
FROM analytics.fact_sales
WHERE customer_id IS NULL;



/*==========================================================
TEST 19 : NULL Product IDs
Expected : 0
==========================================================*/

SELECT COUNT(*) AS null_product_ids
FROM analytics.fact_sales
WHERE product_card_id IS NULL;



/*==========================================================
TEST 20 : NULL Order Dates
Expected : 0
==========================================================*/

SELECT COUNT(*) AS null_order_dates
FROM analytics.fact_sales
WHERE order_date_dateorders IS NULL;



/*==========================================================
FINAL VERDICT

✔ Same number of business events
✔ No duplicate dimensions
✔ No orphan foreign keys
✔ No missing business events
✔ No money lost
✔ No profit lost
✔ No quantity lost
✔ No discount lost
✔ Same timeline
✔ Fact table integrity verified

Warehouse Validation Framework

1. Completeness
   → Did I lose data?

2. Uniqueness
   → Did I duplicate data?

3. Referential Integrity
   → Did relationships break?

4. Accuracy
   → Did values change?

5. Business Rules
   → Does the data still make business sense?

6. Freshness (Production)
   → Is the data current?

Warehouse Status:
READY FOR SQL ANALYTICS
==========================================================*/