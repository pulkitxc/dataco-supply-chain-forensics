-- ① Order-item volume
-- Business question

-- How much transaction-level activity is represented in the warehouse?

-- SELECT COUNt(*)
-- FROM analytics.fact_sales

-- How much orders our warehouse sold 

-- SELECT COUNt(DISTINCT order_id)
-- FROM analytics.fact_sales

-- ② Total sales

-- SELECT sum(sales)
-- from analytics.fact_sales

-- ③ Total profit
-- SELECT SUM(order_profit_per_order) 
-- from analytics.fact_sales;

-- Investigation 01 baseline
-- Unique orders: 65,752
-- Order-line items: 180,519
-- Total sales: $36,784,734.31
-- Total profit: $3,966,902.97
-- Profit margin: ~10.79%

-- WITH order_size as (
-- SELECT 
-- order_id,
-- COUNT (*) as line_items 
-- FROM analytics.fact_sales
-- group by order_id
-- )

-- SELECT AVG(line_items )
-- FROM order_size

-- Average line items/order: ~2.75

-- WITH order_profitability AS (
-- 	SELECT order_id , 
-- 	SUM(sales) as total_sales,
-- 	SUM(order_profit_per_order) AS total_profit
-- 	FROM analytics.fact_sales
-- 	GROUP BY order_id
-- )

-- SELECT * 
-- FROM order_profitability;

-- WITH order_profitability AS (
--     SELECT
--         order_id,
--         SUM(sales) AS total_sales,
--         SUM(order_profit_per_order) AS total_profit
--     FROM analytics.fact_sales
--     GROUP BY order_id
-- ),
-- classified_orders AS (
--     SELECT
--         order_id,
--         total_sales,
--         total_profit,
--         CASE
--             WHEN total_profit > 0 THEN 'Profitable'
--             WHEN total_profit = 0 THEN 'Break-even'
--             ELSE 'Loss-making'
--         END AS profitability_status
--     FROM order_profitability
-- )
-- SELECT
--     profitability_status,
--     COUNT(*) AS order_count
-- FROM classified_orders
-- GROUP BY profitability_status;

-- WITH order_profitability AS (
--     SELECT
--         order_id,
--         SUM(sales) AS total_sales,
--         SUM(order_profit_per_order) AS total_profit
--     FROM analytics.fact_sales
--     GROUP BY order_id
-- ),
-- classified_orders AS (
--     SELECT
--         order_id,
--         total_sales,
--         total_profit,
--         CASE
--             WHEN total_profit > 0 THEN 'Profitable'
--             WHEN total_profit = 0 THEN 'Break-even'
--             ELSE 'Loss-making'
--         END AS profitability_status
--     FROM order_profitability
-- )
-- SELECT
--     profitability_status,
--     COUNT(*) AS order_count,
--     SUM(total_sales) AS total_sales,
--     SUM(total_profit) AS total_profit
-- FROM classified_orders
-- GROUP BY profitability_status;

-- WITH order_profitability AS (
--     SELECT
--         order_id,
--         SUM(sales) AS total_sales,
--         SUM(order_profit_per_order) AS total_profit
--     FROM analytics.fact_sales
--     GROUP BY order_id
-- ),
-- loss_orders AS (
--     SELECT
--         order_id,
--         total_sales,
--         total_profit,
--         (total_profit / NULLIF(total_sales, 0)) * 100 AS profit_margin_pct
--     FROM order_profitability
--     WHERE total_profit < 0
-- )
-- SELECT
--     COUNT(*)                                                        AS loss_order_count,
--     ROUND(MIN(profit_margin_pct)::numeric, 2)                       AS worst_margin_pct,
--     ROUND(MAX(profit_margin_pct)::numeric, 2)                       AS best_margin_pct,
--     ROUND(AVG(profit_margin_pct)::numeric, 2)                       AS avg_margin_pct,
--     ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY profit_margin_pct)::numeric, 2) AS median_margin_pct,
--     ROUND(MIN(total_profit)::numeric, 2)                            AS deepest_loss_dollars,
--     ROUND(MAX(total_profit)::numeric, 2)                            AS smallest_loss_dollars,
--     ROUND(AVG(total_profit)::numeric, 2)                            AS avg_loss_dollars,
--     ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_profit)::numeric, 2) AS median_loss_dollars,
--     ROUND(SUM(total_profit)::numeric, 2)                            AS total_loss_dollars
-- FROM loss_orders;

-- SELECT
--     order_status,
--     COUNT(DISTINCT order_id) AS orders,
--     ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit
-- FROM analytics.fact_sales
-- GROUP BY order_status
-- ORDER BY total_profit ASC;

-- SELECT
--     COUNT(*) AS negative_lines,
--     ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_negative_profit,
--     ROUND(AVG(order_profit_per_order)::numeric, 2) AS avg_negative_profit,
--     ROUND(AVG(order_item_discount_rate)::numeric, 4) AS avg_discount_rate,
--     ROUND(AVG(order_item_quantity)::numeric, 2) AS avg_quantity
-- FROM analytics.fact_sales
-- WHERE order_profit_per_order < 0;

-- SELECT
--     CASE WHEN order_profit_per_order < 0 THEN 'Negative line' ELSE 'Positive line' END AS line_type,
--     COUNT(*) AS line_count,
--     ROUND(AVG(order_item_discount_rate)::numeric, 4) AS avg_discount_rate,
--     ROUND(AVG(order_item_profit_ratio)::numeric, 4) AS avg_profit_ratio,
--     ROUND(AVG(order_item_quantity)::numeric, 2) AS avg_quantity
-- FROM analytics.fact_sales
-- GROUP BY 1;

-- SELECT
--     dp.category_name,
--     COUNT(*) AS line_count,
--     ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2) AS total_profit,
--     ROUND(AVG(fs.order_item_profit_ratio)::numeric, 4) AS avg_profit_ratio,
--     ROUND(AVG(fs.order_item_discount_rate)::numeric, 4) AS avg_discount_rate
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_product dp
--     ON fs.product_card_id = dp.product_card_id
-- GROUP BY dp.category_name
-- ORDER BY total_profit ASC;

-- SELECT
--     dp.product_name,
--     dp.category_name,
--     COUNT(*) AS line_count,
--     ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2) AS total_profit,
--     ROUND(AVG(fs.order_item_profit_ratio)::numeric, 4) AS avg_profit_ratio
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_product dp
--     ON fs.product_card_id = dp.product_card_id
-- GROUP BY dp.product_name, dp.category_name
-- ORDER BY total_profit ASC
-- LIMIT 30;

-- SELECT
--     order_profit_per_order,
--     benefit_per_order,
--     order_item_profit_ratio,
--     sales,
--     order_item_total,
--     order_item_product_price,
--     order_item_quantity,
--     order_item_discount
-- FROM analytics.fact_sales
-- WHERE order_profit_per_order < 0
-- ORDER BY order_profit_per_order ASC
-- LIMIT 20;

-- WITH order_value AS (
--     SELECT
--         order_id,
--         SUM(sales) AS order_sales
--     FROM analytics.fact_sales
--     GROUP BY order_id
-- )
-- SELECT
--     COUNT(*)                                                       AS order_count,
--     ROUND(AVG(order_sales)::numeric, 2)                            AS avg_order_value,
--     ROUND(MIN(order_sales)::numeric, 2)                            AS min_order_value,
--     ROUND(MAX(order_sales)::numeric, 2)                            AS max_order_value,
--     ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY order_sales)::numeric, 2) AS p25,
--     ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY order_sales)::numeric, 2) AS median,
--     ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY order_sales)::numeric, 2) AS p75,
--     ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY order_sales)::numeric, 2) AS p95,
--     ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY order_sales)::numeric, 2) AS p99
-- FROM order_value;


-- ================================================================
-- INVESTIGATION 01 — FINAL REPORT
-- Overall Business Performance
-- DataCo Sherlock — PostgreSQL Investigation
-- ================================================================

----------------------------------------------------------------
-- SECTION 1 — BASELINE
-- ----------------------------------------------------------------

-- Unique orders ............ 65,752
-- Order-line items ......... 180,519
-- Avg lines per order ...... 2.75
-- Total sales .............. $36,784,734.31
-- Total profit ............. $3,966,902.97
-- Overall profit margin .... 10.79%
-- Avg order value .......... $559.45
-- Median order value ....... $504.89

-- ----------------------------------------------------------------
-- SECTION 2 — BRANCH 1: ORDER STRUCTURE
-- ----------------------------------------------------------------

-- Question: Is 2.75 lines/order representative?

