# plsql-window-functions-bikorimana-eric

## Table of Contents

- [Requirement](#13)
- [Problem Definition](#37)
- [Success Criteria](#55)
- [Database Schema Design](#77)
- [Window Function Implementation](#196)
- [Results Analysis](#218)
- [References](#235)

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


## 1. Problem Definition

* **Business Context:**
  A mid-sized **retail company** operates across several regions in Rwanda. 
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

1. **Create user called plsql by using cmd**
   
![Use sqlplus in cmd](screenshots/03_Login_cmd.PNG)

![Create user in cmd](screenshots/04_create_user_plsql.PNG)

![Grant permission to nplsql user in cmd](screenshots/05_grant_permission_plsql_user.PNG)

2. **Create a connection in SQL Developer**

![Create a connection in SQL Developer](screenshots/06_create_connection_in_sqldeveloper.PNG)

### Tables

See all tables created queries [here](sql/01_sql_schema.sql)

![Tables created in Oracle SQL Developer](screenshots/01_Table_created.png)

> Tables created 



![Customers](screenshots/19_Transactions_table_has_relationship_to_customers_table.PNG)

> Customer-Transaction Relationship

![Products](screenshots/20_Transactions_table_has_relationship_to_product_table.PNG)

> Product-Transaction Relationship

![Transactions has foreign keys from customers and products tables](screenshots/02_tables_relationship..png)

> Customers-Transactions-Products Relationship





### ER Diagram

![ER diagram](screenshots/ER_Diagram.png)

**Relationships:**

* **CUSTOMERS** →  **TRANSACTIONS** : "MAKES" relationship (1:M) - One customer can make many transactions
* **PRODUCTS** →  **TRANSACTIONS** : "SOLD IN" relationship (1:M) - One product can be sold in many transactions

## 4. Window Function Implementation

* Ranking: ROW_NUMBER(), RANK(), DENSE_RANK(), PERCENT_RANK() Use case: Top N customers by revenue
>Interpretation: This query ranks customers by total revenue using multiple functions that handle ties and relative
>positioning. It helps identify top spenders and segment customers based on their contribution to overall sales.
> See the result [here](sql/03_result_queries.sql)

* Aggregate: SUM(), AVG(), MIN(), MAX() with frame comparisons (ROWS vs RANGE) Use case: Running totals & trends
>Interpretation: This query tracks cumulative and rolling metrics over time using different window frames. It helps
>monitor sales growth, detect anomalies, and smooth fluctuations for trend analysis and forecasting.
> See the result [here](sql/03_result_queries.sql)

* Navigation: LAG(), LEAD(), growth % calculations Use case: Period-to-period analysis
>Interpretation: LAG() and LEAD() access previous and next row values within partitions, enabling period-to-period comparisons.
>Growth percentage calculations become straightforward by comparing current values with previous ones using LAG().        
> See the result [here](sql/03_result_queries.sql)

* Distribution: NTILE(4), CUME_DIST() Use case: Customer segmentation
> Interpretation: This query segments customers into quartiles and percentiles based on total revenue. It assigns intuitive 
>labels like Premium, Gold, Silver, and Bronze to support targeted marketing and loyalty strategies.
> See the result [here](sql/03_result_queries.sql)

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


* [Isokko App](https://app.isokko.com/) for Product categorization reference.
* [Oracle Docs](https://docs.oracle.com/en/database/oracle/oracle-database/index.html) : Analytic Functions. Oracle Help Center.
* [TutorialsPoint](https://www.tutorialspoint.com/apache_tajo/apache_tajo_aggregate_and_window_functions.htm) (2025). *Aggregate & Window Functions*.
* [GeeksforGeeks](https://www.geeksforgeeks.org/sql/window-functions-in-sql/) (2025). *SQL Window Functions*.
* [Window Function Concepts and Syntax](https://docs.oracle.com/cd/E17952_01/mysql-8.0-en/window-functions-usage.html)
* Youtube video: [Lead &amp; Lag Window Functions in SQL (EXAMPLES INCLUDED)](https://www.youtube.com/watch?v=nHEEyX_yDvo)
* [SQL ServerCentral](https://www.sqlservercentral.com/articles/window-function-basics-partition-by) (2025). *Window function basics PARTITION BY*.
* [SQLTutorial](https://www.sqltutorial.org/sql-window-functions/) (2025). *SQL Window Functions*.
* [Mode Analytics](https://mode.com/sql-tutorial/sql-window-functions) (2025). *SQL Window Functions*.
* [TechOnTheNet](https://www.techonthenet.com/oracle/index.php) (2025). *Oracle/PLSQL Analytical Functions*.
* [Window Function Descriptions](https://dev.mysql.com/doc/refman/8.4/en/window-function-descriptions.html)
* Academic paper:
Prof. Dr,-Ing . Stefan deßloch. (2014). Recent Develepments for Data Models. - [Chapter 6 - Windows and Query Functions in SQL](http://wwwlgis.informatik.uni-kl.de/cms/fileadmin/courses/SS2014/Neuere_Entwicklungen/Chapter_6_-_Windows_and_Query_Functions_in_SQL.pdf)



