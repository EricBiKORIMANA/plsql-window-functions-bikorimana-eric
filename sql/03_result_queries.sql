-- =============================================================================
-- WINDOW FUNCTIONS DEMONSTRATION
-- =============================================================================


-- =============================================================================
-- 1. RANKING FUNCTIONS - Top N Customers by Revenue
-- =============================================================================

SELECT 
    c.name,
    c.region,
    SUM(t.amount) AS total_revenue,

    -- ROW_NUMBER: Assigns a unique sequential number to each customer based on descending revenue
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) AS row_num,

    -- RANK: Assigns the same rank to customers with equal revenue; skips ranks after ties
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS rank_pos,

    -- DENSE_RANK: Assigns the same rank to ties but does not skip subsequent ranks
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS dense_rank_pos,

    -- PERCENT_RANK: Calculates relative rank as a percentage between 0 and 1
    PERCENT_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS percent_rank

FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name, c.region
ORDER BY total_revenue DESC;

-- Interpretation: This query ranks customers by total revenue using multiple functions that handle ties and relative
-- positioning. It helps identify top spenders and segment customers based on their contribution to overall sales.


-- =============================================================================
-- 2. AGGREGATE FUNCTIONS WITH WINDOW FRAMES
-- =============================================================================

SELECT 
    t.sale_date,
    c.name AS customer_name,
    t.amount,

    -- Running total using ROWS: sums all previous rows including current
    SUM(t.amount) OVER (ORDER BY t.sale_date ROWS UNBOUNDED PRECEDING) AS running_total_rows,

    -- Running total using RANGE: sums all rows with sale_date less than or equal to current (handles ties)
    SUM(t.amount) OVER (ORDER BY t.sale_date RANGE UNBOUNDED PRECEDING) AS running_total_range,

    -- Moving average of last 3 transactions (current + 2 previous)
    AVG(t.amount) OVER (ORDER BY t.sale_date ROWS 2 PRECEDING) AS moving_avg_3,

    -- Minimum transaction value up to current row
    MIN(t.amount) OVER (ORDER BY t.sale_date ROWS UNBOUNDED PRECEDING) AS running_min,

    -- Maximum transaction value up to current row
    MAX(t.amount) OVER (ORDER BY t.sale_date ROWS UNBOUNDED PRECEDING) AS running_max

FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
ORDER BY t.sale_date;


-- Interpretation: This query tracks cumulative and rolling metrics over time using different window frames. It helps monitor sales growth, detect anomalies, 
-- and smooth fluctuations for trend analysis and forecasting.



-- =============================================================================
-- 3. NAVIGATION FUNCTIONS
-- =============================================================================

-- LAG() and LEAD() for period-to-period analysis
SELECT 
    t.sale_date,
    t.customer_id,
    c.name,
    t.amount,
    -- Previous transaction amount (LAG)
    LAG(t.amount, 1) OVER (
        PARTITION BY t.customer_id 
        ORDER BY t.sale_date
    ) AS previous_amount,
    -- Next transaction amount (LEAD)
    LEAD(t.amount, 1) OVER (
        PARTITION BY t.customer_id 
        ORDER BY t.sale_date
    ) AS next_amount,
    -- Growth calculation using LAG
    ROUND(
        ((t.amount - LAG(t.amount, 1) OVER (
            PARTITION BY t.customer_id 
            ORDER BY t.sale_date
        )) / NULLIF(LAG(t.amount, 1) OVER (
            PARTITION BY t.customer_id 
            ORDER BY t.sale_date
        ), 0)) * 100, 2
    ) AS growth_percent
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
ORDER BY t.customer_id, t.sale_date;

-- Interpretation: LAG() and LEAD() access previous and next row values within partitions, enabling period-to-period comparisons.
-- Growth percentage calculations become straightforward by comparing current values with previous ones using LAG().




-- =============================================================================
-- 4. DISTRIBUTION FUNCTIONS
-- =============================================================================

WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.name,
        c.region,
        SUM(t.amount) as total_revenue,
        COUNT(t.transaction_id) as transaction_count,
        ROUND(AVG(t.amount), 2) as avg_transaction_value
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.region
)
SELECT 
    name,
    region,
    total_revenue,
    transaction_count,
    avg_transaction_value,
    -- Quartile segmentation (1=bottom 25%, 4=top 25%)
    NTILE(4) OVER (ORDER BY total_revenue) as revenue_quartile,
    -- Cumulative distribution (percentile rank)
    ROUND(CUME_DIST() OVER (ORDER BY total_revenue) * 100, 1) as revenue_percentile,
    -- Customer segments based on quartiles
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_revenue) = 4 THEN 'Premium'
        WHEN NTILE(4) OVER (ORDER BY total_revenue) = 3 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY total_revenue) = 2 THEN 'Silver'
        ELSE 'Bronze'
    END as customer_segment
FROM customer_revenue
ORDER BY total_revenue DESC;

-- Interpretation: This query segments customers into quartiles and percentiles based on total revenue. It assigns intuitive 
-- labels like Premium, Gold, Silver, and Bronze to support targeted marketing and loyalty strategies.