-- Finding:
--   - Average = 2.75 lines per order
--   - Distribution not fully verified (noted, not blocking)

-- ----------------------------------------------------------------
-- SECTION 3 — BRANCH 2: SALES -> PROFIT RELATIONSHIP
-- ----------------------------------------------------------------

-- FINDING #1 — 21% of orders lose money

--   Profitability    Orders      Sales              Profit
--   ------------------------------------------------------------
--   Profitable       51,722      $28,669,786.94     +$6,582,106.76
--   Loss-making      13,908      $8,088,899.60      -$2,615,203.79
--   Break-even       122         $26,047.77         $0.00
--   ------------------------------------------------------------
--   Total            65,752      $36,784,734.31     $3,966,902.97

--   Key numbers:
--     - 21.15% of orders are loss-making
--     - Loss-making orders represent 22.0% of sales
--     - They consume 39.7% of gross profit from profitable orders


-- FINDING #2 — Losses are DEEP, not marginal

--   Metric                          Value
--   ------------------------------------------------------------
--   Median loss margin              -22.60%
--   Avg loss margin                 -37.78%
--   Worst single order margin       -269.50%
--   Median loss per order           -$108.79
--   Avg loss per order              -$188.04
--   Deepest single loss             -$4,325.85

--   Interpretation:
--     - Typical bad order loses ~$109 (22.6% of sales)
--     - Average is worse than median -> catastrophic tail exists
--     - Worst case lost 2.7x the sale price


-- FINDING #3 — Negative lines are widespread

--   Line Type        Count       Avg Disc    Avg Profit Ratio   Avg Qty
--   ----------------------------------------------------------------------
--   Positive lines   146,735     10.15%      +29.23%            2.13
--   Negative lines   33,784      10.22%      -62.50%            2.13

--   Key insight:
--     - Negative lines lose -$3,883,547.35 total
--     - Discount rate is identical (10.2%)
--     - Quantity is identical (2.13)


-- SUSPECTS ELIMINATED

--   Hypothesis                      Verdict    Evidence
--   ----------------------------------------------------------------------
--   Discount caused losses          KILLED     Neg 10.22% vs Pos 10.15%
--   Quantity caused losses          KILLED     Both 2.13 avg units
--   Order status caused losses      KILLED     All 9 statuses profitable
--   Category caused losses          KILLED     All 50 categories profitable
--   Product caused losses           KILLED     Only 3 products negative
--                                              totaling -$1,390 (0.036%)


-- FINDING #4 — Schema Issue Flagged

--   Observation:
--     - order_profit_per_order = benefit_per_order (identical)
--     - Raw negative lines show impossible ratios (-1.5 to -2.55)
--     - Loss exceeds sale price (e.g., -$4,274.98 on $1,999.99 sale)

--   Hypothesis:
--     order_profit_per_order may be an ORDER-LEVEL measure repeated
--     on every line item. Summing at line level would inflate totals.

--   Status: FLAGGED for data-quality follow-up. Not a business finding.

-- ----------------------------------------------------------------
-- SECTION 4 — BRANCH 3: ORDER VALUE STRUCTURE
-- ----------------------------------------------------------------

-- FINDING #5 — Order value distribution

--   Percentile    Value
--   ------------------------------------------------------------
--   Min           $9.99
--   P25           $265.96
--   Median        $504.89
--   Avg           $559.45
--   P75           $799.95
--   P95           $1,199.94
--   P99           $1,500.00
--   Max           $3,449.91

--   Interpretation:
--     - Avg ($559) vs median ($505) gap = only 10% -> mildly right-skewed
--     - Middle 50% of orders fall between $266 and $800
--     - No "whale problem" - business is middle-heavy
--     - $1,500 appears as a hard anchor (P99 = exactly $1,500)
--       -> flagged for later
--     - Same $1,500 shows up in the worst negative lines

-- ----------------------------------------------------------------
-- SECTION 5 — WHAT WE DID NOT FIND
-- ----------------------------------------------------------------

-- We could NOT identify a single dimension that owns the loss:

--   - Not discount
--   - Not quantity
--   - Not order status
--   - Not category
--   - Not product
--   - Not order size

-- The loss is scattered across every dimension we checked.

-- This means:
--   1. Loss is structural at line-item economics level
--   2. OR it is a recording artifact (see Finding #4)

-- ----------------------------------------------------------------
-- SECTION 6 — DASHBOARD CANDIDATES
-- ----------------------------------------------------------------

-- INCLUDE IN DASHBOARD

--   KPI                          Value
--   ------------------------------------------------------------
--   Total sales                  $36.78M
--   Total profit                 $3.97M
--   Overall margin               10.79%
--   Order count                  65,752
--   Line item count              180,519
--   Avg lines/order              2.75
--   Avg order value              $559
--   Median order value           $505
--   % loss-making orders         21.15%
--   Total loss magnitude         -$2.62M

-- CONDITIONAL (only if driver found later)

--   KPI                          Condition
--   ------------------------------------------------------------
--   Loss depth (median -22.6%)   Only if Inv 07/08 finds a driver
--   Negative line count          Only if schema issue resolved

-- DO NOT INCLUDE

--   Item                         Reason
--   ------------------------------------------------------------
--   Discount/loss correlation    Killed - no signal
--   Category-level loss          Killed - all profitable
--   Order status loss            Killed - all profitable
--   Schema bug details           Internal data-quality note

-- ----------------------------------------------------------------
-- SECTION 7 — OPEN THREADS FOR LATER
-- ----------------------------------------------------------------

-- 1. Schema issue: order_profit_per_order may be order-level repeated
--    on lines -> needs verification

-- 2. $1,500 anchor: appears at P99 and in worst negative lines
--    -> investigate in Investigation 07 (Discount)

-- 3. Loss distribution not fully verified: median -22.6% but
--    avg -37.8% -> the tail deserves a look in Investigation 08
--    (Cross-Dimension)

-- ----------------------------------------------------------------
-- SECTION 8 — FINAL VERDICT
-- ----------------------------------------------------------------

-- The business is profitable at 10.79% margin, but ~1 in 5 orders
-- loses money. Those losses are deep (median -22.6% margin),
-- widespread, and not explained by any single dimension we tested.

-- The loss is structural at the line-item level. Further root-cause
-- investigation belongs in Investigations 07 (Discount) and 08
-- (Cross-Dimension).

-- ================================================================
-- INVESTIGATION 01 — STATUS: COMPLETE
-- ================================================================

-- NEXT -> Investigation 02: Sales / Profit Trend Over Time
-- ================================================================

-- SELECT
--     dd.order_year,
--     dd.order_month,
--     COUNT(DISTINCT fs.order_id)                          AS orders,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_date dd
--     ON fs.order_date_dateorders = dd.order_date_dateorders
-- GROUP BY dd.order_year, dd.order_month
-- ORDER BY dd.order_year, dd.order_month;

-- SELECT
--     MAX(order_date_dateorders) AS last_order_date,
--     MIN(order_date_dateorders) AS first_order_date
-- FROM analytics.fact_sales;

-- SELECT
--     dd.order_year,
--     dd.order_month,
--     COUNT(*) / COUNT(DISTINCT fs.order_id)::numeric AS avg_lines_per_order
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_date dd
--     ON fs.order_date_dateorders = dd.order_date_dateorders
-- WHERE dd.order_year >= 2017
-- GROUP BY dd.order_year, dd.order_month
-- ORDER BY dd.order_year, dd.order_month;

-- SELECT
--     order_date_dateorders::date AS order_day,
--     COUNT(DISTINCT order_id)    AS orders,
--     ROUND(SUM(sales)::numeric, 2) AS sales
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders >= '2017-09-01'
-- GROUP BY order_day
-- ORDER BY order_day;

-- SELECT
--     dd.order_year,
--     ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2) AS total_profit,
--     COUNT(DISTINCT fs.order_id) AS orders
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_date dd
--     ON fs.order_date_dateorders = dd.order_date_dateorders
-- WHERE dd.order_date_dateorders < '2017-10-01'
-- GROUP BY dd.order_year
-- ORDER BY dd.order_year;

-- ================================================================
-- INVESTIGATION 02 — FINAL REPORT
-- Sales / Profit Trend Over Time
-- DataCo Sherlock — PostgreSQL Investigation
-- ================================================================

-- ----------------------------------------------------------------
-- SECTION 1 — QUESTION
-- ----------------------------------------------------------------

-- How do sales and profit move over time?
-- Do they track each other, or diverge?
-- Are there strong/weak periods?

