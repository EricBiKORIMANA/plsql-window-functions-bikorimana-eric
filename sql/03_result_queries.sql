-- =============================================================================
-- WINDOW FUNCTIONS DEMONSTRATION
-- Success Criteria
-- =============================================================================

-- 1. Top 5 products per region/quarter → RANK()
-- Goal: To show top-selling 5 products in each region.
SELECT region,
       product_id,
       name AS product_name,
       total_sales,
       RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS product_rank
FROM (
  SELECT c.region,
         p.product_id,
         p.name,
         SUM(t.amount) AS total_sales
  FROM transactions t
  JOIN customers c ON t.customer_id = c.customer_id
  JOIN products p ON t.product_id = p.product_id
  GROUP BY c.region, p.product_id, p.name
);


-- 2. Running monthly sales totals → SUM() OVER()
-- Goal: To tracks cumulative sales growth month by month.

SELECT TO_CHAR(t.sale_date, 'YYYY-MM') AS month,
       c.region,
       t.amount,
       SUM(t.amount) OVER (PARTITION BY c.region ORDER BY TO_CHAR(t.sale_date, 'YYYY-MM')) AS running_total
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id;



-- 3. Month-over-month growth → LAG()/LEAD()
-- Goal: Measures month-to-month performance changes.

SELECT TO_CHAR(t.sale_date, 'YYYY-MM') AS month,
       c.region,
       SUM(t.amount) AS monthly_sales,
       LAG(SUM(t.amount)) OVER (PARTITION BY c.region ORDER BY TO_CHAR(t.sale_date, 'YYYY-MM')) AS previous_month_sales,
       SUM(t.amount) - LAG(SUM(t.amount)) OVER (PARTITION BY c.region ORDER BY TO_CHAR(t.sale_date, 'YYYY-MM')) AS growth
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY TO_CHAR(t.sale_date, 'YYYY-MM'), c.region;


-- 4. Customer quartiles → NTILE(4)
-- Goal: Segments customers into four spending tiers.

SELECT customer_id,
       name,
       region,
       total_spent,
       NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM (
  SELECT c.customer_id,
         c.name,
         c.region,
         SUM(t.amount) AS total_spent
  FROM transactions t
  JOIN customers c ON t.customer_id = c.customer_id
  GROUP BY c.customer_id, c.name, c.region
);



-- 5. 3-month moving averages → AVG() OVER()
-- Goal: 5. Compute 3-month moving average of monthly sales per region

SELECT TO_CHAR(t.sale_date, 'YYYY-MM') AS month,
       c.region,
       SUM(t.amount) AS monthly_sales,
       AVG(SUM(t.amount)) OVER (
         PARTITION BY c.region
         ORDER BY TO_CHAR(t.sale_date, 'YYYY-MM')
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_avg
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY TO_CHAR(t.sale_date, 'YYYY-MM'), c.region;

