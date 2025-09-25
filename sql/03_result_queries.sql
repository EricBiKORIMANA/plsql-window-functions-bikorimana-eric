
-- Goal: 1. Identify top 5 products by sales amount per region and quarter
SELECT
    region,
    product_name,
    category,
    sales_quarter,
    total_sales,
    product_rank
FROM (
    SELECT
        c.region,
        p.name AS product_name,
        p.category,
        TO_CHAR(t.sale_date, 'YYYY-Q') AS sales_quarter,
        SUM(t.amount) AS total_sales,
        RANK() OVER (
            PARTITION BY c.region, TO_CHAR(t.sale_date, 'YYYY-Q') 
            ORDER BY SUM(t.amount) DESC
        ) AS product_rank
    FROM transactions t
        JOIN customers c ON t.customer_id = c.customer_id
        JOIN products p ON t.product_id = p.product_id
    GROUP BY c.region, p.name, p.category, TO_CHAR(t.sale_date, 'YYYY-Q')
) AS ranked_products
-- <-- Added alias here
WHERE product_rank <= 5
ORDER BY region, sales_quarter, product_rank;


-- Goal: 2. Calculate cumulative running total of sales by month
SELECT
    sales_month,
    monthly_sales,
    SUM(monthly_sales) OVER (
        ORDER BY sales_month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM (
    SELECT
        TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
        SUM(amount) AS monthly_sales
    FROM transactions
    GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
) AS monthly_data -- <-- Added alias here
ORDER BY sales_month;


-- Goal: 3. Calculate percentage growth from previous month
WITH
    monthly_sales
    AS
    (
        SELECT
            TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
            SUM(amount) AS current_month_sales
        FROM transactions
        GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
    )
SELECT
    sales_month,
    current_month_sales,
    LAG(current_month_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
    ROUND(
        ((current_month_sales - LAG(current_month_sales) OVER (ORDER BY sales_month)) 
         / LAG(current_month_sales) OVER (ORDER BY sales_month)) * 100, 2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY sales_month;

-- Goal: 4 Segment customers into 4 spending quartiles
SELECT
    customer_id,
    name,
    region,
    total_spending,
    NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_spending DESC) = 1 THEN 'Top 25% - High Value'
        WHEN NTILE(4) OVER (ORDER BY total_spending DESC) = 2 THEN '25-50% - Medium High'
        WHEN NTILE(4) OVER (ORDER BY total_spending DESC) = 3 THEN '50-75% - Medium Low'
        ELSE 'Bottom 25% - Low Value'
    END AS quartile_segment
FROM (
    SELECT
        c.customer_id,
        c.name,
        c.region,
        SUM(t.amount) AS total_spending
    FROM customers c
        JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.region
) AS segmented_customers -- <-- Added alias here
ORDER BY spending_quartile, total_spending DESC;


-- Goal: 5 Calculate 3-month moving average of sales
SELECT
    sales_month,
    monthly_sales,
    ROUND(AVG(monthly_sales) OVER (
        ORDER BY sales_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3month
FROM (
    SELECT
        TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
        SUM(amount) AS monthly_sales
    FROM transactions
    GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
) AS monthly_data -- <-- Added alias here
ORDER BY sales_month;











-- ________________________________________________________________________________________














-- =============================================================================
-- WINDOW FUNCTIONS DEMONSTRATION
-- E-commerce Sales Analysis
-- =============================================================================

-- 1. RANKING FUNCTIONS
-- Top 3 products by sales amount per region
SELECT
    region,
    product_name,
    category,
    total_sales,
    row_num,
    rank,
    dense_rank,
    percent_rank
FROM (
    SELECT
        c.region,
        p.name AS product_name,
        p.category,
        SUM(t.amount) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS row_num,
        RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS rank,
        DENSE_RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS dense_rank,
        PERCENT_RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS percent_rank
    FROM transactions t
        JOIN customers c ON t.customer_id = c.customer_id
        JOIN products p ON t.product_id = p.product_id
    GROUP BY c.region, p.name, p.category
) ranked_products
WHERE row_num <= 3
ORDER BY region, total_sales DESC;


-- Interpretation: Identifies top-performing products in each region for inventory optimization
--------------------------------------------------------------------------------

-- 2. AGGREGATE FUNCTIONS WITH FRAMING
-- Running total of monthly sales with ROWS vs RANGE comparison
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
    SUM(amount) AS monthly_sales,
    -- Running total using ROWS (physical rows)
    SUM(SUM(amount)) OVER (
        ORDER BY TO_CHAR(sale_date, 'YYYY-MM') 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_rows,
    -- Running total using RANGE (logical range)
    SUM(SUM(amount)) OVER (
        ORDER BY TO_CHAR(sale_date, 'YYYY-MM') 
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_range,
    -- 3-month moving average
    AVG(SUM(amount)) OVER (
        ORDER BY TO_CHAR(sale_date, 'YYYY-MM')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3month
FROM transactions
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY sales_month;

-- Interpretation: Shows sales trends and helps in forecasting future demand
--------------------------------------------------------------------------------

-- 3. NAVIGATION FUNCTIONS
-- Month-over-month growth analysis
WITH
    monthly_sales
    AS
    (
        SELECT
            TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
            SUM(amount) AS total_sales,
            COUNT(*) AS transaction_count
        FROM transactions
        GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
    )
SELECT
    sales_month,
    total_sales,
    transaction_count,
    LAG(total_sales) OVER (ORDER BY sales_month) AS prev_month_sales,
    LAG(transaction_count) OVER (ORDER BY sales_month) AS prev_month_transactions,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY sales_month)) / 
        LAG(total_sales) OVER (ORDER BY sales_month) * 100, 2
    ) AS sales_growth_pct,
    LEAD(total_sales) OVER (ORDER BY sales_month) AS next_month_sales
FROM monthly_sales
ORDER BY sales_month;

-- Interpretation: Identifies growth patterns and seasonal trends for marketing planning
--------------------------------------------------------------------------------

-- 4. DISTRIBUTION FUNCTIONS
-- Customer segmentation by spending behavior
WITH
    customer_spending
    AS
    (
        SELECT
            c.customer_id,
            c.name,
            c.region,
            SUM(t.amount) AS total_spent,
            COUNT(t.transaction_id) AS transaction_count
        FROM customers c
            JOIN transactions t ON c.customer_id = t.customer_id
        GROUP BY c.customer_id, c.name, c.region
    )
SELECT
    customer_id,
    name,
    region,
    total_spent,
    transaction_count,
    -- Segment customers into 4 quartiles by spending
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile,
    -- Cumulative distribution of spending
    ROUND(CUME_DIST() OVER (ORDER BY total_spent) * 100, 2) AS cume_dist_percent,
    -- Percent rank within region
    ROUND(PERCENT_RANK() OVER (PARTITION BY region ORDER BY total_spent) * 100, 2) AS percent_rank_in_region
FROM customer_spending
ORDER BY total_spent DESC;

-- Interpretation: Enables targeted marketing campaigns based on customer value segments