-- ----------------------------------------------------------------
-- SECTION 2 — GRAIN & SOURCE
-- ----------------------------------------------------------------

-- Grain:   Month
-- Source:  fact_sales + dim_date
-- Period:  2015-01-01 to 2018-01-31 (raw)
-- Valid:   2015-01-01 to 2017-09-30 (after data quality check)

-- ----------------------------------------------------------------
-- SECTION 3 — MONTHLY OVERVIEW (raw data)
-- ----------------------------------------------------------------

-- The monthly query returned 37 months of data.
-- Full monthly detail is retained in the working file.

-- Headline pattern:

--   2015-01 to 2017-09:  stable
--     ~1,700-1,800 orders/month
--     ~$1.0-1.1M sales/month
--     ~10-12% margin

--   2017-10 to 2018-01:  structural break
--     orders fixed at ~68-69/day (alternating)
--     avg lines/order = 1.0 (exactly)
--     sales collapse progressively
--     margin stays ~10-13%

-- ----------------------------------------------------------------
-- SECTION 4 — FINDINGS
-- ----------------------------------------------------------------

-- FINDING #1 — Business is FLAT 2015-2016

--   Metric        2015           2016           Change
--   ------------------------------------------------------------
--   Sales         $12,340,831.19 $12,303,817.08  -0.3%
--   Profit        $ 1,318,856.90 $ 1,310,119.07  -0.7%
--   Orders            20,904         20,859      -0.2%
--   Margin            10.69%         10.65%      -0.04pp

--   Interpretation:
--     2015 and 2016 are statistically identical.
--     Flat business. No growth, no decline.


-- FINDING #2 — Slight GROWTH in 2017 (annualized)

--   Metric        2016 actual    2017 annualized   Change
--   ------------------------------------------------------------
--   Sales         $12,303,817    $12,804,816        +4.1%
--   Profit        $ 1,310,119    $ 1,409,340        +7.6%
--   Orders            20,859         20,781         -0.4%
--   Margin            10.65%         11.01%        +0.36pp

--   Note: 2017 data covers Jan-Sep only (9 months),
--         annualized by multiplying by 12/9.

--   Interpretation:
--     Same number of orders, but higher sales per order,
--     higher profit per order, and higher margin.
--     Business is becoming slightly more profitable
--     without acquiring more customers.


-- FINDING #3 — STRUCTURAL BREAK at 2017-10

--   Evidence:
--     - avg lines/order drops from ~3.0 to 1.0 (exactly)
--     - daily order count alternates 68/69 (synthetic pattern)
--     - sales values repeat across days
--     - sales per order drops from ~$660 to ~$156

--   Verdict:
--     The last 4 months (Oct 2017 - Jan 2018) are
--     synthetic / placeholder data, NOT real transactions.

--   Implication:
--     All trend analysis and dashboard visuals must
--     use 2015-01-01 to 2017-09-30 only.


-- FINDING #4 — Margin is STABLE

--   Margin by year:
--     2015:  10.69%
--     2016:  10.65%
--     2017:  11.01% (annualized)

--   Interpretation:
--     No margin deterioration over time.
--     No evidence of "sales up, profit down" pattern.
--     Slight margin improvement in 2017.

-- ----------------------------------------------------------------
-- SECTION 5 — WHAT WE DID NOT FIND
-- ----------------------------------------------------------------

--   - No seasonality tested (month-of-year pattern not run)
--   - No regional / product / market breakdown (belongs to Inv 03+)
--   - No "sales rise but profit falls" divergence detected
--   - No decline detected in the real data period

-- ----------------------------------------------------------------
-- SECTION 6 — DASHBOARD CANDIDATES
-- ----------------------------------------------------------------

-- INCLUDE

--   KPI                                Value
--   ------------------------------------------------------------
--   Sales by year                      2015 / 2016 / 2017*
--   Profit by year                     2015 / 2016 / 2017*
--   Margin by year                     10.69% / 10.65% / 11.01%
--   Monthly sales trend                2015-01 to 2017-09
--   Monthly profit trend               2015-01 to 2017-09
--   YoY growth                         ~flat 2015-2016, +4% 2017
--                                      (*2017 annualized)

-- DO NOT INCLUDE

--   Item                               Reason
--   ------------------------------------------------------------
--   Oct 2017 - Jan 2018 trend          Synthetic / placeholder
--   "Sales collapse" narrative         False pattern from data
--   Daily trend                        Too noisy, not decision-useful

-- ----------------------------------------------------------------
-- SECTION 7 — OPEN THREADS
-- ----------------------------------------------------------------

-- 1. Seasonality — month-of-year pattern not tested.
--    May be worth a quick check later.

-- 2. Annualized 2017 — assumes remaining 3 months
--    would have matched the Jan-Sep pattern.
--    Reasonable, but worth noting as an assumption.

-- ----------------------------------------------------------------
-- SECTION 8 — FINAL VERDICT
-- ----------------------------------------------------------------

-- The business is mature and stable:

--   - 2015-2016: flat, no growth, no decline
--   - 2017: slight growth in sales (+4%) and profit (+7%)
--     with the same number of orders
--   - Margin is stable at ~10.7-11.0%
--   - No deterioration pattern detected

-- The final 4 months of the dataset (Oct 2017 - Jan 2018)
-- are synthetic / placeholder data and must be excluded
-- from all analysis and dashboards.

-- ================================================================
-- INVESTIGATION 02 — STATUS: COMPLETE
-- ================================================================

-- NEXT -> Investigation 03: Market & Regional Performance

-- ================================================================
-- SELECT
--     fs.market,
--     COUNT(DISTINCT fs.order_id)                          AS orders,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_date dd
--     ON fs.order_date_dateorders = dd.order_date_dateorders
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY fs.market
-- ORDER BY total_sales DESC;

-- SELECT
--     fs.order_region,
--     COUNT(DISTINCT fs.order_id)                          AS orders,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_date dd
--     ON fs.order_date_dateorders = dd.order_date_dateorders
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY fs.order_region

-- SELECT
--     fs.market,
--     dd.order_year,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_date dd
--     ON fs.order_date_dateorders = dd.order_date_dateorders
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY fs.market, dd.order_year
-- ORDER BY fs.market, dd.order_year;

-- SELECT
--     EXTRACT(YEAR FROM order_date_dateorders) AS year,
--     COUNT(*) AS rows_in_fact
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders < '2017-10-01'
-- GROUP BY year
-- ORDER BY year;

