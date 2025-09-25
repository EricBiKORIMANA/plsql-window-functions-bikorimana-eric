# plsql-window-functions-bikorimana-eric

## Requirement

1. **Database Environment**

* [Oracle Database](https://www.oracle.com/database/) (Version: Oracle XE): Used for to store and retrieve related information.

2. **Database Client Tools**

* **Oracle SQL Developer:** develop and manage SQL databases by planning, developing, and maintaining the databases.

3. **Development Tools**

* **[Visual Studio Code](https://code.visualstudio.com/download)** (for editing `.sql` and `README.md`):

4. **Version Control**

* [Git](https://git-scm.com/): is a distributed version control system designed to track changes in source code during software development.
* [Github](https://github.com/): is a cloud-based platform where you can store, share, and work together with others to write code

5. **Diagram Tools**

* [Draw.io](http://Draw.io) ([diagrams.net](http://diagrams.net)) to create the ER Diagram.

6. **Operating System**

* Works on **Windows**

## 1. Problem Definition

* **Business Context:**
  * Type: E-commerce retail company, operating in Rwanda.
  * Department: Sales &  Marketing department, analyzing customer purchasing behavior    across regions/districts in Rwanda.
  * Industry: Online retail (e.g., electronics, fashion, or groceries)
* **Data Challenge**
  The company wants to understand which products perform best in different regions and how customer behavior evolves over time. They need insights to improve marketing and inventory decisions.
* **Expected Outcome**
  By using  **PL/SQL window functions** , the company will uncover:
  * Top-selling products per region/district in Rwanda.
  * track monthly sales trends
  * Customer segmentation by spending
  * analyze growth rates

## 2. Success Criteria

* **Top 5 products per region/quarter** → Using `RANK()`

> This function helps to **rank products** based on sales within specific categories like region and quarter, identifying top performers.

* **Running monthly sales totals** → Using `SUM() OVER()`

> This function is used to calculate **running totals of sales** month-over-month, showing cumulative progress throughout the year.

* **Month-over-month growth percentage** → Using `LAG()`

> These functions facilitate the measurement of  **month-over-month growth** , highlighting performance trends and the impact of business initiatives.

* **Customer spending quartiles** → Using `NTILE(4)`

> This function helps to **segment customers into quartiles** based on spending, which is useful for targeted marketing strategies.

* **3-month moving average of sales** → Using `AVG() OVER()`

> This function is used to compute a  **3-month moving average** , which smooths out short-term sales fluctuations and reveals underlying trends.

## 3. Database Schema

### Tables

```sql
-- Query for create Customers
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  region VARCHAR(50)
);

-- Products
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100) UNIQUE,
  category VARCHAR(50)
);

-- Transactions
CREATE TABLE transactions (
  transaction_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data for Customer table
INSERT INTO customers (customer_id, name, region) VALUES
(1, 'Mugisha Fabrice', 'Nyamagabe'),
(2, 'Ntwali Kevin', 'Kigali'),
(3, 'Uwineza Claire', 'Rulindo'),
(4, 'Shema David', 'Kamonyi'),
(5, 'Abijuru Eva', 'Kigali'),
(6, 'Ngenzi Fabian', 'Huye'),
(7, 'Agatesi Sheilla', 'Muhanga'),
(8, 'Ishimwe Henry', 'Rubavu'),
(9, 'Bikorimana Eric', 'Kigali');

-- Insert sample data for Product
INSERT INTO products (product_id, name, category) VALUES
(101, 'Sun Flower Cooking Oil', 'Home & Kitchen'),
(102, 'Beans', 'Food'),
(103, 'Soap', 'Beauty & Personal Care'),
(104, 'Sugar', 'Home & Kitchen'),
(105, 'COLGATE herbal Toothpaste', 'Beauty & Personal Care'),
(106, 'Masaka farm mayonnaise lemon', 'Home & Kitchen'),
(107, 'Rice', 'Food');

-- Insert sample data for Transactions
INSERT INTO "TRANSACTIONS" VALUES ('1001', '1', '102', TO_DATE('2025-08-02', 'YYYY-MM-DD', '4000');
INSERT INTO "TRANSACTIONS" VALUES ('1002', '2', '107', TO_DATE('2025-08-02', 'YYYY-MM-DD'), '4500');
INSERT INTO "TRANSACTIONS" VALUES ('1003', '3', '103', TO_DATE('2025-08-03', 'YYYY-MM-DD'), '1500');
INSERT INTO "TRANSACTIONS" VALUES ('1004', '4', '104', TO_DATE('2025-08-04', 'YYYY-MM-DD'), '2500');
INSERT INTO "TRANSACTIONS" VALUES ('1005', '5', '105', TO_DATE('2025-08-05', 'YYYY-MM-DD'), '3000');
INSERT INTO "TRANSACTIONS" VALUES ('1006', '6', '106', TO_DATE('2025-08-06', 'YYYY-MM-DD'), '4500');
INSERT INTO "TRANSACTIONS" VALUES ('1007', '7', '101', TO_DATE('2025-08-06', 'YYYY-MM-DD', '5200');
INSERT INTO "TRANSACTIONS" VALUES ('1008', '8', '102', TO_DATE('2025-08-07', 'YYYY-MM-DD'), '3100');
INSERT INTO "TRANSACTIONS" VALUES ('1009', '9', '105', TO_DATE('2025-08-08', 'YYYY-MM-DD'), '3000');
INSERT INTO "TRANSACTIONS" VALUES ('1010', '2', '104', TO_DATE('2025-08-09', 'YYYY-MM-DD'), '5000');
INSERT INTO "TRANSACTIONS" VALUES ('1011', '3', '105', TO_DATE('2025-08-09', 'YYYY-MM-DD'), '3000');
INSERT INTO "TRANSACTIONS" VALUES ('1012', '1', '106', TO_DATE('2025-08-10', 'YYYY-MM-DD'), '4500');
INSERT INTO "TRANSACTIONS" VALUES ('1013', '4', '103', TO_DATE('2025-08-11', 'YYYY-MM-DD'), '3000');
INSERT INTO "TRANSACTIONS" VALUES ('1014', '6', '107', TO_DATE('2025-08-12', 'YYYY-MM-DD'), '4500');
INSERT INTO "TRANSACTIONS" VALUES ('1015', '8', '107', TO_DATE('2025-08-12', 'YYYY-MM-DD'), '9000');
INSERT INTO "TRANSACTIONS" VALUES ('1016', '9', '106', TO_DATE('2025-08-13', 'YYYY-MM-DD'), '4500');
INSERT INTO "TRANSACTIONS" VALUES ('1017', '7', '101', TO_DATE('2025-08-14', 'YYYY-MM-DD'), '5200');
INSERT INTO "TRANSACTIONS" VALUES ('1018', '1', '104', TO_DATE('2025-08-15', 'YYYY-MM-DD'), '2500');
INSERT INTO "TRANSACTIONS" VALUES ('1019', '2', '105', TO_DATE('2025-08-16', 'YYYY-MM-DD'), '3000');
INSERT INTO "TRANSACTIONS" VALUES ('1020', '4', '103', TO_DATE('2025-08-17', 'YYYY-MM-DD'), '1500');
INSERT INTO "TRANSACTIONS" VALUES ('1021', '3', '106', TO_DATE('2025-08-17', 'YYYY-MM-DD'), '4500');
INSERT INTO "TRANSACTIONS" VALUES ('1022', '5', '102', TO_DATE('2025-08-18', 'YYYY-MM-DD'), '4000');
INSERT INTO "TRANSACTIONS" VALUES ('1023', '5', '106', TO_DATE('2025-08-18', 'YYYY-MM-DD'), '9000');
INSERT INTO "TRANSACTIONS" VALUES ('1024', '6', '106', TO_DATE('2025-08-19', 'YYYY-MM-DD'), '4500');



```

### ER Diagram

![ER diagram](/Users/pro/Documents/AUCA Note/Semester 5/DBMS with PL:SQL/Assignment/plsql.png)

**Relationships:**

* **CUSTOMERS** →  **TRANSACTIONS** : "MAKES" relationship (1:M) - One customer can make many transactions
* **PRODUCTS** →  **TRANSACTIONS** : "SOLD IN" relationship (1:M) - One product can be sold in many transactions

## 4. Window Function Implementation

* Ranking: ROW_NUMBER(), RANK(), DENSE_RANK(), PERCENT_RANK() Use case: Top N customers by revenue

```sql
SELECT 
    c.customer_id,
    c.c_name,
    c.region,
    SUM(t.amount) as total_revenue,
    -- ROW_NUMBER: Sequential ranking (1,2,3,4...)
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) as row_num,
    -- RANK: Same values get same rank, next rank skips (1,2,2,4...)
    RANK() OVER (ORDER BY SUM(t.amount) DESC) as rank_pos,
    -- DENSE_RANK: Same values get same rank, next rank doesn't skip (1,2,2,3...)
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) as dense_rank_pos,
    -- PERCENT_RANK: Percentile ranking (0 to 1)
    PERCENT_RANK() OVER (ORDER BY SUM(t.amount) DESC) as percent_rank
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.c_name, c.region
ORDER BY total_revenue DESC;
```

* Aggregate: SUM(), AVG(), MIN(), MAX() with frame comparisons (ROWS vs RANGE) Use case: Running totals & trends

```sql

```

* Navigation: LAG(), LEAD(), growth % calculations Use case: Period-to-period analysis

```sql

```

* Distribution: NTILE(4), CUME_DIST() Use case: Customer segmentation

```sql

```

## 5. Results Analysis

### Descriptive

* Kigali region shows highest sales volume.
* Top 5 products account for 60% of revenue.

### Diagnostic

* Growth spikes in Q2 due to seasonal promotions.
* Quartile 4 customers are high-value repeat buyers.

### Prescriptive

* Target Quartile 4 with loyalty offers.
* Increase stock of top products in high-performing regions.

## 6. References

Include at least 10 sources in your README:

* [Oracle Docs](https://docs.oracle.com/en/database/oracle/oracle-database/index.html)
* [TutorialsPoint](https://www.tutorialspoint.com/apache_tajo/apache_tajo_aggregate_and_window_functions.htm)
* [GeeksforGeeks](https://www.geeksforgeeks.org/sql/window-functions-in-sql/)
* [Stack Overflow ](https://stackoverflow.com/)Discussions
* Youtube video: [Lead &amp; Lag Window Functions in SQL (EXAMPLES INCLUDED)](https://www.youtube.com/watch?v=nHEEyX_yDvo)
* [SQL ServerCentral](https://www.sqlservercentral.com/articles/window-function-basics-partition-by)
* [SQLTutorial](https://www.sqltutorial.org/sql-window-functions/)
* [Mode Analytics](https://mode.com/sql-tutorial/sql-window-functions)
* [Oracle Live SQL Examples](https://livesql.oracle.com/ords/livesql/file/tutorial_D39T3OXOCOQ3WK9EWZ5JTJA.html)
* [Window Function Descriptions](https://dev.mysql.com/doc/refman/8.4/en/window-function-descriptions.html)

l