-- SELECT
--     EXTRACT(YEAR FROM order_date_dateorders) AS order_year,
--     COUNT(DISTINCT order_id)                 AS orders,
--     ROUND(SUM(sales)::numeric, 2)            AS total_sales,
--     ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
--     ROUND((SUM(order_profit_per_order) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS margin_pct
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders < '2017-10-01'
-- GROUP BY EXTRACT(YEAR FROM order_date_dateorders)
-- ORDER BY order_year;
-- -- ORDER BY total_sales DESC;

-- SELECT
--     market,
--     EXTRACT(YEAR FROM order_date_dateorders) AS order_year,
--     COUNT(DISTINCT order_id)                 AS orders,
--     ROUND(SUM(sales)::numeric, 2)            AS total_sales,
--     ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
--     ROUND((SUM(order_profit_per_order) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS margin_pct
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders < '2017-10-01'
-- GROUP BY market, EXTRACT(YEAR FROM order_date_dateorders)
-- ORDER BY market, order_year;

-- ================================================================
-- INVESTIGATION 03 — FINAL REPORT
-- Market & Regional Performance
-- DataCo Sherlock — PostgreSQL Investigation
-- ================================================================

-- ----------------------------------------------------------------
-- SECTION 1 — QUESTION
-- ----------------------------------------------------------------

-- Which markets generate the most sales?
-- Which markets generate the most profit?
-- Are there high-sales but low-profit markets?
-- Which regions perform poorly?
-- Are there geographic profitability differences?
-- Does any market show growing sales but flat/falling profit?

-- ----------------------------------------------------------------
-- SECTION 2 — GRAIN & SOURCE
-- ----------------------------------------------------------------

-- Grain:   Market, Region (whole-period)
-- Source:  fact_sales + dim_date
-- Period:  2015-01-01 to 2017-09-30 (real data only)

-- ----------------------------------------------------------------
-- SECTION 3 — FINDINGS
-- ----------------------------------------------------------------

-- FINDING #1 — MARKET LEVEL

--   Market          Orders    Total Sales       Total Profit     Margin
--   ---------------------------------------------------------------------
--   LATAM           17,181    $10,277,612.64    $1,123,321.61    10.93%
--   Europe          15,778    $ 9,596,779.18    $1,036,634.09    10.80%
--   Pacific Asia    11,957    $ 7,012,891.55    $  709,644.37    10.12%
--   USCA             8,579    $ 5,066,528.61    $  564,313.78    11.14%
--   Africa           3,854    $ 2,294,452.88    $  252,071.18    10.99%

--   Sales range:  $2.29M – $10.28M (4.5x spread)
--   Margin range: 10.12% – 11.14% (1.02pp)

--   LATAM leads sales ($10.28M).
--   Africa smallest ($2.29M).
--   No market is broken.


-- FINDING #2 — REGION LEVEL

--   Region               Orders    Sales        Profit      Margin
--   ---------------------------------------------------------------------
--   Central America        9,396   $5,665,712   $616,342    10.88%
--   Western Europe         8,395   $5,152,093   $551,027    10.70%
--   South America          4,979   $2,960,881   $335,154    11.32%
--   Northern Europe        3,114   $1,878,913   $204,373    10.88%
--   Southern Europe        2,977   $1,791,507   $201,517    11.25%
--   Oceania                2,926   $1,720,379   $171,873     9.99%
--   Caribbean              2,806   $1,651,019   $171,826    10.41%
--   West of USA            2,667   $1,571,416   $164,941    10.50%
--   Southeast Asia         2,607   $1,538,177   $157,185    10.22%
--   East of USA            2,323   $1,371,112   $156,263    11.40%
--   South Asia             2,216   $1,299,776   $135,980    10.46%
--   West Asia              2,022   $1,174,672   $118,815    10.11%
--   Eastern Asia           2,002   $1,170,048   $112,746     9.64%
--   US Center              1,935   $1,151,356   $131,094    11.39%
--   South of USA           1,345   $  785,784   $ 88,115    11.21%
--   Eastern Europe         1,292   $  774,267   $ 79,717    10.30%
--   West Africa            1,223   $  727,951   $ 80,030    10.99%
--   North Africa           1,064   $  634,752   $ 64,600    10.18%
--   East Africa              613   $  376,235   $ 43,168    11.47%
--   Central Africa           556   $  327,263   $ 33,447    10.22%
--   Southern Africa          398   $  228,252   $ 30,826    13.51%
--   Canada                   309   $  186,861   $ 23,901    12.79%
--   Central Asia             184   $  109,840   $ 13,045    11.88%

--   Sales range:  $109K – $5.67M (52x spread)
--   Margin range: 9.64% – 13.51% (3.87pp)

--   Biggest region:  Central America ($5.67M)
--   Smallest region: Central Asia ($109K)
--   Worst margin:    Eastern Asia (9.64%)
--   Best margin:     Southern Africa (13.51%)


-- FINDING #3 — NO BROKEN MARKET OR REGION

--   Every market and region is profitable.
--   Lowest margin: Eastern Asia (9.64%).
--   Highest margin: Southern Africa (13.51%).
--   No region is losing money.
--   No region is "dangerous."
--   No high-sales / low-profit market exists.


-- FINDING #4 — GEOGRAPHIC UNIFORMITY

--   Market margins: 10.12% – 11.14% (1.02pp spread)
--   Region margins:  9.64% – 13.51% (3.87pp spread)

--   Margins are unusually uniform across all geographies.
--   Held at both grains, so confirmed real (not artifact).

--   Possible explanations:
--     - Uniform global pricing/cost model
--     - DataCo-specific business structure
--     - Schema artifact (low confidence)

--   Implication:
--     No region needs fixing.
--     No geographic profitability strategy needed.


-- FINDING #5 — GROWTH-BY-MARKET ANALYSIS IMPOSSIBLE

--   We attempted market x year analysis. Result:

--     Market        2015      2016      2017 (Jan-Sep)
--     --------------------------------------------------------
--     Africa            0     3,445       409
--     Europe        8,315     1,274     6,189
--     LATAM         8,598         0     8,583
--     Pacific Asia  3,991     7,602       364
--     USCA              0     8,538        41

--   Pattern:
--     Each market has 1-2 strong years and 1-2 missing/tiny years.
--     Annual totals still add up (no rows lost).
--     Market labels are NOT consistent across years.

--   Implication:
--     Growth-by-market over time cannot be analyzed with this data.
--     Market-level analysis is only reliable at the whole-period level.

--   Note: This is a data quality issue, not a business finding.
--         Flagged for data-quality follow-up.


-- FINDING #6 — INVESTIGATION 02 RE-VERIFIED

--   The 2017-10 synthetic-data break triggered a re-check of
--   Investigation 02's annual figures.

--   Re-run without dim_date join:
--     2015:  20,904 orders  |  $12,340,831  |  $1,318,857  |  10.69%
--     2016:  20,859 orders  |  $12,303,817  |  $1,310,119  |  10.65%
--     2017:  15,586 orders  |  $ 9,603,617  |  $1,057,009  |  11.01%

--   Matches Investigation 02.
--   Investigation 02's annual findings are CONFIRMED.

-- ----------------------------------------------------------------
-- SECTION 4 — WHAT WE DID NOT FIND
-- ----------------------------------------------------------------

--   - No high-sales / low-profit market
--   - No broken region
--   - No geographic margin problem
--   - No regional deterioration over time (untestable)
--   - No country-level analysis (not needed)

-- ----------------------------------------------------------------
-- SECTION 5 — DASHBOARD CANDIDATES
-- ----------------------------------------------------------------

-- INCLUDE

--   KPI                              Value
--   ------------------------------------------------------------
--   Sales by market                  LATAM / Europe / Pacific
--                                    Asia / USCA / Africa
--   Sales by region                  Top 10-15 regions
--   Margin by market                 10.12% – 11.14%
--   Margin by region                 9.64% – 13.51%
--   Geographic concentration         LATAM + Europe = ~54%

-- DO NOT INCLUDE

--   Item                             Reason
--   ------------------------------------------------------------
--   Market growth over time          Data unreliable
--   "Broken market" narrative        No such market exists
--   Country-level breakdown          Diminishing returns

-- ----------------------------------------------------------------
-- SECTION 6 — OPEN THREADS
-- ----------------------------------------------------------------

--   1. Market labels unstable across years.
--      Flagged for data-quality follow-up.
--      Not blocking other investigations.

--   2. Geographic uniformity is unusual.
--      Possible schema artifact or genuine business model.
--      Could revisit in Investigation 08.

-- ----------------------------------------------------------------
-- SECTION 7 — FINAL VERDICT
-- ----------------------------------------------------------------

-- The business is geographically unbalanced by VOLUME but
-- remarkably UNIFORM by MARGIN.

--   - LATAM + Europe = ~54% of total sales
--   - Africa is smallest market by far
--   - Every market and region is profitable
--   - Margin range: 9.64% – 13.51% (region level)
--   - No broken market. No dangerous region.

-- There is no geographic profitability problem to fix.

-- ================================================================
-- INVESTIGATION 03 — STATUS: COMPLETE
-- ================================================================

-- NEXT -> Investigation 04: Product & Category Performance
-- ================================================================

-- SELECT
--     dp.category_name,
--     COUNT(*)                                             AS line_count,
--     COUNT(DISTINCT fs.order_id)                          AS orders,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_product dp
--     ON fs.product_card_id = dp.product_card_id
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY dp.category_name
-- ORDER BY total_sales DESC;

-- SELECT
--     dp.product_name,
--     dp.category_name,
--     COUNT(*)                                             AS line_count,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_product dp
--     ON fs.product_card_id = dp.product_card_id
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY dp.product_name, dp.category_name
-- ORDER BY total_sales DESC
-- LIMIT 30;

-- ================================================================
-- INVESTIGATION 04 — FINAL REPORT
-- Product & Category Performance
-- DataCo Sherlock — PostgreSQL Investigation
-- ================================================================

-- ----------------------------------------------------------------
-- SECTION 1 — QUESTION
-- ----------------------------------------------------------------

-- Which products generate the highest sales?
-- Which products generate the highest profit?
-- Which categories generate the highest sales/profit?
-- Are there high-sales / weak-profit products?
-- Are there loss-making products?
-- Are there category-level profitability differences?

-- ----------------------------------------------------------------
-- SECTION 2 — GRAIN & SOURCE
-- ----------------------------------------------------------------

-- Grain:   Category, then Product
-- Source:  fact_sales + dim_product
-- Period:  2015-01-01 to 2017-09-30 (real data only)

-- ----------------------------------------------------------------
-- SECTION 3 — FINDINGS (LAYER 1)
-- ----------------------------------------------------------------

-- FINDING #1 — CATEGORY LEVEL

--   Most categories:       ~10-11% margin (normal)
--   Big-volume categories: all ~10-11% (uniform)
--   Tiny anomalies:
--     Basketball:          -2.64%   ($19K sales)
--     Strength Training:    1.55%   ($37K sales)
--     "As Seen on TV!":     3.47%   ($20K sales)

--   Top categories by sales:
--     Fishing              $6,922,854   margin 10.90%
--     Cleats               $4,424,744   margin 11.16%
--     Camping & Hiking     $4,113,926   margin 10.37%
--     Cardio Equipment     $3,688,444   margin 10.35%
--     Women's Apparel      $3,143,900   margin 11.14%

--   Highest-margin categories (small volume):
--     Golf Bags & Carts    $10,369      margin 17.46%
--     Fitness Accessories  $33,801      margin 14.88%
--     Soccer               $26,477      margin 14.74%
--     Baseball & Softball  $94,057      margin 13.57%

--   Interpretation:
--     No meaningful category-level loss.
--     Category margins are UNIFORM, like markets and regions.
--     The 3 tiny anomalies are small-sample noise.


-- FINDING #2 — PRODUCT LEVEL (top 30 by sales)

--   Top products are dominated by:
--     - Field & Stream Sportsman 16 Gun Fire Safe  $6.92M  10.90%
--     - Perfect Fitness Perfect Rip Deck           $4.41M  11.17%
--     - Diamondback Women's Serene Bike            $4.11M  10.37%
--     - Nike Men's Free 5.0+ Running Shoe          $3.66M  10.34%
--     - Nike Men's Dri-FIT Victory Golf Polo       $3.14M  11.14%

--   Product margins range: 6.97% to 14.58%
--   No high-sales product is loss-making at scale.
--   No high-sales product has notably weak margin.


-- FINDING #3 — STRUCTURAL OBSERVATION

--   Same pattern as markets and regions:
--   Margins are suspiciously uniform across categories.

--     Markets:    10.12% – 11.14%  (1.02pp)
--     Regions:     9.64% – 13.51%  (3.87pp)
--     Categories:  9.90% – 17.46%  (7.56pp, excluding anomalies)

--   Real retail businesses do NOT show this level of uniformity.

-- ----------------------------------------------------------------
-- SECTION 4 — FORENSICS REVIEW (LAYER 2)
-- ================================================================

-- LAYER 2 AUDIT — Trust Assessment

-- Question: Are the categories real?

-- Evidence collected:

--   "Field & Stream Sportsman 16 Gun Fire Safe"
--       → classified as "Fishing"

--   "Perfect Fitness Perfect Rip Deck"
--       → classified as "Cleats"

--   "Diamondback Women's Serene Classic Comfort Bike"
--       → classified as "Camping & Hiking"

--   "Nike Men's Free 5.0+ Running Shoe"
--       → classified as "Cardio Equipment"

--   "Nike Men's Dri-FIT Victory Golf Polo"
--       → classified as "Women's Apparel"

--   "Titleist Pro V1x Golf Balls"
--       → classified as "Electronics"

--   "O'Brien Men's Neoprene Life Vest"
--       → classified as "Indoor/Outdoor Games"

-- Observations:

--   1. Product names do not match assigned categories.
--   2. Category sizes are suspiciously balanced ($3-7M each).
--   3. Category margins are unusually uniform (~10-11%).

-- Trust verdict:

--   ⚠️ CATEGORY-LEVEL ANALYSIS IS NOT TRUSTWORTHY.

--   The uniform margins observed are an artifact of random
--   grouping, not a real business pattern.

--   Categories should NOT appear in any downstream analysis
--   or report as a business dimension.

-- What CAN be said:

--   "The dataset assigns products to 50 categories, but the
--    assignment appears random. Category-level conclusions
--    about this dataset are invalid."

-- What CANNOT be said:

--   ❌ "Category X is the most profitable for DataCo"
--   ❌ "Category Y underperforms Category Z"
--   ❌ Anything framed as a business insight about categories

-- Root cause (hypothesis):

--   The DataCo dataset is a research dataset created for Big Data /
--   Machine Learning experiments. Category fields may have been
--   randomized during dataset construction, or sourced from a
--   system that did not maintain consistent category mappings.

--   This is consistent with the earlier discovery (Investigation 02)
--   that Oct 2017 onwards is synthetic data.

-- ----------------------------------------------------------------
-- SECTION 5 — WHAT WE DID NOT FIND
-- ----------------------------------------------------------------

--   - No high-sales / weak-profit category
--   - No meaningful loss-making category
--   - No category-level profitability problem
--   - No trustworthy category-level pattern of any kind

-- ----------------------------------------------------------------
-- SECTION 6 — DASHBOARD CANDIDATES
-- ----------------------------------------------------------------

-- INCLUDE

--   None for category-level analysis.
--   Category dimension is unusable.

-- CONDITIONAL

--   Product-level sales and profit — only if product data is later
--   verified as non-synthetic. Currently uncertain.

-- DO NOT INCLUDE

--   Item                          Reason
--   ----------------------------------------------------------
--   Category-level analysis       Categories are randomly assigned
--   "Category X is profitable"    Not trustworthy
--   Category margin comparisons   Artifact of random grouping

-- ----------------------------------------------------------------
-- SECTION 7 — OPEN THREADS
-- ----------------------------------------------------------------

--   1. Product-level forensics — are product names, prices, and
--      attributes internally consistent? Not tested yet.
--      Could be a follow-up.

--   2. Department-level analysis — department_name may also be
--      affected by the same shuffling. Not tested.

--   3. The category anomaly "Basketball -2.64%" — likely noise,
--      but if product-level forensics is done, we could confirm.

-- ----------------------------------------------------------------
-- SECTION 8 — FINAL VERDICT
-- ----------------------------------------------------------------

-- The dataset's category dimension is NOT reliable.

--   - Category-level margins are uniform (~10-11%), an artifact
--     of random grouping.
--   - Product names do not match assigned categories.
--   - Category-level business conclusions are INVALID.
--   - Investigation 04 cannot produce trustworthy category
--     insights.

--   What we CAN legitimately say:
--     "In this dataset, the category field does not reflect
--      real product groupings. Category analysis is not
--      meaningful."

--   This is a DATA FORENSICS finding, not a business finding.

-- ================================================================
-- INVESTIGATION 04 — STATUS: COMPLETE
-- (with forensics review)
-- ================================================================

-- NEXT -> Investigation 05: Customer Performance
-- ================================================================

-- ================================================================
-- DATACO FORENSICS FINDINGS
-- Consolidated Data Quality Investigation
-- DataCo Sherlock — PostgreSQL Investigation
-- ================================================================

-- ----------------------------------------------------------------
-- PURPOSE
-- ----------------------------------------------------------------

-- This document consolidates every data quality and trust issue
-- uncovered during the DataCo investigation (Investigations 01-04).

-- Each finding follows a standard structure:

--   CLAIM          — what we observed
--   EVIDENCE       — the SQL output / data that shows it
--   INTERPRETATION — what it means
--   LIMITATION     — what we cannot confirm

-- The goal is not to attack the dataset. The goal is to determine
-- what the dataset CAN and CANNOT support as evidence.

-- ----------------------------------------------------------------
-- F1 — THE DATASET IS A RESEARCH DATASET, NOT REAL BUSINESS DATA
-- ----------------------------------------------------------------

-- CLAIM:
--   The DataCo Supply Chain dataset is a research artifact, not
--   recorded transactions from a real company.

-- EVIDENCE:
--   - Kaggle source: "DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS"
--   - Author: Shashwat Tiwari, Instituto Politecnico de Leiria
--   - Purpose: Big Data / Machine Learning research
--   - Tagged: Data Visualization, EDA, Research

-- INTERPRETATION:
--   The "DataCo business" is a construct for research purposes.
--   Business findings derived from this dataset do not describe
--   a real company.

-- LIMITATION:
--   Some datasets are semi-synthetic — real patterns with
--   synthetic additions. We cannot rule out that portions of
--   this dataset reflect real supply chain structure.

-- ----------------------------------------------------------------
-- F2 — OCT 2017 ONWARD IS SYNTHETIC
-- ----------------------------------------------------------------

-- CLAIM:
--   The last four months of the dataset (Oct 2017 - Jan 2018) are
--   synthetic / placeholder data.

-- EVIDENCE:
--   - avg lines/order drops from ~3.0 to exactly 1.0
--   - daily order count alternates 68/69 for every day
--   - sales values repeat across days
--   - sales per order drops from ~$660 to ~$156

-- INTERPRETATION:
--   This is not a business collapse. It is a data generation
--   artifact — likely a synthetic fill at the end of the dataset.

-- LIMITATION:
--   We cannot determine why this fill exists. Could be intentional
--   (for a specific ML experiment) or accidental (from a data
--   pipeline test).

-- IMPACT:
--   All trend analysis must EXCLUDE Oct 2017 onwards.
--   Real analysis window: 2015-01-01 to 2017-09-30.

-- ----------------------------------------------------------------
-- F3 — MARKET LABELS ARE NOT STABLE ACROSS YEARS
-- ----------------------------------------------------------------

-- CLAIM:
--   The market field in fact_sales is not consistent year-to-year.
--   Entire market-years are missing.

-- EVIDENCE:
--   Market-year order counts:
--     Africa:       2015=0,     2016=3,445, 2017=409
--     Europe:       2015=8,315, 2016=1,274, 2017=6,189
--     LATAM:        2015=8,598, 2016=0,     2017=8,583
--     Pacific Asia: 2015=3,991, 2016=7,602, 2017=364
--     USCA:         2015=0,     2016=8,538, 2017=41

--   Annual totals still add up (no rows lost).

-- INTERPRETATION:
--   Market assignments were not maintained consistently across
--   years. Either the dataset was assembled from multiple sources
--   or market labels were randomly assigned.

-- LIMITATION:
--   Market-level analysis is only reliable at the whole-period
--   level. Growth-by-market cannot be analyzed.

-- ----------------------------------------------------------------
-- F4 — MARGINS ARE UNIFORMLY ~10-11% ACROSS EVERY DIMENSION
-- ----------------------------------------------------------------

-- CLAIM:
--   Every major dimension (market, region, category, product) shows
--   margins that are suspiciously uniform.

-- EVIDENCE:
--   Market margins:   10.12% – 11.14%  (1.02pp spread)
--   Region margins:    9.64% – 13.51%  (3.87pp spread)
--   Category margins:  9.90% – 17.46%  (7.56pp, excluding anomalies)
--   Product margins:   6.97% – 14.58%  (top 30 by sales)

-- INTERPRETATION:
--   Real retail businesses do NOT have uniform margins across
--   markets, regions, and categories. This uniformity suggests
--   the data was constructed/generated with a narrow margin band.

-- LIMITATION:
--   It is theoretically possible (but very unusual) for a real
--   business to operate with a uniform pricing/cost model. We
--   cannot rule it out completely.

-- ----------------------------------------------------------------
-- F5 — CATEGORIES ARE RANDOMLY ASSIGNED
-- ----------------------------------------------------------------

-- CLAIM:
--   Product categories in dim_product do not reflect real product
--   groupings. Category assignments appear shuffled.

-- EVIDENCE:
--   - "Field & Stream Sportsman 16 Gun Fire Safe" → "Fishing"
--   - "Perfect Fitness Perfect Rip Deck"          → "Cleats"
--   - "Nike Men's Free 5.0+ Running Shoe"         → "Cardio Equipment"
--   - "Titleist Pro V1x Golf Balls"               → "Electronics"
--   - "O'Brien Men's Neoprene Life Vest"          → "Indoor/Outdoor Games"
--   - Category sizes are suspiciously balanced ($3-7M each)

-- INTERPRETATION:
--   The category field is not reliable as a business dimension.
--   Category-level analysis is meaningless.

-- LIMITATION:
--   Some categories may still be internally consistent (e.g., all
--   Titleist Pro V1 products ended up in "Electronics"). So the
--   shuffling may be at the category-name level, not per-product.

-- IMPACT:
--   Category should NOT appear as a business dimension in any
--   downstream analysis or report.

-- ----------------------------------------------------------------
-- F6 — ORDER_PROFIT_PER_ORDER MAY BE ORDER-LEVEL, NOT LINE-LEVEL
-- ----------------------------------------------------------------

-- CLAIM:
--   order_profit_per_order may be an order-level measure repeated
--   on every line item, causing inflation when summed at line level.

-- EVIDENCE:
--   - order_profit_per_order = benefit_per_order (identical)
--   - Raw negative lines show impossible ratios (-1.5 to -2.55)
--   - Loss exceeds sale price (e.g., -$4,274.98 on $1,999.99 sale)
--   - 13,908 orders classified as loss-making under this assumption

-- INTERPRETATION:
--   If the field is order-level repeated on lines, then:
--     - Total profit at line level is INFLATED
--     - The "21% loss-making orders" finding may be overstated
--     - The "-$2.62M total loss" may be smaller than reported

-- LIMITATION:
--   We have not confirmed this hypothesis with a direct test.
--   The field could also be a line-level measure that happens to
--   be equal across lines in many orders.

-- STATUS:
--   OPEN — requires verification.
--   A simple deduplication test would confirm or deny this.

-- ----------------------------------------------------------------
-- F7 — THE $1,500 PRICE ANCHOR
-- ----------------------------------------------------------------

-- CLAIM:
--   $1,500 appears as a suspicious recurring price/value in the
--   dataset — both as an order value ceiling and as a product
--   price in the worst negative lines.

-- EVIDENCE:
--   - P99 order value = exactly $1,500.00
--   - Top negative lines cluster around $1,500 product price
--   - P95 order value = $1,199.94, P99 = exactly $1,500

-- INTERPRETATION:
--   $1,500 is likely a hard ceiling in the data or a very common
--   pricing point. It could be intentional (product line at that
--   price) or a data construction artifact.

-- LIMITATION:
--   We have not investigated whether $1,500 products have
--   consistent behavior or whether the price is synthetic.

-- STATUS:
--   OPEN — could be investigated in future work.

-- ----------------------------------------------------------------
-- SUMMARY TABLE
-- ----------------------------------------------------------------

--   ID  Finding                                        Status
--   ----------------------------------------------------------------
--   F1  Dataset is a research dataset, not real         Confirmed
--   F2  Oct 2017 onwards is synthetic                   Confirmed
--   F3  Market labels unstable across years             Confirmed
--   F4  Margins uniformly ~10-11% across dimensions     Confirmed
--   F5  Categories are randomly assigned                Confirmed
--   F6  order_profit_per_order may be order-level       Open
--   F7  $1,500 price anchor                             Open

-- ----------------------------------------------------------------
-- WHAT THIS MEANS FOR THE PROJECT
-- ----------------------------------------------------------------

-- The dataset cannot support real business insights.

-- It CAN support:
--   - Practicing the full analyst workflow
--   - Data quality assessment and forensics
--   - Methodological demonstration

-- It CANNOT support:
--   - "DataCo's business strategy" recommendations
--   - Real market/regional/category insights
--   - Real profitability analysis (given F6 uncertainty)

-- ----------------------------------------------------------------
-- RECOMMENDATIONS FOR FUTURE USERS OF THIS DATASET
-- ----------------------------------------------------------------

-- If you are using the DataCo dataset for analysis:

--   1. Exclude Oct 2017 - Jan 2018 (synthetic data).
--   2. Do NOT trust category assignments.
--   3. Do NOT do market growth analysis (unstable labels).
--   4. Verify whether order_profit_per_order is order-level or
--      line-level before using it.
--   5. Treat any "uniform pattern" finding with suspicion —
--      it may be a generation artifact.

-- If you are using the DataCo dataset for ML:

--   The dataset is still useful for:
--     - Training models on structured/tabular data
--     - Practicing EDA workflows
--     - Benchmarking algorithms

--   But do NOT treat learned patterns as reflecting real
--   business dynamics.

-- ================================================================
-- FORENSICS FINDINGS — END OF DOCUMENT
-- ================================================================

-- SELECT
--     dc.customer_segment,
--     COUNT(DISTINCT fs.order_id)                          AS orders,
--     COUNT(DISTINCT fs.customer_id)                       AS customers,
--     ROUND(SUM(fs.sales)::numeric, 2)                     AS total_sales,
--     ROUND(SUM(fs.order_profit_per_order)::numeric, 2)    AS total_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct,
--     ROUND(
--         (SUM(fs.sales) / NULLIF(COUNT(DISTINCT fs.customer_id), 0))::numeric,
--         2
--     )                                                    AS sales_per_customer
-- FROM analytics.fact_sales fs
-- JOIN analytics.dim_customer dc
--     ON fs.customer_id = dc.customer_id
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY dc.customer_segment
-- ORDER BY total_sales DESC;

-- INVESTIGATION 05 — Customer Performance
-- STATUS: Findings documented

-- FINDING #1 — SEGMENT LEVEL
--   Consumer:    29,789 orders  |  $17.77M sales  |  10.78% margin
--   Corporate:   17,304 orders  |  $10.39M sales  |  10.77% margin
--   Home Office: 10,256 orders  |  $ 6.10M sales  |  10.70% margin

--   Margin range: 10.70% – 10.78% (0.08pp spread)
--   Sales per customer range: $2,756 – $2,800 (1.6% spread)

-- FINDING #2 — UNIFORMITY PATTERN CONFIRMED (4th dimension)
--   Markets:     10.12% – 11.14%
--   Regions:      9.64% – 13.51%
--   Categories:   9.90% – 17.46%
--   Segments:    10.70% – 10.78%  ← tightest yet

-- FINDING #3 — NO SEGMENT-LEVEL PROBLEM
--   Every segment is profitable.
--   No segment is broken.
--   No segment is a "danger" segment.

-- LAYER 2 AUDIT — Trust Assessment

-- Question: Are the customer segments real?

-- Evidence:

--   1. Margins are identical across all three segments (0.08pp spread).
--   2. Sales per customer is nearly identical ($2,756 - $2,800).
--   3. This is the 4th dimension showing uniform margins.
--   4. Real customer segments would have different economics
--      (corporate ≠ consumer ≠ home office).
--   5. The DataCo dataset is a research dataset with known
--      synthetic components.

-- Interpretation:

--   ⚠️ CUSTOMER SEGMENT ANALYSIS IS NOT TRUSTWORTHY.

--   The "segment" field does not produce meaningfully different
--   business behavior. This is consistent with the dataset being
--   synthetic or partially randomized.

--   The uniform margins we observe are likely an artifact of the
--   dataset's construction (a fixed markup rule), not evidence
--   about real customer economics.

-- What CAN be said:

--   "In this dataset, three customer segments exist (Consumer,
--    Corporate, Home Office), but they show nearly identical
--    profitability and per-customer value."

-- What CANNOT be said:

--   ❌ "Consumer customers are more profitable than Corporate"
--   ❌ "DataCo should focus on the Corporate segment"
--   ❌ Any business recommendation about customer segments

-- Root cause (consistent with earlier forensics):

--   This is the 4th dimension (after markets, regions, categories)
--   showing suspiciously uniform margins. It reinforces the
--   hypothesis that the dataset uses a fixed margin rule.

-- STATUS: Findings hold descriptively.
--         Interpretations are limited by dataset construction.

-- SELECT
--     fs.shipping_mode,
--     COUNT(*)                                                        AS line_count,
--     ROUND(AVG(fs.late_delivery_risk)::numeric, 4)                   AS late_risk_pct,
--     ROUND(AVG(fs.days_for_shipping_real)::numeric, 2)               AS avg_real_days,
--     ROUND(AVG(fs.days_for_shipment_scheduled)::numeric, 2)          AS avg_scheduled_days,
--     ROUND(
--         AVG(fs.days_for_shipping_real - fs.days_for_shipment_scheduled)::numeric,
--         2
--     )                                                                AS avg_days_gap
-- FROM analytics.fact_sales fs
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY fs.shipping_mode
-- ORDER BY line_count DESC;

-- WITH order_shipping AS (
--     SELECT
--         order_id,
--         MAX(shipping_mode)         AS shipping_mode,
--         MAX(late_delivery_risk)    AS late_risk,
--         MAX(days_for_shipping_real) AS real_days,
--         MAX(days_for_shipment_scheduled) AS scheduled_days
--     FROM analytics.fact_sales
--     WHERE order_date_dateorders < '2017-10-01'
--     GROUP BY order_id
-- )
-- SELECT
--     shipping_mode,
--     COUNT(*)                                          AS orders,
--     ROUND(AVG(late_risk)::numeric, 4)                 AS late_risk_pct,
--     ROUND(AVG(real_days)::numeric, 2)                 AS avg_real_days,
--     ROUND(AVG(scheduled_days)::numeric, 2)            AS avg_scheduled_days,
--     ROUND(AVG(real_days - scheduled_days)::numeric, 2) AS avg_gap
-- FROM order_shipping
-- GROUP BY shipping_mode
-- ORDER BY orders DESC;

-- ================================================================
-- INVESTIGATION 06 — FINAL REPORT
-- Shipping Performance
-- DataCo Sherlock — PostgreSQL Investigation
-- ================================================================

-- ----------------------------------------------------------------
-- SECTION 1 — QUESTION
-- ----------------------------------------------------------------

-- What is the overall late-delivery rate?
-- Does late risk differ by shipping mode?
-- How do actual vs scheduled shipping times compare?
-- Are shipping problems associated with poor profitability?

-- ----------------------------------------------------------------
-- SECTION 2 — GRAIN & SOURCE
-- ----------------------------------------------------------------

-- Grain:   Order (deduplicated from line-level fact)
-- Source:  fact_sales
-- Period:  2015-01-01 to 2017-09-30 (real data only)

-- ----------------------------------------------------------------
-- SECTION 3 — FINDINGS (LAYER 1)
-- ----------------------------------------------------------------

-- FINDING #1 — SHIPPING MODE PERFORMANCE (order grain)

--   Shipping Mode    Orders   Late Risk %   Real  Scheduled  Gap
--   --------------------------------------------------------------
--   Standard Class   34,331      38.14%      4.00    4.00    0.00
--   Second Class     11,128      76.68%      4.00    2.00    2.00
--   First Class       8,786      95.25%      2.00    1.00    1.00
--   Same Day          3,104      45.65%      0.48    0.00    0.48

--   Late risk range: 38.14% – 95.25% (57pp spread)

-- FINDING #2 — SHIPPING IS THE FIRST NON-UNIFORM DIMENSION
--   Unlike markets, categories, and segments (all ~10.8% margin),
--   shipping shows REAL variance in late risk.

-- FINDING #3 — THE PATTERN IS BACKWARDS
--   Standard Class (cheapest):    38% late risk   ← LOWEST
--   First Class (most expensive): 95% late risk   ← HIGHEST
--   → Backwards from expected logistics behavior.

-- FINDING #4 — SHIPPING DAYS HAVE NO VARIANCE
--   Standard Class:  Real = Scheduled = 4.00 exactly, gap = 0.00
--   All modes have round numbers (4.00, 2.00, 1.00, 0.48)
--   → No within-mode variance.
--   → Impossible for real logistics.

-- ----------------------------------------------------------------
-- SECTION 4 — FORENSICS REVIEW (LAYER 2)
-- ================================================================

-- LAYER 2 AUDIT — Trust Assessment

-- Question: Is the shipping data real?

-- Evidence:

--   1. Standard Class: ZERO variance in shipping days (gap = 0.00
--      for all 34,331 orders). Real operations have variance.

--   2. First Class: HIGHER late risk (95%) than Standard Class (38%).
--      Backwards from expected logistics behavior.

--   3. Same Day shipping: averages 0.48 days (not same day).
--      Inconsistent with mode name.

--   4. All shipping day values are round numbers (4.00, 2.00, 1.00).
--      Real operational averages are not exact.

--   5. late_delivery_risk is constant within each order
--      (order-level field repeated on lines).

-- Interpretation:

--   ⚠️ SHIPPING DATA IS SYNTHETIC WITH NON-SENSICAL PARAMETERS.

--   The variance we observed (38-95% late risk) is real in the
--   data, but the pattern is artificial. It does not reflect
--   a plausible real logistics operation.

-- What CAN be said:

--   "In this dataset, shipping modes have different recorded
--    late-delivery rates (38-95%), but the underlying timing
--    patterns are implausible (zero variance, backwards
--    reliability)."

-- What CANNOT be said:

--   ❌ "First Class shipping is unreliable — fix it"
--   ❌ "Standard Class is the most reliable mode"
--   ❌ Any business recommendation about shipping modes

-- Root cause (consistent with earlier forensics):

--   This is the 5th finding of synthetic construction
--   (after Oct 2017, category shuffle, market instability,
--   uniform margins).

-- STATUS: Findings hold descriptively.
--         Interpretations are limited by dataset construction.

-- ----------------------------------------------------------------
-- SECTION 5 — WHAT WE DID NOT FIND
-- ----------------------------------------------------------------

--   - No real operational insight about shipping performance
--   - No mode-specific business problem that can be trusted
--   - No late-risk pattern that makes business sense

-- ----------------------------------------------------------------
-- SECTION 6 — DASHBOARD CANDIDATES
-- ----------------------------------------------------------------

-- INCLUDE

--   None — shipping dimension is synthetic.

-- DO NOT INCLUDE

--   Item                                Reason
--   ------------------------------------------------------------
--   Late risk by shipping mode          Artificial pattern
--   Real vs scheduled days              Round numbers, no variance
--   Any shipping recommendation         Not trustworthy

-- ----------------------------------------------------------------
-- SECTION 7 — OPEN THREADS
-- ----------------------------------------------------------------

--   1. late_delivery_risk confirmed as order-level field repeated
--      on lines. Add to forensics chapter (F6 family).

--   2. Shipping days appear constant within mode. Would be
--      confirmed by checking distinct values per mode.

-- ----------------------------------------------------------------
-- SECTION 8 — FINAL VERDICT
-- ----------------------------------------------------------------

-- Shipping performance shows real variance in the data, but the
-- pattern is synthetic:

--   - Standard Class: zero variance in days (impossible)
--   - First Class: 95% late risk (backwards from expectation)
--   - Same Day: 0.48 days average (not same-day)
--   - All day values are round numbers

--   No business insight about shipping can be legitimately derived
--   from this dataset.

-- ================================================================
-- INVESTIGATION 06 — STATUS: COMPLETE
-- (with forensics review)
-- ================================================================

-- NEXT -> Investigation 07: Discount & Profitability
-- ================================================================

-- SELECT
--     COUNT(*)                                                AS total_lines,
--     ROUND(AVG(order_item_discount_rate)::numeric, 4)        AS avg_discount_rate,
--     ROUND(MIN(order_item_discount_rate)::numeric, 4)        AS min_discount_rate,
--     ROUND(MAX(order_item_discount_rate)::numeric, 4)        AS max_discount_rate,
--     ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY order_item_discount_rate)::numeric, 4) AS p25,
--     ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY order_item_discount_rate)::numeric, 4) AS median,
--     ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY order_item_discount_rate)::numeric, 4) AS p75
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders < '2017-10-01';

-- SELECT
--     order_item_discount_rate,
--     COUNT(*) AS line_count
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders < '2017-10-01'
-- GROUP BY order_item_discount_rate
-- ORDER BY order_item_discount_rate;

-- SELECT
--     order_item_discount_rate,
--     COUNT(*)                                                    AS line_count,
--     ROUND(AVG(order_item_profit_ratio)::numeric, 4)             AS avg_profit_ratio,
--     ROUND(AVG(order_profit_per_order)::numeric, 2)              AS avg_line_profit
-- FROM analytics.fact_sales
-- WHERE order_date_dateorders < '2017-10-01'
-- GROUP BY order_item_discount_rate
-- ORDER BY order_item_discount_rate;

-- INVESTIGATION 07 — Discount & Profitability
-- STATUS: Findings documented

-- FINDING #1 — DISCOUNT DISTRIBUTION IS SYNTHETIC

--   18 distinct discount rates (0-7%, 9-10%, 12-13%, 15-18%,
--   20%, 25%), each with ~9,550 lines.

--   → Artificial equal distribution.

-- FINDING #2 — DISCOUNT HAS MECHANICAL EFFECT ON PROFIT

--   From 0% to 25% discount:
--     Avg profit ratio: 12.56% → 12.71% (no change)
--     Avg line profit:  $25.67 → $19.12 (−26%)

--   → Profit ratio is FLAT across discount rates.
--   → Profit dollars drop proportionally to discount.
--   → This is a mathematical artifact, not a business pattern.

-- FINDING #3 — NO REAL DISCOUNT BEHAVIOR

--   Real business would show:
--     - Profit ratio declining with discount
--     - Uneven distribution across discount rates
--     - Concentrations at strategic rates (10%, 15%, 20%)

--   This dataset shows:
--     - Flat profit ratio
--     - Perfectly even distribution
--     - Missing rates (8%, 11%, 14%, 19%, 21-24%)

--   → Synthetic construction.

-- LAYER 2 AUDIT — Trust Assessment

-- Question: Is the discount data real?

-- Evidence:

--   1. Every discount rate has ~9,550 lines (artificial equalization).
--   2. Only 18 distinct rates, with specific gaps.
--   3. Max discount is 25% (hard cap).
--   4. Profit ratio is FLAT across discount rates (12-13%).
--      Real discounting would show declining margin.

-- Interpretation:

--   ⚠️ DISCOUNT DATA IS SYNTHETIC.

--   The discount field was generated to appear varied, but:
--     - Distribution is mathematically uniform
--     - Profit ratio is unaffected by discount rate
--     - The profit drop is purely mechanical (sales × (1-discount))

--   No behavioral signal exists.

-- What CAN be said:

--   "In this dataset, discount rates are evenly distributed
--    across 18 values, and profit ratio does not vary with
--    discount."

-- What CANNOT be said:

--   ❌ "Discounts reduce profitability" (mechanical artifact)
--   ❌ "Product X is heavily discounted" (random distribution)
--   ❌ Any business recommendation about discounting

-- Root cause (consistent with earlier forensics):

--   This is the 7th finding of synthetic construction
--   (after Oct 2017, category shuffle, market instability,
--   uniform margins, shipping non-sense, order-level field
--   repetition).

-- STATUS: Findings hold descriptively.
--         Interpretations are limited by dataset construction.

-- SELECT
--     fs.market,
--     fs.shipping_mode,
--     COUNT(*)                                             AS line_count,
--     ROUND(AVG(fs.order_profit_per_order)::numeric, 2)    AS avg_line_profit,
--     ROUND(
--         (SUM(fs.order_profit_per_order) / NULLIF(SUM(fs.sales), 0) * 100)::numeric,
--         2
--     )                                                    AS profit_margin_pct
-- FROM analytics.fact_sales fs
-- WHERE fs.order_date_dateorders < '2017-10-01'
-- GROUP BY fs.market, fs.shipping_mode
-- ORDER BY avg_line_profit ASC
-- LIMIT 20;

-- INVESTIGATION 08 — Cross-Dimension Deep Dive
-- STATUS: Findings documented

-- FINDING #1 — MARKET × SHIPPING_MODE COMBINATIONS

--   Margin range: 8.68% – 12.71% (4.03pp spread)

--   Extreme values appear in SMALL combinations:
--     Africa + Same Day:       668 lines  →  8.68%
--     Africa + First Class:  1,727 lines  → 12.71%
--     Pacific Asia + 2nd:    7,035 lines  →  9.34%

--   Large combinations cluster near mean:
--     LATAM + Standard:     31,119 lines  → 10.70%
--     Europe + Standard:    27,982 lines  → 10.97%
--     Pacific Asia + Std:   21,247 lines  → 10.33%

-- FINDING #2 — THE VARIANCE IS SMALL-SAMPLE NOISE

--   → Extremes appear in small buckets.
--   → Large buckets converge to ~10.8% margin.
--   → No real cross-dimension pattern.
--   → Same uniform distribution as individual dimensions.

-- FINDING #3 — NO HIDDEN SIGNAL

--   We tested the most promising cross-dimension combination
--   (market × shipping_mode). It shows noise, not signal.
--   Other combinations would show the same.

--   → The dataset is uniformly synthetic at all dimensional levels.

-- LAYER 2 AUDIT — Trust Assessment

-- Question: Do any cross-dimension combinations reveal real patterns?

-- Evidence:

--   1. Margin range across market × shipping_mode: 8.68% – 12.71%
--      But extremes appear only in small line-count combinations.

--   2. Large combinations (>20,000 lines) converge to ~10.8%.

--   3. This is the signature of small-sample noise, not business
--      signal.

-- Interpretation:

--   ⚠️ NO CROSS-DIMENSION PATTERN EXISTS.

--   The dataset is uniformly synthetic across every dimension
--   and every combination. No real signal is hiding in the
--   intersections.

-- What CAN be said:

--   "In this dataset, all cross-dimension combinations show
--    margins clustering around ~10.8%, with deviations
--    explained by small-sample noise."

-- What CANNOT be said:

--   ❌ "Africa + Same Day is a loss-making combination"
--   ❌ Any cross-dimension business insight

-- Root cause (consistent with earlier forensics):

--   This confirms findings F2-F7 from the forensics chapter.
--   The dataset is synthetic at every level.

-- STATUS: Findings hold descriptively.
--         Interpretations are limited by dataset construction.